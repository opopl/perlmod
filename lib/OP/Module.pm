
package OP::Module;

use strict;
use warnings;

use File::Slurp qw( read_file );
use Env qw( $hm  );
use File::Spec::Functions qw( catfile );

use parent qw( Class::Accessor::Complex );


###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    textcolor
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    modulesubs
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors)
    ->mk_new;

sub update {
    my $self=shift;

    $self->retrieve_modulesubs;
}

sub retrieve_modulesubs {
    my $self=shift;

    my $module=$self->module;

    my @subs = ();
    my $mfile;

    my @lines=read_file(catfile($hm,qw(config mk vimrc),'perl_installed_modules.i.dat'));

    foreach (@lines) {
        chomp;
        /^$module\s+(\S*)\s*$/ && do {
            $mfile=$1;
            next;
        };
    }

    while (1) {
        last unless $mfile;
        last unless -e $mfile;

        my @lines = read_file $mfile;
        foreach (@lines) {
            chomp;
            next if /^\s*#/;

          #/^\s*sub\s*(?<subname>\w+)[\n\s]*(|\([\w\$,\n\s]*\))[\n\s]*{/ && do {
            /^\s*sub\s*(?<subname>\w+)\s*(|\([\w\$,\s]*\))\s*{/ && do {
                push( @subs, $+{subname} );
                next;
            };
        }

        last;
    }

    @subs = sort(@subs);

    $self->modulesubs(@subs);

}

1;
