package HTML::Tool::tab_test;

use strict;
use warnings;

use File::Spec::Functions qw(catfile);

use Tk;
use Tk::Widgets qw(
	Frame 
	DirTree
);

###tab_test
sub tk_init_tab_test {
	my $self=shift;

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_test};

	my $htw=$self->{htw};

	my $fr_left= $tab->Frame(
		-height => '50',
		-width  => 30,
	)->pack(
		-side   => 'top',
		-expand => 0,
	);

	my $dt=$fr_left->DirTree(
		-directory => catfile(qw(c: saved)),
	)->pack(
		-side   => 'top',
		-fill   => 'both',
		-expand => 1,
	);
}

1;
 

