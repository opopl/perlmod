
package OP::PAPERS::PSH;

#---------------------------------
# main()
#---------------------------------
# intro               {{{

# use ... {{{

use strict;
use warnings;

use feature qw(switch);

use Env qw( $hm );

use OP::Base qw( 
	readhash 
	readarr
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

use LaTeX::BibTeX;
use LaTeX::Table;
use LaTeX::TOM;

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

op::papers::psh - Perl package implementing shell functionality for dealing
with papers and other stuff in the wrk/p/ directory

=head1 INHERITANCE

L<Class::Accessor::Complex>, L<OP::Script>

=head1 DEPENDENCIES

=cut

use parent qw( OP::Script Class::Accessor::Complex );

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
  bibfname
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
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();

    if ( $self->_opt_true("shcmds") ) {
        $self->inputcommands( $self->_opt_get("shcmds") );
    }

}

# }}}

sub init_MAKETARGETS {
    my $self = shift;

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
        "vars" => catfile( $self->texroot, $ENV{PVARSDAT} // 'vars.i.dat' ),
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
    $self->texroot( $ENV{'PSH_TEXROOT'} // catfile( "$ENV{hm}", qw(wrk p) )
          // catfile( "$hm", qw(wrk p) ) );

    $self->init_dirs;
    $self->init_files;
    $self->init_MAKETARGETS;

    $self->LATEXMK( $ENV{LATEXMK} // "LATEXMK" );

    $self->read_VARS;
    my $pname = $self->pname;

    $self->init_docstyle();

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
    $self->bibfname( $self->bibtex->bibfname );

    # directory where the PDF files of the articles are stored
    $self->pdfpapersfield("ChemPhys");

    my $papdir = catfile( $hm, qw( doc papers ), $self->pdfpapersfield );

	$self->_die("papdir does not exist")
		unless -e $papdir;

    $self->papdir($papdir);
    $self->bibtex->papdir($papdir);

    $self->bibfile( catfile( $self->texroot, "repdoc" ) );
    $self->bibfilex( catfile( $self->texroot, "xrepdoc" ) );

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
	File::Find::find({ 
		wanted => sub { 
			return unless /\.pdf$/;
			my $subdir= $File::Find::dir =~ s{\Q$sdir}{}gr;

			return if $subdir;

			my $pkey = $_ =~ s{\.pdf$}{}gr;

			$self->original_pdf_papers_push($pkey);

		} 
	},	$sdir
	);

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

sub init_docstyle {
    my $self = shift;

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
    $self->_term_x();

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
# _tex_paper_* {{{

# _tex_paper_splitmain {{{

sub _tex_paper_splitmain {
    my $self = shift;

    my $pkey = shift // $self->pkey;
    $self->pkey($pkey);

    my $mfile = catfile( $self->texroot, 'p.' . $pkey . '.tex' );
    my @lines = read_file $mfile;

    my ( $cname, $ctitle );
    $cname = '';
    my @outside = ();
    my %onchapter;

    my ( @CHAPTERNAMES, $CHAPTERS );

    foreach (@lines) {
        chomp;

        /^\\subsection{(?<ctitle>.*)}$/ && do {
            $onchapter{$cname} = 0 if defined $onchapter{$cname};

            $ctitle = $+{ctitle};

            $cname = join( '_', split( ' ', $ctitle ) );
            $cname =~ s/\\(TeX)/_$1/g;
            $cname =~ s/\\//g;
            $cname =~ s/\./_/g;
            $cname =~ s/'s//g;
            $cname =~ s/[_()]+/_/g;

            $cname =~ s/^\s*//g;
            $cname =~ s/\s*$//g;

            push( @CHAPTERNAMES, $cname );

            $ctitle =~ s/\\/ /g;
            s/(.)\\\\/$1 /g;

            $CHAPTERS->{$cname}->{file} =
              catfile( $self->texroot,
                'p.' . $pkey . '.sec.' . $cname . '.i.tex' );

            $CHAPTERS->{$cname}->{title} = $ctitle;

            push( @outside, '\iii{' . $cname . '}' );
            $onchapter{$cname} = 1;

            $_ = '\isec{' . $cname . '}{' . $ctitle . '}';

        };

        /^\s*\\labelsec{\d+}\s*$/ && do { $_ = ''; };

        if ( $onchapter{$cname} ) {
            push( @{ $CHAPTERS->{$cname}->{text} }, $_ );
        }
        else {
            push( @outside, $_ );
            next;
        }
    }

    # end loop over @lines

    #write_file($FILES{OUTSIDE},join("\n",@outside) . "\n");

    foreach my $cname (@CHAPTERNAMES) {

        print "Printing chapter: $cname" . "\n";

        my @lines = @{ $CHAPTERS->{$cname}->{text} };
        my $file  = $CHAPTERS->{$cname}->{file};
        write_file( $file, join( "\n", @lines ) . "\n" );

        #system("git add $file");

    }

    if (@CHAPTERNAMES) {
        my $sofile =
          catfile( $self->texroot, "p." . $self->pkey . ".secorder.i.dat" );

        write_file( $sofile, join( "\n", @CHAPTERNAMES ) . "\n" );

        #system("git add $sofile");
    }

}

#                                       }}}
# _tex_paper_splitpiece {{{

sub _tex_paper_splitpiece {
    my $self = shift;

    my $piece = shift;

    my $pkey = shift // $self->pkey;
    $self->pkey($pkey);

    my $pfile =
      catfile( $self->texroot, 'p.' . $pkey . '.' . $piece . 's.tex' );

    my @lines = read_file $pfile;

    my ( $num, $short );
    my @outside = ();
    my %onchapter;

    my ( @NUMS, $CHAPTERS );

    $num = 0;

    foreach (@lines) {
        chomp;

        if ( $piece eq "fig" ) {
            /^\\figp\{\w+\}\{(?<num>\w+)\}\[(?<short>.*)\]/ && do {
                $onchapter{$num} = 0 if defined $onchapter{$num};

                $short = $+{short};
                $num   = $+{num};

                print "Found figure number: $num \n";

                push( @NUMS, $num );

                $CHAPTERS->{$num}->{file} =
                  catfile( $self->texroot,
                    join( ".", 'p', $pkey, $piece, $num, 'tex' ) );

                $CHAPTERS->{$num}->{title} = $short;

                push( @outside, '\ienv{' . $piece . '}{' . $num . '}' );
                $onchapter{$num} = 1;

            };

            if ( $onchapter{$num} ) {
                push( @{ $CHAPTERS->{$num}->{text} }, $_ );
            }
            else {
                push( @outside, $_ );
                next;
            }
        }
    }

    # end loop over @lines

    #write_file($FILES{OUTSIDE},join("\n",@outside) . "\n");

    foreach my $num (@NUMS) {

        print "Printing num: $num" . "\n";

        my @lines = @{ $CHAPTERS->{$num}->{text} };
        my $file  = $CHAPTERS->{$num}->{file};
        write_file( $file, join( "\n", @lines ) . "\n" );

        #system("git add $file");

    }

    if (@NUMS) {
        my $pdat = catfile( $self->texroot,
            join( ".", "p", $self->pkey, $piece . "s", "i.dat" ) );

        my @LINES;
        foreach my $num (@NUMS) {
            push( @LINES, $num . ' ' . $CHAPTERS->{$num}->{title} );
        }

        write_file( $pdat, join( "\n", @LINES ) . "\n" );

        #system("git add $sofile");
    }

}

#                                       }}}

# _tex_paper_mh()                       {{{

sub _tex_paper_mh() {
    my $self = shift;

    my $pkey = shift;

    my $f   = "p.$pkey.pdf";
    my $paf = "$f.preamble.tex";

    #$self->sysrun("perltex --nosafe $f");

    $self->sysrun("ltm --dvi --perltex $f");
    $self->sysrun("t4ht -f $f");

}

# }}}
# _tex_paper_mh_short() {{{

sub _tex_paper_mh_short() {
    my $self = shift;

    # Short key
    my $skey = shift // '';

    # Long key
    my $lkey = $self->_long_key($skey);

    return 1 unless $lkey;

    $self->_tex_paper_mh($lkey);
}

# }}}
# _tex_paper_latex_2_html() {{{

sub _tex_paper_latex_2_html() {

    my $self = shift;

    my $pkey = shift // '';
    my %nc = ();

    my $l2h = "latex2html";

    my $ftex  = "p.$pkey.pdf.tex";
    my $fhtml = "p.$pkey.html";

    #my $nc="p.$pkey.nc.tex";

    #open NC, "<$nc" || die $!;
    #while (<NC>) {
    #next if /^\s*%/;
    #}
    #close NC;

    #$self->sysrun("latex2html $f");
    my $opts = "";

    #$opts='"html,2,info"';
    #$opts='"html,mathplayer" "" "--nonstopmode"';
    #$opts='"html,mathplayer"';
    #$opts='"xhtml,mozilla" "-cmozhtf" "-cvalidate"';
    #$opts='"html,2,info,fn-in"';
    #$opts="\"p.$pkey\"";
    #$self->sysrun("htlatex $ftex \"frames\"");
    #$self->sysrun("tth -a -L < $ftex > $fhtml");

}

# }}}
# _tex_paper_htlatex() {{{

###htlatex

sub _tex_paper_htlatex() {

    my $self = shift;

    my $pkey = shift // '';

    my $htlatex = "htlx";
    my $if      = "p.$pkey.pdf";

    my $cfg = "p.$pkey.cfg.tex";

    my $htmlout = catfile( $hm, qw(html pap), $pkey );
    make_path($htmlout);
    chdir $self->texroot;

    unless ( -e $cfg ) {
        my $text;

        my $s = Text::Generate::TeX->new;
        my ( @in_document, @in_preamble );

        @in_preamble = qw( _cfg.frames-two _cfg.tabular _common.cfg );
        @in_document = qw( _cfg.HEAD.showHide _cfg.TOC );

        $s->_add_line(
            '\Preamble{html,frames,4,index=2,next,charset=utf-8,javascript}');
        foreach my $in (@in_preamble) {
            $s->input("$in");
        }
        $s->_add_line('\begin{document}');
        foreach my $in (@in_document) {
            $s->input("$in");
        }
        $s->_add_line('\EndPreamble');
        $s->_print( { file => $cfg, fmode => 'w' } );
    }

    copy( "$cfg", "$if.cfg" );

    # use the above handled cfg file for htlatex
    $self->sysrun("$htlatex $if $if");

    #remove_tree("$if.cfg");
    my @pfiles;

    push( @pfiles, glob("p.$pkey.pdf*.html") );
    push( @pfiles, glob("p.$pkey.pdf*.png") );

    foreach my $f (@pfiles) {
        move( $f, $htmlout );
    }

}

# }}}
# _tex_paper_latex_2_html_short() {{{

sub _tex_paper_latex_2_html_short() {
    my $self = shift;

    # Short key
    my $skey = shift // '';

    # Long key
    my $lkey = $self->_long_key($skey);

    return 1 unless $lkey;

    $self->_tex_paper_latex_2_html($lkey);
}

# }}}

# _tex_paper_view_pdfeqs() {{{

sub _tex_paper_view_pdfeqs() {
    my $self = shift;

    my $pkey = shift // $self->pkey // '';
    $self->pkey($pkey);

    my $fname = 'p.' . $self->pkey . '.pdfeqs';
    my $file = catfile( $self->texroot, $fname . '.pdf' );

    if ( -e $file ) {
        my $view_cmd = "evince " . $file;
        system("$view_cmd &");
    }
}

#}}}
# _tex_paper_mpdfeqs() {{{

sub _tex_paper_mpdfeqs() {
    my $self = shift;

    my $pkey = shift // $self->pkey // '';
    $self->pkey($pkey);

    $self->_tex_paper_sep( 'eqs', $pkey );

    my $fname = 'p.' . $self->pkey . '.pdfeqs';
    my $file = catfile( $self->texroot, $fname . '.tex' );

    if ( -e $file ) {
        $self->say( "Will run ltm for file: " . $file );
        system("ltm --infile $fname --perltex --nonstop");
    }
    else {
        $self->warn("PDFEQS file was not found");
    }

}

# }}}
# _tex_paper_mpdfrevtex() {{{

sub _tex_paper_mpdfrevtex() {
    my $self = shift;

    my $pkey = shift // $self->pkey // '';
    $self->pkey($pkey) if $pkey;
}

# }}}
# _tex_paper_write_title_page() {{{

sub _tex_paper_write_title_page() {
    my $self = shift;

    my $pkey = shift // '';

    return 1 unless $pkey;

    $self->out("Writing title page for paper: $pkey\n");

    my $config = $self->paperconfig($pkey) // '';

    my $pname   = $self->pname;
    my $titpage = "p.$pkey.titpage.tex";

    open( TIT, ">$titpage" );

    print TIT "\\clearpage%\n";
    print TIT "\\phantomsection\n";
    print TIT "\\begingroup%\n";
    print TIT " \\nc{\\pn}{$pkey}\n";

    # Bookmark at the chapter level
    print TIT "\\hypertarget{$pkey-titpage}{}\n";

    #print TIT "\\bookmark[dest=$pkey-titpage,level=0]{$pkey}" . "\n";

    my $width = $config->{titpage_width} // "5";

    ##################################
    # Print the article reference

    my $bibt = "bibt.$pkey.tex";
    if ( -e $bibt ) {
        print TIT '\vspace*{5pt}' . "\n";
        print TIT ' \begin{center}' . "\n";
        print TIT '   \begin{fminipage}{' . $width . 'in}' . "\n";
        print TIT '     \input{' . $bibt . "}\n";
        print TIT '   \end{fminipage}' . "\n";
        print TIT ' \end{center}' . "\n";
        print TIT '\vspace*{5pt}' . "\n";
    }

    print TIT "\\addcontentsline{toc}{chapter}{$pkey} \n";

    ##################################
    # Print the article abstract

    my $abs = "p.$pkey.abs.tex";
    edit_file {
        s/^\\clearpage.*$//gxm;
        s/^\\(\w+){Abstract}.*$//igxm;
        s/^\\label.*$//igx;
    }
    $abs;

    my $iabs = $config->{include_abstract} // '';

    if ( ( -e $abs ) && ($iabs) ) {
        print TIT '\vspace*{5pt}' . "\n";
        print TIT ' \begin{center}' . "\n";
        print TIT '   \begin{fminipage}{' . $width . 'in}' . "\n";
        print TIT '     \input{' . $abs . "}\n";
        print TIT '   \end{fminipage}' . "\n";
        print TIT ' \end{center}' . "\n";
        print TIT '\vspace*{5pt}' . "\n";
    }

    print TIT "\\endgroup\n";
    close(TIT);
}

# }}}
# _tex_paper_bundle () {{{

sub _tex_paper_bundle () {
    my $self = shift;

    my $pkey = shift;

}

# }}}
# _tex_paper_run_tex {{{

sub _tex_paper_run_tex {
    my $self = shift;

    my $type = shift;
    my $ref  = shift;

    my $file;

    for ($type) {

        # run tex for PDF file
        /^pdf$/ && do {
            my $pkey = $ref;
            $file = "p.$pkey.pdf";
            next;
        };

        # run tex for part
        /^part$/ && do {
            my $part = $ref;
            $file = "pap_part_$part";
            next;
        };
    }
    my $cmd = $self->texcmd . " $file";

    $self->sysrun($cmd);
}

# }}}
# _tex_paper_run_latex {{{

sub _tex_paper_run_latex {
    my $self = shift;

    my $pkey = shift;

    my $cmd = $self->latexcmd . " p.$pkey.pdf";
    $self->sysrun($cmd);
}

# }}}
# _tex_paper_run_latex_short {{{

sub _tex_paper_run_latex_short {
    my $self = shift;

    # Short key
    my $skey = shift // '';

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

    return 1 unless $lkey;

    $self->_tex_paper_run_latex($lkey);

}

# }}}
# _tex_paper_run_tex_short {{{

sub _tex_paper_run_tex_short {
    my $self = shift;

    # Short key
    my $skey = shift // '';

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

    return 1 unless $lkey;

    $self->_tex_paper_run_tex( 'pdf', $lkey );

}

# }}}

sub _tex_paper_set() {
    my $self = shift;

    my $pkey = shift;

    my $done = "set_paper_$pkey";

    return if $self->done_exists($done);

    $self->pkey($pkey);

    $self->pap_allfiles_clear;

    $self->pap_allfiles( glob( catfile( $self->texroot, "p.$pkey.*.tex" ) ) );

    $self->pap_allfiles_push( catfile( $self->texroot, "p.$pkey.tex" ) );

    # make sure other papers' data is removed
    foreach my $k ( $self->done_keys ) {
        next unless ( $k =~ /^set_paper_/ );

        $self->done( $k => 0 );
    }
    $self->done( $done => 1 );

}

sub _make() {
    my $self = shift;

    my $t = shift;

    if ( grep { /^$t$/ } $self->tex_papers ) {
        $self->_tex_paper_make("$t");
    }
    elsif ( $self->_part_exists("$t") ) {
        $self->_part_make("$t");
    }
    else {
        system("make $t");
    }

}

# _tex_paper_make() {{{

sub _tex_paper_make() {
    my $self = shift;

    my $pkey = shift;

    $self->_tex_paper_set($pkey);

    my $cmd = '';

    $cmd .= "export TEXDOCSTYLE=" . $self->docstyle . "; ";

    #$cmd.="export BIBSTYLE=apsrev ; " ;
    $cmd .= "make $pkey";

    $self->out("Generating PDF file from LaTeX sources...\n");

    $self->_tex_paper_conf_create($pkey);

    $self->_tex_paper_cbib2cite($pkey);

    # generate p.PKEY.eqs.tex
    $self->_tex_paper_gen_file('eqs');

    #convert pics
    $self->_tex_paper_convert_ppics();

    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
      IPC::Cmd::run( command => $cmd, verbose => 1 );

    my (@lines) = split( "\n", join( " ", @$full_buf ) );

    my $log_file = "make.$pkey.log";

    open L, ">$log_file";
    foreach my $line (@lines) {
        print L "$line\n";
    }
    close L;

    unless ($success) {
        print "Failure. Look  $log_file for details.\n";
    }
    else {
        print "Success. Look  $log_file for details.\n";
    }

}

# }}}
# _tex_paper_cbib2cite() {{{

sub _tex_paper_cbib2cite() {
    my $self = shift;

    my $pkey = shift;
    $self->pkey($pkey);

    $self->_tex_paper_get_secfiles();

    my @done_cbib2cite = readarr( $self->files("done_cbib2cite") );

    if ( grep { /^$pkey$/ } @done_cbib2cite ) {
        return 0;
    }

    foreach my $secfile ( $self->papsecfiles ) {

        #my $newsecfile = '_cbibr_cite_' . basename($secfile);
        my $newsecfile = $secfile;
        $self->out("Processing file: $secfile\n");
        my @plines = read_file $secfile;

        foreach my $line (@plines) {
            chomp($line);
            next if ( $line =~ /^%\\(cbibr|cbibm|cbib)/ );
            $line = $self->line_cbib2cite($line);
            $line = $self->line_cbibr_to_cite($line);
            $line = $self->line_cbibm_to_cite($line);
        }    # end for-loop over @plines
        write_file( $newsecfile, join( "\n", @plines ) );
    }    # end for-loop over $self->papsecfiles

    append_file( $self->files("done_cbib2cite"), $pkey . "\n" );

}

# }}}
# _tex_paper_tex_nice() {{{

=head3 _tex_paper_tex_nice()

=cut

##TODO texnice
sub _tex_paper_tex_nice() {
    my $self = shift;

    my $pkey = shift // $self->pkey;

    my $iopts = shift // {
        TEXNICE_OPTS    => '',
        NICE_ISECS_ONLY => [],
        NICE_FILE       => '',
    };

    my $cpack = 'Config::' . $pkey;

    $self->pkey($pkey);

    $self->_tex_paper_load_conf($pkey);

    my @evs;

    push( @evs, '$' . $cpack . '::TEXNICE_OPTS=$iopts->{TEXNICE_OPTS}' );
    push( @evs, '$' . $cpack . '::NICE_FILE=$iopts->{NICE_FILE}' );
    push( @evs,
        '@' . $cpack . '::NICE_ISECS_ONLY=@{$iopts->{NICE_ISECS_ONLY}}' );

    push( @evs, $cpack . '::init_vars;' );

    eval( join( ";\n", @evs ) );
    die $@ if $@;

    $self->out("Trying to run tex_nice_local()... \n");
    my $subname = '&' . $cpack . '::tex_nice_local';

    my $SubExists;
    eval '$SubExists=exists ' . $subname;

    die $@ if $@;

    if ($SubExists) {
        eval( $subname . '()' );
        die $@ if $@;
    }

}

# }}}
# _tex_paper_list_refs() {{{

sub _tex_paper_list_refs() {
    my $self = shift;

    my $pkey = shift // $self->pkey;

    my $refs  = $self->paperrefs_h($pkey);
    my $order = $self->paperrefs_h_order($pkey);

    print $_ . " " . $refs->{$_} . " " . "\n" for (@$order);

}

sub _tex_paper_list_eqs() {
    my $self = shift;

    my $pkey = shift // $self->pkey;

    my $refs  = $self->papereqs_h($pkey);
    my $order = $self->papereqs_h_order($pkey);

    print $_ . " " . $refs->{$_} . " " . "\n" for (@$order);

}

# }}}
# _tex_paper_is_compiled() {{{

sub _tex_paper_is_compiled() {
    my $self = shift;

    my $pkey = shift;

    return 1 if ( grep { /^$pkey$/ } $self->compiled_tex_papers );
    return 0;
}

# }}}
# _tex_paper_write_conf() {{{

sub _tex_paper_write_conf() {
    my $self = shift;

    my $pkey = shift // '';

    my $cfile = "p.$pkey.conf.pl";

    $self->_tex_paper_load_conf($pkey);

    open( C, ">$cfile" ) || die $!;

    print C "package Config::$pkey;"
      . "\n" x 2
      . "use strict;" . "\n"
      . "use warnings;" . "\n";

    close(C);
}

# }}}
# _tex_paper_gen_secsdat() {{{

sub _tex_paper_gen_secsdat() {
    my $self = shift;

    my $pkey = shift // '';

    my $fmain    = catfile( $self->texroot, "p.$pkey.tex" );
    my $fsecsdat = catfile( $self->texroot, "p.$pkey.secs.i.dat" );

    my $secdata = {};

    open( F,    "<$fmain" )    || die $!;
    open( FDAT, ">$fsecsdat" ) || die $!;

    # read in p.PKEY.tex
    while (<F>) {
        chomp;
        /^\s*\\iii{\s*(?<seckey>\w+)\s*}\s*%(?<sectitle>.*)/ && do {
            $secdata->{ $+{seckey} } .= $+{sectitle};
            next;
        };
    }

    # write out p.*.secs.i.dat
    foreach my $seckey ( sort keys %$secdata ) {
        my $val = $secdata->{$seckey};
        $val =~ s/^\s*(.*?)\s*$/$1/g;
        print FDAT $seckey . ' ' . $val . "\n";
    }
    close(F);
    close(FDAT);

}

# }}}
# _tex_paper_gen_refsdat() {{{

sub _tex_paper_gen_refsdat() {
    my $self = shift;

    my $pkey = shift // '';

    my $frefs    = catfile( $self->texroot, "p.$pkey.refs.tex" );
    my $frefsdat = catfile( $self->texroot, "p.$pkey.refs.i.dat" );

    my $prefs;

    open( F,    "<$frefs" )    || die $!;
    open( FDAT, ">$frefsdat" ) || die $!;

    # read in p.*.refs.tex
    while (<F>) {
        chomp;
        /^\\pbib{(?<num>\d+)}{(?<pkey>\w+)}/ && do {
            $prefs->{ $+{num} } .= ' ' . $+{pkey};
            next;
        };
    }

    # write out p.*.refs.i.dat
    foreach my $num ( sort { $a <=> $b } keys %$prefs ) {
        print FDAT $num . ' ' . $prefs->{$num} . "\n";
    }
    close(F);
    close(FDAT);

}

sub _tex_paper_gen_eqsdat() {
    my $self = shift;

    my $pkey = shift // $self->pkey;
    my %eqdesc;

    $self->pkey($pkey);

    $self->_tex_paper_load_conf($pkey);

    $self->_tex_paper_get_secfiles();

    my $sec;

    # identifies which equations belong to which sections
    my %eqsec;

    my %labeq;

    foreach my $file ( $self->papsecfiles ) {

        if ( $file =~ /sec\.(?<sec>\w+)\.i\.tex$/ ) {
            $sec = $+{sec};
        }
        else {
            next;
        }

        $self->say( "Processing section: " . $sec );

        my @lines = read_file $file;

        my $eqnum = undef;
        my $label;

        foreach (@lines) {
            chomp;

            /^\s*\\labeleq\{(?<lab>.*)\}/ && do {
                $label = $+{lab};
            };

            /^%%equation\s+(eq_|)(?<eqnum>[\w\.]+)/ && do {
                $eqnum          = $+{eqnum};
                $eqdesc{$eqnum} = '';
                $labeq{$eqnum}  = $label;
            };
            /^%%eqdesc\s+(?<eqdesc>.*)/ && do {
                $eqdesc{$eqnum} = $+{eqdesc};
                push( @{ $eqsec{$sec} }, $eqnum );
              }
        }
    }

    my $fdat = catfile( $self->texroot, "p.$pkey.eqs.i.dat" );
    open( FDAT, ">$fdat" ) || die $!;

    my $delim = "#" . "=" x 20 . "\n";

    foreach my $sec ( $self->secorder ) {
        next unless defined $eqsec{$sec};

        print FDAT $delim;
        print FDAT "sec_$sec" . "\n";
        print FDAT $delim;
        foreach my $eqnum ( @{ $eqsec{$sec} } ) {
            print FDAT $labeq{$eqnum} . " " . $eqdesc{$eqnum} . "\n";
        }
    }
    close(FDAT);

}

# }}}

sub _tex_paper_sep() {
    my $self = shift;

    my $sectype = shift // '';

    my $pkey = shift // $self->pkey;
    $self->pkey($pkey);

    $self->_tex_paper_load_conf($pkey);

    unless ( grep { /^$sectype$/ } qw( eqs refs figs ) ) {
        $self->say("Unsupported sectype");
        return 0;
    }

    $self->_tex_paper_get_secfiles();

    foreach my $file ( $self->papsecfiles ) {
        $self->say( "Processing section file: " . $file );

        my @lines = read_file $file;

        # insideeq=1 if we are inside equation environment, otherwise 0
        # starteq=1 if we match begin{equation}, otherwise 0
        # endeq=1 if we match end{equation}, otherwise 0
        my ( $insideeq, $starteq, $endeq, $label );

        # for tags
        my ($eqtag);

        # This will temporarily contain the contents of a single equation
        my (@eqlines);

        # name of the current eq.*.tex file
        my $eqfile = '';

        $insideeq = 0;
        $starteq  = 0;
        $endeq    = 0;

        foreach (@lines) {
            chomp;

            unless ($insideeq) {
                @eqlines = ();
            }

            /^\s*\\begin{(equation|align)}/
              && do { $insideeq = 1; $starteq = 1; };
            /^\s*\\end{(equation|align)}/  && do { $endeq = 1; };
            /^\s*\\labeleq{(?<label>\d+)}/ && do { $label = $+{label}; };

            /^%%equation\s+(?<eqtag>.*)/ && do {
                $eqtag = "$+{eqtag}";
                append_file( $eqfile, "$_" . "\n" ) if -e $eqfile;
                $self->paptageqlabels( $label => $eqtag );
                $label = '';
                next;
            };

            if ($insideeq) {
                push( @eqlines, $_ );
            }

            # Immediately after we passed after the closing line
            #   of the equation environment, write the recorded contents
            #   to the corresponding *.eq.*.tex file
            if ($endeq) {
                $insideeq = 0;
                if ($label) {
                    $eqfile = catfile( $self->texroot,
                        'p.' . $pkey . '.eq.' . $label . '.tex' );

                    #unless(-e $eqfile){
                    #}
                    $self->say( "Writing equation file for label: " . $label );
                    write_file( $eqfile, join( "\n", @eqlines ) . "\n" );
                    $self->papeqnums_push($label);
                }
            }

            $starteq = 0;
            $endeq   = 0;

        }
    }

    $self->papeqnums_uniq();

    #$self->paptageqlabels_print();

    $self->papeqfiles(
        glob( catfile( $self->texroot, "p." . $self->pkey . ".eq.*.tex" ) ) );

    my $s = Text::Generate::TeX->new();

    $self->pdfeqfile(
        catfile( $self->texroot, 'p.' . $self->pkey . '.pdfeqs.tex' ) );

    $s->input( "p." . $self->pkey . ".pdf.preamble" );
    $s->begin("document");
    $s->nc( 'pn', $self->pkey );

    $s->input( "p." . $self->pkey . ".nc" );
    $s->input("toc.i");

    $s->section('Equations');
    $s->bookmark( level => 1, dest => 'start', title => 'Equations' );
    $s->hypertarget('start');

    #$s->_add_line('\begin{longtable}{|p{8cm}|p{8cm}|}');

    $self->papeqnums_sort('num');

    foreach my $eqnum ( $self->papeqnums ) {
        if ( $self->paptageqlabels_exists("$eqnum") ) {
            $s->_add_line( '%% ' . $self->paptageqlabels("$eqnum") );
        }

        $s->clearpage;
        $s->subsection("$eqnum");

        my $picname = 'eq' . $eqnum;
        my $picfile =
          catfile( $self->texroot, 'ppics', $self->pkey, $picname . '.eps' );

        if ( -e $picfile ) {
            $s->figure(
                pdir     => catfile( 'ppics', $self->pkey ),
                files    => [ 'eq' . $eqnum ],
                width    => '15cm',
                position => 'ht',
            );
        }

        $s->_add_line( '  \ienv{eq}{' . $eqnum . '}' );
        $s->_c_delim;
    }

    #$s->_add_line('\end{longtable}');

    $s->end("document");

    $s->_print( { file => $self->pdfeqfile, fmode => 'w' } );

}

# _tex_paper_gen_file() {{{

sub _tex_paper_gen_file() {
    my $self = shift;

    my $ThisSubName = ( caller(0) )[3];

    my $sectype = shift // '';
    my $pkey    = shift // $self->pkey;

    $self->_tex_paper_load_conf($pkey);

    unless ( grep { /^$sectype$/ } qw( eqs refs figs tabs ) ) {
        $self->say("Unsupported sectype");
        return 0;
    }

    $self->_tex_paper_get_secfiles();

    # Refs info stored in the Perl conf file will
    #   have priority over the TeX refs-file (if it exists)

    my $evs = '';

    $evs .= 'return 1 unless ( $self->paper' . $sectype . '_h );';
    $evs .=
        'return 1 unless ( defined $self->paper'
      . $sectype
      . '_h_exists("$pkey") );';

    eval("$evs");
    die $@ if $@;

    my $secfile = "p.$pkey.$sectype.tex";

    open( R, ">$secfile" ) || die $!;

    print R '\sec' . $sectype . "\n\n";

    for ($sectype) {
###papgenrefs
        /^refs$/ && do {

            my $refs = $self->paperrefs_h($pkey);
            my @nums = sort { $a <=> $b } keys %$refs;

            foreach my $n (@nums) {
                my @refkeys = split( " ", $refs->{$n} );
                foreach my $rkey (@refkeys) {
                    print R "\\pbib{$n}{$rkey}\n";
                }
            }
            next;

        };
###papgenfigs
        /^(eqs|figs|tabs)$/ && do {
            my ( $sechash, @nums, $horder );

            $horder  = [];
            $sechash = {};

            my $evs = ''
              . '$sechash = $self->paper'
              . $sectype
              . '_h("$pkey") // {}' . ";\n"
              . '$horder = $self->paper'
              . $sectype
              . '_h_order("$pkey") // []' . ";\n";

            #. '@nums = sort { $a <=> $b } keys %$sechash;'         . ";\n";
            #. '@nums = sort { $a <=> $b } keys %$sechash;'         . ";\n";

            eval("$evs");
            die $@ if $@;

            next unless @$horder;

            @nums = @{$horder};

            foreach my $n (@nums) {

                # Equation/figure title
                my $sectitle = $sechash->{$n};
                if ( ( $sectitle =~ m/<\+\+>/ ) && ( $sectype eq "eqs" ) ) {
                    next;
                }

                for ($sectype) {
                    /^eqs$/ && do {

                        if ( $n =~ /^sec_(?<sec>\w+)/ ) {
                            my $stitle;
                            if ( $self->papsecs_exists("$+{sec}") ) {
                                $stitle = $self->papsecs("$+{sec}");
                            }
                            else {
                                $stitle = $+{sec};
                            }
                            print R '\bmksec{'
                              . $+{sec} . '}{'
                              . $stitle . '}' . "\n";
                            next;
                        }
                        print R '\bmkeq{' . $n . '}{' . $sectitle . '}' . "\n";
                        next;
                    };
                    /^(figs|tabs)$/ && do {

                        # figs => fig, tabs => tab
                        ( my $sstype = $sectype ) =~ s/s$//g;

                        unless ( $sectitle =~ m/<\+\+>/ ) {
                            print R '% ' . $sectitle . "\n";
                            print R '\ienv{' . $sstype . '}{' . $n . '}' . "\n";
                        }

                        my $figfile = catfile( $self->texroot,
                            join( '.', qw(p), $pkey, $sstype, $n, qw(tex) ) );

                        if ( ( $sstype eq "fig" ) ) {
                            my $s = Text::Generate::TeX->new;

                            if ( !-e $figfile ) {
                                my $sz = "12cm";

                                $s->_add_line("\\figp{$sz}{$n}[$sectitle]{%");
                                $s->_add_line(" $sectitle");
                                $s->_add_line("}%");

                                $s->_print( { file => $figfile } );

                            }
                        }
                        elsif ( $sstype eq "tab" ) {
                            my $s = Text::Generate::TeX->new;
                            use LaTeX::Table;

                            # file with tabular data
                            ( my $datfile = $figfile ) =~ s/\.tex/.i.dat/g;

                            print "$datfile\n";

                            if ( -e $datfile ) {
                                my $ref = {
                                    datfile => $datfile,
                                    caption => $sectitle,
                                    label   => $n,
                                };

                                my $theme = '';

                          #eval '$theme=$self->VARS("LaTeX_Table_theme") // ""';

                                $ref->{table_theme} = $theme if $theme;

                                my $tabtex = $self->_tex_paper_tabdat2tex($ref);

                                $s->_c_delim;
                                $s->_c('Generated by LaTeX::Table');
                                $s->_c( 'Outer subroutine: ' . $ThisSubName );
                                $s->_c( 'Date: ' . localtime );
                                $s->_c( 'Table theme: ' . $theme );
                                $s->_c_delim;
                                $s->clearpage;
                                $s->_add_line("$tabtex");
                                $s->_c_delim;

                                $s->_print( { file => $figfile } );

                                edit_file_lines {
                                    s/\\label/\\labeltab/g;
                                }
                                $figfile;
                            }
                            elsif ( !-e $figfile ) {

                                $s->begin( 'table', { optvars => 'ht' } );
                                $s->begin('center');
                                $s->begin( 'tabular', { vars => [qw(ccc)] } );
                                $s->end('tabular');
                                $s->end('center');
                                $s->end('table');

                                $s->_print( { file => $figfile } );
###papgentabs
                            }
                        }

                        next;
                    };
                }
            }

            next;

        };
    }

    close(R);
}

# }}}

###gen_secdata
sub _tex_paper_gen_secdata {
    my $self = shift;

    my $allfiles = shift // $self->pap_allfiles;
    my $isecs;
    my %secnums;

    foreach my $file (@$allfiles) {
        my @lines = read_file $file;
        foreach (@lines) {
            chomp;
            next if /^\s*%/;

            /^\\i(par|sec|subsec|subsubsec)\{(?<isec>\w+)\}/ && do {
                my $isec = $+{isec};
                push( @$isecs, $isec );
                if ( $isec =~ /^([\d_]+)/ ) {
                    my $secn = $1;
                    $secn =~ s/_/\./g;
                    $secn =~ s/\.$//g;
                    $secnums{$secn} = $isec;
                }
            };
        }

    }
    my $t = Text::Table->new;
    my @d;
    while ( my ( $k, $v ) = each %{secnums} ) {
        push( @d, [ $k, $v ] );
    }
    $t->load(@d);
    my $secdat = catfile( $self->texroot, 'secdata.' . $self->pkey );
    write_file( $secdat, $t . "\n" );

}

# _tex_paper_tabdat2tex {{{

sub _tex_paper_tabdat2tex {
    my $self = shift;

    my $ref = shift // {};

    my ( $CAPTION, $LABEL );
    my ( $caption, $label );

    my $datfile = $ref->{datfile};

    $caption = $ref->{caption} // '';
    $label   = $ref->{label}   // '';

    my @lines = read_file $datfile;

    my $lnum = 0;
    my ( $header, $data );

    my $SEP = '';
    my $FW;

    my ( $NCOLS, $NROWS );

    my ($firstrow);

    $LABEL   = $label;
    $CAPTION = $caption;

    $firstrow = 1;

    # separator positions for each row
    my @STARTPOS;

    my @d = ();

    my $ROW      = 0;
    my @COLWIDTH = qw( );

    foreach my $line (@lines) {
        chomp($line);
        next if ( $line =~ /^\s*#/ );

        #VimMsg($line, {prefix => 'none '});

        if ( $line =~ /^(?<FW>\w+)\s*$/ ) {
            $FW = $+{FW};

            if ( $FW eq "ROW" ) {
                $firstrow = 1;
                for (@d) {
                    s/\s*$//g;
                    s/^\s*//g;
                }
                push( @$data, [@d] );
                @d = ();
                $ROW++;
            }
            else {
                for ($FW) {
                    /^(CAPTION|LABEL)$/ && do {
                        my @evs;
                        push( @evs, '$' . $FW . "=''" );

                        eval( join( ";\n", @evs ) );
                        die $@ if $@;

                        next;
                    };
                }
            }

            next;
        }

        $line =~ s/\s*$//g;

        for ($FW) {
###tabdat2tex_SEP
            /^SEP$/ && do {
                $SEP .= $line;
                $SEP =~ s/\s*//g;
                next;
            };
###tabdat2tex_HEADER
            /^HEADER$/ && do {
                my @h = split( /\s*$SEP\s*/, $line );
                $NCOLS = scalar(@h);
                $header = [ [@h] ];
                next;
            };
###tabdat2tex_CAPTION
            /^CAPTION$/ && do {
                $line =~ s/^\s*//g;
                $CAPTION .= ' ' . $line;
                next;
            };
###tabdat2tex_LABEL
            /^LABEL$/ && do {
                $line =~ s/^\s*//g;
                $LABEL .= $line;
                next;
            };
###tabdat2tex_COLWIDTH
            /^COLWIDTH$/ && do {
                $line =~ s/^\s*//g;
                @COLWIDTH = split( ' ', $line );
                next;
            };

###tabdat2tex_ROW
            /^ROW$/ && do {

                # find column numbers for each column separator
                if ($firstrow) {

                    #VimMsg("LINE: $line");

                    @STARTPOS = (0);

                    while ( $line =~ m/($SEP)/g ) {
                        push( @STARTPOS, pos $line );
                    }
                    @d = split( /\s*$SEP\s*/, $line );
                    $firstrow = 0;
                }
                else {
                    my $i = 0;

                    my @startpos = @STARTPOS;

                    while (@startpos) {
                        my $spos = shift @startpos;
                        my ( $epos, $lencol, $cell );

                        if (@startpos) {

                            $epos   = $startpos[0] - length($SEP);
                            $lencol = $epos - $spos + 1;

                        }
                        else {

                            $lencol = length($line);
                        }

                        $cell = substr( $line, $spos, $lencol );
                        $d[$i] .= $cell;

                  #VimMsg("i: $i; spos: $spos; lencol: $lencol; cell: $cell " );

                        $i++;
                    }
                }
                next;
            };
        }

        $lnum++;
    }
    push( @$data, [@d] );
    $ROW++;

    #return#;
    #open(F,">>aa") || die $!;

    #print F '=========' . "\n";
    #print F $LABEL . "\n";
    #print F '=========' . "\n";
    #print F Dumper($data);
    #close(F);

    my $table = LaTeX::Table->new(
        caption     => "$CAPTION",
        caption_top => 'topcaption',
        label       => "$LABEL",
        data        => $data,
        header      => $header,
        type        => 'xtab',
        callback    => sub {
            my ( $row, $col, $value, $is_header ) = @_;

            unless ($is_header) {
                if ( $label eq "2-2" ) {
                    if ( $col == 0 ) {
                        $value = '\verb|' . $value . '|';
                    }
                }
                elsif ( $label eq "2-3" ) {
                    $value =~ s/->/\$\\rightarrow\$/g;
                }
            }

            return $value;
        }
    );

    my $theme = $ref->{table_theme} // '';

    $table->set_theme($theme) if $theme;

    #$table->set_width('0.75\textwidth');
    $NCOLS--;

    if (@COLWIDTH) {
        $table->set_coldef( '|p{' . join( '}|p{', @COLWIDTH ) . '}|' );
    }

    my $string = $table->generate_string();

    return $string;

}

# }}}

sub catroot {
    my $self = shift;

    return catfile( $self->texroot, @_ );

}

###_gen_make_pdf_tex_
sub _gen_make_pdf_tex_mk {
    my $self = shift;

    my $mk = catfile( $self->texroot, 'make_pdf_tex.mk' );

    my @flines;
    my @mkopts;

    require OP::Perl::Installer;
    require OP::PERL::PMINST;

    my $i = OP::Perl::Installer->new;
    $i->main_no_getopt;

    my $pminst = OP::PERL::PMINST->new;

###gen_make_perlmods
   my @needed_mods = qw( OP::PaperConf OP::PAPERS::MKPDF );
	my %modpaths_installed;

	foreach my $module (@needed_mods) {
		my @ipaths = $i->module_full_installed_paths($module);
		$modpaths_installed{$module} = \@ipaths;

	}
    my @req_imods;

	for my $ipaths ( @modpaths_installed{@needed_mods} ) {
		push( @req_imods, @$ipaths );
	}

    my $varsdat = $self->files('vars');

    push( @mkopts, '--skip_run_tex' );
    push( @mkopts, '--skip_tex_nice' );
    push( @mkopts, '--skip_make_bibt' );
    push( @mkopts, '--skip_make_cbib' );

    my $rbi = '@local_module_install.pl ';

    my @write_tex_ids = qw(preamble titpage start);

###make_dat
		my @prereq;
		foreach my $id (qw(list_tex_papers list_bibkeys)) {
				given($id){
					when('list_bibkeys') { push(@prereq,qw( repdoc.bib )); }
					default { }
				}
        push( @flines, "$id.i.dat: " . join(' ',@prereq) );
        push( @flines, "\t" . 'perl _gendat_' . $id . '.pl' );

        push( @flines, ' ' );
		}

###_gen_make_pdf_tex_LOOP
    foreach my $p ( $self->tex_papers ) {
        my $first_prereq;
        my @prereq;

        my @prereq_pdf = ();

        my $pdftex  = "p.$p.pdf.tex";
        my $pdfname = "p.$p.pdf.tex";
        my $pdf     = "p.$p.pdf.pdf";

        my $p_figsdat = "p.$p.figs.i.dat";
        my $p_figstex = "p.$p.figs.tex";

        my $p_tabsdat = "p.$p.tabs.i.dat";
        my $p_tabstex = "p.$p.tabs.tex";

        my $p_refsdat = "p.$p.refs.i.dat";
        my $p_refstex = "p.$p.refs.tex";
        my $p_refs    = "$p_refsdat $p_refstex";

        my $p_cbib = "p.$p.cbib.tex";
        my $p_bibt = "bibt.$p.tex";

###make_p_PKEY_refs_dat
        push( @flines, "$p_refsdat : " );
        push( @flines, "\t" . '@if [ ! -e $@ ]; then ' . "\\" );
        push( @flines, "\t" . ' touch $@; ' . "\\" );
        push( @flines, "\t" . 'fi; ' );

        push( @flines, ' ' );
###make_p_PKEY_refs_tex
        push( @flines, "$p_refstex : $p_refsdat " );
        push( @flines, "\t" . 'pshcmd genrefs ' . $p );

        push( @flines, ' ' );

###make_p_PKEY_figs_dat
        push( @flines, "$p_figsdat : " );
        push( @flines, "\t" . '@if [ ! -e $@ ]; then ' . "\\" );
        push( @flines, "\t" . ' touch $@; ' . "\\" );
        push( @flines, "\t" . 'fi; ' );

        push( @flines, ' ' );

###make_p_PKEY_figs_tex
        push( @flines, "$p_figstex : $p_figsdat " );
        push( @flines, "\t" . 'pshcmd genfigs ' . $p );

        push( @flines, ' ' );
###make_p_PKEY_tabs_dat
        push( @flines, "$p_tabsdat : " );
        push( @flines, "\t" . '@if [ ! -e $@ ]; then ' . "\\" );
        push( @flines, "\t" . ' touch $@; ' . "\\" );
        push( @flines, "\t" . 'fi; ' );

        push( @flines, ' ' );
###make_p_PKEY_tabs_tex
        push( @flines, "$p_tabstex : $p_tabsdat " );
        push( @flines, "\t" . 'pshcmd gentabs ' . $p );

        push( @flines, ' ' );

###make_p_PKEY_tex
        my @prereq_p_tex;
        push( @prereq_p_tex, "p.$p.secorder.i.dat" );

        push( @flines, "p.$p.tex: " . shift(@prereq_p_tex) . " \\" );
        push( @flines, " " . join( " \\\n", @req_imods ) ) if @req_imods;

        push( @flines,
            "\t" . '@mk_pap_pdf.pl --pkey  ' . $p . ' --only_write_tex_main' );

        push( @flines, ' ' );

###make_p_PKEY_pdf_preamble_tex
        foreach my $id (@write_tex_ids) {

            my @prereq_pdf_preamble = ();
            my $dir_docstyle = $self->catroot( qw(docstyles), $self->docstyle );

            push( @prereq_pdf_preamble, @req_imods ) if @req_imods;
            push( @prereq_pdf_preamble,
                catfile( $dir_docstyle, 'usedpacks.i.dat' ) );
            push( @prereq_pdf_preamble,
                catfile( $dir_docstyle, 'packopts.i.dat' ) );
            push( @prereq_pdf_preamble,
                catfile( $dir_docstyle, 'dclass.i.dat' ) );
            push( @prereq_pdf_preamble, 'vars.i.dat' );

            push( @flines, "p.$p.pdf.$id.tex: " . " \\" );
            push( @flines, " " . join( " \\\n", @prereq_pdf_preamble ) );

            push( @flines,
                    "\t"
                  . '@mk_pap_pdf.pl --pkey  '
                  . $p
                  . ' --only_write_tex_'
                  . $id );

            push( @flines, ' ' );
        }

###make_p_PKEY_pdf_tex
        my @prereq_pdf_tex = ();
        my @d;

        @d = glob( $self->catroot("p.$p.*.tex") );

        # do not include PKEY.pdf.*.tex files
        @d = map { /\.pdf(|\.(\w*))\.tex$/ ? () : $_ } @d;

        # do not include PKEY.cbib.tex files
        @d = map { /\.cbib\.tex$/ ? () : $_ } @d;

        # do not include p.PKEY.tex file
        @d = map { /p\.$p\.tex$/ ? () : $_ } @d;

        # leave only section files
        @d = map { /\.sec\.(\w+)\.i\.tex$/ ? $_ : () } @d;

        # include the conf.pl file
        push( @prereq_pdf_tex, "p.$p.conf.pl" );

        push( @prereq_pdf_tex, @d );

        @prereq_pdf_tex = uniq( sort(@prereq_pdf_tex) );

        $first_prereq = shift(@prereq_pdf_tex) // '';

        push( @flines, "p.$p.pdf.tex: " . $first_prereq . " \\" );

        push( @flines, " " . join( ' ', @req_imods ) . "\\" ) if @req_imods;
        my $sp = " " x 10;
        s/^/\t/g for (@prereq_pdf_tex);
        my $depss = join( "  " . "\\\n", @prereq_pdf_tex );
        push( @flines, $depss );

        push( @flines, "\t" . '$(eval pkey := $(patsubst p.%.pdf.tex,%,$@))' );
        push( @flines, "\t" . '@echo_green "make> Paper key: $(pkey)"' );
        push( @flines,
                "\t"
              . '@mk_pap_pdf.pl --pkey  '
              . $p . ' '
              . join( ' ', @mkopts ) );

        push( @flines, ' ' );

### target: PKEY
###make_p_PKEY_pdf_pdf
        push( @prereq_pdf, glob( $self->catroot("p.$p.*.tex") ) );
        push( @prereq_pdf, glob("pdf.*.tex") );

        foreach my $id (@write_tex_ids) {
            push( @prereq_pdf, $self->catroot("p.$p.pdf.$id.tex") );
        }

        @prereq_pdf = uniq( sort(@prereq_pdf) );

        push( @flines, "$p: $pdf" );
        push( @flines, ' ' );
        push( @flines, "$pdf : $p_cbib $pdftex \\" );
        push( @flines, " " . join( " \\\n", @prereq_pdf ) );

        #push( @flines, "\t" . '@mk_pap_pdf.pl --pkey ' . $p . ' --nonstop ');
        push( @flines, "\t" . '@LATEXMK -f -pdf ' . $pdfname );

        push( @flines, ' ' );

###make_bibt_PKEY_tex
        my @prereq_bibt;

        push( @prereq_bibt, @req_imods ) if @req_imods;
        push( @prereq_bibt, "$varsdat" );

        push( @flines, "$p_bibt : \\" );
        push( @flines, " " . join( " \\\n", @prereq_bibt ) );
        push( @flines,
            "\t" . '@mk_pap_pdf.pl --pkey ' . $p . ' --only_make_bibt' );

        push( @flines, ' ' );

        push( @flines, ' ' );

###make_p_PKEY_cbib_tex
        my @prereq_cbib_tex;

        push( @prereq_cbib_tex, $varsdat );
        push( @prereq_cbib_tex, $p_refs );
        push( @prereq_cbib_tex, @req_imods ) if @req_imods;

        push( @flines, "$p_cbib : \\" );
        push( @flines, " " . join( " \\\n", @prereq_cbib_tex ) );
        push( @flines,
            "\t" . '@mk_pap_pdf.pl --pkey ' . $p . ' --only_make_cbib' );

        push( @flines, ' ' );

        push( @flines, ' ' );

    }

    write_file( $mk, join( "\n", @flines ) . "\n" );

}

# _tex_paper_latex_parse() {{{

sub _tex_paper_latex_parse() {
    my $self = shift;

    my $pkey = shift // '';

    return 1 unless $pkey;

    my $parser = LaTeX::TOM->new();

    my $f = "p.$pkey.pdf.tex";

    #my $doc=$parser->parseFile($f)->getFirstNode;
    #my $doc=$parser->parseFile($f);

    #print Dumper($doc);
    #$doc->print;
}

# }}}
# _tex_paper_latexml() {{{

sub _tex_paper_latexml() {
    my $self = shift;

    my $pkey = shift // '';

    return 1 unless $pkey;

    #$self->sysrun()
}

# }}}
# _tex_paper_hermes() {{{

sub _tex_paper_hermes() {
    my $self = shift;

    my $pkey = shift // '';

    return 1 unless $pkey;

    # Hermes variables
    my $hermesdir = "/home/op/arch/unpacked/hermes-0.9.12";
    my $hermes    = "$hermesdir/hermes";
    my $seed      = "$hermesdir/seed";

    # Paper PDF filename
    my $fname = "p.$pkey.pdf";

    my $seed_tex = "$fname.s.tex";
    my $seed_dvi = "$fname.s.dvi";
    my $xml_lib  = "_hermes.$fname.s.lib.xml";
    my $xml_pub  = "_hermes.$fname.s.pub.xml";

    #my $perltex="\"" . "perltex --nosafe" . "\"";
    my $perltex = "perltex --nosafe";
    my $bibtex  = "bibtex";

    $self->sysrun("$seed $fname.tex");

    #$self->sysrun("cp $fname.tex $seed_tex");

    #$self->sysrun("$perltex $seed_tex");
    #$self->sysrun("$bibtex $seed_tex");
    #$self->sysrun("$perltex $seed_tex");
    #$self->sysrun("$perltex $seed_tex");
    $self->sysrun("ltm --perltex --dvi $seed_tex");

    $self->sysrun("hermes $seed_dvi > $xml_lib");
    $self->sysrun("xsltproc ./inc/xslt/pub.xslt $xml_lib > $xml_pub");

    #$self->sysrun("xmlto html $xml_pub");

    #$self->sysrun("latexmk -dvi -latex=$perltex $seed_tex");

}

# }}}
# _tex_paper_tralics() {{{

sub _tex_paper_tralics() {
    my $self = shift;

    my $pkey = shift // '';

    return 1 unless $pkey;

    my $f = "p.$pkey.pdf.tex";

    $self->sysrun("tralics $f");
}

# }}}
# _tex_paper_load_conf_short() {{{

sub _tex_paper_load_conf_short() {
    my $self = shift;

    my $skey = shift // '';
    my $lkey = $self->_long_key($skey);

    $self->_tex_paper_load_conf($lkey);
}

# }}}
# _tex_paper_load_conf() {{{

###load_conf

sub _tex_paper_load_conf() {
    my $self = shift;

    my $pkey = shift // $self->pkey;

    my $done = "load_conf_$pkey";

    return if $self->done_exists($done);

    $self->pkey($pkey) if $pkey;
    $self->say( "Paper key reset to: " . $pkey );

    my $cnf = catfile( $self->texroot, "p.$pkey.conf.pl" );
    my $pack = "Config::$pkey";

    $pack =~ s/-/_/g;

    unless ( -e $cnf ) {
        $self->_tex_paper_conf_create($pkey);
    }

    $self->out("Loading configuration file for paper: $pkey\n");
    require "$cnf";

    foreach my $id (
        qw( config
        refs_h
        eqs_h
        figs_h
        tabs_h
        refs_h_order
        eqs_h_order
        figs_h_order
        tabs_h_order
        viewfiles
        )
      )
    {

        my $idref = '$' . $pack . '::' . $id;
        my $iddef = eval "( defined $idref ) ? 1 : 0;";
        my $evalstring =
          '$self->paper' . $id . '(' . $pkey . ' => ' . $idref . ');';
        $iddef && eval $evalstring;
        die $@ if $@;

    }

    $self->done( "$done" => 1 );

}

# }}}
# _tex_paper_conf_remove() {{{

sub _tex_paper_conf_remove() {
    my $self = shift;

    my $pkey = shift // '';
    my $cnf = "p.$pkey.conf.pl";

    File::Path::remove_tree($cnf) if ( -e $cnf );
}

# }}}
# _tex_paper_conf_exists() {{{

sub _tex_paper_conf_exists() {
    my $self = shift;

    my $pkey = shift // '';
    my $cnf = "p.$pkey.conf.pl";

    return 1 if ( -e $cnf );
    return 0;
}

# }}}
# _tex_paper_conf_create() {{{

sub _tex_paper_conf_create() {
    my $self = shift;

    my $pkey = shift // '';

    my $tem = "paper_conf_template.pl";
    my $cnf = "p.$pkey.conf.pl";

    return 1 if ( -e "$cnf" );

    $self->out("Creating Perl configuration file for: $pkey\n");

    File::Copy::copy( "$tem", "$cnf" );
    if ( -e $cnf ) {
        File::Slurp::edit_file {
            s/__PKEY__/$pkey/g;
        }
        $cnf;
    }

}

# }}}
# _tex_paper_view_short() {{{

sub _tex_paper_view_short() {
    my $self = shift;

    # Short key
    my $skey = shift // '';

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

    return 1 unless $lkey;

    $self->_tex_paper_view("$lkey");
}

# }}}

sub _tex_paper_get_figs() {
    my $self = shift;

}

# _tex_paper_get_secfiles() {{{

sub _tex_paper_get_secfiles() {
    my $self = shift;

    my $done = "get_secfiles_" . $self->pkey;

    return if $self->done_exists($done);

    $self->say("Filling array accessor: papsecfiles");

    $self->papsecfiles(
        glob( catfile( $self->texroot, "p." . $self->pkey . ".sec.*.i.tex" ) )
    );

    $self->say("Filling hash accessor: papsecs");

    my %oldsecs = ();

    foreach my $secfile ( $self->papsecfiles ) {
        my @lines = read_file $secfile;

        my $title   = '';
        my $secname = '';

        # Done with getting the section id and title?
        my $got = 0;

        # Will need to rewrite the original section file?
        my $rewrite = 0;

        $secname = $+{sec} if ( $secfile =~ /sec\.(?<sec>\w+)\.i\.tex$/ );
        next unless $secname;
        $self->say( "Current section : " . $secname );

        foreach (@lines) {
            chomp;
            if (/^\\isec\{(?<sec>\w+)\}\{(?<title>.*)\}/) {
                $secname = $+{sec};
                $title   = $+{title};
                $got     = 1;
            }
            elsif (/^\\(section|subsection)\{(?<title>.*)\}/) {
                $got     = 1;
                $title   = $+{title};
                $rewrite = 1;
            }

            last if $got;
        }

        $self->say( "   Section title : " . $title );

        next unless $secname;
        next unless $title;

        $self->papsecs( "$secname" => "$title" );

        $self->say( "   Section file : " . $secfile );

        my $count  = 0;
        my $oldsec = '';
        if ($rewrite) {
            $self->say("  Rewriting section file... ");
###rewrite_sections
            my @lines = read_file $secfile;
            foreach (@lines) {
                chomp;

                s/^\s*\\clearpage//g unless $count;
                if ( $count == 1 ) {
                    if (/^\s*\\labelsec{(?<lsec>\w+)}/) {
                        $_ = '';
                        unless ( "$+{lsec}" == "$secname" ) {
                            $oldsecs{$oldsec} = $secname;
                        }
                    }
                }
                if (/^\s*\\(section|subsection|subsubsection)/) {

                    #$_ = "\\isec{$secname}{$title}" unless $count;
                    $count++;
                }
            }
            write_file( $secfile, join( "\n", @lines ) . "\n" );
        }
    }

    if (%oldsecs) {
        $self->say("   Replacing old sections: ");

        foreach my $secfile ( $self->papsecfiles ) {
            foreach my $osec ( keys %oldsecs ) {
                my $newsec = $oldsecs{$osec};
                $self->say("  Old: $osec; New: $newsec");
                edit_file_lines {
                    s/\\refsec{$osec}/$newsec/g;
                }
                $secfile;
            }
        }
    }

    $self->say(
        "   Trying to generate secorder.i.dat file from the main paper file... "
    );

    my $sofile =
      catfile( $self->texroot, "p." . $self->pkey . ".secorder.i.dat" );
    my $mfile = catfile( $self->texroot, "p." . $self->pkey . ".tex" );
    my @mlines = read_file $mfile;
    my @secorder;

    foreach (@mlines) {
        chomp;
        next if /^\s*%/;
        next if /^\s*$/;
        push( @secorder, $+{sec} ) if /^\s*\\iii{(?<sec>\w+)}/;
    }
    unless ( -e $sofile ) {
        if (@secorder) {
            $self->say("Secorder array is non-zero, writing it to file...");
            write_file( $sofile, join( "\n", @secorder ) );
            $self->secorder(@secorder);
        }
        else {
            $self->warn("No secorder file was generated");
        }
    }

    $self->done_exists( $done => 1 );

}

# }}}
# _tex_paper_renames() {{{

sub _tex_paper_renames() {
    my $self = shift;

    my $pkey = shift // '';

    $self->sysrun("bash renames.sh $pkey");
}

# }}}
# _tex_paper_view() {{{

sub _tex_paper_view() {
    my $self = shift;

    my $pkey  = shift // '';
    my $vopts = shift // '';

    return unless $pkey;

    my @ptexfiles;

    $self->_tex_paper_load_conf("$pkey");

    my $viewfiles = $self->paperviewfiles($pkey) // '';

    unless ($viewfiles) {
        foreach my $piece ( $self->viewtexfiles ) {
            push( @ptexfiles, "p.$pkey.$piece.tex" );
        }
        push( @ptexfiles, glob("p.$pkey.*.i.tex") );
    }
    else {
        if ( defined $viewfiles->{secs} ) {
            for my $sec ( @{ $viewfiles->{secs} } ) {
                my $secfile = "p.$pkey.sec.$sec.i.tex";
                push( @ptexfiles, $secfile );
            }
        }
        if ( defined $viewfiles->{texpieces} ) {
            for my $piece ( @{ $viewfiles->{texpieces} } ) {
                my $piecefile = "p.$pkey.$piece.tex";
                push( @ptexfiles, $piecefile );
            }
        }
    }

    push( @ptexfiles, "p.$pkey.tex" );
    push( @ptexfiles, "p.$pkey.conf.pl" );

    print $_ . "\n" for (@ptexfiles);

    my $view_cmd;

    #foreach my $file (@ptexfiles) {
    #}
    $view_cmd = $self->viewtexcmd . " $vopts @ptexfiles";
    $self->sysrun($view_cmd);

}

# }}}
# _tex_paper_make_short() {{{

sub _tex_paper_make_short() {
    my $self = shift;

    # Short key
    my $skey = shift;

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

    return 1 unless $lkey;

    $self->_tex_paper_make("$lkey");
}

# }}}

# }}}
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
    my $skey = shift // '';

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

    return 1 unless $lkey;

    $self->_compiled_tex_paper_view("$lkey");
}

# }}}
# _compiled_tex_paper_view() {{{

sub _compiled_tex_paper_view() {
    my $self = shift;

    my $ref = shift // '';
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
# _part_* _parts_* {{{

# _part_exists() {{{

sub _part_exists() {
    my $self = shift;

    my $part = shift // '';

    unless ($part) { return 0 }

    ( grep { /^$part$/ } $self->all_parts ) ? 1 : 0;
}

# }}}
# _part_make_generate_tex() {{{

sub _part_make_generate_tex() {
    my $self = shift;

    my $part = shift;
    $self->part($part);

    my $itex = $self->part_make_opts("main_tex_file");

###_PART_MAKE_READ_PAPERS
    my ( $paps, $usedpacks, $packopts );

    # This sets the part_paps hash accessor
    $self->_part_read_paps($part);

    # This sets the pap_usedpacks hash accessor
    $self->_part_read_usedpacks($part);

    # This sets the pap_packopts hash accessor
    $self->_part_read_packopts($part);

    $paps      = $self->part_paps($part);
    $usedpacks = $self->pap_usedpacks($part);
    $packopts  = $self->pap_packopts($part);

    my $s = Text::Generate::TeX->new();
    $s->texroot( $self->texroot );

###_PART_MAKE_PREAMBLE
    # Generate the preamble
    my $ncfiles = [qw( nc pap-nc pdf.nc preamble.tocloft )];
    push( @$ncfiles, qw( nc.perltex ) ) if $self->_package_is_used('perltex');

    $s->preamble(
        {
            dclass         => [qw( report 12pt a4paper dvips)],
            usedpacks      => $self->pap_usedpacks($part),
            packopts       => $self->pap_packopts($part),
            doctitle       => "Papers for part: $part",
            makeindex      => 1,
            put_today_date => 1,
            shift_parname  => 1,
            hypsetup       => {
                pdfauthor => 'op',
                pdftitle  => "Part: $part"
            },
            ncfiles => $ncfiles,
            dims    => {
                textwidth      => '15cm',
                textheight     => '23cm',
                textheight     => '23cm',
                marginparwidth => '3cm',
                oddsidemargin  => '0.5cm',
                topmargin      => '-1cm'
            }
        }
    );

    ## Push common (for the whole part file)
    ##  newcommands-files
    foreach (@$ncfiles) {
        s/$/\.tex/g;
        $self->part_build_files_push($_);
    }

    $self->part_build_files_push("pap-nc.0.tex");

    $self->part_build_files_push(qw( cbibm.pl cbibr.pl ));

    foreach my $x (qw( BO base bf colors const env graphics math ref s vars )) {
        $self->part_build_files_push("nc.$x.tex");
    }

###_PART_MAKE_HDR
    $s->_c_delim;
    $s->_c("Fancyhdr customization");
    $s->_c_delim;

    $s->_add_line("\\pagestyle{fancy}");
    my $hdrstyle = qq|

    %========== bottom ===

    \\lhead{\\LHEAD}%

    \\chead{\\thepage}
    \\rhead{\\bfseries PAPERS: $part}
    %========== head =====

    \\lfoot{\\LFOOT}
    \\rfoot{\\RFOOT}

    \\cfoot{\\thepage}
    %=====================
    \\renewcommand{\\headrulewidth}{0.4pt}
    \\renewcommand{\\footrulewidth}{0.4pt}
  |;
    $s->_add_line("$hdrstyle");
    $s->_c_delim;

    $s->_add_line('\papsinglefalse');

###_PART_MAKE_NC_INPUT
    # New-commands files

###_PART_MAKE_DOCUMENT
    # Generate the document body
    $s->begin("document");

    # Title
    $s->_add_line("\\maketitle");

    # Table of Contents
    $s->toc;

    $s->_add_line("\\let\\ptype=\\ptypepaps");

    $s->_c_delim;
    $s->_c("Needed for fancy hdr options");
    $s->_add_line("\\def\\ptype{paps}");
    $s->_c_delim;

    $s->_add_line("\\part{Papers}");

    # Input the source for all papers
    # together with any new commands defined
    # specifically for each paper
###_PART_MAKE_LOOP_PKEYS
    foreach my $pkey (@$paps) {
        $self->pkey($pkey);

        #$self->_tex_paper_cbib2cite($pkey);

        my $cbib = "p.$pkey.cbib.tex";

###_PART_MAKE_CBIB
        unless ( -e $cbib ) {
            $self->sysrun("cbib.pl --pkey $pkey --wcbib");
        }

        $s->_c("Paper-specific new command definitions");
        $s->input( "p.$pkey.nc.tex", { check_exists => 1 } );

        $self->part_build_files_push("p.$pkey.nc.tex");

        $s->_c("Definitions for the \\cbib* commands");
        $s->input( "$cbib", { check_exists => 1 } );

        $self->part_build_files_push("$cbib");

        my $psource = "p.$pkey.tex";

        # Load the paper's configuration
        $self->_tex_paper_load_conf($pkey);
        my $config = $self->paperconfig($pkey);

        $s->_c_delim;
        $s->_c("Mandatory new commands for paper: $pkey");
        $s->_c_delim;
        $s->_c("  pn - LaTeX variable for paper key");
        $s->_c_delim;
        $s->nc( "pn", $pkey );
        $s->_c_delim;
        $s->idef("secfigs");
        $s->_c_delim;

        # --------------------- PAPER TITLE
        $s->_c("  ptitle - title of the paper for the given paper key");
        my $ptitle        = $self->bibtex->entries_pkey("$pkey")->get("title");
        my $allowedlength = 30;
        if ( length($ptitle) > $allowedlength ) {
            $ptitle = substr( $ptitle, 0, $allowedlength ) . "\\ \\ldots";
        }
        $s->nc( "ptitle", $ptitle );
        $s->_c_delim;

        # --------------------- PAPER AUTHORS
        $s->_c("  pauthors - authors of the paper for the given paper key");
        my $pauthors = $self->bibtex->entries_pkey("$pkey")->get("author");
        if ( length($pauthors) > $allowedlength ) {
            $pauthors = substr( $pauthors, 0, $allowedlength ) . "\\ \\ldots";
        }

        $s->nc( "pauthors", $pauthors );

        $s->nc( "LHEAD", '\pauthors' );
        $s->nc( "LFOOT", '\pn' );
        $s->nc( "RFOOT", '\ptitle' );

        $s->_c_delim;

        # -----------------------------------
        #$s->_add_line('\nc{\igb}[2]{\includegraphics[width=#1]{#2}}');
        $s->_add_line( '\nc{\igp}[2]{\igb{#1}{'
              . $self->texroot
              . '/ppics/'
              . $pkey
              . '/fig#2}}' );
        $s->_c_delim;

        # Include the title page
        $self->_tex_paper_write_title_page($pkey);
        $s->input( "p.$pkey.titpage.tex", { check_exists => 1 } );

        $self->part_build_files_push("p.$pkey.titpage.tex");
        $self->part_build_files_push("p.$pkey.abs.tex");

        # Input figs-, tabs- LaTeX include parts
        my $itexparts = $config->{include_tex_parts};

        foreach my $ipart (@$itexparts) {
            my $if = "p.$pkey.$ipart.tex";
            $s->input( "$if", { check_exists => 1 } );
            $self->part_build_files_push("$if");
        }

        # Source LaTeX text in the *.i.tex files
        foreach my $if ( glob("p.$pkey.*.i.tex") ) {
            $self->part_build_files_push("$if");
        }

        $s->_c_delim;
###_PART_MAKE_INPUT_LATEX_SOURCE
        # Now follows the raw LaTeX text from
        # the p.PKEY.tex file
        $s->_c("Contents for paper: $pkey");
        $s->_c_delim;
        my @lines = File::Slurp::read_file $psource, chomp => 1;
        foreach (@lines) {
            next if /^\s*\\ssec{$pkey}/;
            my $line = $_;
            $s->_add_line("$line");
        }
        $s->_c_delim;
        $s->_c("End of contents for paper: $pkey");
        $s->_c_delim;
    }

    foreach ( $self->part ) {
        /^blnpull$/ && do {
            $s->_insert_file("pap-blnpull.conf.tex");
            $s->_insert_file("pap-blnpull.eqs.tex");
            next;
        };
    }

###_PART_MAKE_AUXILIARY
    $s->part("Auxiliary");

    $s->_add_line("\\def\\LHEAD{List of Figures}%");
    $s->_add_line("\\def\\LFOOT{List of Figures}%");
    $s->_add_line("\\def\\RFOOT{}%");

    # List of Figures
    $s->lof;

    foreach my $pkey (@$paps) {

      #$s->bookmark(dest  => $pkey . '-figs', level  => 2, title  =>  "$pkey" );
        $s->bookmark( dest => $pkey . '-lof', level => 2, title => "$pkey" );
    }
    $s->input( "pap_part_" . $part . ".lof" );

    $s->_add_line("\\def\\LHEAD{List of Tables}%");
    $s->_add_line("\\def\\LFOOT{List of Tables}%");
    $s->_add_line("\\def\\RFOOT{}%");

    # List of Tables
    $s->lot;

###_PART_MAKE_BIBLIOGRAPHY

    $s->_c("Needed for fancy hdr options");
    $s->_add_line("\\def\\LHEAD{Bibliography}%");
    $s->_add_line("\\def\\LFOOT{Bibliography}%");
    $s->_add_line("\\def\\RFOOT{}%");

    #$s->_add_line("\\def\\ptype\\ptypebib");
    $s->_c_delim;

    $s->bibliography(
        {
            hypertarget => 'bib',
            title       => 'Bibliography',
            bibstyle    => $self->bibstyle,

            #bibstyle    => 'alpha',
            inputs   => 'jnames',
            bibfiles => 'repdoc',
            sec      => 'chapter'
        }
    );

###_PART_MAKE_PRINT_INDEX

    $s->_c("Needed for fancy hdr options");
    $s->_add_line("\\def\\LHEAD{Index}%");
    $s->_add_line("\\def\\LFOOT{Index}%");
    $s->_add_line("\\def\\RFOOT{}%");
    $s->_c_delim;

    $s->printindex();

    $s->end("document");

###_PART_MAKE_PRINT_TEX_CODE
    $self->out("Printing the generated LaTeX code\n");
    $self->out("  to output file:\n");
    $self->out( " " . $self->part_make_opts("main_tex_file") . "\n" );

###_PART_MAKE_CHANGE_TO_BUILD_DIR
    chdir $self->workdir;
    $self->out( "Changed to working directory:\n " . $self->workdir . "\n" );

    $s->_print(
        {
            file  => $self->part_make_opts("main_tex_file"),
            fmode => 'w'
        }
    );

###_PART_MAKE_COPY_BUILD_FILES
    if ( $self->tex_tmpdir ) {
        $self->out("Copying build files to temporary dir...\n");
        foreach my $f ( $self->part_build_files ) {
            if ( -e $f ) {
                File::Copy::copy( "$f", $self->tex_tmpdir );
            }
        }
    }

}    # end _part_make_generate_tex()

# }}}
# _part_make_set_opts() {{{

sub _part_make_set_opts() {
    my $self = shift;

    my $part = $self->part;

###_PART_MAKE_OPTS
    my $opts = {
        main_tex_file        => catfile( $self->texroot, "pap_part_$part.tex" ),
        output_file          => catfile( $self->pdfout,  "pap.$part.pdf" ),
        output_file_format   => "pdf",
        tex_driver_formatter => 'latex'
    };

    $self->part_make_opts($opts);

    $self->workdir( $self->texroot );

}

# }}}
# _part_make_tmpdir() {{{

sub _part_make_tmpdir() {
    my $self = shift;

    my $part = shift // $self->part // '';

    if ( $self->compiletex_opts("use_tmpdir") ) {
        $self->out("Will use temporary directory for LaTeX builds.\n");
        $self->tex_tmpdir(
            catfile( $self->texroot, '_builds', '_parts', $part ) );

        remove_tree( $self->tex_tmpdir ) if ( -e -d $self->tex_tmpdir );

        make_path( $self->tex_tmpdir );
        $self->workdir( $self->tex_tmpdir );
        $self->out( "Temporary dir created:\n" . $self->tex_tmpdir . "\n" );
    }

}

# }}}
# _part_make() {{{

=head3 _part_make()

=cut

###_PART_MAKE
sub _part_make() {
    my $self = shift;

    my $part = shift // '';

    $self->part($part);

    my @starttime = localtime;

    $self->_part_make_set_opts();

    my $itex = $self->part_make_opts("main_tex_file");

    unless ($part) {
        $self->out("_part_make(): no part specified!\n");
        return 1;
    }

    $self->_part_make_tmpdir();
    #
    $self->part_build_files_push("pap.tex");

    # Check whether the specified input part exists
    unless ( $self->_part_exists($part) ) {
        $self->out("The input part is not defined!\n");
        return 0;
    }

    $self->_part_make_generate_tex($part);

###_PART_MAKE_EXPAND_CBIB

###_PART_MAKE_COMPILE
    foreach ( $self->texdriver ) {

        my $tdrv = $self->texdriver;

        $self->out("LaTeX driver option used: $_\n");
###_PART_MAKE_COMPILE_USE_LTM
        /^ltm$/ && do {

            # {{{
            $self->out("Cleaning any LaTeX intermediate files...\n");
            $self->sysrun("ltm c");
            $self->out("Removing generated PDF, PS and dvi files...\n");
            $self->sysrun("rm -rf *.pdf *.dvi *.ps");

            $self->sysrun("ltm pap");

            next;

            # }}}
        };
###_PART_MAKE_COMPILE_USE_NLTM
        /^nltm$/ && do {

            #$self->_part_tex_clean($part);

            # Adjust the TEXINPUTS environment variable
            # ( where latex searches for input files )
            my $txi = $ENV{TEXINPUTS} // '';
            $ENV{TEXINPUTS} = ".:" . $self->texroot . ":$txi";

            my $bibi = $ENV{BIBINPUTS} // '';
            $ENV{BIBINPUTS} = ".:" . $self->texroot . ":$bibi";

            if ( $self->compiletex_opts("nonstopmode") ) {
                prepend_file( $itex, '\nonstopmode' . "\n" );
            }

            my $dvips  = 'dvips ' . $self->dvips_opts;
            my $ps2pdf = 'ps2pdf ' . $self->ps2pdf_opts;

            # latex and bibtex runs
            do {
                my $f = "pap_part_$part";

                my ( $lf, $idx, $latex, $bibtex );

                # Changing listof-files
                # *.lof (list-of-figures)
                # *.lot (list-of-tables)
                # etc.
                $lf = '';
                foreach my $type ( $self->listof_types ) {
                    my $ext = $self->listof_exts($type);
                    my $if  = "pap_part_$part.$ext";

                    #next unless -e $if;

                    $lf .=
                        'listof_change.pl --infile '
                      . $if
                      . ' --rw --type '
                      . $type . ' ; ';
                }

###_PART_MAKEINDEX
                # Changing the *.idx index file
                $idx = "";
                $idx .= "idx_ins_hpage.pl --infile $f.idx --rw; ";
                if ( $self->makeindexstyle ) {
                    $idx .=
                      " makeindex -s " . $self->makeindexstyle . " $f.idx; ";
                }
                else {
                    $idx .= " makeindex $f.idx; ";
                }

                #$idx.="  ind_style.pl $f.ind ";

                $latex = "perllatex $f; $lf  $idx ";
                $latex .= "ind_insert_bookmarks.pl $f.ind";

                $bibtex = "bibtex $f";

                $self->sysrun("$latex");

                # Run bibtex
                $self->sysrun("$bibtex");

                foreach my $i ( ( 1 .. $self->nlatexruns ) ) {
                    $self->sysrun("$latex");

                    # body...
                }

                # PS/PDF handling via dvips, ps2pdf etc.
                $self->sysrun("$dvips $f");
                $self->sysrun("$ps2pdf $f.ps");

                goto _END_PART_MAKE;

            };

            next;
        };
###_USE_OP_TEX_DRIVER
        /^optexdriver$/ && do {
            my $drv = OP::TEX::Driver->new(
                source => $self->part_make_opts("main_tex_file"),

                #output  => catfile($self->texroot,'pap.pdf'),
                #format  => $opts->{output_file_format},
                format    => 'pdf',
                formatter => $self->part_make_opts("tex_driver_formatter"),
                DEBUG     => 1
            );

            $self->out("Running the OP::TEX::Driver LaTeX driver...\n");

            my $ok = $drv->run();

            if ($ok) {
                $self->out("Success!\n");

                #$self->sysrun("dvips -Ppdf pap.dvi");
                #$self->sysrun("ps2pdf pap.ps");
                File::Copy::copy( "pap.pdf",
                    $self->part_make_opts("output_file") );
            }
            else {
                $self->out("Failure.\n");
            }

            my $stats = $drv->stats;
            print Dumper($stats);
            $drv->cleanup('tempfiles');
            $self->_tex_clean();

            next;
        };
###_USE_LATEXMK
        /^latexmk$/ && do {
            $self->out(
                "Cleaning any LaTeX intermediate files + PS,PDF,DVI files...\n"
            );
            $self->sysrun( $self->LATEXMK . " -C" );

            my $cmd =
                $self->LATEXMK
              . " -latex=perllatex "
              . " -interaction=nonstopmode " . " pap";
            $self->sysrun("$cmd");
            next;
        };
    }

  _END_PART_MAKE:

    my $pdf = catfile( $self->workdir, "pap_part_$part.pdf" );
    if ( -e $pdf ) {
        $self->out("Copying $pdf to the output directory...\n");
        File::Copy::copy( "$pdf", $self->part_make_opts("output_file") );
    }

    chdir $self->texroot;

    my @endtime = localtime;
    my @ttime;

    for ( my $i = 0 ; $i < 2 ; $i++ ) {
        $ttime[$i] = $endtime[$i] - $starttime[$i];
    }

    my $secs = $ttime[0] % 60;
    my $mins = $ttime[1];

    $self->say(
        "Total time elapsed: " . $mins . " (mins) " . $secs . " (secs) " );

}

# }}}

# _part_read_usedpacks($) {{{

=head3 _part_read_usedpacks()

=cut

sub _part_read_usedpacks($) {
    my $self = shift;

    my $part = shift // '';

    # Read in the list of used packages
    $self->out(
        "_part_read_usedpacks(): Reading in the list of used packages...\n");

    my $usedpacks = &readarr("pap.usedpacks.i.dat") // '';
    die
      "_part_make(): (part: $part) Failed to read in the list of used packages "
      unless $usedpacks;

    $self->pap_usedpacks( $part => $usedpacks );

}

# }}}
# _part_read_packopts($) {{{

sub _part_read_packopts($) {
    my $self = shift;

    my $part = shift // '';

    # Read in the list of package options
    $self->out( "_part_read_packopts(): Reading in the "
          . "list of used package options...\n" );

    # Read in the list of package options
    my $packopts = &readhash("pap.packopts.i.dat") // '';

    die
      "_part_make(): (part: $part) Failed to read in the package options file "
      unless $packopts;

    $self->pap_packopts( $part => $packopts );

}

# }}}
# _part_tex_clean() {{{

sub _part_tex_clean() {
    my $self = shift;

    my $part = shift;

    $self->out( "Cleaning any LaTeX intermediate files"
          . " in the current directory for part: $part...\n" );

    foreach my $ext ( $self->nltm_cleanfiles ) {
        foreach my $f ( glob("pap_part_$part.$ext") ) {
            remove_tree($f);
        }
    }

}

# }}}
# _part_pdf_remote_copy() {{{

sub _part_pdf_remote_copy() {
    my $self = shift;

    my $part = shift // '';

    unless ($part) { return 0 }

    $self->sysrun( "rsync -avz "
          . $self->remotehost
          . ":~/wrk/p/out/pap."
          . $part . ".pdf "
          . "~/pdfout/" );
}

# }}}
# _part_read_paps() {{{

sub _part_read_paps() {
    my $self = shift;

    my $part = shift // '';

    #$self->out("_part_read_paps(): read in the list of papers...\n");

    # Read in list of papers for the specified part
    my $paps = &readarr("pap.paps.$part.i.dat") // '';
    die "_part_make(): (part: $part) Failed to read in the list of papers "
      unless $paps;

    $self->part_paps( $part => $paps );
}

# }}}
# _part_view_pdf() {{{

=head3 _part_view_pdf()

=cut

sub _part_view_pdf() {
    my $self = shift;

    my $part = shift;

    my $files_to_view = [];
    my $files         = [];

    push( @$files, catfile( $self->pdfout, "pap.$part.pdf" ) );
    for my $f (@$files) { push( @$files_to_view, $f ) if ( -e $f ); }

    unless (@$files_to_view) {
        $self->out("No PDF files exist for the input part: $part\n");
        return 1;
    }

    $self->_view( files => $files_to_view, viewer => "evince" );
}

# }}}
# _part_view_tex() {{{

=head3 _part_view_tex()

=cut

sub _part_view_tex() {
    my $self = shift;

    my $part = shift // '';

    my $files_to_view = [];

    my $files = [];

    push( @$files, "paps.$part" ) if $part;
    push( @$files, qw(parts) );

    foreach my $f (@$files) {
        $f = "pap." . $f . ".i.dat";
    }

    push( @$files, 'pap-blnpull.conf.tex' );
    push( @$files, 'pap-blnpull.eqs.tex' );

    foreach my $f (@$files) {
        $f = catfile( $self->texroot, $f );
    }

    for my $f (@$files) { push( @$files_to_view, $f ) if ( -e $f ); }

    return 1 unless @$files_to_view;

    $self->_view( files => $files_to_view );
}

# }}}
# _parts_list() {{{

sub _parts_list() {
    my $self = shift;

    print "$_\n" for ( $self->all_parts );
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

    my $re = qr/\s*\s*(?<cites>[\d, ]+)\s*}/;

    if (@pieces) {
        foreach my $piece (@pieces) {
            if ( $piece =~ m/$re/ ) {
                my $cite_str = $self->cbibm_get_cite_str( $+{cites} );
                my $cbibm    = '\cbibm{' . $+{cites} . '}';
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

    my $re = qr/\s*\s*(?<num>\d+)\s*}/;

    if (@pieces) {
        foreach my $piece (@pieces) {
            if ( $piece =~ m/$re/ ) {
                my $cite_str = `cbib.pl --pkey $pkey --N $+{num}`;
                my $cbib     = '\cbib{' . $+{num} . '}';
                $piece = $cite_str . substr( $piece, $+[0] );
            }
        }
        $line = join( '', $startline, @pieces );
    }

    return $line;

}

# line_cbibr_to_cite() {{{

sub line_cbibr_to_cite() {
    my $self = shift;

    my $re = qr/\s*\s*(?<min>\d+)\s*}\s*{\s*(?<max>\d+)\s*}/;

    my $line      = shift;
    my @pieces    = split( /\\cbibr\s*{/, $line );
    my $startline = shift @pieces;

    if (@pieces) {
        foreach my $piece (@pieces) {
            if ( $piece =~ m/$re/ ) {
                my $cite_str = $self->cbibr_get_cite_str( $+{min}, $+{max} );
                my $cbibr = '\cbibr{' . $+{min} . '}{' . $+{max} . '}';
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
    my $skey = shift // '';

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
    my $skey = shift // '';

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

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

    my $lkey = $self->plongkeys($skey) // '';

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

    my $package = shift // '';

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
# list_accessors () {{{

sub list_accessors () {
    my $self = shift;

    open( LESS, "| less" ) || die $!;

    print LESS "-" x 50 . "\n";
    print LESS "List of defined accessors in psh.pl" . "\n";

    foreach my $id (qw(scalar hash array)) {
        my @columns;
        my $value;

        if ( $id =~ /^scalar$/ ) {
            @columns = qw( Name Value Description );
        }
        else {
            @columns = qw( Name Description );
        }

        print LESS "-" x 50 . "\n";
        print LESS "$id accessors: \n\n";

        my $table = Text::TabularDisplay->new(@columns);

        for my $acc ( @{ $self->accessors($id) } ) {
            my $accvar = $id . "_$acc";

            my @row;
            push( @row, $acc );

            if ( $id =~ /^scalar$/ ) {
                eval '$value=$self->' . $acc;
                die $@ if $@;
                my $width = 30;
                if ( length($value) > $width ) {
                    $value = substr( $value, 0, $width ) . ' ...';
                }
                push( @row, $value );
            }

            if ( $self->accdesc_exists("$accvar") ) {
                push( @row, $self->accdesc("$accvar") );
            }
            else {
                push( @row, " " );
            }

            $table->add(@row);

        }

        print LESS $table->render;
    }

    close(LESS);

}

# }}}
# list_compiled() {{{

sub list_compiled() {
    my $self = shift;

    my $ref = shift;

    foreach ($ref) {
        /^pdf_papers$/ && do {
            print "$_\n" for ( $self->compiled_tex_papers );
            next;
        };
        /^pdf_parts$/ && do {
            print "$_\n" for ( $self->compiled_parts );
            next;
        };

    }
}

# }}}
# list_fig_tex () {{{

=head3 list_fig_tex () 

=cut

sub list_fig_tex() {
    my $self = shift;

    my @files = glob("p.*.fig.*.tex");

    foreach my $f (@files) {
        print "$f\n";
    }

}

# }}}
# list_partpaps() {{{

sub list_partpaps() {
    my $self = shift;

    my $part = shift // $self->part;
    $self->part($part);

    $self->_part_read_paps($part);
    print "$_" . "\n" for ( @{ $self->part_paps($part) } );
}

# }}}
# list_vars() {{{

sub list_vars() {
    my $self = shift;

    #foreach my $id (qw( hash array scalar )) {
    #foreach my $x ($self->) {
    ## body...
    #}
    #}

}

# }}}
# list_scripts() {{{

sub list_scripts() {
    my $self = shift;

    my $mode = shift // '';

    $self->scripts(qw());

    opendir( D, $self->texroot ) || die $!;
    while ( my $file = readdir(D) ) {
        $file = basename($file);
        $file =~ s/^\.\///g;
        next if -d $file;
        if ( $file =~ /^(\w+)$/ ) {
            $self->scripts_push($1);
        }
    }
    closedir(D);

    $self->scripts_sort();
    $self->scripts_uniq();

    unless ($mode) {
        $self->scripts_print();
        return 1;
    }

    foreach ($mode) {
        /^less$/ && do {
            open( LESS, "| less" ) || die $!;
            $self->scripts_print( \*LESS );
            close(LESS);
            next;
          }
    }

}

# }}}
# sysrun() {{{

=head3 sysrun()

=cut

sub sysrun() {
    my $self = shift;

    my $cmd = shift // '';
    my %opts = (
        verbose => 1,
        driver  => 'IPC::Cmd'
    );

    while (@_) {
        my $key = shift;
        my $val = shift // '';

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
# Completions {{{

# _complete_papers()        {{{

=head3 _complete_papers()

=cut

sub _complete_papers() {
    my $self = shift;

    my $type = shift;
    my $cmpl = shift;

    my ( @comps, @pkeys, $ref );

    if ( grep { /^$type$/ } qw( original_pdf tex bib short_tex ) ) {
        eval '@pkeys=$self->' . "$type" . "_papers";
        die $@ if $@;
    }

    if ( $cmpl->{str} ) {

        my $str = lc $cmpl->{str};
        my @arr = ();

        foreach my $pkey (@pkeys) {
            if ( lc($pkey) =~ /^\s*$str/i ) {
                push( @arr, $pkey );
            }
        }
        $ref = \@arr;
    }
    else {
        $ref = \@pkeys;
    }

    return $ref;

}

#                     }}}
# _complete_cmd() {{{

=head3 _complete_cmd()

=cut

sub _complete_cmd() {
    my $self = shift;

    my $ref_cmds = shift // '';

    return [] unless $ref_cmds;

    my @comps = ();
    my $ref;

    return 1 unless ( ref $ref_cmds eq "ARRAY" );

    while ( my $cmd = shift @$ref_cmds ) {
        foreach ($cmd) {
            /^bt$/ && do {
                push( @comps, qw( lk lak la ) );
                next;
            };

            # List of scalar accessors
            /^scalar_accessors$/ && do {
                push( @comps, @{ $self->accessors('scalar') } );
                next;
            };

            # Specific accessor
            /^scalar_accessor_(?<acc>\w+)$/ && do {
                for ( $+{acc} ) {
                    /^view_cmd_pdf_(generated|original)$/ && do {
                        push( @comps, qw(evince okular) );
                        next;
                    };
                    /^(pkey|tex_papers)$/ && do {
                        push( @comps, $self->tex_papers );
                        next;
                    };

                    /^part$/ && do {
                        push( @comps, $self->all_parts );
                        next;
                    };
                    /^docstyle$/ && do {
                        my @s = $self->docstyles;
                        push( @comps, @s );
                        next;
                    };
                }
                next;
            };

            /^short_tex_papers$/ && do {
                push( @comps, $self->short_tex_papers );
                next;
            };

            # List of makeindex styles
            /^mistyles$/ && do {
                push( @comps, $self->mistyles );
                next;
            };
            /^gitco$/ && do {
                push( @comps, qw(ptex nc isec) );
                next;
            };

            # List of BibTeX keys
            /^(lk|bib_papers)$/ && do {
                push( @comps, $self->bib_papers );
                next;
            };

            # List of parts
            /^lparts$/ && do {
                push( @comps, $self->all_parts );
                next;
            };

            # List of builds
            /^builds$/ && do {
                push( @comps, $self->builds );
                next;
            };

            # make (compile a PDF from LaTeX sources)
            # - both list of TeX papers and list of parts
            # need to be completed
###_complete_cmd_make
            /^make$/ && do {

                #push( @comps, $self->tex_papers );
                push( @comps, $self->MAKETARGETS );
                next;
            };

            # Make PDF part
            /^mpa$/ && do {
                push( @comps, $self->all_parts );
                next;
            };

            # makehtml (generate HTML from LaTeX sources)
            /^makehtml$/ && do {
                push( @comps, $self->all_parts );
                push( @comps, $self->tex_papers );
                next;
            };

        }
    }

    $ref = \@comps if @comps;

    return $ref;
}

# }}}

# }}}
#=================================
# Shell Terminal stuff {{{

# _term_get_commands()  {{{

=head3 _term_get_commands()

=cut

sub _term_get_commands() {
    my $self = shift;

    my $commands = {
        #########################
        # Aliases           {{{
        #########################
        "q"   => { alias => "quit" },
        "h"   => { alias => "help" },
        "m"   => { alias => "make" },
        "tns" => { alias => "texnices" },

        #               }}}
        #########################
        # General purpose        {{{
        #########################
##cmd_quit
        "quit" => {
            desc    => "Quit",
            maxargs => 0,
            method  => sub {
                $self->_term_exit;
                shift->exit_requested(1);
            },
        },
##cmd_help
        "help" => {
            desc => "Print helpful information",
            args => sub { shift->help_args( undef, @_ ); },
            meth => sub {
                $self->termcmd_reset("help @_");
                shift->help_call( undef, @_ );
              }
        },
##cmd_cat
        "cat" => {
            desc => "Use the 'cat' system command"
        },
##cmd_clear
        "clear" => {
            desc => "Use the 'clear' system command",
            proc => sub {
                system("clear");
            },
        },
##cmd_pdf2tex
        "pdf2tex" => {
            desc => "Convert PDF file(s) to LaTeX",
            proc => sub { $self->_pdf2tex(@_); },
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
        },
##cmd_pwd
        "pwd" => {
            desc => "Return the current directory",
            proc => sub {
                $self->termcmd_reset("pwd");
                print rel2abs( curdir() ) . "\n";
              }
        },
        "ui" => {
            desc    => "Update info",
            maxargs => 0,
            proc    => sub {
                $self->termcmd_reset("ui");
                $self->update_info();
            },
        },

        #                 }}}
        #########################
        # List ...       {{{
        #########################
        "lpdf" => {
            desc => "List PDF files of different type",
            cmds => {
                xp => {
                    desc => "List compiled (from LaTeX source) PDF files",
                    proc => sub { $self->list_compiled("pdf_papers"); }
                },
                pa => {
                    desc => "List compiled PDF parts",
                    proc => sub { $self->list_compiled("pdf_parts"); }
                },
                b => {
                    desc    => "List base PDF files (original paper files)",
                    minargs => 0,
                    args    => sub {
                        shift;
                        $self->_complete_papers( "original_pdf", @_ );
                    },
                    proc => sub { $self->list_pdf_papers(@_); }
                }
            }
        },
##cmd_part
        "part" => {
            cmds => {
                gentex => {
                    desc => "Generate pap_part_PART.tex file",
                    args =>
                      sub { shift; $self->_complete_cmd( [qw(lparts)] ); },
                    proc => sub {
                        $self->part(@_);
                        $self->_part_make_set_opts();
                        $self->_part_make_tmpdir();
                        $self->_part_make_generate_tex(@_);
                      }
                },
                runtex => {
                    desc => "Run tex for pap_part_PART.tex file",
                    args =>
                      sub { shift; $self->_complete_cmd( [qw(lparts)] ); },
                    proc => sub {
                        $self->part(@_);
                        $self->_part_make_set_opts();
                        $self->_part_make_tmpdir();
                        $self->_part_make_generate_tex(@_);
                        $self->_tex_paper_run_tex( 'part', @_ );
                      }
                },
            }
        },
##cmd_x
        "x" => {
            desc => "Execute file with psh commands",
        },
##cmd_nwp
        nwp => {
            desc => "Create LaTeX sources for the given bibtex key",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            proc => sub { system("bash nwp @_"); }
        },
##cmd_list
        "list" => {
            cmds => {
                commands => {},
##cmd_list_pdf_papers
                pdfpapers => {
                    desc => "List original PDF papers",
                    proc => sub { $self->original_pdf_papers_print; }
                },
                "refs" => {
                    desc => "List references for the given paper key",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub { $self->_tex_paper_list_refs(@_); }
                },
                "eqs" => {
                    desc => "List equations for the given paper key",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub { $self->_tex_paper_list_eqs(@_); }
                },
##cmd_list_papsecs
                papsecs => {
                    desc =>
                      "List paper section names and ids for the given paper",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub {
                        my $pkey = shift // '';

                        $self->pkey($pkey) if $pkey;
                        $self->_tex_paper_load_conf();
                        $self->_tex_paper_get_secfiles();
                        $self->papsecs_print();
                      }
                },
##cmd_list_papfigs
                papfigs => {
                    desc =>
                      "List paper figure names and ids for the given paper",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub {
                        $self->pkey(shift);
                        $self->_tex_paper_get_figs();
                        $self->papfigs_print();
                      }
                },
##cmd_list_accessors
                accessors => {
                    desc =>
                      "List Class::Accessor::Complex accessors for psh.pl",
                    proc => sub { $self->list_accessors(); }
                },
                bibkeys => {
                    desc => "List BibTeX keys",
                    proc => sub { $self->bibtex->list_keys(); }
                },
                figtex => {
                    desc => "List available p.*.fig.*.tex files ",
                    proc => sub { $self->list_fig_tex(); }
                },
                texpapers => {
                    desc => "List LaTeX source papers",
                    proc => sub { print $_ . "\n" for ( $self->tex_papers ); }
                },
                shorttexpapers => {
                    desc => "List short keys for LaTeX source papers",
                    proc =>
                      sub { print $_ . "\n" for ( $self->short_tex_papers ); }
                },
                compiledtexpapers => {
                    desc => "List compiled PDFs for LaTeX source papers",
                    proc => sub {
                        print $_ . "\n" for ( $self->compiled_tex_papers );
                      }
                },
                compiledparts => {
                    desc => "List compiled PDFs for LaTeX source papers",
                    proc => sub {
                        print $_ . "\n" for ( $self->compiled_parts );
                      }
                },
                parts => {
                    desc => "List parts",
                    proc => sub { $self->_parts_list(); }
                },
##cmd_list_vars
                vars => {
                    desc => "List variables (used by mktex.pl etc. )",

                    #TODO list vars
                    proc => sub { $self->list_vars(); }
                },
##cmd_list_scripts
                scripts => {
                    desc => "List scripts ( in this directory )",
                    proc => sub { $self->list_scripts(); }
                },
##cmd_list_partpaps
                partpaps => {
                    desc => "List paper keys for the given part",
                    args =>
                      sub { shift; $self->_complete_cmd( [qw(lparts)], @_ ); },
                    proc => sub { $self->list_partpaps(@_); }
                  }

            }
        },

        # }}}
        #########################
        # Builds {{{
        build => {
            desc    => "Perform a build",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(builds)], @_ ); },
            proc => sub { $self->_build(@_); },
        },

        # }}}
        #########################
        # View ... {{{
        vrefs => {
            desc    => "View the refs (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_tex_short( "ref", @_ ); },
        },
        vref => {
            desc    => "View the refs",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "ref", @_ ); },
        },
        vcits => {
            desc    => "View the citing papers (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_tex_short( "cit", @_ ); },
        },
        vcit => {
            desc    => "View the citing papers",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "cit", @_ ); },
        },
        vidx => {
            desc    => "View the *.ind, *.idx  files",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "idx", @_ ); },
        },
        vnc => {
            desc => "View the nc files",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "nc", @_ ); }
        },
        vm => {
            desc => "View myself",
            proc => sub { $self->view("vm"); }
        },
        vcnf => {
            desc    => "View the p.PKEY.conf.pl file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "cnf", @_ ); },
        },
        vcnfs => {
            desc    => "View the p.PKEY.conf.pl file (using the short key)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_tex_short( "cnf", @_ ); },
        },
        vref => {
            desc    => "View the p.PKEY.refs.tex file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "ref", @_ ); },
        },
        vbib => {
            desc => "View the bibtex file currently in use",
            proc => sub { $self->view( "bib", @_ ); },
        },
        vxpdf => {
            desc    => "View the p.PKEY.pdf.tex file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "pdf", @_ ); },
        },

        # }}}
        #########################
        # Print ... {{{
        p => {
            desc    => "Print full info for the given pkey",
            proc    => sub { $self->_p(@_); },
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "bib", @_ ); },
        },
        ps => {
            desc    => "Print full info for the given pkey (short)",
            proc    => sub { $self->_p_short(@_); },
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
        },

        # }}}
        #########################
        # Remove ... {{{
        rmcnf => {
            desc    => "Remove Perl configuration file for the given paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_conf_remove(@_); },
        },

        # }}}
        #########################
        # Parts {{{
        #########################
        lparts => {
            desc => "Alias for list parts",
            proc => sub { $self->_parts_list(); }
        },
##cmd_gitco
        gitco => {
            desc => "Run git co -- *",
            proc => sub { $self->_gitco(@_); },
            args => sub { shift; $self->_complete_cmd( [qw( gitco )], @_ ); }
        },
##cmd_vpr
        vpr => {
            desc => "View (edit) the list of papers for a specific part",
            proc => sub { $self->_part_view_tex(@_); },
            args => sub { shift; $self->_complete_cmd( [qw(lparts)], @_ ); }
        },
##cmd_vpap
        vpap => {
            desc =>
              "View the compiled PDF file which corresponds to the given part ",
            minargs => 1,
            proc    => sub { $self->_part_view_pdf(@_); },
            args    => sub { shift; $self->_complete_cmd( [qw(lparts)], @_ ); }
        },

        #           }}}
        #########################
        # PDF (base) paper files      {{{
        #########################
        #"pget" => {
        #desc => "Download PDF files",
        #minargs => 1,
        #args => sub { shift; $self->_complete_papers("pdf",@_); },
        #proc => sub { $self->view_pdf_paper(@_); }
        #},
        "vep" => {
            desc    => "View the PDF file for the corresponding paper key",
            minargs => 1,
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
            proc => sub {
                $self->read_VARS;
                $self->view_pdf_paper(@_);
              }
        },
        "veqs" => {
            desc    => "View the PDF eqs file for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_view_pdfeqs(@_); }
        },
        "veps" => {
            desc    => "View the PDF file given the short key",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_pdf_paper_short(@_); }
        },
        "vepist" => {
            desc    => "vep -i -s SKEY -t",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_vepist(@_); }
        },
        "cnp" => {
            desc =>
              "(bash script) OCR the PDF file and then convert it to DJVU",
            minargs => 1,
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
            proc => sub { $self->_cnp(@_); }
        },
        "lsp" => {
            desc    => "List all PDF papers starting with the given pattern",
            minargs => 0,
            proc    => sub { $self->list_pdf_papers(@_); },
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); }
        },

        #                }}}
        #########################
        # PDF LaTeX files      {{{
        #########################
        rtex => {
            desc => "Run LaTeX single time",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_run_tex( 'pdf', @_ ); }
        },
        splitmain => {
            desc => "Run LaTeX main file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub {
                $self->_tex_paper_splitpiece( 'fig', @_ );
                $self->_tex_paper_splitmain(@_);
              }
        },
        rtexs => {
            desc => "Run LaTeX single time (short form)",
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_run_tex_short(@_); }
        },
        cbib2cite => {
            desc =>
"Convert all cbib/cbibr/cbibm occurences to cite{...} (leaving cbib... inside comments )",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_cbib2cite(@_); }
        },
        latex => {
            desc => "Run LaTeX single time",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_run_latex(@_); }
        },
        latexs => {
            desc => "Run LaTeX single time",
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_run_latex_short(@_); }
        },
        "ctex" => {
            desc => "Clean LaTeX intermediate files",
            proc => sub {
                $self->termcmd_reset("ctex @_");
                $self->_tex_clean(@_);
              }
        },
        "wconf" => {
            desc    => "Write Perl configuration file for the given paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_write_conf(@_); }
        },
        "lconf" => {
            desc    => "Load Perl configuration file for the given paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_load_conf(@_); }
        },
        "pp" => {
            desc    => "LaTeX parsing through LaTeX::TOM parser",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_latex_parse(@_); }
        },
        "latexml" => {
            desc    => "LaTeX parsing through LaTeXML",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_latexml(@_); }
        },
        "hermes" => {
            desc    => "LaTeX parsing through hermes",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_hermes(@_); }
        },
        "tralics" => {
            desc    => "LaTeX parsing through tralics",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_tralics(@_); }
        },
        "htlatex" => {
            desc    => "LaTeX-to-HTML conversion through (customized) htlatex",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_htlatex(@_); }
        },
        "l2h" => {
            desc    => "LaTeX -> HTML conversion",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_latex_2_html(@_); }
        },
        "l2hs" => {
            desc    => "LaTeX -> HTML conversion (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_latex_2_html_short(@_); }
        },
        "lconfs" => {
            desc =>
              "Load Perl configuration file for the given paper key (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_load_conf_short(@_); }
        },
        "renames" => {
            desc => "Perform renames on LaTeX paper source using renames.sh ",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_renames(@_); }
        },
        "setp" => {
            desc    => "Set the given pkey as the current one",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "bib", @_ ); },
            proc => sub { $self->_pkey_set_current(@_); }
        },
        "setps" => {
            desc    => "Set the given pkey as the current one (short key)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_pkey_set_current_short(@_); }
        },
        "genrefs" => {
            desc => "Generate p.PKEY.refs.tex "
              . " file from the Perl configuration file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'refs', @_ ); }
        },
##cmd_geneqs
        "geneqs" => {
            desc => "Generate p.PKEY.eqs.tex "
              . " file from the Perl configuration file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'eqs', @_ ); }
        },
##cmd_gen_make_pdf_tex_mk
        "gen_make_pdf_tex_mk" => {
            desc => "",
            proc => sub { $self->_gen_make_pdf_tex_mk(); }
        },
##cmd_geneqsdat
        "geneqsdat" => {
            desc => "Generate p.PKEY.eqs.dat "
              . " file from the LaTeX paper source files",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_eqsdat(@_); }
        },
        "sepeqs" => {
            desc => "Generate p.PKEY.eq.*.tex "
              . " file from the tex paper sources",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_sep( 'eqs', @_ ); }
        },
        "genfigs" => {
            desc => "Generate p.PKEY.figs.tex "
              . " file from the corresponding .dat file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'figs', @_ ); }
        },
        "gentabs" => {
            desc => "Generate p.PKEY.tabs.tex "
              . " file from the corresponding .dat file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'tabs', @_ ); }
        },
        "genrefsdat" => {
            desc => "Generate p.PKEY.refs.i.dat "
              . " file from the Perl configuration file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_refsdat(@_); }
        },
        "gensecsdat" => {
            desc => "Generate p.PKEY.secs.i.dat "
              . " file from the corresponding LaTeX source file(s)",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_secsdat(@_); }
        },
        "texnice" => {
            desc => "Make TeX files nicer",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_tex_nice(@_); }
        },
        "texnices" => {
            desc    => "Make TeX files nicer (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_tex_nice( $self->_long_key(@_) ); }
        },
        "lrefs" => {
            desc => "List references for the given paper key",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_list_refs(@_); }
        },
        "vp" => {
            desc    => "View the LaTeX files for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_view(@_); }
        },
        "vps" => {
            desc    => "View the LaTeX paper source given its short key",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_view_short(@_); }
        },
        "vxp" => {
            desc    => "View the LaTeX files for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_view( @_, "--remote-tab-silent" ); }
        },
        "vpp" => {
            desc => "View the PDF file (compiled from LaTeX sources)"
              . " for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_compiled_tex_paper_view(@_); }
        },
        "vpps" => {
            desc => "View the PDF file (compiled from LaTeX sources)"
              . " for the corresponding paper key (short form)",
            minargs => 1,
            args =>
              sub { shift; $self->_complete_cmd( [qw(short_tex_papers)], @_ ); }
            ,
            proc => sub {
                $self->read_VARS;
                $self->_compiled_tex_paper_view_short(@_);
              }
        },
##cmd_make
###cmd_make
        "make" => {
            desc => "Compile the LaTeX file for the"
              . " given paper key into a PDF document ",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(make)], @_ ); },
            proc => sub { $self->_make(@_); }
        },
##cmd_mpa
        "mpa" => {
            desc    => "Compile the part PDF file",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(mpa)], @_ ); },
            proc    => sub {
                $self->termcmd_reset("mpa @_");
                $self->_part_make(@_);
              }
        },
##cmd_mpdfeqs
        "mpdfeqs" => {
            desc => "Compile the pdfeqs PDF file",
            args => sub { shift; $self->_complete_papers( 'tex', @_ ); },
            proc => sub {
                $self->_tex_paper_mpdfeqs(@_);
              }
        },
##cmd_mpdfrevtex
        "mpdfrevtex" => {
            desc => "Compile the paper PDF file in revtex style",
            args => sub { shift; $self->_complete_papers( 'tex', @_ ); },
            proc => sub {
                $self->_tex_paper_mpdfrevtex(@_);
              }
        },
        "ppc" => {
            desc    => "Copy the part PDF file from remote host to ~/pdfout",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(mpa)], @_ ); },
            proc    => sub {
                $self->termcmd_reset("ppc @_");
                $self->_part_pdf_remote_copy(@_);
              }
##cmd_mps
        },
        "mps" => {
            desc =>
              "Compile the LaTeX paper source using as input its short key",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub {
                $self->termcmd_reset("mps @_");
                $self->_tex_paper_make_short(@_);
              }
        },
        "mh" => {
            desc    => "Compile the LaTeX paper source to HTML",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(make)], @_ ); },
            proc => sub { $self->_tex_paper_mh(@_); }
        },
        "mhs" => {
            desc    => "Compile the LaTeX paper source to HTML (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_mh_short(@_); }
        },

        #             }}}
        #########################
        # HTML {{{

        "makehtml" => {
            desc    => "Generate HTML from LaTeX sources",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(make)], @_ ); },
            proc => sub { $self->make_html_paper(@_); }
        },

        # }}}
        #########################
        # BibTeX       {{{
        #########################
        "bibexpand" => {
            desc => "Expand a BiBTeX file using the LaTeX file 
            with journal definitions",
            proc => sub { $self->_bib_expand(); }
        },
        "rmfields" => {
            desc => "Remove unnecessary fields from the BibTeX file",
            proc => sub { $self->_bibtex_rmfields(); }
        },
        "cbib" => {
            desc => "Create p.PKEY.cbib.tex file for the given paper key PKEY",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            minargs => 1,
            proc    => sub { $self->sysrun("cbib.pl --pkey @_ --wcbib"); }
        },
        "spk" => {
            desc =>
"Print (if exists), or compute short paper key given its long form",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            minargs => 1,
            proc    => sub { $self->sysrun("spk @_"); }
        },
        "bt" => {
            desc => "BibTeX wrapper command",
            args => sub { shift; $self->_complete_cmd( [qw(bt)], @_ ); },
            proc => sub { $self->_bt(@_); },
            cmds => {
                lk => {
                    desc => "List BibTeX "
                      . " keys starting with the specified string pattern",
                    args =>
                      sub { shift; $self->_complete_papers( "bib", @_ ); },
                    proc => sub { $self->_bt( "lk", @_ ); }
                },
                pkt => {
                    desc =>
                      "Given the BibTeX key, print the corresponding title ",
                    args =>
                      sub { shift; $self->_complete_papers( "bib", @_ ); },
                    proc => sub { $self->_bt( "pkt", @_ ); }
                }
            }
        },
        "lbib" => {
            desc => "List all BibTeX keys starting with the given pattern",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            proc => sub { $self->_bt( "lk", @_ ); }
        },

        #             }}}
        #########################
        # Makeindex {{{
        #########################
        "mist" => {
            desc => "Change makeindex style (PDF part generation) ",
            proc => sub { $self->makeindexstyle(@_); },
            args => sub { shift; $self->_complete_cmd( [qw(mistyles)], @_ ); },
        },

        # }}}
        #########################
        # Sync {{{
        "updateppics" => {
            desc => "Update ppics directory ",
            proc => sub { $self->update_ppics(@_); }
        },
        "convertppics" => {
            desc => "Convert pics for the given paper",
            proc => sub { $self->_tex_paper_convert_ppics(@_); },
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
        },
        #########################
    };
##cmd_set
    $commands->{set} = { desc => "(Re-)Set scalar accessor value", };
    foreach my $acc ( @{ $self->accessors("scalar") } ) {
        $commands->{set}->{cmds}->{$acc} = {
            proc => sub { $self->set_scalar_accessor( $acc, @_ ); },
            args => sub {
                shift;
                $self->_complete_cmd( ["scalar_accessor_$acc"], @_ );
            },
        };
    }

    #########################
    # System commands   {{{
    #########################
    $self->shellterm_sys_commands(qw( cat less more ));

    foreach my $cmd ( $self->shellterm_sys_commands ) {
        $commands->{$cmd} = {
            desc => "Wrapper for the system command: $cmd",
            proc => sub { $self->sysrun("$cmd @_"); },
            args => sub { shift->complete_files(@_); }
        };
    }

    #           }}}
    #########################

    $self->term_commands($commands);
    $self->shellterm( commands => $commands );

}

# }}}
# _term_list_commands() {{{

=head3 _term_list_commands()

=cut

sub _term_list_commands() {
    my $self = shift;
}

# }}}
# _term_init() {{{

=head3 _term_init()

Initialize a shell terminal L<Term::ShellUI> instance.

=cut

sub _term_init() {
    my $self = shift;

    $self->inputcmdfile("x.psh");

    $self->_term_get_commands();

    $self->shellterm( history_file => $self->files('history') );

    $self->shellterm( prompt       => "PaperShell>" );

    my $term = Term::ShellUI->new(
        commands     => $self->shellterm("commands"),
        history_file => $self->shellterm("history_file"),
        prompt       => $self->shellterm("prompt")
    );

    $self->shellterm( obj => $term );
}

sub _term_x() {
    my $self = shift;

    $self->read_cmdfile();

    foreach my $cmd ( $self->xcommands ) {
        $self->x($cmd) if $self->_opt_true("runx");
    }
}

sub x {
    my $self = shift;

    my $cmd = shift;

    system("pshcmd $cmd");
}

sub read_cmdfile() {
    my $self = shift;

    return 0 unless -e $self->inputcmdfile;

    my @lines = read_file $self->inputcmdfile;

    foreach (@lines) {
        next if /^\s*#/;
        next if /^\s*$/;
        chomp;
        $self->xcommands_push( split( ';', $_ ) );
    }
}

# }}}
# _term_run() {{{

=head3 _term_run()

=cut

sub _term_run() {
    my $self = shift;

    my $cmds = shift // [qw()];

    unless (@$cmds) {
        if ( $self->inputcommands ) {
            @$cmds = split( ';', $self->inputcommands );
        }
    }

    if (@$cmds) {

        # Single command with arguments
        unless ( ref $cmds ) {
            $self->shellterm("obj")->run($cmds);
        }
        elsif ( ref $cmds eq "ARRAY" ) {
            foreach my $cmd (@$cmds) {
                $self->shellterm("obj")->run($cmd);
            }
        }
    }
    else {
        exit 0 unless $self->_opt_true("shell");
        $self->shellterm("obj")->run();
    }
}

# }}}
# _term_exit() {{{

=head3 _term_exit() 

=cut

sub _term_exit() {
    my $self = shift;

    $self->LOGFILE->close;
}

# }}}

# }}}

# }}}
#=================================
# PDF original papers {{{

# view_pdf_paper_short() {{{

sub view_pdf_paper_short() {
    my $self = shift;

    # Short key
    my $skey = shift // '';

    # Long key
    my $lkey = $self->plongkeys($skey) // '';

    return 1 unless $lkey;

    $self->view_pdf_paper($lkey);
}

# }}}
# view_pdf_paper() {{{

sub view_pdf_paper() {
    my $self = shift;

    my $pkey = shift // '';
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

=head3 _bib_readfile()

=cut

sub _bib_readfile() {
    my $self = shift;

    my $if = $self->bibfile . ".bib";

    my @biblines = read_file($if);
    $self->biblines(@biblines);

}

# }}}
# _bib_expand() {{{

=head3 _bib_expand()

Expand all BibTeX file with all LaTeX definitions

=cut

sub _bib_expand() {
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

    my $of = $self->bibfilex . ".bib";
    write_file( $of, $self->biblines );

}

# }}}
# _bibtex_rmfields() {{{

sub _bibtex_rmfields() {
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

    my $pkey = shift // $self->pkey;
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

