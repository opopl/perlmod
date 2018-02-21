
package Vim::DBI;

use strict;
use warnings;

use Vim::Perl qw( :vars :funcs );

our $LastResult;

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

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}
}




1;
 

