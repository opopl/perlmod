# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Viewer' ); }

my $object = OP::Viewer->new ();
isa_ok ($object, 'OP::Viewer');


