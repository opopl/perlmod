# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::TEX::LATEX2HTML' ); }

my $object = OP::TEX::LATEX2HTML->new ();
isa_ok ($object, 'OP::TEX::LATEX2HTML');


