require 5.005;                          # to compile BibTeX.xs (I think)

use strict;

use ExtUtils::MakeMaker;
use File::Basename;

our @support_files;

sub configure_btparse;
sub main;

sub configure_btparse
{
   my ($dir) = @_;

   chdir $dir or die "couldn't chdir to $dir: $!\n";
   unless (-f "config.status" && -f "config.cache" &&
           -M "config.status" < -M "configure" &&
           -M "config.cache" < -M "configure")
   {
      print "btparse distribution in '$dir' is not configured; doing so now:\n";
      my @cmd = ('sh', './configure');
      print "@cmd\n";
      system @cmd;
      die "configure failed\n" unless $? == 0;

   }

   chdir ".." or die "couldn't chdir to ..: $!\n";
   print "btparse distribution in '$dir' is configured and ready to build\n";
}

sub main {

	@support_files = ('btxs_support$(OBJ_EXT)');

	# See lib/ExtUtils/MakeMaker.pm for details of how to influence
	# the contents of the Makefile that is written.
	WriteMakefile (
	    'NAME'        => 'LaTeX::BibTeX',
	    'VERSION'     => '0.34',
	    'XSPROTOARG'  => '-prototypes',
	    'LIBS'        => [''],   # e.g., '-lm'
	    'DEFINE'      => '',     # e.g., '-DHAVE_SOMETHING'
	    'INC'         => '-Ibtparse/src',
	    'MYEXTLIB'    => 'btparse/src/.libs/libbtparse$(LIB_EXT)',
	    'OBJECT'      => 'BibTeX$(OBJ_EXT) ' . join (' ', @support_files),
	    'dynamic_lib' => { 
			INST_DYNAMIC_DEP  => join (' ', @support_files) 
		},
	    'dist'        => { 
			COMPRESS   => "gzip", 
			SUFFIX     => "gz" 
		}
	);
	
	configure_btparse ('btparse');

}

main;

# -- END main ----------------------------------------------------------


# -- Overrides ---------------------------------------------------------
package MY;

sub dist
{
   local $_ = shift->SUPER::dist;
   s/CI \s* = \s* .*/CI = true/mx;
   s/-Nv/-sRel -N\$(NAME_SYM)_v/m;
   return $_;
}

sub postamble
{
'
$(MYEXTLIB):
	cd btparse && $(MAKE)
';
}

sub manifypods
{
   local $_ = shift->SUPER::manifypods (@_);
   s/Text::btool_faq/btool_faq/;
   return $_;
}
