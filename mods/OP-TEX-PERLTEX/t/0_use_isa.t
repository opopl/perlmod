# -*- perl -*-

use strict;
use warnings;

use Test::More tests => 2;                     

BEGIN { use_ok( 'OP::TEX::PERLTEX' ); }

my $object = OP::TEX::PERLTEX->new();
isa_ok ($object, 'OP::TEX::PERLTEX');

