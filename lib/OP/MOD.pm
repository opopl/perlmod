package OP::MOD;

use strict;
use warnings;

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw();

###__ACCESSORS_HASH
our @hash_accessors=qw(
	accessors
	vars
);

###__ACCESSORS_ARRAY
our @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

sub init_vars(){
	my $self=shift;

	$self->vars(qw());

}

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();
}

sub run() {
	my $self=shift;
}

sub main() {
    my $self = shift;

    $self->init_vars();

    $self->get_opt();

    $self->run();

}

sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

1;
