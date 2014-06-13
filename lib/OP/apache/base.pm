
package OP::apache::base;

use strict;
use warnings;

###use
use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Const qw(OK);
use Apache2::Request ();
use Apache2::Log ();
use Apache2::ServerUtil ();
use File::Spec::Functions qw(catfile);

use CGI;

use OP::apache::base::html;

use Exporter qw( );

###our
our @ISA=qw(Exporter); 

our @ex_vars_scalar=qw(
	$H
	$LOG
	$PINFO
	$Q
	$R
	$SERVROOT
	$SNAME
);
our @ex_vars_array=qw( @SUBMITS );
our @ex_vars_hash=qw(
	%FILES
);

our %EXPORT_TAGS = (
###export_funcs
	'funcs' => [qw( 
		init_handler_vars
	)],
	'vars'  => [ 
		@ex_vars_scalar,
		@ex_vars_array,
		@ex_vars_hash 
	]
);

our @EXPORT_OK = ( 
	@{ $EXPORT_TAGS{'funcs'} }, 
	@{ $EXPORT_TAGS{'vars'} } 
);

our($Q, $R, $PINFO, $SNAME, $LOG );
our $H;
our $SERVROOT;
our %FILES;
our @SUBMITS;

###subs
sub init_handler_vars;

sub init_handler_vars {

 	$R = Apache2::Request->new(shift);
	$LOG=$R->log;

	$SERVROOT=Apache2::ServerUtil::server_root();

	foreach my $id (qw(error_log)) {
		$FILES{$id}=catfile($SERVROOT,qw(logs),$id);
	}

	$LOG->info('<<<<< start: init_handler_vars >>>>>');

	foreach my $id (qw(
		filename 
		hostname 
		method 
		path_info 
		uri 
	)) {
		no strict 'refs';
		$LOG->info('$R->' . $id . ' = ', $R->$id);
	}

	$PINFO = $R->path_info =~ s{^\/}{}gr;
	$SNAME = $R->uri =~ s{^\/$PINFO}{}gr;
    
    $Q = CGI->new($R);

	$H=OP::apache::base::html->new( 
		R	=> $R,
		Q	=> CGI->new,
	);

	$Q=$H->{Q};

	$LOG->info('<<<<< end: init_handler_vars >>>>>');

}

1;
 
