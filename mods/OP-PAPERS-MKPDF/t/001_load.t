# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::PAPERS::MKPDF' ); }

my $object = OP::PAPERS::MKPDF->new ();
isa_ok ($object, 'OP::PAPERS::MKPDF');


