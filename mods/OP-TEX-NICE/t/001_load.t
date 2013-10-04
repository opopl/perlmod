# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::TEX::NICE' ); }

my $object = OP::TEX::NICE->new ();
isa_ok ($object, 'OP::TEX::NICE');


