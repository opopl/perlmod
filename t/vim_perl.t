#
#===============================================================================
#
#         FILE: vim_perl.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 3/16/2018 1:21:31 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print
use Vim::Perl qw( :vars :funcs );

my @list=('a'..'z');

VimCmd('let list=[]');
VimLet('list',[@list]);
