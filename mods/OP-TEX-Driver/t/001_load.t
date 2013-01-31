# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { 
	use FindBin qw($Bin);
	use lib ("$Bin/../lib", "$Bin/lib");
	use_ok( 'OP::TEX::Driver' ); 
}

#my $object = OP::TEX::Driver->new();
#isa_ok ($object, 'OP::TEX::Driver');
	use_ok( 'OP::TEX::Driver' ); 
