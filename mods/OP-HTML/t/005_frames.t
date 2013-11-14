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

 @TESTS=qw( frames );

 foreach my $test (@TESTS) {
    eval '*OP::HTML::Tests::test_' . $test . '=*test_' . $test;
    warn $@ if $@;
 }

}

sub test_frames {
    my $reftext;

    $H->_clear;
    $reftext = << 'EOF';
<frameset cols="25%,75%">
 <frame src="SRC1" name="NAME1" />
 <frame src="SRC2" name="NAME2" />
</frameset>
EOF

    $H->frameset({ 
            cols => '25%,75%',
            frames => [ 
                { src => 'SRC1', name => 'NAME1' },
                { src => 'SRC2', name => 'NAME2' },
            ],
    });

    my $msg='frames> frameset generation: ' . "\n";
    $msg.="Original text:\n";
    $msg.="$reftext\n";
    $msg.="Generated text:\n";
    $msg.=$H->text . "\n";

    ok($H->text eq "$reftext"  , $msg );

}

