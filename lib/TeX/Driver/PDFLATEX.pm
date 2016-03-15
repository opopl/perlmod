
package TeX::Driver::PDFLATEX;

use warnings;
use strict;

###use
use Exporter ();

use FindBin qw($Bin $Script);
use IPC::Cmd qw(run_forked);
use Term::ANSIColor;

use File::Which qw(which);
use File::Temp qw(tempdir);

###our
our $VERSION = '0.01';

sub main {
    my $self=shift;

    $self->get_opt;
    $self->run;
}

sub run {
    my $self=shift;

    $self->_pdflatex( $self->{ifname} );

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

    $self->{files}->{pdflatex}=which('pdflatex');

    my $tmp=tempdir();
    $self->{opts}->{pdflatex}=
            ' -file-line-error'; 
        #.   ' -output-directory=' . $tmp;
    
}

sub _pdflatex {
    my $self=shift;

    $self->{ifname} = shift || '';
	
	my $cmd;

    my $exe=$self->{files}->{pdflatex} || 'pdflatex';
    $cmd = join(' ', 
				$exe, 
				$self->{opts}->{pdflatex}, 
				$self->{ifname}
			);

	my $res;
	
	if(not IPC::Cmd::can_run($exe)){
        $self->_die( "Cannot run: $exe ");
    }
	
	my @ERRORS;
    my ($line,$msg,$file,$lnum,$type);

    my $opts={
        stdout_handler => sub {
            local $_=shift;

            #if (/^(?<file>.*):(?<lnum>\d+): LaTeX Error:(?<msg>.*)/) {
            if (/^(.*):(\d+): LaTeX Error:(.*)/) {
				$file=$1;
				$lnum=$2;
				$msg=$3;

                $line=$_;
                $type='latexerror';
                return;
            }

            $line .= $_ if $line;
            $msg .= $_ if $msg;

            if (/^\s*$/ && $line){

	            push(@ERRORS,
	            { 
					lnum    => $lnum, 
					file    => $file, 
					type    => $type,
					msg     => $msg,
					line    => $_,
	            });

                $line='';
                $msg='';
            }

        }
    };
	
    $res= IPC::Cmd::run_forked( $cmd, $opts );

    if ($res->{exit_code}) {
        $self->_warn( "FAILURE with exit code: " . $res->{exit_code});
        $self->_warn('Errors: ');
        for(@ERRORS){
            print $_->{line};
        }

    }else{
        $self->_say( "SUCCESS" );

    }

}

sub get_opt {
    my $self=shift;


    unless (@ARGV) {
        $self->_say( "Usage: $Script OPTIONS FILENAME" );
        exit 1;

    } else {
        $self->{ifname} = pop @ARGV;
        $self->{opts}->{pdflatex}=join(' ',@ARGV) if @ARGV;

    }

    $self->{ifname} =~ s/\.tex$//g;
    $self->{ifile}=$self->{ifname} . '.tex';
    $self->{ofile}=$self->{ifname} . '.pdf';

    if(-e $self->{ifile}){
      $self->_say( "Input filename: " . $self->{ifname} );
      $self->_say( "Input filepath: " . $self->{ifile} );

    }else{
      $self->{opts}->{pdflatex} .= " $self->{ifname}";
      $self->{ifname}='';

    }

    $self->_say( "Input pdflatex options: " . $self->{opts}->{pdflatex} );


}

sub _say {
    my $self=shift;

    my $text=shift;

    my $opts=shift || {};
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
__END__

=head1 NAME

=head1 SYNOPSIS

=head1 LICENSE

=head1 SEE ALSO

=head1 AUTHOR

=cut

=cut
