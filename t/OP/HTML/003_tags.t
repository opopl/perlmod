#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin $Script );
use Test::More;

use lib("$Bin/../lib");
use OP::HTML::Tests qw(do_tests ok_lines @TESTS $H $TEST);

###subs
sub ok_reflines;
sub test_tags;
sub main;
sub init_vars;

###our
our $reflines;

main;

sub main {
	init_vars;
	do_tests;
}

sub init_vars {

 @TESTS=qw( tags );

 foreach my $test (@TESTS) {
    eval '*OP::HTML::Tests::test_' . $test . '=*test_' . $test;
    warn $@ if $@;
 }
 $TEST=$Script

}

sub ok_reflines {

  ok_lines( $reflines , "tags> ". join(" ",@$reflines) );

}

sub test_tags {
  my $refh;

  $reflines=[ '<tag name="a">' ];
  $H->_clear;
  $H->_tag_open('tag',{ name => 'a' });

  ok_reflines;
  
  $reflines=[ '<html>',  ' <body>' ];
	
  $H->_clear;
  $H->open_tags([qw(html body)]);

  ok_reflines;

  $reflines=[ '</body>', '</html>'  ];
	
  $H->_clear;
  $H->close_tags([qw( body html )]);

  ok_reflines;

}

