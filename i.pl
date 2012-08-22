#!/usr/bin/perl 

# use ... {{{

use strict;
use warnings;

use File::Basename;
use FindBin;
use Getopt::Long;
use Pod::Usage;

#use lib("$FindBin::Bin/OP-Base/lib");
use OP::Base qw/:vars :funcs/;
# }}}

my(%modules);

sub set_these_cmdopts;

# set_these_cmdopts(){{{ 
sub set_these_cmdopts(){ 
  @cmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{ name	=>	"i", 			desc	=>	"Short option"	}
	,{ name	=>	"r", 			desc	=>	"Run the script"	}
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
} 
#}}}
# main() {{{

sub main(){
  &sbvars();
  &setsdata();
  &setfiles();
  &set_these_cmdopts();
  &setcmdopts();
  &getopt();
  $files{mods}="$shd/inc/modules_to_install.i.dat";
  %modules=%{&readhash($files{mods})};
  foreach my $mod (keys %modules) {
	 my $dirmod="$shd/" . $modules{$mod};
	 chdir $dirmod;
	 system("perl Makefile.PL PREFIX=$ENV{HOME}");
	 system("make && make install");
  }
}
# }}}

# }}}

&main();

