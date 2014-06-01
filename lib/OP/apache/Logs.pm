
package OP::apache::Logs;

use strict;
use warnings;

=head1 NAME

Apache::Logs 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Const -compile => qw(OK);

sub handler {
	my $r = shift;

	$r->content_type('text/plain');

	return Apache2::Const::OK;

}

1;
