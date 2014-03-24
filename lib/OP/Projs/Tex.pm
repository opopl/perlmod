
package OP::Projs::Tex;

use warnings;
use strict;
 
use parent qw( OP::TEX::Text );

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
	->mk_hash_accessors(@hash_accessors);
	
sub ii {
	my $self=shift;

	my $sec=shift;

	$self->_cmd('ii',$sec);
}

sub TEXHT {
	my $self=shift;

	my $cmd=shift;
	my $nrm=shift // '';

	$self->_add_line('\TEXHT{' . $cmd . '}{' . $nrm . '}' );

}

sub NextFile {
	my $self=shift;

	my $fname=shift;

	$self->TEXHT('\NextFile{' . $fname . '.html}' );

}




1;
