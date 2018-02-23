
package TeX::Project::Generate::cv;

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

use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Slurp qw( edit_file_lines );

our ($PROJSDIR,$hm);

BEGIN {
	use OP::Base qw( readarr readhash env_var );

	$PROJSDIR = env_var('PROJSDIR');
	$hm       = env_var('hm');
}

###our
our ( $if, @pdffiles,  %cvtypes, %files );
our %part_desc;

# Text::Generate::TeX instance
our $TEX;

# TeX file which is being written at the moment 
our $TEXFILE;

# List of languages
our @LANGS;

# Currently selected language
our $LANG;

# List of document parts, e.g. computer, work, stored 
our @PARTS;

# Currently selected part
our $PART;

###subs
sub process_opt;
sub main;
sub init_vars;
sub do_mktex;
sub do_mktex_lang;
sub do_mktex_main;
sub do_list;
sub do_ch;

sub mktex_lang_header;
sub mktex_lang_preamble;
sub mktex_lang_parts;
sub mktex_lang_end;

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
	@PARTS=readarr($files{parts});
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
            'cv.parts.i.dat ' , ' @PARTS=' . join(' ',@PARTS),
            'cv.types.i.dat ' , ],
    );

	@LANGS = qw(eng ukr );
	$TEX=Text::Generate::TeX->new;

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
	do_mktex_main;
	do_mktex_lang;
}

sub do_mktex_main {

  $TEXFILE=catfile($PROJSDIR,qw(cv.tex));

  $TEX->_clear;
  $TEX->ofile($TEXFILE);
  $TEX->_empty_lines;

  $TEX->def('PROJ','cv' );
  $TEX->input('_common.defs.tex');
  $TEX->documentclass('report',{ opts => [qw( a4paper 12pt )] });

  $TEX->_empty_lines;

  $TEX->usepackages([qw( pdfpages bookmark )]);

  $TEX->_empty_lines;
  $TEX->begin('document');

  my %cv_desc=(
      'ukr'  => 'CV (Ukrainian)',
      'rus'  => 'CV (Russian)',
      'eng'  => 'CV (English)',

  );

  foreach $LANG (@LANGS) {
      my $cv='cv_' . $LANG;
      my $cvpdf=catfile($PROJSDIR,$cv . '.pdf');

      next unless -e $cvpdf;

      $TEX->bookmark( 
              dest    => $cv, 
              title   => $cv_desc{$LANG},
              level   => 1,
          ); 
      $TEX->hypertarget($cv);
      $TEX->includepdf({ fname => $cv  });
      $TEX->_empty_lines;

  }

  $TEX->end('document');
  $TEX->_writefile;
}

sub mktex_lang_preamble {

   	$TEX->_empty_lines;
   	$TEX->_c_delim;
   	$TEX->_c("Preamble");
   	$TEX->_c_delim;

	$TEX->documentclass('mycv', {
		opts => [qw(margin 11pt)],
	});
   	$TEX->_empty_lines;
	$TEX->usepackage({
		'package' => 'hyperref',
		'options' => [qw(
			letterpaper
			linktocpage
			bookmarksdepth=subparagraph
		)]
	});
	if (grep { /^$LANG$/ } qw( ukr rus )) {
		$TEX->usepackage({
			'package' => 'fontenc',
			'options' => [qw( OT1 T2A )],
		});
	}
	#$TEX->usepackage({
			#'package' => 'inputenc',
			#'options' => 'utf8',
	#});

	$TEX->_add_line('');

	if (grep { /^$LANG$/ } qw( eng )) {

		$TEX->_add_line('\def\iff#1{%');
		$TEX->plus('indent',2);
		$TEX->_add_line('\hypertarget{#1}{}%');
		$TEX->_add_line('\bookmark[level=2,dest=#1,]{#1}%');
		$TEX->_add_line('\ii{#1}%');
		$TEX->minus('indent',2);
		$TEX->_add_line('}%');

	}

	$TEX->usepackages([qw( url graphicx my bookmark)]);

	# increase textwidth to get smaller right margin
	$TEX->_add_line('\textwidth=5.2in');
	$TEX->_add_line('');

	$TEX->def('gitwchf' , '\url{https://www.gitorious.org/wchf/wchf}');
	$TEX->def('srcfwchf', '\url{https://www.gitorious.org/wchf/wchf}');
	$TEX->def('dxwchf'  , '\url{www.srcf.ucam.org/~op226/wchf/dx_wchf/}');
	$TEX->def('webwchf' , '\url{www.srcf.ucam.org/~op226/wchf}');
	$TEX->def('gitgops' , '\url{www.github.com/opopl/gops}' );

   	$TEX->_empty_lines;
	$TEX->begin('document');
   	$TEX->_empty_lines;

}


sub mktex_lang_parts {

	foreach $PART (@PARTS) {
	
		if (grep { /^$LANG$/ } qw( eng )) {
			$TEX->_cmd('iff',$PART);

		}else{
		
			$TEX->hypertarget($PART);
			$TEX->bookmark( 
				dest    => $PART, 
				title   => $part_desc{$PART} || $PART,
				level   => 2,
			);
			
			$TEX->_cmd('ii',"$PART");
		}
	}
}

sub mktex_lang_end {

	$TEX->_empty_lines;
	$TEX->end('resume');
	$TEX->end('document');

}

sub mktex_lang_header {
	
	my $date=localtime;
	
	$TEX->_c_delim;
	$TEX->_c(" Date:");
	$TEX->_c("   $date");
	$TEX->_c(" File:");
	$TEX->_c("   $TEXFILE");
	$TEX->_c(" Creating script:");
	$TEX->_c("   $Script");
	$TEX->_c(" Creating script directory:");
	$TEX->_c("   $Bin");
	$TEX->_c(" Package:");
	$TEX->_c("   " . __PACKAGE__ );
	$TEX->_c_delim;
	
	$TEX->_empty_lines;
	$TEX->def('PROJ','cv_' . $LANG );
	$TEX->input('_common.defs.tex');
	$TEX->_empty_lines;
}

sub do_mktex_lang {

    foreach $LANG (@LANGS) {
        _say "Editing language: $LANG";

        $TEXFILE=catfile($PROJSDIR,"cv_$LANG.tex");
		$TEX->_clear;
		$TEX->ofile($TEXFILE);

		mktex_lang_header;
		mktex_lang_preamble;
		mktex_lang_parts;
		mktex_lang_end;

        $TEX->_writefile;

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
