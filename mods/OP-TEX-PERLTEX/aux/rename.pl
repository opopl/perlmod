#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(edit_file);
use FindBin qw($Bin);
use Directory::Iterator;
use Data::Dumper;

my $old="OP::TEX::Driver";
my $new="OP::TEX::Driver";

my $d=$FindBin::Bin;
my @files;

my $scalar_accessor_renames=[qw(
			doneflag
			fromflag
			fromperl
			jobname
			latexprog
			logfile
			pipe
			progname
			runsafely
			styfile
			toflag
			toperl
			usepipe
			pipestring
)];

my $renames;

foreach my $id (@$scalar_accessor_renames) {
	$renames->{"\\\$$id"}="\$self->$id";
}

my $it=Directory::Iterator->new("$Bin/../");
$it->show_dotfiles(1);

while (my $file=<$it>) {
	#next unless $file =~ m/(\.t|\.pm)$/;
	print "Processing: $file\n";
		
	edit_file {
		while(my($old,$new)=each %{$renames}){
			s/$old/$new/g;
		}
	} $file;
}

