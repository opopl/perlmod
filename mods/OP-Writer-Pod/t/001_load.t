# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Writer::Pod' ); }

my $object = OP::Writer::Pod->new ();
isa_ok ($object, 'OP::Writer::Pod');


