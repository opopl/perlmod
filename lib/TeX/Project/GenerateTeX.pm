
package TeX::Project::GenerateTeX;

use warnings;
use strict;
 
use parent qw( Text::Generate::TeX );

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

	my $ref=shift;

	unless(ref $ref){
		$self->_cmd('ii',$ref);
			
	}elsif(ref $ref eq "ARRAY"){
		foreach my $sec (@$ref) {
			$self->ii($sec);
		}
	}

}

sub icfg {
	my $self=shift;

	my $cfgname=shift;

	$self->_cmd('icfg',$cfgname);

}

sub TEXHT {
	my $self=shift;

	my $cmd=shift;
	my $nrm=shift || '';

	$self->_add_line('\TEXHT{' . $cmd . '}{' . $nrm . '}' );

}

sub NextFile {
	my $self=shift;

	my $fname=shift;

	$self->TEXHT('\NextFile{' . $fname . '.html}' );

}




1;
