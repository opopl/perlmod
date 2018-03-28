package TeX::Escape;

use strict;
use warnings;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self;
}

###tex_escape
sub escape {
	my $self = shift;

	local $_=shift;
	s/\\/\\\\/g;
	s/([_\\%#\$])/\\$1/g;

	return $_;
}

1;
 

