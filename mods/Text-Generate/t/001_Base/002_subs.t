#!perl

use strict;
use warnings;

use Test::More;

use Text::Generate::Base;

use Text::Generate::Utils qw( _arrays_equal );

use List::Compare;
use File::Spec::Functions qw( catfile );
use File::Path qw( make_path remove_tree );
use File::Temp qw(tempdir);
use FindBin qw( $Bin $Script );

###subs
sub test_printing;
sub ok_lines;
sub test_start;
sub init_vars;
sub test_indentation;
sub test_commenting;
sub test_adding_lines;
sub main;

our $W=Text::Generate::Base->new;

our @TESTS;
our $testdir;

main;

sub test_start {

    ok($W->text eq "",              'upon_start: text zero');
    ok($W->indent == 0,             'upon start: indent zero');
    ok($W->textlines_count == 0 ,   'upon start: textlines zero');

}

sub init_vars {

    @TESTS=qw(
      start
      adding_lines
      indentation
      commenting
      printing
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

sub test_adding_lines {

    $W->_add_line('hello');
    ok($W->text eq 'hello' . "\n",         'text: single line');
    
    ok_lines( [qw(hello)],         'textlines: single line');
    
    $W->_clear;
    $W->_add_line('1');
    $W->_add_line('2');
    $W->_add_line('3');
    ok($W->text eq "1\n2\n3\n",                               'text: three lines');

    ok_lines( [qw(1 2 3)],         'textlines: three lines' );

}
    
sub test_indentation {

    $W->_clear;
    $W->plus('indent');

    $W->_add_line('1');

    ok_lines( [ ' 1' ],            'indentation.1>');

    $W->minus('indent');

}

sub ok_lines {
    my $a=shift;
    my $msg=shift;

    ok( _arrays_equal([ $W->textlines ],$a ), $msg);

}

sub test_printing {

    $testdir=tempdir( CLEANUP => 1 );

    my $filemy=catfile($testdir, 'my.txt');
    my $filepack=catfile($testdir, 'pack.txt');

    open(F,">$filemy") || die $!;

    print F '\begin{document}' . "\n";
    print F ' \begin{tabular}' . "\n";
    print F ' \end{tabular}' . "\n";
    print F '\end{document}' . "\n";

    close(F);

    $W->_clear;
    $W->_add_line('\begin{document}');
    $W->plus('indent');

      $W->_add_line('\begin{tabular}');
      $W->_add_line('\end{tabular}');

    $W->minus('indent');
    $W->_add_line('\end{document}');
    $W->_print( { file => $filepack } );

    system("diff -q $filemy $filepack > /dev/null");

    my $same = ( $? ) ? 0 : 1; 
    
    ok($same,'printing.1> printing to a new file');

    $W->_clear;

}

sub test_commenting {
  my $a;

  $W->commentchar('%');
  $W->delimchar('-');
  $W->delimchars_num(50);

  $W->_clear;
  $W->_c('COMMENT');

  $a=[ '%COMMENT' ];
  ok_lines( $a, 'commenting.1> single comment');

  $W->_clear;
  $W->_c_delim;

  $a=[ $W->commentchar . $W->delimchar x $W->delimchars_num ];
  ok_lines( $a, 'commenting.2> delim comment');

  $W->_clear;
  $W->_c('COMMENT1');
  $W->_c('COMMENT2');
  ok_lines( [qw( %COMMENT1 %COMMENT2)], 'commenting.3> two comments');

}
