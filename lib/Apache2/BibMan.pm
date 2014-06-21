
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
use Apache::DBI ();

use CGI qw(:standard);
use File::Spec::Functions qw( catfile );
use Data::Dumper;

use BibTeX::MySQL qw(@CONFKEYS %DESC);

use CGI::Carp qw(fatalsToBrowser);

use OP::apache::base qw(
	$R $Q $H $PINFO $SNAME
	$LOG
	init_handler_vars
);

use Config::YAML;

###our

# table rows, see init_vars where they are defined
my %rows;

# default values, see init_vars 
my %DEFAULTS;

# list of existing BibTeX fields in the MySQL database
my @BIBFIELDS;

my ( $BIBSQL, $DBH );

my %FILES;

my $ROOT;

local $SIG{__DIE__} = \&Apache2::BibMan::mydie;
local $SIG{__WARN__} = \&Apache2::BibMan::mywarn;

###subs
sub init_vars;

sub print_html_;
sub print_html_view_pkey;
sub print_html_response;

sub _html_footer;
sub _html_header;

sub read_configuration;


sub mywarn {
	my $why=shift;

	print("WARNING: $why\n"), return unless $ENV{MOD_PERL};

	$R->print( 
		_html_header, 
		p({ -style => 'Color: blue' }, 'WARNING: ' . $why ),
		_html_footer, 
	);

	$LOG->warn($why);

}

sub read_configuration {
    $FILES{conf}=catfile($hm,qw( config perl bibtex_mysql.yaml ));

	unless ( $FILES{conf} ){
        mywarn('conffile is zero');
		return 0;
	}

	unless ( -e $FILES{conf} ){
        mywarn('provided conffile does not exist');
		return 0;
	}

	my $c=Config::YAML->new( 
		config => $FILES{conf},
	);
	
	foreach my $id (@CONFKEYS) {
		next unless defined $c->{$id};
	
		$DEFAULTS{$id} =  $c->{$id} ;
	}

}

sub mydie {
	my $why=shift;

	print("ERROR: $why\n"), exit 1 unless $ENV{MOD_PERL};

	$R->print( 
		_html_header, 
		p({ -style => 'Color: red' }, 'ERROR: ' . $why ),
		_html_footer, 
	);

	$LOG->error($why);

	exit 1;

}


sub init_vars {

    read_configuration;

	%rows=(
		bibtex => [
			TR( 
                td( 'bibpath' ),
				td( 'BibTeX file to be loaded:' ),
				td( textfield(
					-name 		=> 'bibpath',
					-default 	=> $DEFAULTS{bibpath},
	            	-size 		=>  50 
				))
			),
		],
		mysqlconf => [
			map { 
				TR( 
                    td( $_ ),
					td( $DESC{CONFKEYS}->{$_} ),
					td( textfield(
						-name 		=> 'user',
						-default 	=> $DEFAULTS{$_},
		            	-size 		=>  50 
					))
				) 
			} map { !/bibpath/ ? $_ : () } @CONFKEYS,
		],
	);

}

sub print_html_ {

	$R->print(
		_html_header,
		start_form( 
			-action => "$SNAME/options",
		),
		submit( 
			-name 	=> 'submit_options', 
			-value 	=> 'Options',
		),
		end_form,
		_html_footer
	);

	OK;
}

sub print_html_options {

    my @table_head=();
    
    #@table_head=TR( map { td($_) } qw( Variable Value Description ) );

	$R->print(
		_html_header,
		start_form( 
			-action => "response",
		),
		b('MySQL database connection parameters'),
		table({ -border => 1 }, @table_head, @{$rows{mysqlconf}}),
		hr,
		b('BibTeX configuration'),
		table({ -border => 1 }, @table_head, @{$rows{bibtex}}),
		hr,
		submit( 
			-name 	=> 'submit_process_bib', 
			-value 	=> 'Process BibTeX file',
		),
		end_form,
		_html_footer
	);

	OK;
}

sub print_html_response {
	my %pars;

	@pars{@CONFKEYS}=map { $R->param($_) } @CONFKEYS;

	$BIBSQL=BibTeX::MySQL->new( %pars, conffile => $FILES{conf} ) 
		or die "Failure to create a BibTeX::MySQL object";

	$BIBSQL->connect
		or die "Failure to connect to the database";

	$DBH=$BIBSQL->dbh;

	$BIBSQL->parsebib
		or die "Failure to parse the bib file";

	#$LOG->info(Dumper(\%pars));

	#die 'aa';

	$R->print( _html_header,
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
		_html_footer,
	);

	$BIBSQL->fillsql;
		#or die "Failure to fill the MySQL database: " . $BIBSQL->err;

	$BIBSQL->end;

	OK;

}

sub print_html_view_pkey {
	my $sth;

	my $pkey=$R->param('pkey');

	$DBH=$BIBSQL->dbh;

	$sth=$DBH->prepare('show columns from ' . $BIBSQL->table_bib );
	$sth->execute;
	while (my @ary=$sth->fetchrow_array) {
		push(@BIBFIELDS,shift @ary);
	}

	$sth=$DBH->prepare('select * from ' . $BIBSQL->table_bib . ' where pkey = ?');
	$sth->execute($pkey);

	my @rows;
	while (my @ary=$sth->fetchrow_array) {
		push(@rows,map { p,$_ } @ary);
	}

	$R->print( 
		_html_header,
		@rows,
		map { p,$_ } @BIBFIELDS,
		_html_footer ,
	);

	OK;

}

sub _html_footer {
	hr, 
	end_html;
}

sub _html_header {
	start_html, 
	a({ -href => 'options' }, 'OPTIONS'),
	hr;
}

sub handler {
	init_handler_vars(@_);
	init_vars;

	$R->content_type('text/html');

	my $code;
	$LOG->info('PINFO: ' . $PINFO );
	eval '$code = print_html_' . $PINFO;
	return $code unless $@;

	die $@ if $@;

	OK;

}

1;
