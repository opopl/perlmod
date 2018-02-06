package HTML::Tool::Tabs;

use strict;
use warnings;

use Tk;
use Tk::Widgets qw(
	Notebook
);

use base qw(
	HTML::Tool::tab_test
	HTML::Tool::tab_options
);

sub tk_init_tabs {
	my $self=shift;

	my $cnf=$self->{config}||{};

	my @tab_names = map { 'tab_'.$_} $self->config_get_text('/tk/tabs/tab');

	$self->{tk_tab_names}=[@tab_names];

	my $w = $self->{tk_mw}->NoteBook()->pack(
		-expand => 1,
		-fill   => 'both',
	);

	my $tabs={};
	foreach my $tab_name (@tab_names) {
		my $tab = $w->add($tab_name,-label => $tab_name);

		$tabs->{$tab_name}=$tab;
		$self->{tk_tabs}=$tabs;

		$self->tk_init_tab($tab_name);
	}

	push @{$self->{tk_objects}},'tabs';
	
}


1;


