package OP::RE;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
);
###export_vars_hash
my @ex_vars_hash=qw(
    %REX
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

###our_REX
our %REX=(
###_figp
    figp  => qr/
            \\figp{(?<size>\w+)}(%+\n*|)
            {(?<num>\w+)}(%+\n*|)
            (\[(?<short>.*)\]|)(%+\n*|)
            {(?<caption>.*)}
            /x
);


1;
