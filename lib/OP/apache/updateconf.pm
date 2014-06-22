
package OP::apache::updateconf;

=head1 NAME

OP::apache::updateconf - for updating Apache configuration files located
in C<$APACHEROOT/conf>.

=cut
 
use strict;
use warnings;
 
use Env qw($APACHEROOT);

use File::Spec::Functions qw( catfile );
use Apache::Admin::Config;
use OP::Base qw(readarr uniq);
use FindBin qw($Bin);

###subs
sub main;
sub init_vars;
sub update_envvars;
sub update_perlenv;
sub reval;

###our
our @ENVVARS;
our %FILES;

sub main {
	init_vars;
	update_envvars;
	update_perlenv;
}

sub init_vars {
	@ENVVARS=readarr(catfile($Bin,qw(envvars.i.dat)));
}

sub update_envvars {

	my $conf=catfile($APACHEROOT,qw(conf envvars.conf));
	unlink $conf;
	my $p=Apache::Admin::Config->new($conf, '-create'  );

	foreach my $var (@ENVVARS) {
		my $val=$ENV{$var};
		$val=reval($val);
		$p->add_directive('SetEnv',"$var $val");
	}


	$p->save;
}

sub reval {
    my $val=shift;

    return join(':',map { $_ ? $_ : () } uniq(split(':',$val)));
}

sub update_perlenv {

	my $conf=catfile($APACHEROOT,qw(conf perlenv.conf));
	unlink $conf;
	my $p=Apache::Admin::Config->new($conf, '-create'  );

	foreach my $var (qw(PERLLIB)) {
		my @dirs=split(':', $ENV{$var});
        foreach my $dir (@dirs) {
            next unless $dir;
		    $p->add_directive('PerlSwitches',"-I$dir");
        }
	}

	$p->save;

}



1;
