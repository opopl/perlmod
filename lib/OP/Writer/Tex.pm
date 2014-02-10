package OP::Writer::Tex;

use strict;
use warnings;

###begin
BEGIN {
    use Env qw( $hm $PERLMODDIR );
    
    use lib("$PERLMODDIR/mods/OP-TEX-Text/lib");

    use parent qw(OP::TEX::Text);
}

1;


