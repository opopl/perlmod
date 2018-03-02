package Home::Manager;

use strict;
use warnings;
use Tk;

use Home::Actions;
use Home::Links;

our $mw;

my @stfx = qw/-side top -fill x/;


###Home::Manager::main
###hmm_main
sub main {
	$mw = MainWindow->new;

	$mw->Button(
		-text => 'Fetch Links',
		-command => sub {
			&Home::Links::fetch_links();
		},
	)->pack(@stfx);

	MainLoop;
}

1;
 

