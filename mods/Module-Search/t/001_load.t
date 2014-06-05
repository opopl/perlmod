# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Module::Search' ); }

my $object = Module::Search->new ();
isa_ok ($object, 'Module::Search');


