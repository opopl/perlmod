# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::GOPS::KW' ); }

my $object = OP::GOPS::KW->new ();
isa_ok ($object, 'OP::GOPS::KW');


