#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

      use URI::Simple;
      my $uri = URI::Simple->new('http://google.com/some/path/index.html?x1=yy&x2=pp#anchor');
  
      #enable strict mode
      my $uri = URI::Simple->new('mailto:username@example.com?subject=Topic');
  
      print $uri->path;
      print $uri->source;
