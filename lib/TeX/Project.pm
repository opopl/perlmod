
package TeX::Project;

use strict;
use warnings;

=head1 NAME 

TeX::Projecte - TeX projects generating package

=head1 PURPOSE

Creation of a new project in the projs-directory specified by the environment
variable C<$PROJSDIR>. 

=head1 SYNOPSIS

	tex_create_proj.pl [ --dir DIR --proj PROJ --sec SEC  --force --appenddat ]

where script C<tex_create_proj.pl> is simply as follows:

	#!/usr/bin/env perl
	#
	use strict;
	use warnings;
	
	use TeX::Project;
	
	TeX::Project->new->main;

=cut

use Env qw( $PROJSDIR );

###_use
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Slurp qw( append_file);

use Getopt::Long;

use TeX::Project::GenerateTeX qw();
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
our($SECFILE,$DIR,$PROJ,$SEC);
our($PFILE,@MAINSECS,@PROJS);

our $PROJEXISTS;

# for Getopt::Long, see get_opt subroutine
our(%opt,@optstr,%optdesc);
our($cmdline);


sub dhelp {
	my $self=shift;

	my $h=[
    	  'USAGE:'
	    , "   $Script --dir <Project directory> --proj <Project name> --sec <Section> [ --appenddat --force ]"
        , 'SCRIPT:'
        , "   $0"
		,
	];
	print join("\n",@$h) . "\n";

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
        "force"  => "Force project creation (in case project already exists)",
        "appenddat"   => "Add project's name to the list of all projects ( PROJS.i.dat )",
    );
    
    unless( @ARGV ){ 
        $self->dhelp;
		exit 0;
    }else{
        $cmdline=join(' ',@ARGV);
        GetOptions(\%opt,@optstr);
    }

    $self->dhelp, exit 1 if $opt{help};

    $DIR=$opt{dir} // $PROJSDIR;
    $PROJ=$opt{proj};
    $SEC=$opt{sec} // '_main_';

	die "No project name provided"
		unless $PROJ;

	die "No project directory provided"
		unless $DIR;

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

    @PROJS=readarr($PFILE);

	$PROJEXISTS= ($PROJ ~~ @PROJS) ? 1 : 0 ;

	die "PROJS datfile not found: $PFILE"
	  	unless -e $PFILE;

    if ($PROJEXISTS && (!$opt{force})){
        die "Project already exists: $PROJ";

    }elsif($opt{appenddat}){
        my $date=localtime;

		unless ($PROJEXISTS){
        	append_file($PFILE,"# Added by $Script on $date" . "\n");
        	append_file($PFILE,$PROJ . "\n");
		}

		warn "Project '" . $PROJ . "' is already written in PROJS datfile\n";

		exit 0;
    }

	foreach($SEC){
		/^_main_$/ && do {
			$SECFILE=catfile($DIR,$PROJ . ".tex");
			next; 
		};
	
		$SECFILE=catfile($DIR,$PROJ . ".$SEC" . ".tex");
	}

}

sub init_vars {
	my $self=shift;

	@MAINSECS=qw( preamble begin body  );

    $self->TEX( TeX::Project::GenerateTeX->new );

}

sub write_tex {
	my $self=shift;

	my $tex=$self->TEX;

    $tex->_c_delim;
    $tex->_c(" Project Name:");
    $tex->_c("  $PROJ");
    $tex->_c(" Creating script:");
    $tex->_c("  $Script");
    $tex->_c(" Script location:");
    $tex->_c("  $Bin");
    $tex->_c(" Creating package:");
    $tex->_c("  " . __PACKAGE__);
    $tex->_c(" Date:");
    $tex->_c("  " . localtime );
    $tex->_c_delim;

    $self->TEX->ofile($SECFILE);

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

            $self->TEX->_c_delim;
            $self->TEX->_c_help("marginparwidth");
            $self->TEX->_c_delim;
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


 

