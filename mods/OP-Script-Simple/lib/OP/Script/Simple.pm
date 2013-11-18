package OP::Script::Simple;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use feature qw(switch);

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
    $HEADCOLOR
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
    _say_head
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
our $HEADCOLOR;
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
sub _say_head;

sub _say {
    my $text=shift;

    my $opts=shift // {};
    my ($color,$prefix)=($TEXTCOLOR,$PREFIX);

    unless(keys %$opts){

    }else{
        while(my($k,$v)=each %{$opts}){
            given($k){
                when('color'){ $color=$v;  }
                when('prefix'){ $prefix=$v;  }
                default { }
            }
            
        }
    }

    print color $color;
    print $prefix . $text . "\n";
    print color 'reset';

}

sub _say_head {
    my $text=shift;

    my $color=$HEADCOLOR;

    _say "---- $text ----", { color => $color };

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

    $TEXTCOLOR='green';
    $HEADCOLOR='bold blue';
    
}

BEGIN{
    pre_init;
}


1;

