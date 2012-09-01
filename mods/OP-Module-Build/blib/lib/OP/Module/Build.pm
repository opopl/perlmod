package OP::Module::Build;

use strict;
use Module::Build;

use vars qw($VERSION @ISA);
$VERSION     = '0.01';
@ISA         = qw(Module::Build);

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}

1;

