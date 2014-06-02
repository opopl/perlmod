
package OP::apache::printenv::2;

use strict;
use warnings;

use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::RequestIO ( );  # for $r->print

use Apache2::Const -compile => 'OK';

sub handler {
    my $r = shift;

    $r->content_type('text/plain');
    $r->subprocess_env;
    for (sort keys %ENV){
        $r->print("$_ => $ENV{$_}\n");
    }

    return Apache2::Const::OK;
}

1;
