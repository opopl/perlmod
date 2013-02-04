#!/usr/bin/env perl
# $Id: 10-simpledoc.t 85 2012-08-31 19:08:22Z andrew $

use strict;
use blib;
use FindBin qw($Bin);
use File::Spec;
use lib ("$Bin/../lib", "$Bin/lib");
use Data::Dumper;

use Test::More tests => 26;
use Test::OP::TEX::Driver;
use OP::TEX::Driver;

tidy_directory($basedir, $docname, $debug);

my $drv = OP::TEX::Driver->new( source => $docpath,
			      format => 'dvi',
			      @DEBUGOPTS );

diag("Checking the formatting of a simple LaTeX document");
isa_ok($drv, 'OP::TEX::Driver');
is($drv->basedir, $basedir, "checking basedir");
is($drv->basename, $docname, "checking basename");
is($drv->basepath, File::Spec->catpath('', $basedir, $docname), "checking basepath");
is($drv->formatter, 'latex', "formatter");

ok($drv->run, "formatting $docname");

is($drv->stats->{runs}{latex},        1, "should have run latex once");
is($drv->stats->{runs}{bibtex},    undef, "should not have run bibtex");
is($drv->stats->{runs}{makeindex}, undef, "should not have run makeindex");


test_dvifile($drv, [ "Simple Test Document $testno",	# title
		     'A.N. Other',			# author
		     '20 September 2007',		# date
		     'This is a test document with a single line of text.' ] );


tidy_directory($basedir, $docname, $debug);

diag("Checking the generation of PDF");
$drv = OP::TEX::Driver->new( source => $docpath,
			   format => 'pdf',
			   @DEBUGOPTS );

ok($drv->run, "formatting $docname");
ok(-f ($drv->basepath . '.pdf'), "PDF file exists");
ok(! -f ($drv->basepath . '.dvi'), "but DVI file doesn't");
ok(! -f ($drv->basepath . '.ps'),  "but PS  file doesn't");


tidy_directory($basedir, $docname, $debug);

diag("Checking the generation of PostScript");
$drv = OP::TEX::Driver->new( source => $docpath,
			   format => 'ps',
			   @DEBUGOPTS );

ok($drv->run, "formatting $docname to PostScript");
ok(-f ($drv->basepath . '.ps'), "PostScript file exists");
ok(-f ($drv->basepath . '.dvi'), "as does DVI file");
ok(! -f ($drv->basepath . '.pdf'),  "but PS file doesn't");


tidy_directory($basedir, $docname, $debug);

diag("Checking the generation of PDF, via PostScript");
$drv = OP::TEX::Driver->new( source => $docpath,
			   format => 'pdf(ps)',
			   @DEBUGOPTS );

ok($drv->run, "formatting $docname to PDF, via PostScript");
ok(-f ($drv->basepath . '.pdf'),  "PDF file exists");
ok(-f ($drv->basepath . '.ps'),   "PostScript file exists");
ok(-f ($drv->basepath . '.dvi'),  "DVI file exists");

tidy_directory($basedir, $docname, $debug);

diag("Checking the generation of PostScript, via PDF");
$drv = OP::TEX::Driver->new( source => $docpath,
			   format => 'ps(pdf)',
			   @DEBUGOPTS );

ok($drv->run, "formatting $docname to PDF, via PostScript");
ok(-f ($drv->basepath . '.pdf'),  "PDF file exists");
ok(-f ($drv->basepath . '.ps'),   "PostScript file exists");
ok(! -f ($drv->basepath . '.dvi'),  "DVI file does not exists");



tidy_directory($basedir, $docname, $debug)
    unless $no_cleanup;

exit(0);
