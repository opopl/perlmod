package HTML::Tool::tab_options;

use strict;
use warnings;

use Tk;
use Tk::Widgets qw(
	Frame
	Label
	Entry
);
use Data::Dumper qw(Dumper);


###tab_options
sub tk_init_tab_options {
	my $self=shift;

	my $mw=$self->{tk_mw};

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_options};

	my ($paths,$path_order)=$self->config_get_hash('/tk/tab_options/paths');

	my $fr=$tab->Frame->pack(-side => 'top',-fill => 'x');

	$self->{paths}=$paths;

	foreach my $pathname (@$path_order) {
		$self->log($pathname);

		my $val = $paths->{$pathname} || '';
		next unless $val;

		$self->log($val);

		#$self->log(Dumper($val));

		my $lb = $fr->Label(
			-text => $pathname,
		)->pack(qw/-side top/);

		my $e= $fr->Entry(
		     -textvariable => \$val,
		     -width        => 20,
		)->pack(qw/-side top -fill x -expand 1/)
	}
 
}


1;
 

