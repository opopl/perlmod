
package OP::apache::search;

use strict;
use warnings;

=head1 NAME

OP::apache::search

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

use Apache2::RequestRec (); 
use Apache2::Const  qw( OK REDIRECT );
use Apache2::Request ();
use Apache2::Response ();

our $R;

sub handler {
    $R = Apache2::Request->new(shift);

	my $url='http://yandex.ua/yandsearch?text=&lr=143';

	$R->custom_response(REDIRECT, $url);
    
}


1;
