# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::TEX::PERLTEX' ); }

my $object = OP::TEX::PERLTEX->new ();
isa_ok ($object, 'OP::TEX::PERLTEX');


