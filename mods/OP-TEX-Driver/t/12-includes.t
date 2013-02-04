#!/usr/bin/env perl
# $Id: 12-includes.t 62 2007-10-03 14:20:44Z andrew $

use strict;
use blib;
use FindBin qw($Bin);
use File::Spec;
use lib ("$Bin/../lib", "$Bin/lib");
use Data::Dumper;

use Test::More tests => 10;

use Test::OP::TEX::Driver;
use OP::TEX::Driver;

tidy_directory($basedir, $docname, $debug);

my $drv = OP::TEX::Driver->new( source => $docpath,
			      format => 'dvi',
			      @DEBUGOPTS );

diag("Checking the formatting of a LaTeX document that includes other files");
isa_ok($drv, 'OP::TEX::Driver');
is($drv->basedir, $basedir, "checking basedir");
is($drv->basename, $docname, "checking basename");
is($drv->basepath, File::Spec->catpath('', $basedir, $docname), "checking basepath");
is($drv->formatter, 'latex', "formatter");

ok($drv->run, "formatting $docname");

is($drv->stats->{runs}{latex},         1, "should have run latex once");
is($drv->stats->{runs}{bibtex},    undef, "should not have run bibtex");
is($drv->stats->{runs}{makeindex}, undef, "should not have run makeindex");

test_dvifile($drv, [ "Simple Test Document $testno",	# title
		     'A.N. Other',			# author
		     '20 September 2007',		# date
		     'This is a test document that includes another file.',
		     '^ 1$',				# page number 1
	             'This is text from an included file.',
		     '^ 2$' ] );			# page number 2

tidy_directory($basedir, $docname, $debug)
    unless $no_cleanup;

exit(0);
