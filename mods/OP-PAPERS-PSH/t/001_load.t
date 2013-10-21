# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::PAPERS::PSH' ); }

my $object = OP::PAPERS::PSH->new ();
isa_ok ($object, 'OP::PAPERS::PSH');


