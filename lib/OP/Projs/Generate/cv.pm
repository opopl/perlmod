
package OP::Projs::Generate::cv;

use strict;
use warnings;

use File::Copy qw(copy);

###begin
use Text::Generate::TeX;
use OP::Script::Simple qw(
	_say 
	get_opt 
	@optstr
	%optdesc
	%opt
	%podsections
	$podsectionorder
);

use OP::Base qw( readarr readhash );
use Env qw( $hm $PROJSDIR );
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Slurp qw( edit_file_lines );

###our
our ( $if, @pdffiles, @parts, %cvtypes, %files );
our %part_desc;

###subs
sub process_opt;
sub main;
sub init_vars;
sub do_mktex;
sub do_list;
sub do_ch;

main;

sub init_vars {

###set_files
    %files = (
		    parts    => "parts.i.dat",
		    pdffiles => "pdffiles.i.dat",
		    types    => "types.i.dat"
    );

    %part_desc=(
        work => 'work experience',
    );

    foreach (keys %files){ 
        $files{$_} =~ s/^/cv./g; 
        $files{$_}=catfile($PROJSDIR,$files{$_});
    }

	@pdffiles=readarr($files{pdffiles});
	@parts=readarr($files{parts});
	%cvtypes=readhash($files{types});

###set_optstr
    @optstr = qw( 
		help
		man
		mktex
		pdf
		ch
        list=s
        type=s
    );

###set_optdesc
    %optdesc=(
        help    => 'Display help message',
        man     => 'Display man page',
        mktex   => 'Generate TeX source files',
    );

###set_podsectionorder
    $podsectionorder=[qw(
        NAME DESCRIPTION USAGE OPTIONS EXAMPLES
    ), "INPUT DAT FILES"];

###set_podsections
    %podsections=(
        NAME            => $Script . ' - CV TeX files generating script' ,
        DESCRIPTION     => '',
        OPTIONS         => '',
        EXAMPLES        => '' 
                      .  $Script . ' --mktex'     
                      .  ''   ,
        "INPUT DAT FILES"  => [
            'cv.pdffiles.i.dat ', ' @pdffiles=' . join(' ',@pdffiles),
            'cv.parts.i.dat ' , ' @parts=' . join(' ',@parts),
            'cv.types.i.dat ' , ],
    );

}

sub main {

    init_vars;
    get_opt(exit_help => 1);
    process_opt;
    
}


sub process_opt {

	do_ch if ($opt{ch});
	do_list if ($opt{list});
	do_mktex if ( $opt{mktex} );

}

sub do_list {

    if ( $opt{list} eq "files" ) {
        if ( $opt{pdf} ) {
            foreach (@pdffiles) { print "$_.pdf\n"; }
        }
        else {
            foreach (@pdffiles) { print "$_\n"; }
        }
    }
    elsif ( $opt{list} eq "types" ) {
		foreach ( keys %cvtypes ) { print "$_\n"; }
    }
    exit 0;

}

sub do_mktex {
	
	    my @langs = qw(eng ukr );
	    my $T=Text::Generate::TeX->new;

        $T->_clear;
        $T->ofile(catfile($PROJSDIR,qw(cv.tex)));
        $T->_empty_lines;

        $T->def('PROJ','cv' );
        $T->input('_common.defs.tex');
        $T->documentclass('report',{ opts => [qw( a4paper 12pt )] });

        $T->_empty_lines;

        $T->usepackages([qw( pdfpages bookmark )]);

        $T->_empty_lines;
        $T->begin('document');

        my %cv_desc=(
            'ukr'  => 'CV (Ukrainian)',
            'rus'  => 'CV (Russian)',
            'eng'  => 'CV (English)',
        );

	    foreach my $lang (@langs) {
            my $cv='cv_' . $lang;
            my $cvpdf=catfile($PROJSDIR,$cv . '.pdf');

            next unless -e $cvpdf;
	
	        $T->bookmark( 
                    dest    => $cv, 
                    title   => $cv_desc{$lang},
                    level   => 1,
                ); 
	        $T->hypertarget($cv);
	        $T->includepdf({ fname => $cv  });
	        $T->_empty_lines;

        }

        $T->end('document');
        $T->_writefile;

	    foreach my $lang (@langs) {
            my $file=catfile($PROJSDIR,"cv_$lang.tex");

	        _say "Editing language: $lang";
	
            $T->_clear;
	        $T->ofile("cv_$lang.tex");
	
			my $date=localtime;

	        $T->_c_delim;
	        $T->_c(" Date:");
	        $T->_c("   $date");
	        $T->_c(" File:");
	        $T->_c("   $file");
	        $T->_c(" Creating script:");
	        $T->_c("   $Script");
	        $T->_c_delim;

            $T->_empty_lines;
            $T->def('PROJ','cv_' . $lang );
            $T->input('_common.defs.tex');
            $T->_empty_lines;

            $T->input('cv.preamble');
            $T->_empty_lines;

	        foreach my $part (@parts) {

                $T->hypertarget($part);
	            $T->bookmark( 
                    dest    => $part, 
                    title   => $part_desc{$part} // $part,
                    level   => 2,
                );

                $T->_cmd('ii',"$part");
	        }

            $T->_empty_lines;
            $T->input('cv.end');

            $T->_writefile;

	    }
}

sub do_ch {

    my @files=glob("$PROJSDIR/cv_*.tex");
	
	foreach my $f (@files) {

		print "Processing file: $f\n";

		edit_file_lines {
			s/^\s*\\section\{([\s\w]+)\}/\\\\ $1 \& /g; 
		} $f;
	}

}

1;
