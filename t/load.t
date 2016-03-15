#
#===============================================================================
#
#         FILE: load.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 9/21/2015 3:12:32 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

BEGIN { use_ok( 'OP::PAPERS::PSH' ); }

my $object = OP::PAPERS::PSH->new ();
isa_ok ($object, 'OP::PAPERS::PSH');
