# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::POD' ); }

my $object = OP::POD->new ();
isa_ok ($object, 'OP::POD');


