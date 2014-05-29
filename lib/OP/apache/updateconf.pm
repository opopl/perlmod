
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

###our
our @ENVVARS;

sub main {
	init_vars;
	update_envvars;
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
		$val=join(':',uniq(split(':',$val)));
		$p->add_directive('SetEnv',"$var $val");
	}

	$p->save;
}

1;
