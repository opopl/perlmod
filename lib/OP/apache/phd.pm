
package OP::apache::phd;

use strict;
use warnings;

=head1 NAME

OP::apache::phd 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Request ( );
use Apache2::Const qw(OK );

use OP::apache::base qw($R $Q $PINFO $SNAME);

sub handler {
	$R = Apache2::Request->new(shift);

	$R->content_type('text/plain');

	return OK;

}

1;
