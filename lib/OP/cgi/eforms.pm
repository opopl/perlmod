
package OP::cgi::eforms;
 
use strict;
use warnings;

use CGI;
use Switch;

use parent qw( OP::cgi );

###__ACCESSORS_SCALAR
my @scalar_accessors=qw();

###__ACCESSORS_HASH
my @hash_accessors=qw();

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors)
	->mk_new;
	
sub main {
	my $self=shift;
	
	$self->init_vars;

	my $q=CGI->new;

	my $sname=$q->script_name;

	print $q->header;

	my $pinfo=$q->path_info;

	$pinfo =~ s{^\/(\w+)\/.*$}{$1}g;

	switch($pinfo){
		case('') { 
			$self->_cgi_eforms;
		}
		case(/query/) { 
			$self->_cgi_frame_query;
		}
		case(/response/) { 
			$self->_cgi_frame_response;
		}
	}

	print $q->end_html . "\n";

    exit 0;

}

sub _cgi_eforms {
	my $self=shift;

	my $q=CGI->new;

	my $sname=$q->script_name;

	my $lines=[
		$q->start_html('Eforms'), 
			$q->h1('Create a filled form'),
		   	$q->start_form(
				-action => "$sname/response",
				-target => "response",
			),
			"<table border=1>",
				"<tr>",
				   "<td>",
						$q->submit('submit_pdfview'  , 'View PDF'),
				   "</td>",
				"</tr>",
			"</table>",
			$q->end_form,
		$q->end_html,
	];

	print join("\n",@$lines) . "\n";

}

sub init_vars {
	my $self=shift;
}


1;
 
