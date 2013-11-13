#!/usr/bin/env perl

# t/002_sections.t - check sectioning commands

use strict;
use warnings;

use Test::More;
use FindBin qw( $Bin $Script );

use OP::TEX::Text;

use OP::Base qw( _arrays_equal );
use File::Spec::Functions qw( catfile );
use File::Path qw( make_path remove_tree );

our @TESTS;
our $testdir;
our $TEX;

###subs
sub test_commands;
sub ok_lines;
sub test_sections;
sub main;
sub init_vars;

main;

sub init_vars {

 $TEX=OP::TEX::Text->new;

 @TESTS=qw(
      commands
      sections
      macros
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

  ok( _arrays_equal($TEX->textlines_ref,$a ), $msg);

}

sub test_commands {
  my $reftex;

	$TEX->_clear;
	$TEX->_cmd('maketitle');
	ok_lines([qw( \maketitle )], 'commands> \maketitle ' );

	$TEX->_clear;
	$TEX->_cmd('begin','document');
	ok_lines( [qw( \begin{document} )], 'commands> \begin{document} ' );

	$TEX->_clear;
  $reftex='\begin{table}[ht]';

	$TEX->_cmd({ cmd => 'begin', vars => 'table', optvars => 'ht' });
	ok_lines([ $reftex ], 'commands> ' . $reftex );

}

sub test_macros {
  my $reftex;

  $reftex='\input{file}';
	
	$TEX->_clear;
	$TEX->input("file");

	ok_lines([ $reftex ], "macros> " . $reftex );

}

sub test_sections {
  my $reftex;

  $reftex='\part{1}';
	
	$TEX->_clear;
	$TEX->part("1");
	ok_lines([ $reftex ], "sections> " . $reftex );

  $reftex='\chapter{1}';
	
	$TEX->_clear;
	$TEX->chapter("1");
	ok_lines([ $reftex ], "sections> " . $reftex );

  $reftex='\section{1}';

	$TEX->_clear;
	$TEX->section("1");
	ok_lines([ $reftex ], "sections> " . $reftex );

  $reftex='\subsection{1}';
	
	$TEX->_clear;
	$TEX->subsection("1");
	ok_lines([ $reftex ], "sections> " . $reftex );

  $reftex='\subsubsection{1}';
	
	$TEX->_clear;
	$TEX->subsubsection("1");
	ok_lines([ $reftex ], "sections> " . $reftex );

  $reftex='\paragraph{1}';
	
	$TEX->_clear;
	$TEX->paragraph("1");
	ok_lines([ $reftex ], "sections> " . $reftex );

}

