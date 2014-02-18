# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Pod::Parser::VimHelp' ); }

my $object = Pod::Parser::VimHelp->new ();
isa_ok ($object, 'Pod::Parser::VimHelp');


