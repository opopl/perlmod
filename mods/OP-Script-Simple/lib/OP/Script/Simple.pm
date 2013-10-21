package OP::Script::Simple;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Term::ANSIColor;
use FindBin qw($Bin $Script);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
    $PREFIX
    $WARNCOLOR
    $TEXTCOLOR
    $DEBUGCOLOR
    $DEBUG
    $IFNAME
    $IFILE
    $OFILE
    $EXITCODE
    $cmdline
);
###export_vars_hash
my @ex_vars_hash=qw(
    %opt
    %DIRS
);
###export_vars_array
my @ex_vars_array=qw(
    @optstr
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
    _say
    _warn
    _debug
    pre_init
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

###our
our $IFNAME;
our $IFILE;
our $OFILE;
our $PREFIX;
our $WARNCOLOR;
our $ERRORCOLOR;
our $TEXTCOLOR;
our $EXITCODE;
our $DEBUG;
our $DEBUGCOLOR;

our (%opt,@optstr);
our $cmdline;
our %DIRS;

sub _warn;
sub _say;
sub pre_init;
sub _debug;
###subs
sub _say {
    my $text=shift;

    print color $TEXTCOLOR;
    print $PREFIX . $text . "\n";
    print color 'reset';

}

###debug
sub _debug {
  my $text=shift;

  if ($DEBUG){
    print color "$DEBUGCOLOR";
    print $PREFIX . $text . "\n";
    print color 'reset';
  }

}


sub _warn {
    my $text=shift;

    print color $WARNCOLOR;
    print $PREFIX . $text . "\n";
    print color 'reset';

}

sub pre_init {
    $PREFIX=$Script . "> ";

    $WARNCOLOR='red';
    $ERRORCOLOR='bold red';
    $TEXTCOLOR='bold green';
}


1;

