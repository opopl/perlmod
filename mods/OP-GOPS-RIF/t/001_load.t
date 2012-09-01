# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::GOPS::RIF' ); }

my $object = OP::GOPS::RIF->new ();
isa_ok ($object, 'OP::GOPS::RIF');


