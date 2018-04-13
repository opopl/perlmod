#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

      use Pod::Simple::Vim;
  
      my $parser = Pod::Simple::Vim->new;
  
my $perldoc;
$parser->output_string(\$perldoc);
$parser->parse_file($pod_filename); 
  
print $perldoc;
