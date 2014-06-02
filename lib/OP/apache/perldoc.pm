
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

###subs
sub printhtml_response;
sub printhtml_;
sub handler;
sub _response_searchmodule;
sub _html_start;
sub _html_restart;
sub _html_print;
sub _html_end;
sub _html_clear;
sub _html_add;


###our
our $HTMLLINES;
our @SUBMITS;

our ($R,$REQ,$Q);
our $SNAME;
our $PINFO;

sub _html_add {
    push(@$HTMLLINES, @_ );
}

sub _html_start {
	_html_add
		$Q->start_html;
}

sub _html_restart {
	_html_clear;
	_html_start;
}

sub _html_print {
    $R->print($_ . "\n") for(@$HTMLLINES);
}

sub _html_clear {
	@$HTMLLINES=();
}

sub _html_end {
	_html_add
		$Q->end_html;
}

sub handler {
    $R = Apache2::Request->new(shift);
    
    $Q = CGI->new($R);

    $PINFO = $R->path_info =~ s{^\/}{}gr ;

	$SNAME = $R->uri =~ s{\/$PINFO$}{}gr;

    @SUBMITS=qw( searchmodule );

    $R->content_type('text/html');

	_html_restart;
    eval 'printhtml_' . $PINFO ;
	_html_end;

	_html_print;

    return OK;

}

sub printhtml_searchform {

	_html_add
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
    ;
}

sub printhtml_ {

	_html_clear;
	_html_add
		$Q->frameset( 
			{ -rows => '20%,70%' }, 
			$Q->frame({ 
					-src 	=> "$SNAME/searchform", 	
					-name 	=> 'searchform' }),
			$Q->frame({ 
					-src 	=> "$SNAME/response", 	
					-name 	=> 'response' }),
		);

}

sub _response_searchmodule {

	_html_add
        $Q->h1('Found modules'),
        $Q->hr 
    ;

    my $mod=$R->param('perlmodule');
    my $s=Apache::perldoc::pmsearch->new( pattern => $mod );

    $s->search( untaint => 1 );

	_html_add
        $Q->p('Provided search pattern:'), 
        $Q->p($mod),
        $Q->p('Value of @INC:'), 
        $Q->p(join(':',@INC)),
    ;

	my @modules=@{$s->{modules}};

	_html_add '<table border="1">';

	foreach my $module (@modules) {
		my $paths=$s->{modpaths}->{$module};

		foreach my $path (@$paths) {
			_html_add 
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
				;
		}
	}

	_html_add '</table>';

}

sub printhtml_loadsource {
	my $path=uri_unescape( $R->param('path') );

	_html_add $Q->p($path);
}

sub printhtml_response {

    foreach my $id (@SUBMITS) {
		if ($R->param('submit_' . $id )){
			eval '_response_' . $id;
        }
    }


}

1;
