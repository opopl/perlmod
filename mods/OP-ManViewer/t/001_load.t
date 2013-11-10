# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::ManViewer' ); }

my $object = OP::ManViewer->new ();
isa_ok ($object, 'OP::ManViewer');


