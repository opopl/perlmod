
package OP::docperltex::build;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Env qw($HTMLOUT $hm);

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

use Pod::ProjectDocs;
use Data::Dumper;

use OP::Script::Simple qw(
	get_opt _say _warn _die 
);

my %res;

###our
our @TARGETS;
our $TARGET;
our $DAT;
our $BUILDOPT;
our $TEXDIR;
our $OUTDIR;
our $LIBROOT;
our $OUTROOT;
our $HTMLTITLE;

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
		_eval [ 'build' . $BUILDOPT . '(@_)']; 
	}

}

sub init_vars {

	$DAT=catfile($Bin,qw( hperl_targets.i.dat ));
	@TARGETS=readarr($DAT);

	$OUTDIR=catfile($HTMLOUT,qw(perldoc)) // catfile($hm,qw(html perldoc));
	$TEXDIR=catfile(qw(doc perl tex));

}

=head3 build_hperl_html

=cut 

sub build_hperl_html {

	#$LIBROOT=[ grep { -d } @INC ];
	#$OUTROOT=catfile($hm,qw(html perldoc ));
	$LIBROOT=[];
	$OUTROOT='';
	$HTMLTITLE='';

	_say "Processing: " . $TARGET ;
	for($TARGET){
		/^odtdms$/ && do {

			my @mods=qw( Job Base Git Table Run );
			push(@$LIBROOT,catfile($hm,qw(wrk filer odtdms lib ready ODTDMS )));
			#foreach my $m (@mods) {
				#push(@$LIBROOT,catfile($hm,qw(wrk filer odtdms lib ready ODTDMS ),$m));
			#}

			$OUTROOT=catfile($hm,qw(html perldoc odtdms));
			$HTMLTITLE='ODTDMS';
			
			next;
		};

	}

	if (@$LIBROOT && $OUTROOT){

		my $pd = Pod::ProjectDocs->new(
			outroot 	=> $OUTROOT,
			libroot 	=> $LIBROOT,
			index 		=> 1,
			title 		=> $HTMLTITLE,
		);
		$pd->gen;
	}

}

=head3 build_hperl_tex

=cut 

sub build_hperl_tex {

	@ARGV=( qw( --what ) , $TARGET);

	my $p2tex=OP::perldoc2tex->new;
	
	_say "Running perldoc2tex for: $TARGET";

	$p2tex->main;

}

=head3 build_hperl_pdf
 
X<build_hperl_pdf,OP::docperltex::build>
 
=head4 Usage
 
	build_hperl_pdf(%options);
 
=head4 Purpose
 
=head4 Input
 
=over 4
 
=item * C<%options> - the input options are forwarded to call C<< $hperl->main(%options) >>.
 
=back
 
=head4 Returns

Return value from C<< $hperl->main(%options) >>.
 
=head4 See also
 
=cut

sub build_hperl_pdf {

	my $hperl=OP::hperl->new;

	@ARGV=(qw( --skip vdoc --topic ),$TARGET);
	
	_say "Running hperl for: $TARGET" ;

	$hperl->main(@_);

}

1;
