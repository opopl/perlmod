# -*- perl -*-

use strict;
use warnings;

use Test::More qw(no_plan);                     
use FindBin qw($Bin);

my $d="$Bin";
my @textests=qw( 1 );
my $perllatex="$d/../scripts/perllatex";

ok(-e $perllatex,"perllatex script exists");

foreach my $test (@textests) {
	my $if="$d/tex/test.$test.tex";
	die "Required LaTeX file not found for test: $test" unless -e $if;

	#ok((system("$perllatex $if")==0),"Run perllatex script");
}

#use OP::TEX::PERLTEX;
#use File::Spec;
#use FindBin;

#my %opts=(
	#scriptname  => "$FindBin::Script",
	#workdir  	=> File::Spec->curdir()
#);

## Test on a simple LaTeX File
#my $tex=File::Spec->catfile(qw(tex test.1.tex));

#my $t = OP::TEX::PERLTEX->new(%opts);
##$t->main($tex);
##ok($t->main($tex), 'Running...');

#isa_ok ($t, 'OP::TEX::PERLTEX');


