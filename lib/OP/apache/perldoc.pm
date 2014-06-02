
package OP::apache::perldoc;

use strict;
use warnings;

=head1 NAME

Apache::perldoc

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

###use
use Apache2::RequestRec (); # for $R->content_type
use Apache2::Const  qw(OK DECLINED);
use Apache2::Request;
use CGI; 
use Data::Dumper;
use URI::Escape;

use OP::apache::perldoc::pmsearch;
use OP::apache::base qw(
	$PINFO $SNAME
	$R $H $Q
	init_handler_vars
);
use OP::apache::base::html;

###subs
sub printhtml_response;
sub printhtml_;
sub handler;
sub _response_searchmodule;

###our
our @SUBMITS;

sub init_vars {

    @SUBMITS=qw( searchmodule );

}

sub handler {
	init_handler_vars(@_);
	init_vars;

    $R->content_type('text/html');

	$H->restart;
    eval 'printhtml_' . $PINFO ;
	$H->end;

	$H->print;

    return OK;

}

sub printhtml_searchform {

	$H->_add(
        $Q->h1('Perl modules search form'),
        $Q->hr,
        $Q->start_form(
			-action => "$SNAME/response",
			-target => "response",
        ),
        $Q->submit('submit_searchmodule', 'Search a perl module:'), 
        $Q->textfield(
            -name 		=> 'perlmodule', 
            -default 	=> 'File::Slurp', 
            -size 		=>  50 
        ),
        $Q->hr,
		$Q->checkbox_group(
			-name		=> 'PatternProps',
			-values		=>	[ 'At start', 'At end'  ],
			-defaults	=>	[ 'At start' ]	),
        $Q->end_form,
	);
}

sub printhtml_ {

	$H->clear;
	$H->_add(
		$Q->frameset( 
			{ -rows => '20%,70%' }, 
			$Q->frame({ 
					-src 	=> "$SNAME/searchform", 	
					-name 	=> 'searchform' }),
			$Q->frame({ 
					-src 	=> "$SNAME/response", 	
					-name 	=> 'response' }),
		)
	);

}

sub _response_searchmodule {

	$H->_add(
        $Q->h1('Found modules'),
        $Q->hr, 
	);

    my $mod=$R->param('perlmodule');
    my $s=Apache::perldoc::pmsearch->new( pattern => $mod );

	$s->search( untaint => 1 );

	$H->_add(
        $Q->p('Provided search pattern:'), 
        $Q->p($mod),
        $Q->p('Value of @INC:'), 
        $Q->p(join(':',@INC)),
	);

	my @modules=@{$s->{modules}};

	$H->_add( '<table border="1">' );

	foreach my $module (@modules) {
		my $paths=$s->{modpaths}->{$module};

		foreach my $path (@$paths) {
			$H->_add(
				'<tr>',
				$Q->td($module),
				$Q->td( 
					$Q->a( { 
						-href 	=> "$SNAME/loadsource?path=" 
							. uri_escape($path),
						-target => 'response',
						}, $path 
					)
				),
				'</tr>',
			);
		}
	}

	$H->_add( '</table>' );

}

sub printhtml_loadsource {
	my $path=uri_unescape( $R->param('path') );

	$H->_add( $H->Q->p($path) );
}

sub printhtml_response {

    foreach my $id (@SUBMITS) {
		if ($R->param('submit_' . $id )){
			eval '_response_' . $id;
        }
    }


}

1;
