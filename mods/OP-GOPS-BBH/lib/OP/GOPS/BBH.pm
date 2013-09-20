
package OP::GOPS::BBH;

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

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();
}

sub init_vars(){
	my $self=shift;

	$self->vars(
	  'CHANGEACCEPT' => '',
	  'MCSTEPS'      => 'Number of Monte-Carlo steps',
	  'DGUESS'       => '',
      'SLOPPYCONV'   => '1.0D-3',
      'TIGHTCONV'    => '1.0D-4',
      'UPDATES'      => '50',
      'DGUESS'       => '0.1',
      'SAVE'         => '10',
      'CHANGEACCEPT' => '50',
      'P46'          => 1,
      'EDIFF'        => '0.001',
      'STEPS'        => '10000 1.0',
      'MAXBFGS'      => '1.0',
      'MAXIT'        => '1000 1000',
      'STEP'         => '1.9 0.0 ',
      'TEMPERATURE'  => '0.03',
      'PULL'         => '1 46 0.0'
  );
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

