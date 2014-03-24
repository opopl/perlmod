
package OP::cgi;

use parent qw( 
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
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
	
sub main {
	my $self=shift;
	
	$self->init_vars;
}

sub init_vars {
	my $self=shift;
}


1;
