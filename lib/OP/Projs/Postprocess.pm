
package OP::Projs::Postprocess;

use strict;
use warnings;

###use
use Env qw($PDFOUT);

use FindBin qw( $Bin $Script );
use File::Spec::Functions qw(catfile);
use Class::Date;
use File::Slurp qw(read_file);
use LaTeX::Table;
use Data::Dumper;

use File::Copy qw(move);
use OP::TEX::Text;
use OP::Base qw(readarr readhash);

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
    PROJ
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
    DATA
    FILES
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
    $self->postprocess;
    
}

sub postprocess {
    my $self=shift;
}

sub init_FILES {
    my $self=shift;

    my( $proj ) = ( $Script =~ /^(\w+)\./ );
    $self->PROJ($proj);

    $self->FILES( 'oldpdf' => catfile($PDFOUT,$self->PROJ . '.pdf'));
    
    $self->FILES( '_main_' => catfile($Bin,$self->PROJ . '.tex' ));
    
    foreach my $id (qw( preamble begin defs body )) {
        $self->FILES( $id => catfile($Bin,$self->PROJ . '.' . $id . '.tex' ));
    }

    foreach my $id (qw( DATA PACKOPTS USEDPACKS TRANS HEADER NAMES )) {
        $self->FILES( $id => catfile($Bin,$self->PROJ . '.' . $id . '.i.dat' ));
    }

}

sub init_vars {
    my $self=shift;

    $self->init_FILES;
    $self->init_DATA;

}

sub init_DATA {
    my $self=shift;

    my @lines=read_file($self->FILES("DATA"));

    foreach (@lines) {
        chomp;
        next if /^\s*#/;
        my $line=$_;
        my @F=split(' ',$line);
        my $key=shift @F;
        my $val=join(' ',@F);

        $self->DATA( $key => $val );
    }
}

1;
