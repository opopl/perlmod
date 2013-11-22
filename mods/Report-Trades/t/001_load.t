# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Report::Trades' ); }

my $object = Report::Trades->new ();
isa_ok ($object, 'Report::Trades');


