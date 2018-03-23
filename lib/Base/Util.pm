package Base::Util;

use strict;
use warnings;

use File::Find qw(find);
use List::MoreUtils qw(minmax);

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
}


sub get_max_num {
	my $self = shift;

	my $ref  = shift;

	my $dir  = $ref->{dir};
	my $exts = $ref->{exts} || [qw(html)];

	my @files;
	my @dirs;
	push @dirs,$dir;
	
	my @nums;
	find({ 
		wanted => sub { 
		foreach my $ext (@$exts) {
			if (/^(\d+)\.$ext$/) {
				push @nums,$1;
			}
		}
		} 
	},@dirs
	);
	my ($min,$max)=(0,0);
	
	($min,$max)=minmax(@nums) if @nums;

	return $max;
}

1;
 

