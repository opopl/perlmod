
package OP::docperltex::build;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK      = qw( main );

=head1 NAME

OP::docperltex::build - builder for POD + SOURCE documentation

=cut

use FindBin qw( $Bin $Script );
use OP::Base qw( readarr run_cmd );
use File::Spec::Functions qw( catfile );

use OP::perldoc2tex;
use OP::hperl;

use OP::Script::Simple qw(
	get_opt _say _warn _die 
);

my %res;

###our
our @TARGETS;
our $TARGET;
our $DAT;
our $BUILDOPT;

###subs
sub build_hperl;
sub build_html;
sub init_vars;
sub _eval;

sub main;

sub _eval {
	my $evs=shift;

	eval(join(";\n",@$evs));
	_die $@ if $@;

}

sub main {

	init_vars;
	get_opt;

	unless(@ARGV){
		exit 0;
	}

	$BUILDOPT=shift @ARGV;

	foreach $TARGET (@TARGETS) {
		_eval [ 'build' . $BUILDOPT ]; 
	}

}

sub init_vars {

	$DAT=catfile($Bin,qw( hperl_targets.i.dat ));
	@TARGETS=readarr($DAT);

}

sub build_html {
}

sub build_tex {

	@ARGV=( qw( --what ) , $TARGET);

	my $p2tex=OP::perldoc2tex->new;
	
	_say "Running perldoc2tex for: $TARGET" ;

	$p2tex->main;

}

sub build_hperl {

	my $hperl=OP::hperl->new;

	@ARGV=(qw( --skip vdoc --topic ),$TARGET);
	
	_say "Running hperl for: $TARGET" ;

	$hperl->main;

}

1;
