#!/usr/bin/perl 

use strict;
use warnings;

system("perl Build.PL");

system("perl Build ");
system("perl Build test");
system("perl Build install");
