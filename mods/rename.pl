#!/usr/bin/env perl
 
use warnings;
use strict;

use FindBin qw($Bin);
use File::Find qw(find);
use File::Slurp qw(edit_file_lines);
use File::Spec::Functions qw(catfile);

my @files;

#my @ext=qw( t pm pl);

File::Find::find({ 
	wanted => sub { 
		push(@files,$File::Find::name);
			#if /$/
	} 
},$Bin	
);

foreach my $f (@files) {
	edit_file_lines {
		s/OP::TEX::Text/Text::Generate::TeX/g;
		s/OP::Writer::Tex/Text::Generate::TeX/g;
		s/OP::Writer::Pod/Text::Generate::Pod/g;
		s/OP::Writer/Text::Generate::Base/g;
	} $f;
}
 
