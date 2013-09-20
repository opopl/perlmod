# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::GOPS::BBH' ); }

my $object = OP::GOPS::BBH->new ();
isa_ok ($object, 'OP::GOPS::BBH');


