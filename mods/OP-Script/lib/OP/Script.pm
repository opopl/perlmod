package OP::Script;

use strict;
use warnings;

use File::Basename;
use FindBin;
use Getopt::Long;
use Pod::Usage;
use OP::Base qw/:vars :funcs/;

our $VERSION     = '0.01';

sub new
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}

sub get_opt(){
	my $self=shift;

	&OP::Base::sbvars();
  	&OP::Base::setsdata();
  	&OP::Base::setfiles();

  	$self->set_these_cmdopts();

  	&OP::Base::setcmdopts();
  	&OP::Base::getopt();
}

sub set_these_cmdopts(){ 
  my $self=shift;
  @cmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{ name	=>	"i", 			desc	=>	"Short option"	}
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
}

# main() {{{
sub main(){
  my $self=shift;
  
  &OP::Base::sbvars();
  &OP::Base::setsdata();
  &OP::Base::setfiles();

  &set_these_cmdopts();

  &OP::Base::setcmdopts();
  &OP::Base::getopt();

}
# }}}

# }}}


1;
