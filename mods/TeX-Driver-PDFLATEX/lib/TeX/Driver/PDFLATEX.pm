
package TeX::Driver::PDFLATEX;

use warnings;
use strict;

###use
use Exporter ();

use FindBin qw($Bin $Script);
use IPC::Cmd qw(run_forked);
use Term::ANSIColor;

###our
our $VERSION = '0.01';

sub main {
    my $self=shift;

    $self->get_opt;
    $self->run;
}

sub run {
    my $self=shift;

    $self->_pdflatex( $self->{IFNAME} );

    if (-e $self->{ofile}){
      $self->_say( "Output file created: " . $self->{ofile} );
    }

}

sub new
{
    my ($class, %pars) = @_;
    my $self = bless (\%pars, ref ($class) || $class);

    $self->init_vars; 

    return $self;
}

sub init_vars {
	my $self=shift;

    $self->{prefix}=$Script . "> ";

    $self->{warncolor}='red';
    $self->{errorcolor}='bold red';

    $self->{textcolor}='green';
    
}

sub _pdflatex {
    my $self=shift;

    $self->{ifname} = shift // '';
	
	my $cmd;

    my $exe=$self->{files}->{pdflatex} // 'pdflatex';
    $cmd = join(' ', $exe, $self->{opts}->{pdflatex}, $self->{ifname});

	my $res;
	
	if(not IPC::Cmd::can_run($exe)){
        $self->_die( "Cannot run: $exe ");
    }
	
    $res= IPC::Cmd::run_forked( $cmd );

    if ($res->{exit_code}) {
        $self->_warn( "FAILURE with exit code: " . $res->{exit_code} );

    }else{
       $self->_say( "SUCCESS" );

    }


}

sub get_opt {
    my $self=shift;

    $self->{opts}->{pdflatex}='';

    unless (@ARGV) {
        $self->_say( "Usage: $Script OPTIONS FILENAME" );
        exit 1;

    } else {
        $self->{ifname} = pop @ARGV;
        $self->{opts}->{pdflatex}=join(' ',@ARGV);

    }

    $self->{ifname} =~ s/\.tex$//g;
    $self->{ifile}=$self->{ifname} . '.tex';
    $self->{ofile}=$self->{ifname} . '.pdf';

    if(-e $self->{ifile}){
      $self->_say( "Input filename: " . $self->{ifname} );

    }else{
      $self->{opts}->{pdflatex} .= " $self->{ifname}";
      $self->{ifname}='';

    }

    $self->_say( "Input pdflatex options: " . $self->{opts}->{pdflatex} );


}

sub _say {
    my $self=shift;

    my $text=shift;

    my $opts=shift // {};
    my ($color,$prefix)=@{$self}{qw(textcolor prefix)};

    unless(keys %$opts){

    }else{
        while(my($k,$v)=each %{$opts}){
            for($k){
                /^color$/ && do { $color=$v; next; };
                /^prefix$/ && do { $prefix=$v; next; };
            }
            
        }
    }

    print color $color;
    print $prefix . $text . "\n";
    print color 'reset';

}

sub _warn {
    my $self=shift;

    my $text=shift;

    print color $self->{warncolor};
    print $self->{prefix} . $text . "\n";
    print color 'reset';

}

sub _die {
    my $self=shift;

    my $text=shift;

    print color $self->{errorcolor};
    print $self->{prefix} . $text . "\n";
    print color 'reset';

	exit 1;

}

1;
