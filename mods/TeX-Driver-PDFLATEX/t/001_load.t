# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'TeX::Driver::PDFLATEX' ); }

my $object = TeX::Driver::PDFLATEX->new ();
isa_ok ($object, 'TeX::Driver::PDFLATEX');


