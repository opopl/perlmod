#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(edit_file);
use FindBin qw($Bin);
use Directory::Iterator;
use Data::Dumper;

my $d=$FindBin::Bin;
my $root="$Bin/lib";
my @files;

my $viewer="gvim -n -p --remote-tab-silent";

my $it=Directory::Iterator->new("$root");
$it->show_dotfiles(1);

my @omit=qw(rename.pl);
my @files_to_view;

while (my $file=<$it>) {

	next if ( grep { /$file\s*$/ } @omit );
	
	foreach($file){
		/\.(pm|pl)$/i && do {
			push(@files_to_view,$file);
		}
	}
}

foreach my $file(@files_to_view){
	system("$viewer $file");
}
