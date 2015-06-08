
package OP::docperltex::makeshell;

use warnings;
use strict;

use base qw( 
	OP::Shell 
	OP::Makefile 
);

use File::Spec::Functions qw(catfile);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	rootdir
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

sub _begin {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}
	
sub main {
	my $self=shift;
	
	$self->OP::Shell::main;

}

sub init_vars {
	my $self=shift;

	$self->OP::Shell::init_vars;

	$self->rootdir(catfile(qw(doc perl tex)));
	#$self->files(
	#);

}

sub make {
    my $self=shift;

    my $args=shift // '';

    chdir($self->rootdir) || die $!;

    my $cmd=join(";", "cd " . $self->rootdir, "make " . $args);

	$self->_sys($cmd);

}

1;
