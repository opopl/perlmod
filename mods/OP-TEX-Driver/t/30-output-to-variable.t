#!/usr/bin/env perl
# $Id: 30-output-to-variable.t 62 2007-10-03 14:20:44Z andrew $

use strict;
use blib;
use FindBin qw($Bin);
use File::Spec;
use lib ("$Bin/../lib", "$Bin/lib");
use Data::Dumper;

use Test::More tests => 11;
use Test::OP::TEX::Driver;
use OP::TEX::Driver;

tidy_directory($basedir, $docname, $debug);

my $output;
my $drv = OP::TEX::Driver->new( source      => $docpath,
			      format      => 'ps',
			      output      => \$output,
			      @DEBUGOPTS );

diag("Checking the formatting of a simple LaTeX document into a variable");
isa_ok($drv, 'OP::TEX::Driver');
is($drv->basedir, $basedir, "checking basedir");
is($drv->basename, $docname, "checking basename");
is($drv->basepath, File::Spec->catpath('', $basedir, $docname), "checking basepath");
is($drv->formatter, 'perllatex', "formatter");

ok($drv->run, "formatting $docname");

is($drv->stats->{runs}{perllatex},         1, "should have run perllatex once");
is($drv->stats->{runs}{bibtex},    undef, "should not have run bibtex");
is($drv->stats->{runs}{makeindex}, undef, "should not have run makeindex");
is($drv->stats->{runs}{dvips},         1, "should have run dvips once");

like($output, qr/^%!PS/, "got postscript in output string");


tidy_directory($basedir, $docname, $debug)
 unless $no_cleanup;


exit(0);
