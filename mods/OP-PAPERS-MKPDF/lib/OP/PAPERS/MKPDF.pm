package OP::PAPERS::MKPDF;

use strict;
use warnings;

use feature qw(switch);
use 5.010;

#---------------------------------
# intro {{{
# use ... {{{

use File::Basename;
use File::Spec::Functions qw(catfile);
use FindBin qw($Bin $Script);
use Getopt::Long;
use File::Cat;
use File::Path qw(make_path remove_tree);
use File::Copy;
use File::Slurp qw(edit_file edit_file_lines read_file write_file );
use Getopt::Long;
use Pod::Usage;
use IPC::Cmd;
use PDF::API2;

use Data::Dumper;
use OP::Base qw/:vars :funcs/;
use OP::BIBTEX;
use OP::TEX::Text;
use OP::PaperConf;
use OP::Time;

use parent qw( OP::Script Class::Accessor::Complex );

# }}}
# accessors {{{

###__ACCESSORS_SCALAR
our @scalar_accessors = qw(
  PDFOUT
  bibfname
  bibstyle
  bibtex
  delimstr
  docstyle
  docclass
  do_edit_pdf
  fontsize
  lang
  fpkey
  ltmopts
  makeindexstyle
  pap_mainfile
  pdflatex
  ofname
  orientation
  outpdffile
  pdfedit
  pkey
  pname
  ptitle
  pauthors
  stex
  textcolor
  texroot
  texdriver
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
  PDFOUTDIRS
  SECORDER
  cmdline
  docstyles
  ncfiles
  optids
  write_tex_only
  usedpacks
);

###__ACCESSORS_HASH
our @hash_accessors = qw(
  config
  fancyhdr_style
  files
  packopts
  pdf_offsets
  papsecs
  runopts
  VARS
  SECORDER_CMDS
);

__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_array_accessors(@array_accessors)->mk_hash_accessors(@hash_accessors);

# }}}

=head2 Core methods 

=cut

# }}}
#---------------------------------
# Methods {{{

#=================================
# Core: _begin get_opt init_vars main run set_these_cmdopts  {{{

# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts() {
    my $self = shift;

    $self->SUPER::set_these_cmdopts();

    $self->add_cmd_opts(
        [
            { name => "pkey",    desc => "", type => "s", },
            { name => "list",    desc => "", type => "s" },
            { name => "mbibt",   desc => "" },
            { name => "nonstop", desc => "" },
            {
                name => "docstyle",
                desc =>
                  "Set docstyle. Accepted options: revtex, report (default) ",
                type => "s"
            }
        ]
    );
    foreach my $id ($self->optids) {
        $self->add_cmd_opts([{name  => $id, desc => "", }]); 
    }

}

# }}}
# main() {{{

=head3 main()

=cut

sub main() {
    my $self = shift;

    # Initialize variables
    $self->init_vars();

    # Read command-line arguments
    $self->get_opt();

    #
    $self->run();

}

# }}}
# _begin() {{{

=head3 _begin()

=cut

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

}

# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt() {
    my $self = shift;

    $self->cmdline(@ARGV);

    $self->SUPER::get_opt();

    $self->fpkey( $self->_opt_get("pkey") );

    my $fpkey = $self->fpkey;

    for ($fpkey) {
        /^ImparatoPeliti06$/ && do {

            #$self->pdfoffsets( "fig"    => 100);
            #$self->pdfoffsets( "eq"     => 50);
            $self->pdfedit(0);
            next;
        };
    }
    $self->opts_to_scalar_vars(qw(docstyle));

}

# }}}
# init_vars() {{{

=head3 init_vars()

=cut 

sub init_vars() {
    my $self = shift;

    $self->textcolor('bold blue');

    my $pdfout = $ENV{PDFOUT} // "out";
    my $packopts;

###set_optids
    my @skip=qw(
      make_bibt
      make_cbib
      run_tex
      tex_nice
      );

    my @write_tex_only=qw(main preamble titpage start );

    $self->write_tex_only( @write_tex_only );

    my @only=qw(
      make_bibt
      make_cbib
    );
    push(@only,map { "write_tex_" . $_ } @write_tex_only);

    $self->optids_clear();
    $self->optids_push( map { "skip_" . $_  } @skip );
    $self->optids_push( map { "only_" . $_  } @only );

    # root directory for the LaTeX files
    $self->texroot( $ENV{'PSH_TEXROOT'} // catfile( "$ENV{hm}", qw(wrk p) )
          // catfile( "$ENV{HOME}", qw(wrk p) ) );

    chdir $self->texroot;

    $self->files(
        "done_cbib2cite" => catfile($self->texroot,'keys.done_cbib2cite.i.dat'),
        "vars"  => catfile($self->texroot,$ENV{PVARSDAT} // 'vars.i.dat'),
    );

    $self->read_VARS;

    foreach my $id (qw(fig eq)) {
      my $k="pdf_offsets_$id";
      next unless $self->VARS_exists("$k");

      $self->pdf_offsets( $id  => $self->VARS("$k")); 
    }

    $self->PDFOUT($pdfout);

    $self->PDFOUTDIRS_push($pdfout);
    $self->PDFOUTDIRS_push("out");

    $self->bibtex( OP::BIBTEX->new );
    $self->bibtex->main;
    $self->bibfname( $self->bibtex->bibfname );

    $self->delimstr( "%" x 50 );

    $self->OP::Script::init_docstyles();

}

sub read_VARS {
  my $self=shift;
    $self->VARS(readhash($self->files('vars')));

    $self->VARS_to_accessors([qw(
        bibstyle
        do_edit_pdf
        docstyle
        makeindexstyle
        pdflatex
        pname 
        texdriver
    )]);
}

# }}}

sub process_docstyle() {
    my $self = shift;

    $self->say( "Current style is:  " . $self->docstyle );

    # Document class name + its options
    my %dchash;
    foreach my $ds ($self->docstyles) {
        $dchash{$ds}="";
        my $dcfile=catfile($self->texroot,qw(docstyles),$ds, qw( dclass.i.dat ));

        $self->_die("dclass.i.dat file not found")
            unless -e $dcfile;

        my @opts=readarr($dcfile);
        $dchash{$ds}.=join(' ',@opts);
    }
    my $val = '';
    eval '$val=$dchash{$self->docstyle} // ""';

    return 0 unless $val;

    $self->docclass($val);

    my $style = $self->docstyle;

    for (qw(packopts usedpacks)) {
        my $f = catfile( $self->texroot, qw(docstyles), $style, "$_.i.dat" );
        die "Package dat file: $_ was not found for style: $style"
          unless -e $f;

        $self->files( $_ => $f );
    }

    my @usedpacks=readarr( $self->files("usedpacks") );
    my $expacks=[];
    $expacks=$self->config("exclude_packs") if $self->config_exists("exclude_packs");

    # load additional package information from conf.pl file.
    #   conf-specific packages are appended to the list of used packages defined per docstyle,
    #   whereas package options are replaced by conf-specific ones
    my $conf_packs=[];
    my $conf_packopts={};
    $conf_packs=$self->config("use_packs") if $self->config_exists("use_packs");
    $conf_packopts=$self->config("pack_opts") if $self->config_exists("pack_opts");

    push(@usedpacks,@$conf_packs);

    foreach my $up (@usedpacks){
        next if(grep { /^$up$/ } @$expacks ); 

        $self->usedpacks_push($up);
    }

    $self->packopts( readhash( $self->files("packopts") ) );

    $self->packopts($conf_packopts);

}

sub edit_pdf() {
    my $self = shift;

    my $fpkey = $self->fpkey;
    $self->say( "Editing PDF file: " . $self->outpdffile );

    #my $pdfobj=PDF::API2->open($self->outpdffile);
    #my %infohash=$pdfobj->info();
    #print Dumper(\%infohash);
    #exit 0;

    my $offset;

    if ( $self->pdf_offsets_exists("eq") ) {
            $offset = $self->pdf_offsets("eq");
            $self->say( "(eq) PDF bookmark offset : " . $offset );

            edit_file_lines {

              if (
  /^(?<before>\/$fpkey\.eq(?<eqnum>\d+)\s*\[(\d+)\s+0\s+R\s+\/XYZ\s+(?<X>[\d\.]+))\s+(?<Y>[\d\.]+)\s+(?<after>null\])/
                )
              {
                  my $Y = $+{Y} + $offset;
                  $_ = $+{before} . ' ' . $Y . ' ' . $+{after} . "\n";
              }

            } $self->outpdffile;
     }

###pdf_offset_fig
    if ( $self->pdf_offsets_exists("fig") ) {
            $offset = $self->pdf_offsets("fig");
            $self->say( "(fig) PDF bookmark offset : " . $offset );

            edit_file_lines {

              if (
  /^(?<before>\/fig:$fpkey\-fig(?<fignum>\d+)\s*\[(\d+)\s+0\s+R\s+\/XYZ\s+(?<X>[\d\.]+))\s+(?<Y>[\d\.]+)\s+(?<after>null\])/
                )
              {
                  my $Y = $+{Y} + $offset;
                  $_ = $+{before} . ' ' . $Y . ' ' . $+{after} . "\n";
              }
          } $self->outpdffile;
    }

}

sub pshcmd() {
    my $self = shift;

    my $cmd = shift;
    my $mode = shift // 'call';

    $cmd = "pshcmd $cmd";

    my ( $success, $error_message, $buf, $stdout_buf, $stderr_buf ) =
      IPC::Cmd::run( command => $cmd, verbose => 0 );

    for ($mode) {
        /^call$/ && do {
            print "$_\n" for (@$buf);
            return;

            next;
        };
        /^return$/ && do {

            next;
        };
    }

    wantarray ? $buf : @$buf;

}

sub make_cbib {
    my $self = shift;

    my $fpkey = $self->fpkey;

    $self->say("Making cbib entries for: $fpkey ...");

    # this writes cbib.pl output to p.fpkey.cbib.tex
    system("cbib.pl --pkey $fpkey --wcbib");

}

sub make_bibt_this {
    my $self=shift;

    my $p=$self->fpkey;

    system("bib_print_entry --bibstyle " . $self->bibstyle . " $p > bibt.$p.tex");

}

sub make_bibt {
    my $self = shift;

    my $fpkey = $self->fpkey;

    my @refpaps = map { chomp; $_ } `cbib.pl --pkey $fpkey --list`;
    push( @refpaps, $fpkey );

    foreach my $p (@refpaps) {
        if ( $self->_opt_true("mbibt")
            || ( $self->_opt_false("mbibt") && ( !-e "bibt.$p.tex" ) ) )
        {
            $self->say("Making bibt.$p.tex file...");
            system("bib_print_entry $p > bibt.$p.tex");
        }
    }

}

sub run_tex {
    my $self = shift;

    $self->out( "Running ltm for: " . $self->ofname . "\n" );

    OP::Time::fix_time();

    system("ltm c");

    my $ltmopts ="";

    $ltmopts.=" --perltex " if $self->_package_is_used('perltex');
      
    $ltmopts.="--infile " . $self->ofname . " --outfile " . $self->ofname;

    if ( $self->_opt_true("nonstop") ) { $ltmopts = $ltmopts . " --nonstop"; }

    $self->ltmopts($ltmopts);

    $self->outpdffile( $self->ofname . ".pdf" );

    remove_tree($self->outpdffile);
    my $if=$self->ofname;

    unless($self->docstyle_eq('texht')){
      my $drv=$self->texdriver;
      for($drv){
###texdriver_LATEXMK
        /^LATEXMK$/ && do {
          my $opts;
          
          $opts="-pdf -f ";
          my %drvopts=(
            'dvips'  => '-pdfps',
            'dvipdf'  => '-pdfdvi',
            'pdftex'  => '-pdf',
          );

          if ($self->VARS_exists('tex_internal_driver')){
            my $d=$self->VARS('tex_internal_driver');
            $opts=$drvopts{$d};
          }

          $opts=$opts . ' -f';

          my @ids;

          @ids=qw(makeindexstyle pdflatex );

          foreach my $id (@ids) {
            my @evs;
            push(@evs,'$opts.=" -$id=" . $self->' . $id . ' // ""');

            eval(join(";",@evs));
            die $@ if $@;
          }

          my $cmd="LATEXMK $opts $if";
          $self->say("LATEXMK full command-line is: $cmd");

          system("$cmd");
          next;
        };
###texdriver_ltm
        /^ltm$/ && do {
          system("ltm $ltmopts");
          next;
        };

      }
    }else{
        $self->run_htlatex();
    }

    $self->edit_pdf() if $self->do_edit_pdf_eq("1");

    foreach my $pdfout ( $self->PDFOUTDIRS ) {
        copy( $self->outpdffile, catfile( $pdfout, $self->ofname ) );
    }
##TODO copyrevtex
   unless($self->docstyle_eq('texht')){
        my $dir=catfile( $self->texroot, qw(out),$self->docstyle);
        make_path($dir);

        copy( $self->outpdffile, catfile( $dir, $self->fpkey . '.pdf') );
        chdir $dir;
        system("pdftk " . $self->outpdffile . " output " . $self->ofname . '_unc_.pdf uncompress' );
        chdir $self->texroot;
    }

    $self->say( "Total time elapsed: " . OP::Time::elapsed_time() );

}

sub run_htlatex {

    my $self = shift;

    my $pkey = shift // $self->pkey;
    $self->pkey($pkey);

    my $htlatex = "HTLATEX";
    my $if      = $self->ofname;

    my $cfg="$if.cfg.tex";

    ( my $cfgname=$cfg ) =~ s/(.*)\.cfg\.tex$/$1/g;

    my $htmlout=catfile($ENV{HOME},qw(html pap),$pkey);

    make_path($htmlout);
    chdir $self->texroot;

    if (( ! -e $cfg) || ($self->VARS_eq('htlatex_cfg_force_create',1))){
        my $text;

        $self->say("Creating TeX4ht configuration file: $cfg");

        my $s=OP::TEX::Text->new;
        my(@in_document,@in_preamble);

        @in_preamble=$self->VARS_split(' ','htlatex_cfg_in_preamble');
        @in_document=$self->VARS_split(' ','htlatex_cfg_in_document');

        $s->_c_delim;
        $s->_c("Creation date: " . localtime);
        $s->_c("Creating script: " . $Script);
        $s->_c_delim;

        $s->_add_line('\Preamble{html,frames,4,index=2,next,charset=utf-8,javascript}');
        foreach my $in (@in_preamble) {
            $s->input("$in");
        }
        $s->_add_line('\begin{document}');
        foreach my $in (@in_document) {
            $s->input("$in");
        }
        $s->_add_line('\EndPreamble');
        $s->_print({ file => $cfg, fmode => 'w' });
    }

    copy("$cfg", "$cfgname.cfg");

    my $htlatex_cmd;

    $htlatex_cmd="$htlatex $if $cfgname";

    if ($self->VARS_eq('htlatex_no_cfg',1)){
      $htlatex_cmd="$htlatex $if";
    }elsif($self->VARS_exists('htlatex_no_cfg')){
      $htlatex_cmd="$htlatex $if " . $self->VARS('htlatex_no_cfg');
    }

    $self->say("TeX4ht will be run as follows: $htlatex_cmd");

    # use the above handled cfg file for htlatex
    system("$htlatex_cmd");

    #remove_tree("$if.cfg");
    my @pfiles;

    push(@pfiles,glob("p.$pkey.pdf*.html"));
    push(@pfiles,glob("p.$pkey.pdf*.png"));

    foreach my $f (@pfiles) {
        move($f,$htmlout);
    }
    $self->say("Generated HTML documentation is available at: " . $htmlout)

}

sub run_only {
    my $self=shift;

    my $only=shift // '';

    return unless $only;

    given($only){
      when(/^make_bibt$/) { 
          $self->make_bibt();
	        $self->make_bibt_this();
      }
      when(/^make_cbib$/) { 
            $self->make_cbib();
      }
      when(/^write_tex_(?<opt>.*)$/) { 
        my $opt=$+{opt};
        if($opt ~~ $self->write_tex_only ){
            my $evs='$self->write_tex_' . $opt . '()';
            eval $evs;
        }
      }
      default { }
    }

}

# run() {{{

sub run_switch {
    my $self=shift;

    my $iopts=shift // {};

    my $runopts;
    
    foreach my $id ($self->optids) {
      $self->runopts( $id  => 0 );
      if ($self->_opt_true($id)){
        $self->runopts( $id  => 1 );
      }
    }
    $self->runopts($iopts);

    my $only='';

    while(my($k,$v)=each $self->runopts){
        next unless $v;
	    if ($k =~ /^only_(\w+)/){
          $only=$1;
          last;
	    }
    }

    if ($only) {
        $self->run_only($only);
        return 'run_only';
    }

}


=head3 run()

=cut

sub run() {
    my $self = shift;

    my $iopts=shift // {};

    # load paper configuration from p.PKEY.conf.pl
    $self->load_paper_conf();
    $self->set_lang();

    my $rsw=$self->run_switch($iopts);
    given($rsw){
        when('run_only') { return; }
        default { }
    }

        die "fpkey was not defined\n" unless $self->fpkey;
    my $fpkey = $self->fpkey;

    if ( $self->_opt_true("list") ) {
        $self->usedpacks_print if $self->_opt_eq( "list", "usedpacks" );
    }

    # generate p.PKEY.cbib.tex
    unless ($self->runopts("skip_make_cbib")){
        $self->make_cbib();
    }

    unless ($self->runopts("skip_make_bibt")){
	    # make bibt.*.tex files for all referenced papers,
	    #   if necessary
	    $self->make_bibt();
	
	    # make bibt file for this paper
	    $self->make_bibt_this();
    }

    # generate tex files
    $self->write_tex();

    # apply various tex_nice methods
    unless ($self->runopts("skip_tex_nice")){
        $self->make_tex_nicer();
    }

    if ($self->runopts("skip_run_tex")){
      return;
    }

###_run_tex
    $self->run_tex();

}

# }}}

# }}}
#=================================
# _config_* {{{

sub make_tex_nicer {
    my $self = shift;

    $self->out("Trying to run tex_nice_local()... \n");
    my $subname = '&Config::' . $self->fpkey . '::tex_nice_local';

    my $SubExists;
    eval '$SubExists=exists ' . $subname;
    die $@ if $@;

    if ($SubExists) {
        eval( $subname . '()' );
        die $@ if $@;
    }

    $self->out("Running tex_nice.pl...\n");
    system("tex_nice.pl --pkey " . $self->fpkey );

}

sub _config_value() {
    my $self = shift;

    my $opt = shift;

    return $self->{config}->{$opt};
}

sub _config_def() {
    my $self = shift;

    my $opt = shift;

    return 1 if defined $self->{config}->{$opt};
    return 0;
}

sub _config_false() {
    my $self = shift;

    my $opt = shift;

    return 0 unless defined $self->_config_true("$opt");
}

# }}}
#=================================
# load_paper_conf() {{{

=head3 load_paper_conf()

=cut

sub load_paper_conf() {

    my $self = shift;

    my $fpkey = $self->fpkey;
    my $f     = catfile($self->texroot,"p.$fpkey.conf.pl");

    my $cpack='Config::' . $fpkey;

    return 1 unless -e $f;

    $self->say("Loading configuration for paper: $fpkey");
    require "$f";

    # $Config::PKEY::config => $self->config
    $self->apply_vars( 'Config::' . $fpkey, qw(config) );

    my @evs;
    
    push(@evs,'$self->SECORDER(@' . $cpack . '::SECORDER)');
    push(@evs,'$self->SECORDER_CMDS(%' . $cpack . '::SECORDER_CMDS)');

    eval(join(";\n",@evs));
    die $@ if $@;

    #$self->pshcmd("geneqs $fpkey");

}

# }}}
#=================================

sub catroot {
    my $self=shift;

    return catfile($self->texroot,@_);
}

# write_tex*  {{{

=head3 write_tex_main()

=head4 USAGE

=head4 PURPOSE 

Write p.PKEY.tex by using the secorder.i.dat file

=head4 SEE ALSO

PAP_GenMain() in papers.vim 

=cut

sub write_tex_main {
    my $self=shift;

    my $pkey=shift // $self->fpkey;
    my $mainfile=$self->catroot('p.' . $pkey . '.tex');

    my @outlines=();

    push(@outlines,'%');
    push(@outlines,'% Generated via Perl package: ' . __PACKAGE__ );
    push(@outlines,'%');
    push(@outlines,' ');
    push(@outlines,'\ssec{' . $pkey . '}');
    push(@outlines,' ');

    foreach my $sec ($self->SECORDER) {
      my $cmds=$self->SECORDER_CMDS("$sec") // [];
      if (@$cmds){
        push(@outlines,@$cmds);
      }
      push(@outlines,'\iii{' . $sec . '}');
    }
    write_file($mainfile,join("\n",@outlines) . "\n");

}

# write_tex() {{{

=head3 write_tex()

=cut

sub write_tex() {
    my $self = shift;

    my $outfile;
    my $ofname;
    my $pname = $self->pname;
    my $fpkey = $self->fpkey;

    $outfile = "p.$fpkey.pdf.tex";

    my $date = localtime;

    $self->write_tex_preamble();
    $self->write_tex_start();
    $self->write_tex_figs();
    $self->write_tex_tabs();
    $self->write_tex_titpage();

    my $t=OP::TEX::Text->new;

    $t->_c_delim;
    $t->_c("Generated by: $Script");
    $t->_c("Command-line: " . $self->cmdline_join(' '));
    $t->_c_delim;

    $t->input("p.$fpkey.pdf.preamble");
    $t->begin('document');

    my @include = ();

    push( @include, "p.$fpkey.nc" );
    push( @include, "p.$fpkey.pdf.titpage" );
    push( @include, "p.$fpkey.pdf.start" );
    push( @include, "p.$fpkey" );

    foreach my $f (@include) {
        if ( ( -e "$f.tex" ) || ( -e "$f" ) ) {
            $t->input("$f");
        }
    }

    my $include_tex_parts=$self->{config}->{include_tex_parts} // [];
    my $exclude_tex_parts=$self->{config}->{exclude_tex_parts} // [];

    foreach my $id (@$include_tex_parts) {
        my $f = "p.$fpkey.$id.tex";
        if ( -e $f ){
            next if ( grep { /^$id$/ } @$exclude_tex_parts );

            if ( $id eq "eqs" ) {
                $t->_add_line('\def\leqH{0}');
                $t->input("$f");
                $t->_add_line('\def\leqH{1}');
            }
            else {
                my $newdef=$self->{config}->{texdefs}->{"sec$id"} // '';
                if ($newdef){
                    $t->_c_delim;
                    $t->nc("sec$id",$newdef);
                    $t->_c_delim;
                }
                $t->input("$f");
            }
        }
    }

    $t->input("pdf.bib");

    $t->input("pdf.index") if $self->_package_is_used('makeidx');;

    $t->end('document');
    $t->_print({file => $outfile, fmode => 'w'});
    ( $ofname = $outfile ) =~ s/\.tex$//g;

    $self->ofname("$ofname");

}

# }}}
# write_tex_fancyhdr() {{{

=head3 write_tex_fancyhdr()

=cut

# }}}
# write_tex_figs() {{{

sub write_tex_figs() {
    my $self = shift;

    my $fpkey = $self->fpkey;
    my $pname = $self->pname;
    my $figs  = "p.$fpkey.figs.tex";

    if ( $self->_config_true("edit_figs") ) {
        if ( -e $figs ) {
            edit_file {
                s/^\\clearpage//g;
                s/^\\(\w+){Figures}/\\secfigs/ig;
            }
            $figs;
        }
        else {
        }
    }
}

# }}}
# write_tex_titpage() {{{

sub write_tex_titpage() {
    my $self = shift;

    eval '$self->write_tex_titpage_' . $self->docstyle . '();';
    die $@ if $@;
}

sub write_tex_titpage_texht() {
    my $self = shift;

    $self->write_tex_titpage_report;

}


sub write_tex_titpage_revtex() {
    my $self = shift;

    my $fpkey   = $self->fpkey;
    my $pname   = $self->pname;
    my $titpage = "p.$fpkey.pdf.titpage.tex";
    my $tit     = OP::TEX::Text->new;

    my $abs    = "p.$fpkey.abs.tex";
    my $abstex = read_file $abs;

    $tit->_empty_lines;
    $tit->_add_line( '\title{' . $self->ptitle . '}' );
    $tit->_empty_lines;

    $tit->bookmark( level  => 0, title => $fpkey, dest  => 'start' );
    $tit->hypertarget('start');

    my @authors = split( ' and ', $self->pauthors );
    foreach my $a (@authors) {
        $tit->_add_line("\\author{$a}");
    }

    $abstex= '  \begin{center}\textbf{Abstract}\end{center}' . "\n\n" . $abstex ;
    #$abstex.= "\n" . '\begin{fminipage}{5in}' ;
    $abstex.= "\n\n" . '  \begin{center}\textbf{Citation Info}\end{center}';
    $abstex.= "\n\n" . '  \input{bibt.' . $self->fpkey . '}' ;
    #$abstex.= "\n" . '\end{fminipage}' ;

    $tit->_empty_lines;
    $tit->abstract("$abstex");
    $tit->_empty_lines;

    $tit->_add_line("\\keywords{$fpkey}");

    $tit->_add_line("\\maketitle");

    $tit->_print( { fmode => 'w', file => $titpage } );

}

sub write_tex_titpage_report() {
    my $self = shift;

    my $fpkey   = $self->fpkey;
    my $pname   = $self->pname;
    my $titpage = "p.$fpkey.pdf.titpage.tex";

    open( TIT, ">$titpage" );

    print TIT "\\begingroup%\n";
    print TIT " \\nc{\\pn}{$fpkey}\n";

    # Bookmark at the chapter level
    print TIT "\\hypertarget{$fpkey-titpage}{}\n";
    print TIT "\\addcontentsline{toc}{part}{$fpkey} \n";

    my $width = $self->{config}->{titpage_width} // "5";

    ##################################
    # Print the article reference

    my $bibt = join( ".", "bibt", $self->pkey, "tex" );

    if ( -e $bibt ) {
        print TIT '\vspace*{5pt}' . "\n";
        print TIT ' \begin{center}' . "\n";
        print TIT '   \begin{fminipage}{' . $width . 'in}' . "\n";
        print TIT '     \input{' . $bibt . "}\n";
        print TIT '   \end{fminipage}' . "\n";
        print TIT ' \end{center}' . "\n";
        print TIT '\vspace*{5pt}' . "\n";
    }

    ##################################
    # Print the article abstract

    my $abs = "p.$fpkey.abs.tex";

    edit_file {
        s/^\\clearpage.*$//gxm;
        s/^\\(\w+){Abstract}.*$//igxm;
        s/^\\label.*$//igx;
    }
    $abs;

    if ( ( -e $abs ) && ( $self->_config_true("include_abstract") ) ) {
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
# write_tex_tabs() {{{

sub write_tex_tabs() {
    my $self = shift;

    my $fpkey = $self->fpkey;
    my $pname = $self->pname;
    my $tabs  = "p.$fpkey.tabs.tex";

    if ( $self->_config_true("edit_tabs") ) {
        if ( -e $tabs ) {
            edit_file {
                s/^\\clearpage//g;
                s/^\\(\w+){Tables}/\\sectabs/ig;
            }
            $tabs;
        }
        else {
        }
    }
}

# }}}
# write_tex_start() {{{

sub write_tex_start() {

    my $self = shift;

    my $fpkey = $self->fpkey;
    my $pname = $self->pname;
    my $start = "p.$fpkey.pdf.start.tex";

    my $include = $self->{config}->{include_lists_start} // [qw(toc)];

    my $s=OP::TEX::Text->new;

    foreach my $id (@$include) {
        $s->input("$id.i");
    }
    $s->_print({ file  => $start, fmode  => 'w' }); 
}

# }}}

sub get_pauthors {
    my $self = shift;

    my $pauthors = $self->bibtex->entries_pkey( $self->pkey )->get("author");
    $self->pauthors($pauthors);

}

sub get_ptitle {
    my $self = shift;

    my $ptitle = $self->bibtex->entries_pkey( $self->pkey )->get("title");
    $self->ptitle($ptitle);
}

sub write_tex_preamble_fancyhdr() {
    my $self = shift;

###_FANCY_HDR
    my $pa    = $self->stex;
    my $fpkey = $self->fpkey;

    $pa->_c_delim;
    $pa->_c(" Fancyhdr customization");
    $pa->_c_delim;

    $pa->_add_line("\\pagestyle{fancy}");

    my $allowedlength = 30;
###_FANCY_PAUTHORS
    my $pauthors = $self->pauthors;
    if ( length($pauthors) > $allowedlength ) {
        $pauthors = substr( $pauthors, 0, $allowedlength ) . "\\ \\ldots";
    }
    $pa->def( '\pauthors', $pauthors );
    $self->pauthors($pauthors);

###_FANCY_PTITLE

    my $ptitle = $self->ptitle;
    if ( length($ptitle) > $allowedlength ) {
        $ptitle = substr( $self->ptitle, 0, $allowedlength ) . "\\ \\ldots";
    }

    $pa->def( '\ptitle', $ptitle );

    $self->fancyhdr_style(
        lhead  => '\pauthors',
        chead  => '\thepage',
        rhead  => '\bfseries PAPER: ' . $fpkey,
        lfoot  => '\pn',
        cfoot  => '\thepage',
        rfoot  => '\ptitle',
        headrulewidth  => '0.4pt',
        footrulewidth  => '0.4pt',
    );

    foreach my $id (qw( lhead chead rhead lfoot cfoot rfoot )){
        my $fid='TEX_fancyhdr_' . $id;
        if ($self->VARS_exists($fid)) {
            my $opt=$self->VARS($fid);

            # value of \cfoot or \lfoot or ... etc.
            my $id_value;

            for($opt){
                /^_AcrobatMenu_$/ && do {
                    $id_value='\NavigationBar';
                    my $navbar=<<'_EOF_';

\newcommand{\NavigationBar}{% 
    \Acrobatmenu{PrevPage}{Previous}~ 
    \Acrobatmenu{NextPage}{Next}~ 
    \Acrobatmenu{FirstPage}{First}~ 
    \Acrobatmenu{LastPage}{Last}~ 
    \Acrobatmenu{GoBack}{Back}~ 
    \Acrobatmenu{Quit}{Quit}% 
} 

_EOF_

                     $pa->_add_line($navbar);
    
                    next;
                };
                $id_value=$opt;
            }

            $self->fancyhdr_style($id  => $id_value); 

        }


    }

    $pa->_write_fancyhdr_style( $self->fancyhdr_style_ref );
    $pa->_c_delim;

}

sub write_tex_preamble_papsecs() {
    my $self = shift;

    my $fpkey = $self->fpkey;
    my @ref   = $self->pshcmd( 'list papsecs ' . $fpkey, 'return' );
    my $lines = shift @ref;

    foreach my $line (@$lines) {
        my @L = split( "\n", $line );

        for (@L) {
            chomp;

            # package name
            next if /^op/i;
            next if /^\|\s*===/i;
            if (
/^\|\s*(?<key>\w+[\s\w]*\w+)\s*\|\s*(?<value>\w+[\s\w]*\w+)\s*\|/
              )
            {
                $self->papsecs( $+{key} => $+{value} );
            }
        }
    }

    my $hash;
    foreach my $k ( $self->papsecs_keys ) {
        $hash->{$k} = '\clearpage\subsection{' . $self->papsecs("$k") . '}';
    }

    #$pa->_write_hash( "papsubsec", $hash );

}

# write_tex_preamble() {{{

=head3 write_tex_preamble()

=cut

sub write_tex_preamble() {
    my $self = shift;

    my $date     = localtime;
    my $fpkey    = $self->fpkey;
    my $pkey     = $self->pkey;
    my $pname    = $self->pname;
    my $preamble = "p.$fpkey.pdf.preamble.tex";

    $self->get_ptitle();
    $self->get_pauthors();

    my $pa = OP::TEX::Text->new;
    $self->stex($pa);

    my $s = '';

    foreach my $mode (qw( nonstopmode batchmode )) {
        if ($self->VARS_eq($mode,1)){
            $pa->_add_line("\\$mode");
        }
    }

    $pa->_c_delim;
    $pa->_c(' Date generated: ');
    $pa->_c('  ' . $date );
    $pa->_c(' Generating script: ');
    $pa->_c('  ' . $Script );
    $pa->_c(' Filename: ');
    $pa->_c('  ' . $preamble );
    $pa->_c(' Document style: ');
    $pa->_c('  ' . $self->docstyle );
    $pa->_c_delim;

    $self->orientation("portrait");
    $self->fontsize("12pt");

    $self->process_docstyle();

    $self->ncfiles(qw());

    my $dims = {
        textwidth      => '15cm',
        textheight     => '23cm',
        textheight     => '23cm',
        marginparwidth => '3cm',
        oddsidemargin  => '0.5cm',
        topmargin      => '-1cm'
    };

    ##TODO  preamble
    $pa->preamble(
        {
            dclass         => $self->docclass,
            usedpacks      => $self->usedpacks_ref,
            packopts       => $self->packopts_ref,
            doctitle       => "PDF paper: $pkey",
            makeindex      => $self->_package_is_used('makeidx'),
            put_today_date => 1,
            shift_parname  => 1,
            hypsetup       => {
                pdfauthor          => 'op',
                pdftitle           => "$pkey" . "(" . $self->docstyle . ")",
                citecolor       => 'blue',
                colorlinks      => 'true',
                hyperfigures    => 'true',
                citebordercolor => 'green',
              linkbordercolor     => 'red',
                bookmarksnumbered   => 1,
                pdftex   => 1,
                pdfview   => 'XYZ 0 800 null',
                #bookmarksdepth      => 'subparagraph',
            },
            ncfiles => $self->ncfiles_ref,

            #dims    => $dims,
        }
    );

    $pa->true( "DOCSTYLE" . $self->docstyle );

    # Insert language-specific preamble
    my $langfile =
      catfile( $self->texroot, "p." . $self->lang . "pdf.preamble.tex" );
    $pa->input( $langfile, { check_exists => 1 } );

    $pa->true(qw(papsingle));

    $s = '';
    $s .= '' . "\n";
    $s .= '\sloppy' . "\n";
    $s .= '\def\baselinestretch{1}' . "\n";
    $s .= '\setcounter{page}{1}' . "\n";
    $s .= '\def\leqH{1}' . "\n";

    $pa->_add_line("$s");

    $pa->input(qw(nc));

    my $d=$self->VARS('tex_internal_driver');
    my %exts=(
        'dvips'  => 'eps',
        'dvipdf'  => 'eps',
        'pdftex'  => 'png',
    );
    $pa->_add_line('\DeclareGraphicsExtensions{' . $exts{$d} . '}');

    $pa->input('preamble.rnc_paragraph');

    $pa->setcounter('tocdepth',$self->VARS("TEX_tocdepth"));

    $pa->nc( 'bibname', 'Bibliography' );
    $pa->nc( 'pn',      "$fpkey" );

    $pa->input('preamble.tocloft');
    $pa->input("$pname-nc");

    $pa->input("nc.perltex") if $self->_package_is_used('perltex');

    $pa->input("p.$fpkey.cbib", { check_exists  => 1 });

    $self->write_tex_preamble_fancyhdr() if $self->_package_is_used('fancyhdr');

    $self->write_tex_preamble_papsecs();

    $pa->newnc( [qw(FIG SEC EQ)] );

    $pa->_c_delim;

    $pa->_print( { file => $preamble, fmode => 'w' } );

}

# }}}

# }}}
#=================================
# set_lang() {{{

=head3 set_lang()

=cut

sub set_lang() {
    my $self = shift;

    # determine language if specified
    my $lang = '';

    my $pkey = $self->fpkey;

    ( $self->fpkey =~ m/^(ukr|rus)(\w+)$/ ) && do { $lang = $1; $pkey = $2; };

    unless ($lang) {
        $lang = "eng";
    }

    $self->lang($lang);
    $self->pkey($pkey);
}

#}}}
#=================================
# _package_is_used () {{{

sub _package_is_used () {
    my $self = shift;

    my $package = shift // '';
    return 0 unless $package;

    return 1 if ( grep { /^$package$/ } $self->usedpacks );
    return 0;
}

sub _config_true() {
    my $self = shift;

    my $opt = shift;

    return 0 unless defined $self->{config}->{$opt};
    return !!$self->{config}->{$opt};

}

# }}}

# }}}
#---------------------------------

1;

