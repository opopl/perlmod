
package OP::Makefile;
 
use warnings;
use strict;

use base qw( Class::Accessor::Complex );

use File::Basename qw(dirname);
use File::Spec::Functions qw(catfile rel2abs curdir);
use File::Slurp qw(read_file);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
	MKTARGETS
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);
	
sub main {
	my $self=shift;
	
	$self->init_vars;

}

sub init_vars {
	my $self=shift;

    $self->_read_MKTARGETS();

}

sub _read_MKTARGETS {
    my $self=shift;

    my $tmk=shift || $self->files("maketex_mk");

    my $makefile_dir=dirname($tmk);
    my $old_dir=rel2abs(curdir());

    chdir $makefile_dir;

    unless (-e $tmk) {
		my @w;

		push @w, 
			'_read_MKTARGETS(): input makefile not found:',
			$tmk;

        $self->warn($_) for(@w);
        return;
    }

    my @lines=read_file $tmk;

    foreach (@lines) {
        chomp;
        next if /^\$/ || /^\s*#/;

        if (/^([^:\s]+):\s*[^=]*$/){
            $self->MKTARGETS_push($1);
        }
        elsif (/^(\S[^:]+):\s*[^=]*$/){
            $self->MKTARGETS_push(split(" ",$1));
        }

        if (/^include\s+(.+)/){
          $self->_read_MKTARGETS($1);
        }
    }

    $self->MKTARGETS_sort();
    $self->MKTARGETS_uniq();

    chdir $old_dir;

}


1;
