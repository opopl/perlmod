
package TexPaperManager::TexPart;

use strict;
use warnings;

use OP::Base qw( 
	readhash 
	readarr
);


# _part_* _parts_* {{{

# _part_exists() {{{

sub _part_exists() {
    my $self = shift;

    my $part = shift || '';

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

    my $part = shift || $self->part || '';

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

    my $part = shift || '';

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
            my $txi = $ENV{TEXINPUTS} || '';
            $ENV{TEXINPUTS} = ".:" . $self->texroot . ":$txi";

            my $bibi = $ENV{BIBINPUTS} || '';
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

    my $part = shift || '';

    # Read in the list of used packages
    $self->out(
        "_part_read_usedpacks(): Reading in the list of used packages...\n");

    my $usedpacks = &readarr("pap.usedpacks.i.dat") || '';
    die
      "_part_make(): (part: $part) Failed to read in the list of used packages "
      unless $usedpacks;

    $self->pap_usedpacks( $part => $usedpacks );

}

# }}}
# _part_read_packopts($) {{{

sub _part_read_packopts($) {
    my $self = shift;

    my $part = shift || '';

    # Read in the list of package options
    $self->out( "_part_read_packopts(): Reading in the "
          . "list of used package options...\n" );

    # Read in the list of package options
    my $packopts = readhash("pap.packopts.i.dat") || '';

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

    my $part = shift || '';

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

    my $part = shift || '';

    #$self->out("_part_read_paps(): read in the list of papers...\n");

    # Read in list of papers for the specified part
    my $paps = readarr("pap.paps.$part.i.dat") || '';
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

    my $part = shift || '';

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


1;
 

