
package OP::cgi::perldoc;

use CGI;

use parent qw( 
	OP::cgi 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

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

	my $lines=[
		$q->start_html('PerldocQuery'), 
		$q->start_form(
			-action => "$sname/perldoc/response",
			-target => "response",
		),
		"<table border=1>",
			"<tr>",
			   "<td>",
					$q->submit('submit_pdfview_perldoc'  , 'View PDF'),
			   "</td>",
			"</tr>",
		"</table>",
		# -------------- View/Generate HTML 
		$q->end_form,
		$q->end_html,
	];

	print join("\n",@$lines) . "\n";


}

sub init_vars {
	my $self=shift;
}


1;
