
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
use Apache2::Const -compile => qw(OK REDIRECT);

use OP::apache::base qw(
	$R $Q $H $PINFO $SNAME
	init_handler_vars
);
use CGI qw(:standard);

our @APPS;

sub init_vars;
sub print_html_;

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

	CASE: {
		$_ = $PINFO ;
		/^app$/ and do {
			$R->custom_response( Apache2::Const::REDIRECT, "$SNAME/$PINFO" );
			last CASE;
		};

		print_html_ ;
	}
		
	return Apache2::Const::OK;

}

sub print_html_ {

	$R->print(
		start_html,
		hr,
		'Select app: ',
		popup_menu(
			-name 	=> 'choose_app',
			-values =>  \@APPS,
		),
        start_form(
        	-action => "http://localhost/app",
        	-target => "response",
        ),
		hr,
		submit( 
			-name 	=> 'submit_app', 
			-value 	=> 'Go!'),
		end_form,
		end_html,
	);

}

1;
