#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin $Script );
use Test::More;

use lib("$Bin/../lib");
use OP::HTML::Tests qw(do_tests ok_lines @TESTS $H);

###subs
sub main;
sub init_vars;
sub test_headings;


main;

sub main {

	init_vars;
	do_tests;

}

sub init_vars {

 @TESTS=qw( headings );

 foreach my $test (@TESTS) {
    eval '*OP::HTML::Tests::test_' . $test . '=*test_' . $test;
    warn $@ if $@;
 }

}

sub test_headings {
  my $refh;

  $refh='<h1>Heading1</h1>';
	
	$H->_clear;
	$H->h1('Heading1');
	ok_lines([ $refh ], "headings> " . $refh );

  $refh='<h2>Heading2</h2>';
	
	$H->_clear;
	$H->h2('Heading2');
	ok_lines([ $refh ], "headings> " . $refh );

  $refh='<h3>Heading3</h3>';
	
	$H->_clear;
	$H->h3('Heading3');
	ok_lines([ $refh ], "headings> " . $refh );
  
  $refh='<h4>Heading4</h4>';
	
	$H->_clear;
	$H->h4('Heading4');
	ok_lines([ $refh ], "headings> " . $refh );

}

