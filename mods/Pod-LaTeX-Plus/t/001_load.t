# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Pod::LaTeX::Plus' ); }

my $object = Pod::LaTeX::Plus->new ();
isa_ok ($object, 'Pod::LaTeX::Plus');


