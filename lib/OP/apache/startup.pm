
package OP::apache::startup;
 
use strict;
use warnings;

=head1 NAME

OP::apache::startup

=head1 METHODS

=cut

=head3 main

X<main,OP::apache::startup>

=cut

use Apache2();

use lib qw(/opt/apache/perl);

# enable if the mod_perl 1.0 compatibility is needed
# use Apache::compat ( );

# preload all mp2 modules
# use ModPerl::MethodLookup;
# ModPerl::MethodLookup::preload_all_modules( );

use ModPerl::Util ( ); #for CORE::GLOBAL::exit

use Apache::RequestRec ( );
use Apache::RequestIO ( );
use Apache::RequestUtil ( );

use Apache::Server ( );
use Apache::ServerUtil ( );
use Apache::Connection ( );
use Apache::Log ( );

use APR::Table ( );

use ModPerl::Registry ( );

use Apache::Const -compile => ':common';
use APR::Const -compile => ':common';

sub main { 
	my $self=shift;
   
}
 
1; 
