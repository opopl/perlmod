# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Writer::Tex' ); }

my $object = OP::Writer::Tex->new ();
isa_ok ($object, 'OP::Writer::Tex');


