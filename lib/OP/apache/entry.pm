
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
use Apache2::SubRequest ( );
use Apache2::Response ( );
use Apache2::Const qw(OK REDIRECT);
use APR::Table ();
use CGI::Carp qw(fatalsToBrowser);

use OP::apache::base qw(
	$R $Q $H $PINFO $SNAME
	init_handler_vars
);
use CGI qw(:standard);
use File::Find ();
use File::Spec::Functions  qw(catfile);
use File::Slurp qw(read_file);

###our
our @APPS;
our %DOCS;
our %LISTS;

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

	%DOCS=(
		practical_mod_perl	=> '', 
		apache_the_definitive_guide => '/doc/books',
	);

	$LISTS{DOCS}=[qw(
		apache_the_definitive_guide
		practical_mod_perl	
	)];

	
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
		/^controlpanel_act/ && do {

			my @l=(start_html);

			if ($R->param('submit_app')) {
				my $app=$R->param('choosen_app');
	
				$R->custom_response( REDIRECT, "/$app" );
				return REDIRECT;

			}elsif($R->param('submit_doc')) {

				my $doc=$R->param('choosen_doc');
				my $dir=$DOCS{$doc};

				my @files=map { my $f=catfile( $dir , $doc, "index.$_" ); -e $f ? $f : () } qw(html htm);

				#push(@l,map { br,$_ } @files);
				#push(@l,end_html);
				#$R->print(@l);
	
				#return OK;

				if (@files) {
					my $url;
					
					$url=shift @files;
					$url='http://www.yandex.ua';
	
					$R->custom_response( REDIRECT, $url );
					return REDIRECT;

					#$R->lookup_uri("$file")->run;
					#$R->internal_redirect_handler($url)->run;
					#
					#$R->headers_out->set(Location => $url);
					#$R->status(REDIRECT);

				}
					
			}
		};
		/^controlpanel/ && do {
			print_html_controlpanel;
			return OK;
		};

	}
		
	return OK;

}

sub print_html_frameset {

	$R->print(<<EOF);
<html><head><title>Entry</title></head>
<frameset rows="20%,80%">
	<frame src="localhost/controlpanel" name="controlpanel">
	<frame src="localhost/output" name="output">
</frameset></html>
EOF

}

sub print_html_controlpanel {

	$R->print(
		start_html,
        start_form(
        	-action => "controlpanel_act",
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
			-value 	=> 'Run app'),
		hr,
		'Select doc: ',
		popup_menu(
			-name 	=> 'choosen_doc',
			-values => $LISTS{DOCS},
		),
		submit( 
			-name 	=> 'submit_doc', 
			-value 	=> 'View doc'),
		hr,
		end_form,
		end_html,
	);

}

1;
