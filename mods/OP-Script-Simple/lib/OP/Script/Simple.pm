package OP::Script::Simple;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
#use feature qw(switch);

###use
use Term::ANSIColor;
use FindBin qw($Bin $Script);

use Env qw( $hm $PERLMODDIR );

use Getopt::Long;
use IO::String;

use lib("$PERLMODDIR/mods/OP-Writer-Pod/lib");
use Text::Generate::Pod;

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
    %optdesc
    %DIRS
    %S
    %podsections
    $podsectionorder
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
    get_opt
    write_help_POD
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
our %optdesc;
our %podsections;
our $podsectionorder;
our %S;

sub _warn;
sub _say;
sub pre_init;
sub _debug;

###subs
sub write_help_POD;
sub get_opt;
sub dhelp;
sub _say_head;

sub _say {
    my $text=shift;

    my $opts=shift || {};
    my ($color,$prefix)=($TEXTCOLOR,$PREFIX);

    unless(keys %$opts){

    }else{
        while(my($k,$v)=each %{$opts}){
#            given($k){
                #when('color'){ $color=$v;  }
                #when('prefix'){ $prefix=$v;  }
                #default { }
            #}
			$color = $v if $k eq 'color';
			$prefix = $v if $k eq 'prefix';
            
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

sub write_help_POD {

    my $podw=Text::Generate::Pod->new;
    my %s;

    my $order=$podsectionorder || [qw(NAME USAGE OPTIONS)];

    foreach my $id (@$order) {
        $s{$id}=$podsections{$id} || '';
    }

    $s{NAME}=$podsections{NAME} || $Script . ' - ...';
    $s{USAGE}=$podsections{USAGE} || $Script . ' OPTIONS';
    
    foreach my $id (@$order) {
        $podw->head1($id);
        my $sid=$s{$id};

        unless(ref $sid){
            $podw->_pod_line($s{$id});
        } elsif (ref $sid eq "ARRAY"){
            foreach my $pline(@$sid) {
                $podw->_pod_line($pline);
            }
        }
        for($id){
            /^OPTIONS$/ && do { 
			    my @i;
			    my $width=80;
			
			    foreach my $opt (@optstr) {
			        my $type='';
			        $type='(s)' if ($opt =~ /=s$/);
			
			        ( my $o=$opt ) =~ s/=\w+$//g;
			        my $desc=$optdesc{$o} || '';
			
			        my $first='--' . $o;
			        my $second= $desc;
			        my $shift=$width-length($second) - length($first);
			
			        $shift=0 if $shift < 0;
			
			        my $line= $first . "\n\n" . $type . ' ' .  $second;
			        push(@i,$line);
			    }
		
	            $podw->over({ items => \@i });

				next;
            };
        }
    }

    $podw->cut;

    my $s=$podw->text;
    $S{POD}=IO::String->new($s);

}

sub dhelp {

    Pod::Text->filter($S{POD});

}

sub get_opt {
    my %opts=@_;

    $opts{exit_help}=1;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    write_help_POD;
    
    unless( @ARGV ){ 
        if ($opts{exit_help}){
            dhelp;
            exit 0;
        }
    }else{
        $cmdline=join(' ',@ARGV);
        GetOptions(\%opt,@optstr);
    }

    if ($opt{help}){
        dhelp;
        exit 0;
    }

}

BEGIN{
    pre_init;
}

1;

