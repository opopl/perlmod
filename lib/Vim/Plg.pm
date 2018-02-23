
package Vim::Plg;

use strict;
use warnings;

use strict;
use warnings;
use File::Spec::Functions qw(catfile);

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);
    return $self;
}

sub init {
	my $self=shift;

	my $dirs={
		plg  => $ENV{plg} || catfile($ENV{VIMRUNTIME},'plg'),
	};
	my $h={
		dirs => $dirs
	};
		
	my @k=keys %$h;

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}
}

1;
 

