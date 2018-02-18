#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

#https://habrahabr.ru/post/163439/
#
use strict;
use warnings;

use Encode::Locale;
use Encode;

#use encoding 'utf8';

my $str = 'Привет мир';

if (-t) 
{
	binmode(STDIN, ":encoding(console_in)");
	binmode(STDOUT, ":encoding(console_out)");
	binmode(STDERR, ":encoding(console_out)");
}

print $str . "\n";
