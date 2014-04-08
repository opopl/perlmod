
package OP::PAPERS::ind_insert_bookmarks;

use strict;
use warnings;


###use
use File::Slurp qw(edit_file);
use OP::Script::Simple qw(
	_say 
	override_argv 
	restore_argv 
);

use FindBin qw($Script);
use Data::Dumper;

###our
our @ISA     = qw(Exporter);
our @EXPORT_OK = qw( ind_insert_bookmarks );
our @EXPORT  = qw( );
our $VERSION = '0.01';

our($indfile,$level);


###subs
sub ind_insert_bookmarks;
sub get_opt;
sub run;

sub get_opt {
	my @a=@_;

	override_argv(\@a);

	unless(@ARGV){
		_say "USAGE: $Script INDFILE LEVEL";
		exit 1;
	}

	$indfile=shift @ARGV;
	$level=shift @ARGV // 2;

}

sub ind_insert_bookmarks {

	get_opt(@_);
	run;
}

sub run {

	edit_file {
		s/({\\bfseries\\hfil)\s*(\w+)(\\hfil}\\nopagebreak)/\n\\hypertarget{ind-$2}{}\n\\bookmark[level=$level,dest=ind-$2]{$2}\n $1 $2$3/gm;
	} $indfile;

}

1;
