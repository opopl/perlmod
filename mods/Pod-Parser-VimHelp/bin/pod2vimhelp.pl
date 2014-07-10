#!/usr/bin/env perl 

use strict;
use warnings;

use Pod::Parser::VimHelp;

my $parser=Pod::Parser::VimHelp->new;

$parser->parse_from_filehandle(\*STDIN)  if (@ARGV == 0);
for (@ARGV) { $parser->parse_from_file($_); }
