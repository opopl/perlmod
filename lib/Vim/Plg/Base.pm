
package Vim::Plg::Base;

use strict;
use warnings;

use Vim::Perl qw();
use File::Spec::Functions qw(catfile);
use File::Find qw(find);
use File::Dat::Utils qw(readarr);

use base qw( Class::Accessor::Complex );


sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;


	my $dirs = {
		plgroot => catfile($ENV{VIMRUNTIME},qw(plg base)),
	};

	my @types=qw(list dict listlines );
	$self->dattypes(@types);
	foreach my $type (@types) {
		$dirs->{'dat_'.$type} =catfile($dirs->{plgroot},qw(data),$type);
	}

	my $h={
		dirs => $dirs,
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self->init_dat;
}

sub init_dat {
	my $self=shift;

	my @types=$self->dattypes;
	my @dirs = map { $self->{dirs}->{'dat_'.$_} } @types;
	find({ 
		wanted => sub { 
			my $name=$File::Find::name;
			my $dir=$File::Find::dir;
			my $pat=qr/\.i\.dat$/;

			/$pat/ && do {
					s/$pat//g;
					$self->datfiles( $_ => $name );
			};
			 
		} 
	},@dirs
	);

	my $dat_plg = $self->datfiles('plugins');
	my @p       = readarr($dat_plg);
	$self->plugins([@p]);

}

BEGIN {
	###__ACCESSORS_SCALAR
	our @scalar_accessors=qw(
		dattypes
		plugins
	);
	
	###__ACCESSORS_HASH
	our @hash_accessors=qw(
		datfiles
		vars
	);
	
	###__ACCESSORS_ARRAY
	our @array_accessors=qw();

	__PACKAGE__
		->mk_scalar_accessors(@scalar_accessors)
		->mk_array_accessors(@array_accessors)
		->mk_hash_accessors(@hash_accessors)
		->mk_new;

	use Data::Dumper qw(Dumper);
	my $p = __PACKAGE__->new;
	$p->init_dat;
	#print Dumper({%{ $p->datfiles } }) . "\n";
	print Dumper([$p->plugins]) . "\n";
}

1;
 

