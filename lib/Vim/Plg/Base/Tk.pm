
package Vim::Plg::Base::Tk;

use Tk;

use strict;
use warnings;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub run {
	my $self=shift;

 	my $mw = new MainWindow;

	MainLoop;
}

1;



