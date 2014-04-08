package OP::Script::Simple;

use warnings;
use strict;

=head1 NAME

	OP::Script::Simple 

=head1 SYNOPSIS

	package MyScript;

	sub main;
	sub init_vars;

	main;

	use OP::Script::Simple qw(
		get_opt %opt @optstr
	);

	sub main {
		init_vars;
		get_opt;
	}

	sub init_vars {
		...
	}

=head1 EXPORTS

=cut

use feature qw(switch);

use Exporter ();


###use
use Term::ANSIColor;
use FindBin qw($Bin $Script);

use Getopt::Long;
use IO::String;

use OP::Writer::Pod;
use Data::Dumper;


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
	$ARGVOLD
);

our %EXPORT_TAGS = (
###export_funcs
	'funcs' => [qw( 
		_eval
	    _say
	    _say_head
	    _warn
	    _debug
	    _die
	    pre_init
	    get_opt
	    write_help_POD
		override_argv
		restore_argv
	)],
	'vars'  => [ 
		@ex_vars_scalar,
		@ex_vars_array,
		@ex_vars_hash 
	],
);

our @ISA     = qw(Exporter);
our @EXPORT      = qw();

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
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
our $ARGVOLD;

###subs
sub _debug;
sub _die;
sub _eval;
sub _say;
sub _say_head;
sub _warn;
sub dhelp;
sub get_opt;
sub pre_init;
sub write_help_POD;
sub override_argv;
sub restore_argv;

sub _eval {
	my $evs=shift;

	eval(join(";\n",@$evs));
	_die $@ if $@;
}

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

sub _die {
    my $text=shift;

    print color $ERRORCOLOR;
    print $PREFIX . $text . "\n";
    print color 'reset';

	exit 1;

}

sub override_argv {
	my $argvnew=shift;
	
	print Dumper($argvnew);

	if (defined $argvnew && ref($argvnew) eq 'ARRAY'){
		$ARGVOLD=\@ARGV;
		@ARGV=@$argvnew;
	}

}

sub restore_argv {
	@ARGV=@$ARGVOLD if defined $ARGVOLD;
}

sub pre_init {
    $PREFIX=$Script . "> ";

    $WARNCOLOR='red';
    $ERRORCOLOR='bold red';

    $TEXTCOLOR='green';
    $HEADCOLOR='bold blue';
    
}

sub write_help_POD {

    my $podw=OP::Writer::Pod->new;
    my %s;

    my $order=$podsectionorder // [qw(NAME USAGE OPTIONS)];

    foreach my $id (@$order) {
        $s{$id}=$podsections{$id} // '';
    }

    $s{NAME}=$podsections{NAME} // $Script . ' - ...';
    $s{USAGE}=$podsections{USAGE} // $Script . ' OPTIONS';
    
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
        given($id){
            when('OPTIONS') { 
			    my @i;
			    my $width=80;
			
			    foreach my $opt (@optstr) {
			        my $type='';
			        $type='(s)' if ($opt =~ /=s$/);
			
			        ( my $o=$opt ) =~ s/=\w+$//g;
			        my $desc=$optdesc{$o} // '';
			
			        my $first='--' . $o;
			        my $second= $desc;
			        my $shift=$width-length($second) - length($first);
			
			        $shift=0 if $shift < 0;
			
			        my $line= $first . "\n\n" . $type . ' ' .  $second;
			        push(@i,$line);
			    }
		
	            $podw->over({ items => \@i });
            }
            default { }
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
    
    Getopt::Long::Configure(qw(
		bundling 
		no_getopt_compat 
		no_auto_abbrev 
		no_ignore_case_always
		));
    
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

