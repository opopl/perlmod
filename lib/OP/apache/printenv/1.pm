
package OP::apache::printenv::1;

use strict;
use warnings;

use Apache2::RequestRec ( ); # for $r->content_type

use Apache2::Const -compile => 'OK';

sub handler {
    my $r = shift;

    $r->content_type('text/plain');
    for (sort keys %ENV){
        print "$_ => $ENV{$_}\n";
    }

    return Apache2::Const::OK;
}

1;
