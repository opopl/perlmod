
package OP::apache::entry;

use strict;
use warnings;

=head1 NAME

OP::apache::entry 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Request ( );
use Apache2::Response ( );
use Apache2::Const qw(OK REDIRECT);

use OP::apache::base qw(
	$R $Q $H $PINFO $SNAME
	init_handler_vars
);
use CGI qw(:standard);

our @APPS;

sub init_vars;
sub print_html_;
sub print_html_frameset;
sub print_html_controlpanel;

sub init_vars {

	@APPS=qw(
		printenv1
		printenv2
		mp_eforms
		mp_perldoc
		navbar
		logs
		search
		perldoc
	);
	
}

sub handler {
	init_handler_vars(@_);
	init_vars;

	$R->content_type('text/html');

	unless($PINFO){
		print_html_frameset ;
		return OK;
	}

	for($PINFO){
		/^load_app/ && do {
			my $app=$R->param('choosen_app');

			$R->custom_response( REDIRECT, "http://localhost/$app" );
			return REDIRECT;
		};
		/^controlpanel/ && do {
			print_html_controlpanel;
			return OK;
		};

	}
		
	return OK;

}

sub print_html_frameset {

	$SNAME='localhost';

	$R->print(<<EOF);
<html><head><title>Entry</title></head>
<frameset rows="20%,80%">
<frame src="$SNAME/controlpanel" name="controlpanel">
<frame src="$SNAME/output" name="output">
</frameset></html>
EOF

}

sub print_html_controlpanel {

	$R->print(
		start_html,
        start_form(
        	-action => "load_app",
        	-target => "output",
        ),
		hr,
		'Select app: ',
		popup_menu(
			-name 	=> 'choosen_app',
			-values => \@APPS,
		),
		submit( 
			-name 	=> 'submit_app', 
			-value 	=> 'Go!'),
		hr,
		end_form,
		end_html,
	);

}

1;
