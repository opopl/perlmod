# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::PROJSHELL' ); }

my $object = OP::PROJSHELL->new ();
isa_ok ($object, 'OP::PROJSHELL');


