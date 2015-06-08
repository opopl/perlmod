
package OP::PAPERS::PSH;

#---------------------------------
# main()
#---------------------------------
# intro               {{{

# use ... {{{

use strict;
use warnings;

use Env qw( $hm );

use OP::Base qw( 
	readhash 
	readarr
);

use base qw( 
	OP::Script 
	Class::Accessor::Complex 
	TexPaperManager::TexPaper
	TexPaperManager::TexPart
	TexPaperManager::Complete
	TexPaperManager::Term
	TexPaperManager::List
);


use OP::BIBTEX;
use Text::Generate::TeX;
use OP::TEX::NICE;
use OP::PROJSHELL;
use OP::TEX::Driver;
use IPC::Cmd qw( run );

use Term::ShellUI;
use Data::Dumper;
use File::Copy;
use File::Basename;
use IO::File;
use Directory::Iterator;
use Text::Table;

use Text::TabularDisplay;

#use LaTeX::BibTeX;
use LaTeX::Table;

use File::Spec::Functions qw(catfile rel2abs curdir );
use File::Slurp qw(
  edit_file
  edit_file_lines
  read_file
  write_file
  append_file
  prepend_file
);

use File::Path qw(make_path remove_tree);
use IPC::Cmd qw(can_run run run_forked);

=head1 NAME 

OP::PAPERS::PSH - Perl package implementing shell functionality for dealing
with papers and other stuff in the C<$TexPapersRoot> directory

=head1 INHERITANCE

L<Class::Accessor::Complex>, L<OP::Script>

=head1 DEPENDENCIES

=cut

# }}}
# accessors {{{

###__ACCESSORS_SCALAR
our @scalar_accessors = qw(
  LATEXMK
  LOGFILE
  LOGFILE_PRINTED_TERMCMD
  LOGFILENAME
  bibdefsfile
  bibfile
  bibfilex
  bibtex
  bibstyle
  docstyle
  dvips_opts
  inputcommands
  inputcmdfile
  latexcmd
  makeindexstyle
  nlatexruns
  papdir
  part
  pdfeqfile
  pdfout
  pdfpapersfield
  pkey
  pname
  ps2pdf_opts
  remotehost
  termcmd
  termcmdreset
  tex_tmpdir
  texcmd
  texcompiler
  textcolor
  texdriver
  texroot
  viewtexcmd
  view_cmd_pdf_original
  view_cmd_pdf_compiled
  workdir
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
  MAKETARGETS
  all_parts
  bib_papers
  biblines
  builds
  compiled_parts
  compiled_tex_papers
  docstyles
  listof_types
  mistyles
  nltm_cleanfiles
  nltm_clobberfiles
  pap_allfiles
  paperconfs
  papsecfiles
  papeqfiles
  papeqnums
  part_build_files
  original_pdf_papers
  scripts
  secorder
  shellterm_sys_commands
  short_tex_papers
  tex_papers
  viewtexfiles
  xcommands
);

# papsecfiles -> files like p.PKEY.sec.*.i.tex

###__ACCESSORS_HASH
our @hash_accessors = qw(
  accdesc
  accessors
  compiletex_opts
  dirs
  done
  files
  journaldefs
  listof_exts
  nltm_opts
  makedata
  pap_packopts
  pap_usedpacks
  paperconfig
  papereqs_h
  papereqs_h_order
  paperfigs_h
  paperfigs_h_order
  papertabs_h
  papertabs_h_order
  paperrefs_h
  paperrefs_h_order
  paperviewfiles
  papfigs
  papsecs
  paptageqlabels
  part_make_opts
  part_paps
  plongkeys
  pshortkeys
  secorder_commands
  shellterm
  term_commands
  VARS
);

__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_array_accessors(@array_accessors)->mk_hash_accessors(@hash_accessors);

=head2 METHODS

=cut

# }}}

# }}}
#---------------------------------
# Methods {{{
#=================================
# Core {{{

# _begin() {{{

=head3 _begin()

=cut

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

# }}}

=head3 get_opt()

=cut

sub get_opt {
    my $self = shift;

    $self->OP::Script::get_opt();

    if ( $self->_opt_true("shcmds") ) {
        $self->inputcommands( $self->_opt_get("shcmds") );
    }

}

sub say {
	my $self=shift;

	print $_ . "\n" for(@_);

}


sub init_MAKETARGETS {
    my $self = shift;

    $self->say("Initializing MAKETARGETS...");

    my $pshell = OP::PROJSHELL->new;

    $pshell->_read_MKTARGETS( $self->files('targets.mk') );

    $self->MAKETARGETS( $pshell->MKTARGETS );

}

sub init_dirs {
    my $self = shift;

	$self->dirs(
		'config'	=>	catfile($hm,qw( .pshconfig )),
	);

	foreach my $id ($self->dirs_keys) {
		my $dir=$self->dirs($id);
		make_path($dir);
	}

}


sub init_files {
	my $self = shift;
	
	$self->files(
		"done_cbib2cite" =>
		catfile( $self->texroot, 'keys.done_cbib2cite.i.dat' ),
		"vars" => catfile( $self->texroot, $ENV{PVARSDAT} || 'vars.i.dat' ),
		"keys" => catfile( $self->texroot, 'keys.i.dat' ),
		"parts"    => catfile( $self->texroot, 'pap.parts.i.dat' ),
		"makefile" => catfile( $self->texroot, 'makefile' ),
		"targets.mk" => catfile( $self->texroot, qw(targets.mk) ),
		"history" => catfile( $self->dirs('config'), qw( hist ) ),
	);

}

# init_vars() {{{

=head3 init_vars()

=cut

sub init_vars {
    my $self = shift;

	$self->say('Start init_vars()');

    $self->_begin;

###_ACCDESC
    my ( %accdesc, %accdesc_array, %accdesc_scalar, %accdesc_hash );
###_ACCDESC_SCALAR
    %accdesc_scalar = (
        bibfile  => 'BiBTeX file name',
        bibfilex => 'BiBTeX file name',
        pkey     => 'Currently loaded paper key'
    );

    foreach my $acc ( keys %accdesc_scalar ) {
        $accdesc{"scalar_$acc"} = $accdesc_scalar{$acc};
    }
###_ACCDESC_ARRAY
    %accdesc_array = ( 'part_build_files' =>
          'List of files to be copied to $self->tex_tmpdir' );

    foreach my $acc ( keys %accdesc_array ) {
        $accdesc{"array_$acc"} = $accdesc_array{$acc};
    }
###_ACCDESC_HASH
    %accdesc_hash = ();

    foreach my $acc ( keys %accdesc_hash ) {
        $accdesc{"hash_$acc"} = $accdesc_hash{$acc};
    }

    $self->accdesc(%accdesc);

    $self->textcolor('bold yellow');

    # root directory for the LaTeX files
    $self->texroot( $ENV{'TexPapersRoot'} );

    $self->init_dirs;
    $self->init_files;
    $self->init_MAKETARGETS;

    $self->LATEXMK( $ENV{LATEXMK} || "LATEXMK" );

    $self->read_VARS;
    my $pname = $self->pname;

    $self->init_docstyles();

    $self->builds( map { (m/psh_build_(.*)\.pl$/) ? $1 : () }
          glob( $self->texroot . "/psh_build_*.pl" ) );

    $self->viewtexcmd("gvim -n -p --remote-tab-silent ");

    # Program used to view PDF files

    my $bibdefs = catfile( $self->texroot, "jnames.tex" );
    $self->bibdefsfile($bibdefs);

    $self->remotehost( $ENV{"opdesk"} );

    $self->LOGFILENAME("pshlog.data.tex");
    $self->LOGFILE( IO::File->new() );
    $self->LOGFILE->open( ">" . $self->LOGFILENAME );

    $self->mistyles(
        qw( basic classic docindex minitoc gatech-thesis-index opmist repeatindex )
    );

    $self->viewtexfiles(qw( figs refs not abs nc eqs ));

    #
    $self->listof_types(qw( figure table ));
    $self->listof_exts(
        figure   => 'lof',
        table    => 'lot',
        equation => 'loeq'
    );

    # Initialize an op::bibtex instance, then run it
    $self->bibtex( OP::BIBTEX->new );
    $self->bibtex->main;
	
    $self->bibfile( $self->bibtex->bibfile );

    # directory where the PDF files of the articles are stored
    $self->pdfpapersfield($ENV{PdfPapersField});

    my $papdir = catfile( $ENV{PdfPapersRoot}, $self->pdfpapersfield );

	$self->_die("papdir does not exist")
		unless -e $papdir;

    $self->papdir($papdir);
    $self->bibtex->papdir($papdir);

    $self->bibfile( catfile( $self->texroot, "repdoc.bib" ) );
    $self->bibfilex( catfile( $self->texroot, "xrepdoc.bib" ) );

    $self->debugout( "Setting texroot to: " . $self->texroot . "\n" );

    # List of TeX-papers
    $self->tex_papers( map { ( basename($_) =~ /^p\.(\w+)\./ ) ? $1 : () }
          glob( catfile( $self->texroot, "p.*.tex" ) ) );
    $self->tex_papers_uniq;

    # List of short keys of TeX-papers
    my $sphash;
    $sphash = readhash( $self->files('keys') );
    foreach my $val ( values %$sphash ) { $val = lc($val); }
    $self->short_tex_papers(
        [ map { s/^\s*//g; s/\s*$//g; (lc) } values %{$sphash} ] );

    $self->pshortkeys( %{$sphash} );
    $self->plongkeys( reverse $self->pshortkeys );

    # List of all parts
    $self->all_parts_push( sort keys %{ readhash( $self->files('parts') ) } );

    # Parts with their descriptions
    $self->_h_set( "parts_desc", readhash( $self->files('parts') ) );

    # List of PDF-papers
	my $sdir=$self->papdir ;
	opendir(D,"$sdir") || die $!;
	while(my $file=readdir(D)){
		local $_ = $file;

		next unless /^(.*)\.pdf$/;

		my $pkey = $1;

		$self->original_pdf_papers_push($pkey);
	}
	closedir(D);

	$self->original_pdf_papers_sort;
	$self->original_pdf_papers_uniq;

    # Output directory for compiled PDF files
    my $pdfout = catfile( $self->texroot, "out" );
    $self->pdfout($pdfout);

    # List of compiled PDF files
    $self->compiled_tex_papers(
        [ map { /p\.(.*)\.pdf$/ ? $1 : () } glob("$pdfout/p.*.pdf") ] );

    # List of compiled PDF parts
    $self->compiled_parts(
        [
            map { /pap_(.*)\.pdf$/ ? $1 : () }
              glob( "$pdfout/$pname" . "_*.pdf" )
        ]
    );

    # List of BibTeX keys
    $self->bib_papers( $self->bibtex->pkeys );

###_COMPILETEX_OPTS

    # Which way of LaTeX compiling to use?
    $self->texdriver("nltm");

    # General options used when compiling a LaTeX/TeX source
    # file
    $self->compiletex_opts(
        {
            'use_tmpdir'  => 0,
            'nonstopmode' => 1
        }
    );

###_NLTM_OPTIONS
    # nltm options (copied initially from ltm scripts)

    my @o = qw(
      -dOptimize=true
      -dUseFlateCompression=true
      -dMaxSubsetPct=100
      -dCompatibilityLevel=1.2
      -dSubsetFonts=true
      -dEmbedAllFonts=true
      -dAutoFilterColorImages=false
      -dAutoFilterGrayImages=false
      -dColorImageFilter=/FlateEncode
      -dGrayImageFilter=/FlateEncode
      -dModoImageFilter=/FlateEncode
    );

    $self->ps2pdf_opts( join( ' ', @o ) );

    $self->dvips_opts("-Pamz -Pcmz");
    $self->dvips_opts("-Ppdf");

    # Filename extensions for cleaning up
    # intermediate LaTeX files
    $self->nltm_cleanfiles(
        qw(
          aux backup bak bbl bln
          d dmp frpl idx ilg
          ind lgpl lof log
          lot out pipe swp toc
          )
    );

    # htlatex files
    $self->nltm_cleanfiles_push(qw(tmp idv 4ct lg 4tc 4dx 4ix xref css ));

    # Extensions for generated files
    # ( 'clobber' target in Rakefile terminology )
    $self->nltm_clobberfiles(qw( ps pdf dvi ));

	$self->say('End init_vars()');


}

sub read_VARS {
    my $self = shift;

    $self->VARS( readhash( $self->files('vars') ) );

    $self->VARS_to_accessors(
        [
            qw(
              bibstyle
              makeindexstyle
              nlatexruns
              pname
              texdriver
              texcmd
              latexcmd
              view_cmd_pdf_compiled
              view_cmd_pdf_original
              )
        ]
    );

}

sub init_docstyles {
    my $self = shift;

	$self->say('Initializing docstyles...');

    $self->VARS_to_accessors( [qw(docstyle)] );

    my $dir = catfile( $self->texroot, qw(docstyles) );
    my @styles = ();

    opendir( D, "$dir" ) || die $!;
    while ( my $file = readdir(D) ) {
        next if ( $file =~ /^\.*$/ );

        my $fpath = catfile( $dir, $file );
        next unless -d $fpath;

        push( @styles, $file );

    }
    $self->docstyles( \@styles );
    closedir(D);

}

# }}}
# main() {{{

sub main() {
    my $self = shift;

    $self->get_opt();

    $self->init_vars();

    $self->_term_init();
    #$self->_term_x();

    $self->_term_run();

}

# }}}
# new() {{{

sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

# }}}
# set_scalar_accessor(){{{

sub set_scalar_accessor() {
    my $self = shift;

    # scalar accessor name
    my $accname = shift;

    # scalar accessor assigned value
    my $accval = shift;

    my $evs = join( '', '$self->', $accname, "('", $accval, "');" );

    eval("$evs");
    die $@ if $@;

}

# }}}
# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts() {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts();

    my $opts = [];
    my $desc = {};

    push(
        @$opts,
        {
            name => "shcmds",
            desc => "Run command(s), then exit",
            type => "s"
        },
        {
            name => "runx",
            desc => "Run x"
        }
    );

    push( @$opts, { name => "shell", desc => "Start the interactive shell" } );

    $self->add_cmd_opts($opts);

}

# }}}

#}}}
#=================================
# LaTeX sources {{{
# ********************************
# _compiled_tex_paper_* {{{

# _compiled_tex_paper_path() {{{

sub _compiled_tex_paper_path() {
    my $self = shift;

    my $pkey = shift;

    my $path = catfile( $self->pdfout, "p.$pkey.pdf" );
    return $path;
}

# }}}
# _compiled_tex_paper_view_short() {{{

sub _compiled_tex_paper_view_short() {
    my $self = shift;

    # Short key
    my $skey = shift || '';

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->_compiled_tex_paper_view("$lkey");
}

# }}}
# _compiled_tex_paper_view() {{{

sub _compiled_tex_paper_view() {
    my $self = shift;

    my $ref = shift || '';
    my @files_to_view = ();

    if ($ref) {
        unless ( ref $ref ) {
            my $pkey = $ref;
            my $file = $self->_compiled_tex_paper_path($pkey);
            push( @files_to_view, $file );
        }
    }

    foreach my $file (@files_to_view) {

        my $view_cmd = $self->view_cmd_pdf_compiled . ' ' . $file;
        $self->sysrun( "$view_cmd &", driver => 'system' );
    }
}

# }}}

# }}}
# ********************************
# cbibr {{{

# cbibr_get_cite_str() {{{

sub cbibr_get_cite_str() {
    my $self = shift;

    my $pkey = $self->pkey;
    my ( $min, $max ) = @_;

    my @nums = ( $min .. $max );
    my @all_cite_paps;
    my @cite_paps;
    my ( $s_cite, $cite_str );

    foreach my $num (@nums) {
        $s_cite = `/home/op/wrk/p/cbib.pl --pkey $pkey --N $num`;
        chomp $s_cite;
        $s_cite =~ s/^\\cite\{(.*)\}/$1/g;
        @cite_paps = split( ',', $s_cite );
        push( @all_cite_paps, @cite_paps );
    }

    $cite_str = "\\cite{" . join( ',', @all_cite_paps ) . "}";

    return $cite_str;

}

# }}}
# cbibm_get_cite_str() {{{

sub cbibm_get_cite_str() {
    my $self = shift;

    my $cites = shift;

    my $pkey = $self->pkey;

    my @nums = split( ',', $cites );

    my @all_cite_paps;
    my @cite_paps;
    my ( $s_cite, $cite_str );

    foreach my $num (@nums) {
        $s_cite = `cbib.pl --pkey $pkey --N $num`;

        chomp $s_cite;
        $s_cite =~ s/^\\cite\{(.*)\}/$1/g;
        @cite_paps = split( ',', $s_cite );
        push( @all_cite_paps, @cite_paps );
    }

    $cite_str = "\\cite{" . join( ',', @all_cite_paps ) . "}";
    return $cite_str;

}

# }}}
# line_cbibm_to_cite() {{{

sub line_cbibm_to_cite() {
    my $self = shift;

    my $line      = shift;
    my @pieces    = split( /\\cbibm\s*{/, $line );
    my $startline = shift @pieces;

    my $re = qr/\s*\s*([\d, ]+)\s*}/;

    if (@pieces) {
        foreach my $piece (@pieces) {
            if ( $piece =~ m/$re/ ) {
				my $cites=$1;
                my $cite_str = $self->cbibm_get_cite_str( $cites );
                my $cbibm    = '\cbibm{' . $cites . '}';
                $piece =

                 #"\n" . "%$cbibm" . "\n" . $cite_str . substr( $piece, $+[0] );
                  $cite_str . substr( $piece, $+[0] );
            }
        }
        $line = join( '', $startline, @pieces );
    }
    return $line;

}

# }}}

sub line_cbib2cite {
    my $self = shift;

    my $line      = shift;
    my @pieces    = split( /\\cbib\s*{/, $line );
    my $startline = shift @pieces;
    my $pkey      = $self->pkey;

    my $re = qr/\s*\s*(\d+)\s*}/;

    if (@pieces) {
        foreach my $piece (@pieces) {
            if ( $piece =~ m/$re/ ) {
				my $num=$1;
				my $cite_str = `cbib.pl --pkey $pkey --N $num`;
				my $cbib     = '\cbib{' . $num . '}';
				$piece = $cite_str . substr( $piece, $+[0] );
            }
        }
        $line = join( '', $startline, @pieces );
    }

    return $line;

}

# line_cbibr_to_cite() {{{

sub line_cbibr_to_cite {
    my $self = shift;

    my $re = qr/\s*\s*(\d+)\s*}\s*{\s*(\d+)\s*}/;

    my $line      = shift;
    my @pieces    = split( /\\cbibr\s*{/, $line );
    my $startline = shift @pieces;

    if (@pieces) {
        foreach my $piece (@pieces) {
            if ( $piece =~ m/$re/ ) {
				my $min=$1;
				my $max=$2;

                my $cite_str = $self->cbibr_get_cite_str( $min, $max );
                my $cbibr = '\cbibr{' . $min . '}{' . $max . '}';
                $piece =

                 #"\n" . "%$cbibr" . "\n" . $cite_str . substr( $piece, $+[0] );
                  $cite_str . substr( $piece, $+[0] );
            }
        }
        $line = join( '', $startline, @pieces );
    }

    return $line;
}

# }}}

# }}}
# ********************************
# view* {{{

# view() {{{

sub view() {
    my $self = shift;

    my $id = shift;
    my @files_to_view;

    foreach ($id) {
        /^vm$/ && do {
            push( @files_to_view, $0 );
            next;
        };
        /^bib$/ && do {
            push( @files_to_view, $self->bibfname );
            next;
        };
    }

    my $viewer   = "gvim -n -p --remote-tab-silent";
    my $view_cmd = "$viewer @files_to_view & ";
    $self->sysrun( $view_cmd, driver => 'system' );

}

# }}}
# view_tex_short() {{{

sub view_tex_short() {
    my $self = shift;

    # What to view
    my $id = shift;

    # Short key
    my $skey = shift || '';

    # Long key
    my $lkey = $self->_long_key($skey);

    return 1 unless $lkey;

    $self->view_tex( $id, $lkey );

}

# }}}
# view_tex() {{{

sub view_tex() {
    my $self = shift;

    my $id   = shift;
    my $pkey = shift;
    my (@files_to_view);

    foreach ($id) {
        /^idx$/ && do {
            foreach my $ext (qw(idx ind)) {
                push( @files_to_view, "p.$pkey.pdf.$ext" );
            }
            next;
        };
        /^ref$/ && do {
            foreach my $sec (qw( refs )) {
                push( @files_to_view, "p.$pkey.$sec.tex" );

                foreach my $ext (qw(txt bib )) {
                    my $f = "cit/p.$pkey.frefs.$ext";
                    push( @files_to_view, $f ) if ( -e $f );
                }
            }
            next;
        };
        /^cit$/ && do {
            foreach my $sec (qw( cit )) {
                push( @files_to_view, "p.$pkey.$sec.tex" );

                foreach my $ext (qw(txt bib )) {
                    my @f;
                    push( @f, "cit/p.$pkey.fcit.$ext" );
                    push( @f, "wos.txt" );

                    #push(@files_to_view,$f) if (-e $f);
                    push( @files_to_view, @f );
                }
            }
            next;
        };
        /^cnf$/ && do {
            my $fcnf = "p.$pkey.conf.pl";
            unless ( -e $fcnf ) {
                $self->_tex_paper_conf_create($pkey);
            }
            push( @files_to_view, $fcnf );
            next;
        };
        /^pdf$/ && do {
            foreach my $ext (qw( pdf )) {
                push( @files_to_view, "p.$pkey.pdf.tex" );
            }
            next;
        };
        /^nc$/ && do {
            foreach my $sec (qw( nc pap-nc pap-nc.0 pdf.nc )) {
                push( @files_to_view, "$sec.tex" );
            }
            next;
        };

    }

    my $viewer   = "gvim -n -p --remote-tab-silent";
    my $view_cmd = "$viewer @files_to_view";

    $self->sysrun($view_cmd);

}

# }}}

# }}}
# ********************************
# keys {{{

# _pkey_set_current() {{{

sub _pkey_set_current() {
    my $self = shift;

    my $pkey = shift;

    $self->_v_set( "current_pkey", $pkey );
    $self->out("Have set current paper: $pkey\n");
    $self->_tex_paper_load_conf("$pkey");

}

# }}}
# _pkey_set_current_short() {{{

sub _pkey_set_current_short() {
    my $self = shift;

    # Short key
    my $skey = shift || '';

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->_pkey_set_current("$lkey");

}

# }}}
# _p() {{{

=head3 _p()

=cut

sub _p() {
    my $self = shift;

    my $pkey = shift;

    $self->bibtex->print_entry($pkey);
}

# }}}
# _p_short() {{{

=head3 _p_short()

=cut

sub _p_short() {
    my $self = shift;

    my $skey = shift;
    my $lkey = $self->_long_key($skey);

    $self->_p($lkey);
}

# }}}
# _long_key() {{{

sub _long_key() {
    my $self = shift;

    my $skey = shift;

    my $lkey = $self->plongkeys($skey) || '';

    return $lkey;
}

# }}}

# }}}
# ********************************

# }}}
#=================================
# Other: list_* sysrun termcmd_reset update_info {{{

# _expand_perltex_ienv() {{{

sub _expand_perltex_ienv() {
    my $self = shift;

    my $pkey   = '\pn';
    my $env    = shift;
    my @ranges = split( ',', shift );

    #my $env=$ARGV[0];
    #my @ranges=split(',', $ARGV[1]);

    my ( @pages, @pt );
    my ( $start, $fin );
    my $stex = "";

    foreach (@ranges) {
        chomp;
        if (/^\s*(\w+)\s*$/) {
            push( @pages, $1 );
        }
        elsif (/^\s*(\d+)\-(\d+)\s*$/) {
            $start = $1;
            $fin   = $2;
            @pt    = ( $start .. $fin );
            push( @pages, @pt );
        }
    }

    foreach my $p (@pages) {
        $stex = $stex . "\\input\{p.$pkey.$env.$p.tex\}\n";
    }
    return $stex;

}

# }}}
# _package_is_used() {{{

sub _package_is_used() {
    my $self = shift;

    my $package = shift || '';

    return 0 unless $package;
    die "part scalar is undefined"
      unless $self->part;

    if ( grep { /^$package$/ } @{ $self->pap_usedpacks( $self->part ) } ) {
        return 1;
    }
    return 0;
}

# }}}
# _tex_clean() {{{

sub _tex_clean() {
    my $self = shift;

    $self->out( "Cleaning any LaTeX intermediate files"
          . " in the current directory ...\n" );

    foreach my $ext ( $self->nltm_cleanfiles ) {
        foreach my $f ( glob("*.$ext") ) {
            remove_tree($f);
        }
    }

    #system("LATEXMK -c");
}

# }}}
# _tex_clobber() {{{

sub _tex_clobber() {
    my $self = shift;

    $self->out( "Removing generated PDF, PS and dvi files"
          . " in the current directory...\n" );

    foreach my $ext ( $self->nltm_clobberfiles ) {
        foreach my $f ( glob("*.$ext") ) {
            remove_tree($f);
        }
    }
}

# }}}
# sysrun() {{{

=head3 sysrun()

=cut

sub sysrun() {
    my $self = shift;

    my $cmd = shift || '';
    my %opts = (
        verbose => 1,
        driver  => 'IPC::Cmd'
    );

    while (@_) {
        my $key = shift;
        my $val = shift || '';

        $opts{$key} = $val if $val;
    }

    return 0 unless $cmd;

    #if ( $self->termcmdreset && !$self->LOGFILE_PRINTED_TERMCMD ) {
    #$self->LOGFILE->print( "\\section{command: " . $self->termcmd . "}\n" );
    #$self->LOGFILE_PRINTED_TERMCMD(1);
    #}

    foreach ( $opts{driver} ) {
        /^IPC::Cmd$/ && do {
            my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf )
              = IPC::Cmd::run( command => $cmd, verbose => $opts{verbose} );

            $self->makedata(
                success       => $success,
                error_message => $error_message,
                full_buf      => $full_buf,
                stdout_buf    => $stdout_buf,
                stderr_buf    => $stderr_buf,
            );

            # if ($success) {
            #$self->LOGFILE->print("% $cmd \n");
            #$self->LOGFILE->print("\\begin{verbatim}\n");
            #$self->LOGFILE->print( join "", @$full_buf );
            #$self->LOGFILE->print("\\end{verbatim}\n");
            #$self->LOGFILE->print("%%% \n");
            #}
            #else {
            #}
            next;
        };
        /^system$/ && do {
            system("$cmd");
            next;
        };
    }

}

# }}}
# termcmd_reset () {{{

=head3 termcmd_reset () {{{

=cut

sub termcmd_reset() {
    my $self = shift;
    my $cmd  = shift;

    $self->termcmd($cmd);
    $self->termcmdreset(1);
    $self->LOGFILE_PRINTED_TERMCMD(0);
}

# }}}

# }}}
# update_info() {{{

sub update_info() {
    my $self = shift;

    my $texp = "info";

    my $date = localtime;

    # temporary variable used for storing different file names
    my $file;

    # temporary variable used for storing/printing LaTeX text
    my $s = Text::Generate::TeX->new;

    # Preamble
    open PA, ">$texp.preamble.tex" || die $!;
    close PA;

    # Begin part
    $s->_flush;
    $file = "$texp.begin.tex";

    $s->_flush;
    $s->_add_line( [qw( begin document)] );

    $s->_print( file => $file );

    # List of all compiled LaTeX-source papers
    $s->_flush;
    $file = "$texp.list_tex_papers.tex";

    $s->section("List of LaTeX source papers");
    $s->_print( file => $file );

    # List of all compiled PDF papers (from LaTeX sources)
    $s->_flush;
    $file = "$texp.list_compiled_pdf_papers.tex";

    $s->section("List of compiled PDF papers");
    $s->_print( file => $file );

    # List of all available original PDF papers
    $s->_flush;
    $file = "$texp.list_original_pdf_papers.tex";

    $s->section("Index of available original PDF papers");
    $s->_print( file => $file );

    # Main LaTeX file
    $s->_flush;
    $file = "$texp.main.tex";

    my @main_file_inputs = qw(
      preamble
      begin
      toc
      list_original_pdf_papers
      list_compiled_pdf_papers
      list_tex_papers
      end
    );

    $s->_comments( "", "File: $file", "", "Generated on: $date", "" );

    foreach my $i (@main_file_inputs) {
        my $if = "$texp.$i.tex";
        $s->input("$if") if ( -e $if );
    }

    $s->_print( file => $file );

    # Run LaTeX2HTML to re-generate HTML pages
}

# }}}
# gen_make_sh() {{{

sub gen_make_sh() {

    my $self = shift;

    my $f        = 'pap';
    my $tex      = "perllatex";
    my $mshlines = [
        "#!/bin/bash",
        "",
        'export TEXINPUTS=$TEXINPUTS:' . $self->texroot,
        'export BIBINPUTS=$BIBINPUTS:' . $self->texroot,
        "",
        'LATEX=$1',
        "",
        "\$LATEX $f",
        "bibtex $f",
        "\$LATEX $f",
        "\$LATEX $f",
        ""
    ];
    my $msh = 'make.sh';

    foreach my $line (@$mshlines) {
        $line .= "\n";
    }

    write_file $msh, @$mshlines;
    chmod 0755, $msh;

}

# }}}

# }}}
#=================================
# PDF original papers {{{

# view_pdf_paper_short() {{{

sub view_pdf_paper_short() {
    my $self = shift;

    # Short key
    my $skey = shift || '';

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->view_pdf_paper($lkey);
}

# }}}
# view_pdf_paper() {{{

sub view_pdf_paper() {
    my $self = shift;

    my $pkey = shift || '';
    return 0 unless $pkey;

    my $file = catfile( $self->papdir, "$pkey" . ".pdf" );

    my $cmd = $self->view_cmd_pdf_original . " $file" . " &";

    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
      IPC::Cmd::run( command => $cmd, verbose => 1 );

}

# }}}
# list_pdf_papers() {{{

sub list_pdf_papers() {
    my $self = shift;

    my $pkey = shift;

    my $cmd = "bash lsp $pkey";
    $self->sysrun($cmd);
}

# }}}

sub _pdf2tex {
    my $self = shift;
}

# }}}
#=================================
# BibTeX {{{

# _bib_readfile() {{{

=head3 _bib_readfile

=cut

sub _bib_readfile {
    my $self = shift;

    my $if = $self->bibfile;

    my @biblines = read_file($if);
    $self->biblines(@biblines);

}

# }}}
# _bib_expand() {{{

=head3 _bib_expand

Expand all BibTeX file with all LaTeX definitions

=cut

sub _bib_expand {
    my $self = shift;

    my @lines = read_file $self->bibdefs;

    $self->out("Reading in journal definitions...\n");

    foreach my $line (@lines) {
        chomp($line);
        next if /^\s*%/;

        if ( $line =~ m/^\s*\\def\\(.*){(.*)}\s*$/ ) {
            my ( $def, $name ) = ( $1, $2 );
            $self->journaldefs( { $def => $name } );
        }
    }

    $self->out("Reading in BibTeX file...\n");
    $self->_bib_readfile();
    print Dumper( \%{ $self->journaldefs } );

    $self->out("Performing journal name expansion...\n");

    my $i = 0;

    my @biblines = $self->biblines;
    foreach my $line (@biblines) {
        chomp($line);

        foreach my $k ( $self->journaldefs_keys ) {
            my $v = $self->journaldefs($k);

            $line =~ s/\\$k(?=\W)/$v/g;
        }
        $line .= "\n";
        $i++;

        #last if $i > 100;

    }
    $self->biblines_clear;
    $self->biblines(@biblines);

    $i = 0;
    foreach my $line ( $self->biblines ) {
        chomp($line);

        #print "$line\n";
        #$i++;
        #last if $i > 100;
    }

    $self->out("Writing the output BiBTeX file...\n");

    my $of = $self->bibfilex;
    write_file( $of, $self->biblines );

}

# }}}
# _bibtex_rmfields() {{{
#

sub _bibtex_rmfields {
    my $self = shift;

    my $bibtex   = $self->bibtex;
    my $rmfields = $bibtex->rmfields;

    $self->out("The following fields will be removed:\n");
    print @$rmfields . "\n";

    my $bibout = LaTeX::BibTeX::File("new.bib");

    foreach my $e ( $bibtex->entries_pkey_values ) {
        foreach my $f (@$rmfields) {
            $e->delete($f);
            $e->write($bibout);
        }
    }
}

# }}}

# }}}
sub _build() {
    my $self = shift;

    my $build = shift;

    my $cmd = "perl psh_build_$build" . ".pl";
    system("$cmd");

}

#=================================
# Bash scripts _bt _cnp _nwp _vepist {{{

# _bt() {{{

sub _bt() {
    my $self = shift;

    my @args = @_;

    my $cmd = "bash bt @args";
    $self->sysrun($cmd);
}

# }}}
# _cnp() {{{

sub _cnp() {
    my $self = shift;

    my @args = @_;

    my $cmd = "bash cnp @args";
    $self->sysrun( $cmd, driver => 'system' );
}

# }}}
# _nwp() {{{

sub _nwp() {
    my $self = shift;

    my @args = @_;

    my $cmd = "bash nwp @args";
    $self->sysrun( $cmd, driver => 'system' );
}

# }}}
# _vepist() {{{

sub _vepist() {
    my $self = shift;

    my @args = @_;

    my $cmd = "bash vep -g -i -s @args -t";
    $self->sysrun( $cmd, driver => 'system' );
}

# }}}

# }}}
#=================================
# Git {{{

sub _gitco () {
    my $self = shift;

    my $opt = shift;

    my $cmd = "git co -- ";

    for ($opt) {
        /^ptex$/ && do {
            $cmd .= ' p.*.tex';
            next;
        };
        /^nc$/ && do {
            $cmd .= ' p.*.nc.tex';
            next;
        };
        /^isec$/ && do {
            $cmd .= ' *sec*i.tex';
            next;
        };
    }

    system("$cmd");
}

# }}}
#=================================
# Sync {{{

sub update_ppics() {
    my $self = shift;

    system("rsync -avz --size-only $ENV{opdesk}:~/wrk/p/ppics/ . ");

}

###convertppics
sub _tex_paper_convert_ppics() {
    my $self = shift;

    my $pkey = shift || $self->pkey;
    $self->pkey($pkey);

    my $dir = catfile( $self->texroot, qw(ppics), $pkey );

    return unless -d $dir;

    opendir( D, "$dir" ) || die $!;

    my @exts = qw( eps );

    while ( my $file = readdir(D) ) {
        next if $file =~ /^[\.]+$/;

        my @f = split( /\./, $file );
        my $ext = pop @f;

        if ( grep { /^$ext$/ } @exts ) {
            next;
        }

        my $fname = join( ".", @f );
        $file = catfile( $dir, $file );

        my $dest = catfile( $dir, join( ".", $fname, qw(eps) ) );
        if ( -e $dest ) {
            next;
        }

        $self->say( "Converting: $fname" . ".$ext" );
        system("convert $file $dest");

    }
    closedir(D);

}

# }}}
#=================================
# }}}
#---------------------------------

1;

