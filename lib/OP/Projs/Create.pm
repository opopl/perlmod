
package OP::Projs::Create;

use strict;
use warnings;

=head1 NAME 

tex_create_proj.pl - TeX projects generating script

=head1 PURPOSE

Creation of a new project in the projs-directory specified by the environment
variable $PROJSDIR. 

=head1 SYNOPSIS

tex_create_proj.pl --dir DIR --proj PROJ --sec SEC

=cut

use Env qw( $PROJSDIR );

###_use
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Slurp qw( append_file);

use Getopt::Long;

use OP::Projs::Tex qw();
use OP::Base qw(readarr);

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	TEX
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors)
	->mk_new;

#Usage: $Script DIR PROJ SEC

###_our
our($FILE,$DIR,$PROJ,$SEC);
our($PFILE,@MAINSECS,@PROJS);

# for Getopt::Long, see get_opt subroutine
our(%opt,@optstr,%optdesc);
our($cmdline);


sub dhelp {
	my $self=shift;

    print "USAGE:\n";
	print "   $Script --dir DIR --proj PROJ --sec SEC --dat" . "\n";
    print "SCRIPT:\n";
    print "   $0\n";

}
      
sub get_opt {
	my $self=shift;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    @optstr=(   
        "help",
        "man",
        "appenddat",
        "force",
        "dir=s",
        "proj=s",
        "sec=s",
    );
    
    %optdesc=(
        "help"  => "Display help message",
        "man"   => "Display man page",
        "dir"   => "Value for directory with projects",
        "sec"   => "Project's section",
        "proj"  => "Name of the project",
        "appenddat"   => "Add project's name to the list of all projects ( PROJS.i.dat )",
    );
    
    unless( @ARGV ){ 
        dhelp;
		exit 0;
    }else{
        $cmdline=join(' ',@ARGV);
        GetOptions(\%opt,@optstr);
    }

    $DIR=$opt{dir} // $PROJSDIR;
    $PROJ=$opt{proj};
    $SEC=$opt{sec} // '_main_';

}

sub main { 
	my $self=shift;

    $self->init_vars;
    $self->get_opt;
    $self->process_opt;
    $self->write_tex;

}

sub process_opt {
	my $self=shift;

	$PFILE=catfile($DIR,"PROJS.i.dat");

	die "$PFILE file not found!"
	  unless -e $PFILE;

    @PROJS=readarr($PFILE);
    if (($PROJ ~~ @PROJS) && (!$opt{force})){
        die "Project already exists";
    }elsif($opt{appenddat}){
        my $date=localtime;

        append_file($PFILE,"# Added by $Script on $date" . "\n");
        append_file($PFILE,$PROJ . "\n");

		exit 0;
    }

	foreach($SEC){
		/^_main_$/ && do {
			$FILE=catfile($DIR,$PROJ . ".tex");
			next; 
		};
	
		$FILE=catfile($DIR,$PROJ . ".$SEC" . ".tex");
	}

}

sub init_vars {
	my $self=shift;

	@MAINSECS=qw( preamble begin body  );

    $self->TEX( OP::Projs::Tex->new );

}

sub write_tex {
	my $self=shift;

    $self->TEX->_c("Generated via $Script");

    $self->TEX->ofile($FILE);

	my %write_subs=(
###print_main
	    '_main_' => sub  {
            $self->TEX->def('PROJ',$PROJ);
            $self->TEX->input('_common.defs.tex');
            $self->TEX->_empty_lines;

		    foreach my $sec (@MAINSECS) {
                $self->TEX->_cmd('ii',$sec);
		    }

            $self->TEX->_empty_lines;
            $self->TEX->end('document');

	    },
###print_cfg
	    'cfg' => sub  {

            $self->TEX->_c_delim;
            $self->TEX->_c("Generated via Perl package: " . __PACKAGE__ );
            $self->TEX->_c("On: " . localtime );
            $self->TEX->_c_delim;

			$self->TEX->_cmd('Preamble',
					'html,frames,5,index=2,next,charset=utf-8,javascript');
            $self->TEX->_empty_lines;

			$self->TEX->icfg('common');
            $self->TEX->_empty_lines;

			$self->TEX->begin('document');
            $self->TEX->_empty_lines;

			$self->TEX->icfg('HEAD.showHide');
			$self->TEX->icfg('TOC');

            $self->TEX->_empty_lines;
			$self->TEX->_cmd('EndPreamble');
	    },
###print_title
	    'title' => sub  {
            $self->TEX->_cmd('maketitle');
	    },
###print_begin
	    'begin'  => sub {
            $self->TEX->begin('document');
            $self->TEX->_cmd('thispagestyle','plain');

            $self->TEX->ii('title');
            $self->TEX->_cmd('restoregeometry');

            $self->TEX->input('toc');
	    },
###print_preamble
	    'preamble' => sub { 

	        $self->TEX->documentclass('extreport', {
					opts => [qw(a4paper 10pt )],
			}); 

            $self->TEX->_empty_lines;
            $self->TEX->ii('packages');
            $self->TEX->ii('makeatletter');
            $self->TEX->ii('preamble_page_geometry');
            $self->TEX->ii('preamble_text_formatting');
            $self->TEX->_empty_lines;

	        $self->TEX->setcounter('page', '1');

            $self->TEX->_cmd('title','TITLE');
            $self->TEX->_cmd('date','\today');

	    },
###print_preamble_text_formatting
	    'preamble_text_formatting'  => sub {

            $self->TEX->_cmd('sloppy');
            $self->TEX->def('baselinestretch','1');
	        $self->TEX->setlength('parindent', '0em');
		},
###print_preamble_page_geometry
	    'preamble_page_geometry'  => sub {
	        $self->TEX->setlength('marginparwidth', '3cm');
	        $self->TEX->setlength('textwidth', '17cm');
	        $self->TEX->setlength('topmargin', '-1cm');
	        $self->TEX->setlength('oddsidemargin', '-0.5cm');
	        $self->TEX->setlength('textheight', '23cm');
		},
###print_makeatletter
	    'makeatletter' => sub {
            $self->TEX->_cmd('makeatletter');

            my $s=<<'EOF';

\@ifpackageloaded{bookmark}{%
	\def\bmk#1#2{%
		\bookmark[#1]{#2}%
	}%
}{}

\renewcommand\paragraph{%
   \@startsection{paragraph}{4}{0mm}%
      {-\baselineskip}%
      {.5\baselineskip}%
      {\normalfont\normalsize\bfseries}}
EOF

            $self->TEX->_add_line("$s");
            $self->TEX->_cmd('makeatother');

	    },
###print_packages
	    'packages'  => sub {
	        $self->TEX->usepackages([ qw( makeidx multirow multicol url ) ]);
	        $self->TEX->usepackage({ 
	                'package' => 'hyperref', 
	                'options' => [ qw(
							hyperindex
							letterpaper
							linktocpage
							pdfpagelabels
							plainpages=false
							bookmarksdepth=subparagraph 
					)],
	            });
	        $self->TEX->usepackages([ qw(bookmark) ]);
	
	        $self->TEX->usepackages([ qw( 
					nameref 
					ifthen 
					graphicx 
					verbatim ) ]);
	
	        $self->TEX->usepackage({ 
	                'package' => 'geometry', 
	                'options' => [ 
								'hmargin={1cm,1cm}',
								'vmargin={2cm,2cm}',
								'centering' 
								],
	        });

	        $self->TEX->usepackages([ qw( my projs )]); 
	        $self->TEX->usepackages([ qw( 
					authblk soul csquotes 
					longtable alltt 
			)]); 
	
	    },
    );

	if (defined $write_subs{$SEC}){
		my $sub=$write_subs{$SEC};
		$sub->();
	
	    $self->TEX->_writefile;
	}

}

1;


 
