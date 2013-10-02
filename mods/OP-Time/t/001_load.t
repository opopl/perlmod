# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Time' ); }

my $object = OP::Time->new ();
isa_ok ($object, 'OP::Time');


