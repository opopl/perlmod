
package OP::apache::base;

use strict;
use warnings;

###use
use Apache2::RequestRec ( ); # for $r->content_type
use Apache2::Const qw(OK);
use Apache2::Request ();
use CGI;

use OP::apache::base::html;

use Exporter qw( );

###our
our @ISA=qw(Exporter); 

our @ex_vars_scalar=qw( $Q $R $PINFO $SNAME $H );
our @ex_vars_array=qw( @SUBMITS );
our @ex_vars_hash=qw();

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

our($Q, $R, $PINFO, $SNAME );
our $H;
our @SUBMITS;

###subs
sub init_handler_vars;

sub init_handler_vars {

 	$R = Apache2::Request->new(shift);
    
    $Q = CGI->new($R);

    $PINFO = $R->path_info =~ s{^\/}{}gr ;

	$SNAME = $R->uri ;

	if (defined $PINFO) {
		$SNAME =~ s{\/$PINFO$}{}g;
	}

	$H=OP::apache::base::html->new( 
		R	=> $R,
		Q	=> CGI->new,
	);

	$Q=$H->{Q};


}

1;
 
