# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Script' ); }

my $object = OP::Script->new ();
isa_ok ($object, 'OP::Script');


