# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'OP::Perl::Edit' ); }

my $object = OP::Perl::Edit->new ();
isa_ok ($object, 'OP::Perl::Edit');


