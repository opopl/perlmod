# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Pod::Display::Pdf' ); }

my $object = Pod::Display::Pdf->new ();
isa_ok ($object, 'Pod::Display::Pdf');


