#!/usr/bin/env perl 

use strict;
use warnings ;
#use warnings FATAL => 'all';

use utf8;
use open qw(:std :utf8);
use encoding 'utf8';


use Data::Dumper qw(Dumper);
use Encode;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $string = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя";
$string="ывавыа здравствуй";

my $d=Dumper($string);
my $subs=[
	sub { print $string . "\n"; },
	sub { print utf8::encode("\x{410}") . "\n"; },
	sub { print utf8::encode($d) . "\n"; },
	sub { print $d . "\n"; },
	sub { print decode('utf8',$d) . "\n"; },
	sub { print utf8::downgrade($d) . "\n"; },
	sub { print utf8::upgrade($d) . "\n"; },
	sub { 
			my $VAR1; 
		   	eval $d; 
			print $VAR1 . "\n"; 
		},
	sub { print utf8::downgrade($string) . "\n" },
	sub { print utf8::upgrade($string) . "\n" },
	sub { print decode('utf8',$string) . "\n" },
];

my $i=1;
foreach my $sub (@$subs) {
	print 'STEP# '.$i . "\n";
	eval { $sub->(); };
	if ($@) {
		warn $@ . "\n"
	}
	$i++;
}

;

use Data::Dumper qw(Dumper);

#print Dumper(decode('utf8',$string));
#print Dumper($string);
#print Dumper(utf8::downgrade($string));
#my $s=utf8::downgrade($string);
#my $s=utf8::upgrade($string);
#use Data::Dumper qw(Dumper);

#print $s . "\n";
#exit 0;
#exit 0;

#print decode('utf8','аа') . "\n";

#print decode('utf8',$string) . "\n";
#print encode('utf8',$string) . "\n";

#print "'" . utf8::is_utf8($string) . "'" . "\n";
#print length($string) . "\n";
#print $string . "\n";
#print uc($string) . "\n";

#my $a = utf8::downgrade("\x{d0}\x{90}");
#print $a . "\n";
#print string($a) . "\n";
#print string($a) . "\n";
#print utf8::decode($string) . "\n";
