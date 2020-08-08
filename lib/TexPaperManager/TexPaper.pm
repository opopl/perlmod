
package TexPaperManager::TexPaper;

use strict;
use warnings;

use Env qw( $hm );
use File::Spec::Functions qw(catfile);
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);


# ********************************
# _tex_paper_* {{{

# _tex_paper_splitmain {{{

sub _tex_paper_splitmain {
    my ($self, $pkey) = @_;

    $pkey ||= $self->pkey;
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

        /^\\subsection\{(.*)\}$/ && do {
            $onchapter{$cname} = 0 if defined $onchapter{$cname};

            $ctitle = $1;

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

        /^\s*\\labelsec\{\d+\}\s*$/ && do { $_ = ''; };

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

    return $self;

}

#                                       }}}
# _tex_paper_splitpiece {{{

sub _tex_paper_splitpiece {
    my ($self, $piece, $pkey) = @_;

    $pkey ||= $self->pkey;
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
            /^\\figp\{\w+\}\{(\w+)\}\[(.*)\]/ && do {
                $onchapter{$num} = 0 if defined $onchapter{$num};

                $num   = $1;
                $short = $2;

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

    return $self;

}

#                                       }}}

# _tex_paper_mh()                       {{{

sub _tex_paper_mh {
    my ($self, $pkey) = @_;

    my $f   = "p.$pkey.pdf";
    my $paf = "$f.preamble.tex";

    #$self->sysrun("perltex --nosafe $f");

    $self->sysrun("ltm --dvi --perltex $f");
    $self->sysrun("t4ht -f $f");

    return $self;

}

# }}}
# _tex_paper_mh_short() {{{

sub _tex_paper_mh_short {
    my ($self, $skey) = @_;

    # Short key
    $skey ||= '';

    # Long key
    my $lkey = $self->_long_key($skey);

    return 1 unless $lkey;

    $self->_tex_paper_mh($lkey);

    return $self;
}

# }}}
# _tex_paper_latex_2_html() {{{

sub _tex_paper_latex_2_html {
    my ($self, $pkey) = @_;

    $pkey ||= '';
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
    #
    return $self;

}

# }}}
# _tex_paper_htlatex() {{{

###htlatex

sub _tex_paper_htlatex {
    my ($self, $pkey) = @_;

    $pkey ||= '';

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

    return $self;

}

# }}}
# _tex_paper_latex_2_html_short() {{{

sub _tex_paper_latex_2_html_short {
    my ($self, $skey) = @_;

    # Short key
    $skey ||= '';

    # Long key
    my $lkey = $self->_long_key($skey);

    return 1 unless $lkey;

    $self->_tex_paper_latex_2_html($lkey);

    return $self;
}

# }}}

# _tex_paper_view_pdfeqs() {{{

sub _tex_paper_view_pdfeqs {
    my ($self, $pkey) = @_;

    $pkey ||= $self->pkey || '';
    $self->pkey($pkey);

    my $fname = 'p.' . $self->pkey . '.pdfeqs';
    my $file = catfile( $self->texroot, $fname . '.pdf' );

    if ( -e $file ) {
        my $view_cmd = "evince " . $file;
        system("$view_cmd &");
    }

    return $self;
}

#}}}
# _tex_paper_mpdfeqs() {{{

sub _tex_paper_mpdfeqs {
    my ($self, $pkey) = @_;

    $pkey ||= $self->pkey || '';
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

    return $self;

}

# }}}
# _tex_paper_mpdfrevtex() {{{

sub _tex_paper_mpdfrevtex {
    my $self = shift;

    my $pkey = shift || $self->pkey || '';
    $self->pkey($pkey) if $pkey;

    return $self;
}

# }}}
# _tex_paper_write_title_page() {{{

sub _tex_paper_write_title_page {
    my $self = shift;

    my $pkey = shift || '';

    return 1 unless $pkey;

    $self->out("Writing title page for paper: $pkey\n");

    my $config = $self->paperconfig($pkey) || '';

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

    my $width = $config->{titpage_width} || "5";

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

    my $iabs = $config->{include_abstract} || '';

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

    return $self;
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
    my ($self, $type, $ref) = @_;

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

    return $self;
}

# }}}
# _tex_paper_run_latex {{{

sub _tex_paper_run_latex {
    my ($self, $pkey) = @_;

    my $cmd = $self->latexcmd . " p.$pkey.pdf";
    $self->sysrun($cmd);

    return $self;
}

# }}}
# _tex_paper_run_latex_short {{{

sub _tex_paper_run_latex_short {
    my $self = shift;

    # Short key
    my $skey = shift || '';

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->_tex_paper_run_latex($lkey);

}

# }}}
# _tex_paper_run_tex_short {{{

sub _tex_paper_run_tex_short {
    my $self = shift;

    # Short key
    my $skey = shift || '';

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->_tex_paper_run_tex( 'pdf', $lkey );

}

# }}}

sub _tex_paper_set {
    my ($self, $pkey) = @_;

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

    return $self;

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

sub _tex_paper_make {
    my ($self, $pkey) = @_;

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

    return $self;

}

# }}}
# _tex_paper_cbib2cite() {{{

sub _tex_paper_cbib2cite {
    my ($self, $pkey) = @_;

    $self->pkey($pkey);

    $self->_tex_paper_get_secfiles;

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

    return $self;

}

# }}}
# _tex_paper_tex_nice() {{{

=head3 _tex_paper_tex_nice()

=cut

##TODO texnice
sub _tex_paper_tex_nice {
    my ($self, $pkey) = @_;

    my $pkey ||= $self->pkey;

    my $iopts = shift || {
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

    return $self;

}

# }}}
# _tex_paper_list_refs() {{{

sub _tex_paper_list_refs() {
    my $self = shift;

    my $pkey = shift || $self->pkey;

    my $refs  = $self->paperrefs_h($pkey);
    my $order = $self->paperrefs_h_order($pkey);

    print $_ . " " . $refs->{$_} . " " . "\n" for (@$order);

}

sub _tex_paper_list_eqs() {
    my $self = shift;

    my $pkey = shift || $self->pkey;

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

    my $pkey = shift || '';

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

    my $pkey = shift || '';

    my $fmain    = catfile( $self->texroot, "p.$pkey.tex" );
    my $fsecsdat = catfile( $self->texroot, "p.$pkey.secs.i.dat" );

    my $secdata = {};

    open( F,    "<$fmain" )    || die $!;
    open( FDAT, ">$fsecsdat" ) || die $!;

    # read in p.PKEY.tex
    while (<F>) {
        chomp;
        /^\s*\\iii\{\s*(\w+)\s*\}\s*%(.*)/ && do {

            my $seckey = $1;
            my $sectitle = $2;

            $secdata->{ $seckey } .= $sectitle;
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

    my $pkey = shift || '';

    my $frefs    = catfile( $self->texroot, "p.$pkey.refs.tex" );
    my $frefsdat = catfile( $self->texroot, "p.$pkey.refs.i.dat" );

    my $prefs;

    open( F,    "<$frefs" )    || die $!;
    open( FDAT, ">$frefsdat" ) || die $!;

    # read in p.*.refs.tex
    while (<F>) {
        chomp;
        /^\\pbib\{(\d+)\}\{(\w+)\}/ && do {

            my $num  = $1;
            my $pkey = $2;

            $prefs->{ $num } .= ' ' . $pkey ;
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

    my $pkey = shift || $self->pkey;
    my %eqdesc;

    $self->pkey($pkey);

    $self->_tex_paper_load_conf($pkey);

    $self->_tex_paper_get_secfiles();

    my $sec;

    # identifies which equations belong to which sections
    my %eqsec;

    my %labeq;

    foreach my $file ( $self->papsecfiles ) {

        if ( $file =~ /sec\.(\w+)\.i\.tex$/ ) {
            $sec = $1;
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

            /^\s*\\labeleq\{(.*)\}/ && do {
                $label = $1;
            };

            /^%%equation\s+(eq_|)([\w\.]+)/ && do {
                $eqnum          = $2;
                $eqdesc{$eqnum} = '';
                $labeq{$eqnum}  = $label;
            };
            /^%%eqdesc\s+(.*)/ && do {
                $eqdesc{$eqnum} = $1;
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

    my $sectype = shift || '';

    my $pkey = shift || $self->pkey;
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

            /^\s*\\begin\{(equation|align)\}/
              && do { $insideeq = 1; $starteq = 1; };
            /^\s*\\end\{(equation|align)\}/  && do { $endeq = 1; };
            /^\s*\\labeleq\{(\d+)\}/ && do { $label = $1; };

            /^%%equation\s+(.*)/ && do {
                $eqtag = $1;
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

sub _tex_paper_gen_file {
    my ($self, $sectype, $pkey) = @_;

    my $ThisSubName = ( caller(0) )[3];

    my $sectype ||= '';
    my $pkey    ||= $self->pkey;

    $self->_tex_paper_load_conf($pkey);

    unless ( grep { /^$sectype$/ } qw( eqs refs figs tabs ) ) {
        $self->say("Unsupported sectype");
        return 0;
    }

    $self->_tex_paper_get_secfiles;

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
              . '_h("$pkey") || {}' . ";\n"
              . '$horder = $self->paper'
              . $sectype
              . '_h_order("$pkey") || []' . ";\n";

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

                        if ( $n =~ /^sec_(\w+)/ ) {
                            my $stitle;
                            my $sec=$1;
                            if ( $self->papsecs_exists("$sec") ) {
                                $stitle = $self->papsecs("$sec");
                            }
                            else {
                                $stitle = $sec;
                            }
                            print R '\bmksec{'
                              . $sec . '}{'
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

                          #eval '$theme=$self->VARS("LaTeX_Table_theme") || ""';

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

    return $self;
}

# }}}

###gen_secdata
sub _tex_paper_gen_secdata {
    my ($self, $allfiles) = @_;

    my $allfiles ||= $self->pap_allfiles;

    my $isecs;
    my %secnums;

    foreach my $file (@$allfiles) {
        my @lines = read_file $file;
        foreach (@lines) {
            chomp;
            next if /^\s*%/;

            /^\\i(par|sec|subsec|subsubsec)\{(\w+)\}/ && do {
                my $isec = $2;
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

    return $self;

}

# _tex_paper_tabdat2tex {{{

sub _tex_paper_tabdat2tex {
    my $self = shift;

    my $ref = shift || {};

    my ( $CAPTION, $LABEL );
    my ( $caption, $label );

    my $datfile = $ref->{datfile};

    $caption = $ref->{caption} || '';
    $label   = $ref->{label}   || '';

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

        if ( $line =~ /^(\w+)\s*$/ ) {
            $FW = $1;

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

    my $theme = $ref->{table_theme} || '';

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
            if($id eq 'list_bibkeys'){
                push(@prereq,qw( repdoc.bib ));
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

        $first_prereq = shift(@prereq_pdf_tex) || '';

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

# _tex_paper_latexml() {{{

sub _tex_paper_latexml() {
    my $self = shift;

    my $pkey = shift || '';

    return 1 unless $pkey;

    #$self->sysrun()
}

# }}}
# _tex_paper_hermes() {{{

sub _tex_paper_hermes() {
    my $self = shift;

    my $pkey = shift || '';

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

    my $pkey = shift || '';

    return 1 unless $pkey;

    my $f = "p.$pkey.pdf.tex";

    $self->sysrun("tralics $f");
}

# }}}
# _tex_paper_load_conf_short() {{{

sub _tex_paper_load_conf_short() {
    my $self = shift;

    my $skey = shift || '';
    my $lkey = $self->_long_key($skey);

    $self->_tex_paper_load_conf($lkey);
}

# }}}
# _tex_paper_load_conf() {{{

###load_conf

sub _tex_paper_load_conf {
    my ($self, $pkey) = @_;

    my $pkey ||= $self->pkey;

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

    return $self;

}

# }}}
# _tex_paper_conf_remove() {{{

sub _tex_paper_conf_remove {
    my ($self, $pkey) = @_;

    my $pkey ||= '';

    my $cnf = "p.$pkey.conf.pl";

    File::Path::remove_tree($cnf) if ( -e $cnf );

    return $self;
}

# }}}
# _tex_paper_conf_exists() {{{

sub _tex_paper_conf_exists {
    my ($self, $pkey) = @_;

    my $pkey ||= '';

    my $cnf = "p.$pkey.conf.pl";

    return 1 if ( -e $cnf );
    return 0;
}

# }}}
# _tex_paper_conf_create() {{{

sub _tex_paper_conf_create {
    my ($self, $pkey) = @_;

    my $pkey ||= '';

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

    return $self;

}

# }}}
# _tex_paper_view_short() {{{

sub _tex_paper_view_short {
    my ($self, $skey) = @_;

    my $skey ||= '';

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->_tex_paper_view("$lkey");

    return $self;
}

# }}}

sub _tex_paper_get_figs() {
    my $self = shift;

}

# _tex_paper_get_secfiles() {{{

sub _tex_paper_get_secfiles {
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

        $secname = $1 if ( $secfile =~ /sec\.(\w+)\.i\.tex$/ );
        next unless $secname;
        $self->say( "Current section : " . $secname );

        foreach (@lines) {
            chomp;
            if (/^\\isec\{(\w+)\}\{(.*)\}/) {
                $secname = $1;
                $title   = $2;
                $got     = 1;
            }
            elsif (/^\\(section|subsection)\{(.*)\}/) {
                $got     = 1;
                $title   = $2;
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
                    if (/^\s*\\labelsec\{(\w+)\}/) {
                        $_ = '';
                        unless ( "$1" == "$secname" ) {
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
        push( @secorder, $1 ) if /^\s*\\iii\{(\w+)\}/;
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

    return $self;

}

# }}}
# _tex_paper_renames() {{{

sub _tex_paper_renames {
    my ($self, $pkey) = shift;

    $pkey ||= '';

    $self->sysrun("bash renames.sh $pkey");
}

# }}}
# _tex_paper_view() {{{

sub _tex_paper_view {
    my ($self, $pkey, $vopts) = @_;

    $pkey  ||= '';
    $vopts ||= '';

    return unless $pkey;

    my @ptexfiles;

    $self->_tex_paper_load_conf("$pkey");

    my $viewfiles = $self->paperviewfiles($pkey) || '';

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

    return $self;

}

# }}}
# _tex_paper_make_short() {{{

sub _tex_paper_make_short {
    my ($self, $skey) = @_;

    # Long key
    my $lkey = $self->plongkeys($skey) || '';

    return 1 unless $lkey;

    $self->_tex_paper_make("$lkey");

    return $self;
}

# }}}

# }}}


1;
