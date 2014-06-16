
package OP::apache::bibtex;

use strict;
use warnings;

=head1 NAME

OP::apache::bibtex 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

###use
use Env qw($hm);

use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Request ( );
use Apache2::Const qw(OK);
use CGI qw(:standard);
use File::Spec::Functions qw( catfile );
use BibTeX::MySQL;
use CGI::Carp qw(fatalsToBrowser);

use OP::apache::base qw(
	$R $Q $H $PINFO $SNAME
	init_handler_vars
);

# table rows 
our %rows;

# default values
our %defaults;

sub init_vars;

sub init_vars {

	%defaults=( 
		user 			=> 'bibuser',
		password	 	=> 'bib',
		db			 	=> 'bibdb',
		table_keys		=> 'keys',
		bibpath		 	=> catfile($hm,qw(wrk p repdoc.bib )),
	);

	%rows=(
		bibtex => [
			TR( 
				td( 'BibTeX file to be loaded:' ),
				td( textfield(
					-name 		=> 'bibpath',
					-default 	=> $defaults{bibpath},
	            	-size 		=>  50 
				))
			),
		],
		mysqlconf => [
			TR( 
				td( 'User name' ),
				td( textfield(
					-name 		=> 'user',
					-default 	=> $defaults{user},
	            	-size 		=>  50 
				))
			),
			TR( 
				td( 'Password' ),
				td( textfield(
					-name 		=> 'password',
					-default 	=> $defaults{password},
	            	-size 		=>  50 
				))
			),
			TR( 
				td( 'Database name' ),
				td( textfield(
					-name 		=> 'db',
					-default 	=> $defaults{db},
	            	-size 		=>  50 
				))
			),
			TR( 
				td( 'Table for storing BibTeX keys' ),
				td( textfield(
					-name 		=> 'table_keys',
					-default 	=> $defaults{table_keys},
	            	-size 		=>  50 
				))
			),
		],
	);

}

sub handler {
	init_handler_vars(@_);
	init_vars;

	$R->content_type('text/html');

	unless($PINFO){
		$R->print(
			start_html,,
			b('MySQL database connection parameters'),
			table(@{$rows{mysqlconf}}),
			hr,
			b('BibTeX configuration'),
			table(@{$rows{bibtex}}),
			hr,
			start_form( 
				-action => "$SNAME/response",
			),
			submit( 
				-name 	=> 'submit_process_bib', 
				-value 	=> 'Process .bib file',
			),
			end_form,
			end_html
		);
		return OK;
	}

	for($PINFO){
		/^response/ && do {

			my %pars;
			foreach my $id (qw( user password db bibpath )) {
				$pars{$id}=$R->param($id);
			}

			my $bibsql=BibTeX::MySQL->new( %pars ) 
				or die "Failure to create a BibTeX::MySQL object";

			$bibsql->parsebib;

			return OK;

			$R->print( start_html );
			foreach my $pkey ($bibsql->pkeys) {
				$R->print(  
					p($pkey),
				);
			}
			$R->print( end_html );

			return OK;
	
			next;
		};
	}
		
	return OK;

}

1;
