
package Mysql::Setup;
 
use warnings;
use strict;
 
use Env qw($hm);
use File::Path qw( make_path remove_tree );
use FindBin qw( $Bin );
use File::Spec::Functions qw(catfile);
 
use Data::Dumper; 
use FindBin qw( $Script $Bin ); 
 
our %DIRS;

sub new
{
    my ($class, %ipars) = @_;
	my %pars=();
    my $self = bless (\%pars, ref ($class) || $class);

	$self->init;

    return $self;
}

sub init {
	my $self=shift;

	$DIRS{MYSQLROOT} = $ENV{MYSQLROOT} || catfile(qw(/opt mysql));
}


sub run {
	my $self=shift;

	chdir $DIRS{MYSQLROOT} || die 'Fail to change to mysql root dir: ' . $DIRS{MYSQLROOT};

}

1;
