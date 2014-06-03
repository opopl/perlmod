
package Text::Generate::Utils;

use warnings;
use strict;

use List::Compare;
use parent qw( Exporter );

our @EXPORT_OK=qw( _arrays_equal );
 
sub _arrays_equal;

sub _arrays_equal {
    my ($a,$b)=@_;

    my $lc=List::Compare->new($a,$b);
    my @d=$lc->get_symdiff;

    return @d == 0 ? 1 : 0 ;
}

1;

