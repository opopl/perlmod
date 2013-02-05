# -*- perl -*-

use strict;
use warnings;

use Test::More qw(no_plan);                     
use Test::Cmd;
use FindBin qw($Bin);

my $d="$Bin";
my @textests=qw( 1 );
my $perllatex="$d/../scripts/perllatex";

ok(-e $perllatex,"perllatex script exists");

foreach my $test (@textests) {
	my $if="$d/tex/test.$test.tex";
	die "Required LaTeX file not found for test: $test" unless -e $if;

	my $cmd=Test::Cmd->new(prog  => "$perllatex $if"); 
	ok($cmd,"Run perllatex script, test index: $test");
}

