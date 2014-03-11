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
sub test_head;

main;

sub main {
	init_vars;
	do_tests;
}

sub init_vars {

 @TESTS=qw( head );

 foreach my $test (@TESTS) {
    eval '*OP::HTML::Tests::test_' . $test . '=*test_' . $test;
    warn $@ if $@;
 }

}

sub test_head {
    my $reftext;

    $H->_clear;
    $reftext = << 'EOF';
<head>
 <title>TITLE</title>
</head>
EOF
    $H->head({ title => 'TITLE' });

    ok($H->text eq "$reftext"  , 'head> TITLE ' );

}

