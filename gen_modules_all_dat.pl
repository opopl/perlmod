#!/usr/bin/env perl

use strict;
use warnings;

use Env qw( $PERLMODDIR );
use OP::Perl::Installer;
use File::Spec::Functions qw(catfile rel2abs curdir );
use File::Slurp qw(
  edit_file
  edit_file_lines
  read_file
  write_file
  append_file
  prepend_file
);
use Data::Dumper;

my $DAT=catfile($PERLMODDIR,qw(inc modules_all.i.dat));
my $i=OP::Perl::Installer->new;

$i->main_no_getopt;

my @MODULES=$i->modules;

write_file($DAT,join("\n",@MODULES) . "\n");
