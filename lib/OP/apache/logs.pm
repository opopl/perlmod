
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
use Apache2::Const qw(OK);
use Apache2::Request ();
use Apache2::ServerUtil ();

use File::Slurp qw(read_file);

use OP::apache::base qw(
	$R $Q $H $PINFO $SNAME
	init_handler_vars $SERVROOT %FILES
);
use CGI qw(:standard);

sub init_vars;

sub init_vars {
}

sub handler {
	init_handler_vars(@_);
	init_vars;

	$R->content_type('text/html');

	unless($PINFO){
		my @lines=map { br,$_ } read_file($FILES{error_log});

		$R->print(
			start_html,
			b('Log files'),
			br,$FILES{error_log},
			hr,
			@lines,
			end_html
		);
		
		return OK;
	}

	for($PINFO){
		/^ / && do {
			next;
		};
	}
		
	return OK;

}
1;
