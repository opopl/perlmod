
package Apache2::BibMan;

use strict;
use warnings;

=head1 NAME

Apache2::BibMan 

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
	$LOG
	init_handler_vars
);

# table rows, see init_vars where they are defined
our %rows;

# default values, see init_vars 
our %defaults;

our ( $BIBSQL, $DBH );

our $ROOT;

sub init_vars;

sub print_html_;
sub print_html_view_pkey;
sub print_html_response;

sub init_vars {

	%defaults=( 
		user 			=> 'bibuser',
		password	 	=> 'bib',
		db			 	=> 'bibdb',
		table_keys		=> 'pkeys',
		bibpath		 	=> catfile($hm,qw( wrk p repdoc.bib )),
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

sub print_html_ {

	$R->print(
		start_html,
		start_form( 
			-action => "$SNAME/options",
		),
		submit( 
			-name 	=> 'submit_options', 
			-value 	=> 'Options',
		),
		end_form,
		end_html
	);

	OK;
}

sub print_html_options {

	$R->print(
		start_html,
		start_form( 
			-action => "response",
		),
		b('MySQL database connection parameters'),
		table(@{$rows{mysqlconf}}),
		hr,
		b('BibTeX configuration'),
		table(@{$rows{bibtex}}),
		hr,
		submit( 
			-name 	=> 'submit_process_bib', 
			-value 	=> 'Process BibTeX file',
		),
		end_form,
		end_html
	);

	OK;
}

sub print_html_response {
	my %pars;

	foreach my $id (qw( user password db bibpath )) {
		$pars{$id}=$R->param($id);
	}

	$BIBSQL=BibTeX::MySQL->new( %pars ) 
		or die "Failure to create a BibTeX::MySQL object";

	$BIBSQL->connect
		or die "Failure to connect to the database";

	$BIBSQL->parsebib
		or die "Failure to parse the bib file";

	$R->print(  
		'Select a BibTeX key: ',
		start_form(
			-action => "view_pkey"
		),
		popup_menu(
			-name 	=> 'pkey',
			-values => [ $BIBSQL->pkeys ],
		),
       	submit(
       		-name       => 'submit_view_pkey',
        	-value      => 'View BibTeX key record',
       	),
		end_form,
	);
	$R->print( end_html );

	$BIBSQL->fillsql
		or die "Failure to fill the MySQL database";

	OK;

}

sub print_html_view_pkey {

	my $pkey=$R->param('pkey');

	$DBH=$BIBSQL->dbh;
	my $sth;

	$sth=$DBH->prepare('select * from pkeys where pkey = ?');
	$sth->execute($pkey);

	my @rows;
	while (my @ary=$sth->fetchrow_array) {
		push(@rows,map { p,$_ } @ary);
	}

	$R->print( 
		start_html,
		@rows,
		end_html ,
	);

	OK;

}

sub handler {
	init_handler_vars(@_);
	init_vars;

	$R->content_type('text/html');

	my $code;
	$LOG->info('PINFO: ' . $PINFO );
	eval '$code = print_html_' . $PINFO;
	return $code unless $@;

	OK;

}

1;
