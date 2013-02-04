#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(edit_file);
use FindBin qw($Bin);
use Directory::Iterator;
use Data::Dumper;

my $old="LaTeX::Driver";
my $new="OP::TEX::Driver";

my $d=$FindBin::Bin;
my $root="$Bin/../";
my @files;

my $it=Directory::Iterator->new("$root");
$it->show_dotfiles(1);

while (my $file=<$it>) {
	
	foreach($file){
		/(\.t)$/ && do {
			print "Processing file: $file\n";
			edit_file {
				#s/$old/$new/g;
				s/\/usr\/bin\/perl/\/usr\/bin\/env perl/g;
			} $file;
			next;
		};
	}
}

