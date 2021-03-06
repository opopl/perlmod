#!/usr/local/bin/perl -w

use strict ;
use File::Slurp ;

use Test::More tests => 2 ;


my $data = <<TEXT ;
line 1
more text
TEXT

my $file = 'xxx' ;

unlink $file ;


my $err = write_file( $file, { no_clobber => 1 }, $data ) ;
ok( $err, 'new write_file' ) ;

$err = write_file( $file, { no_clobber => 1, err_mode => 'quiet' }, $data ) ;

ok( !$err, 'no_clobber write_file' ) ;

unlink $file ;
