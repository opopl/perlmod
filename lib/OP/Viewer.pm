package OP::Viewer;

use strict;
use warnings;

use parent qw(Class::Accessor::Complex);

__PACKAGE__
###_ACCESSORS_SCALAR
	->mk_scalar_accessors(qw(
		exe
		viewcmd
	));

sub view() {
	my $self=shift;

	system($self->viewcmd);
}

sub init() {
	my $self=shift;

	#body ...
}

sub new
{
    my ($class, %opts) = @_;
    my $self = bless ({}, ref ($class) || $class);
	$self->init(%opts);
    return $self;
}

1;
# The preceding line will help the module return a true value

