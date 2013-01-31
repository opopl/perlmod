#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(edit_file);
use FindBin;
use Directory::Iterator;
use Data::Dumper;

my $old="OP::TEX::Driver";
my $new="OP::TEX::Driver";

my $d=$FindBin::Bin;
my @files;

my $it=Directory::Iterator->new(".");
$it->show_dotfiles(1);

while (my $file=<$it>) {
	#next unless $file =~ m/(\.t|\.pm)$/;
	print "Processing: $file\n";
	edit_file {
		s/$old/$new/g;
	} $file;
}

