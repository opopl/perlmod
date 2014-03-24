
package OP::Projs::Base;

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

use parent qw(Class::Accessor::Complex);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
    PROJ
    PROJSDIR
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
    DATA
    FILES
	PACKOPTS
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
	USEDPACKS
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors)
    ->mk_new;

sub init_FILES {
    my $self=shift;

    my( $proj ) = ( $Script =~ /^(\w+)\./ );
    $self->PROJ($proj);

    $self->FILES( 'oldpdf' => catfile($PDFOUT,$self->PROJ . '.pdf'));
    
    $self->FILES( '_main_' => catfile($Bin,$self->PROJ . '.tex' ));
    
    foreach my $id (qw( preamble begin defs body )) {
        $self->FILES( $id => catfile($Bin,$self->PROJ . '.' . $id . '.tex' ));
    }

    foreach my $id (qw( DATA PACKOPTS USEDPACKS TRANS HEADER NAMES secorder )) {
		my $projdat=catfile($Bin,$self->PROJ . '.' . $id . '.i.dat' ); 
		my $dat=catfile($Bin, $id . '.i.dat' ); 

		my $datfile=( -e $projdat ) ? $projdat : $dat; 

        $self->FILES( $id => $datfile );
    }

}

sub init_vars {
    my $self=shift;

	$self->PROJSDIR($Bin);

    $self->init_FILES;
    $self->init_DATA;
    $self->init_PACKS;

}

sub init_PACKS {
    my $self=shift;

	return unless -e $self->FILES("USEDPACKS");

	$self->USEDPACKS(readarr($self->FILES("USEDPACKS")));

	if(-e $self->FILES("PACKOPTS")){
		$self->PACKOPTS(readhash($self->FILES('PACKOPTS')));
	}


}

sub init_DATA {
    my $self=shift;

	return unless -e $self->FILES("DATA");

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
