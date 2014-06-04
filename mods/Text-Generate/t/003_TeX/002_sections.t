#!/usr/bin/env perl

# t/002_sections.t - check sectioning commands

use strict;
use warnings;

use Test::More;
use FindBin qw( $Bin $Script );

use Text::Generate::TeX;

use Text::Generate::Utils qw( _arrays_equal );
use File::Spec::Functions qw( catfile );
use File::Path qw( make_path remove_tree );

our @TESTS;
our $testdir;
our $TEX;

###subs
sub init_vars;
sub main;
sub ok_lines;
sub test_commands;
sub test_sections;
sub test_macros;
sub test_usepackage;
sub test_usepackages;

main;

sub init_vars {

 $TEX=Text::Generate::TeX->new;

 @TESTS=qw(
      commands
      sections
      macros
      usepackage
      usepackages
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

  ok( _arrays_equal( [ $TEX->textlines ] ,$a ), $msg);

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

sub test_usepackages {
  my $reflines;

  $reflines=[ 
  	'\usepackage[draft]{bookmark}',
  	'\usepackage{my}',
  ];

  $TEX->_clear;
  $TEX->usepackages( 
	  [ qw(bookmark my) ],
  	  { bookmark => 'draft' }
  );

  ok_lines($reflines, "usepackages> " );

  $TEX->_clear;
  $TEX->usepackages( 
	  [ qw(bookmark my) ],
  	  { bookmark => [qw(draft)] }
  );

  ok_lines($reflines, "usepackages> " );


}

sub test_usepackage {
  my $reftex;

  $reftex='\usepackage{bookmark}';
	
	  $TEX->_clear;
	  $TEX->usepackage("bookmark");
	
	  ok_lines([ $reftex ], "usepackage> " . $reftex );
	
	  $TEX->_clear;
	  $TEX->usepackage({ package => "bookmark" });
	
	  ok_lines([ $reftex ], "usepackage> " . $reftex );

  $reftex='\usepackage[draft]{bookmark}';

	  $TEX->_clear;
	  $TEX->usepackage({ 
			  'package' => "bookmark", 
			  'options' => 'draft' 
	  });
	
	  ok_lines([ $reftex ], "usepackage> " . $reftex );

	  $TEX->_clear;
	  $TEX->usepackage({ 
			  'package' => "bookmark", 
			  'options' => [qw(draft)], 
	  });

	  ok_lines([ $reftex ], "usepackage> " . $reftex );

  $reftex='\usepackage[draft,view={FitB}]{bookmark}';

	  $TEX->_clear;
	  $TEX->usepackage({ 
			  'package' => "bookmark", 
			  'options' => 'draft,view={FitB}', 
	  });
	
	  ok_lines([ $reftex ], "usepackage> " . $reftex );

	  $TEX->_clear;
	  $TEX->usepackage({ 
			  'package' => "bookmark", 
			  'options' => [qw(draft view={FitB} )], 
	  });
	
	  ok_lines([ $reftex ], "usepackage> " . $reftex );

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

