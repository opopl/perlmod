
package Text::Generate::Utils;

use warnings;
use strict;

use List::Compare;
use parent qw( Exporter );

our @EXPORT_OK=qw( 
	_arrays_equal 
	_hash_add
);
 
sub _arrays_equal;
sub _hash_add;

sub _arrays_equal {
    my ($a,$b)=@_;

    my $lc=List::Compare->new($a,$b);
    my @d=$lc->get_symdiff;

    return @d == 0 ? 1 : 0 ;
}

sub _hash_add {
    my ( $h, $ih ) = @_;

    while ( my ( $k, $v ) = each %{$ih} ) {
        $h->{$k} = $ih->{$k};
    }
    wantarray ? %$h : $h;

}

1;

