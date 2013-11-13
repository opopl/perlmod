#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use FindBin qw( $Bin $Script );

use OP::HTML;

use OP::Base qw( _arrays_equal );
use File::Spec::Functions qw( catfile );
use File::Path qw( make_path remove_tree );

our @TESTS;
our $testdir;
our $H;

###subs
sub test_commands;
sub ok_lines;
sub test_headings;
sub main;
sub init_vars;

main;

sub init_vars {

 $H=OP::HTML->new;

 @TESTS=qw(
      headings
      tags
 );

}

sub main {

  init_vars;

  foreach my $test (@TESTS) {
      eval 'test_' . $test;
      warn $@ if $@;
  }

  done_testing;

}

sub ok_lines {
  my $a=shift;
  my $msg=shift;

  ok( _arrays_equal($H->textlines_ref,$a ), $msg);

}

sub test_tags {
  my $refh;
  my $reflines;
  
  $reflines=[ qw( <html> <body> ) ];
	
  $H->_clear;
  $H->open_tags([qw(html body)]);

  ok_lines( $reflines , "tags> ". join(" ",@$reflines) );

  $reflines=[ qw( </html> </body> ) ];
	
  $H->_clear;
  $H->close_tags([qw(html body)]);

  ok_lines( $reflines , "tags> ". join(" ",@$reflines) );

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

