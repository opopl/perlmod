
package OP::apache::logs;

use strict;
use warnings;

=head1 NAME

OP::apache::logs 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Const -compile => qw(OK);
use Apache2::Request ();

our $R;

sub handler {
	$R=Apache2::Request(shift);

	return Apache2::Const::OK;

}

1;
