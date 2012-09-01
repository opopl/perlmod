# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Parse::BL' ); }

my $object = OP::Parse::BL->new ();
isa_ok ($object, 'OP::Parse::BL');


