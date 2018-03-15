#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use Vim::Perl qw(:funcs :vars);

my $s='d\dsfsdf';
my $a=[qw(a b c )];
my $h={qw(a b c d)};

VimLet('s',$s);
VimLet('a',$a);
VimLet('h',$h);
