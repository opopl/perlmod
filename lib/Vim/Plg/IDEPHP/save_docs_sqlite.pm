
package Vim::Plg::IDEPHP::save_docs_sqlite;

use strict;
use warnings;

use HTML::Work;
use Vim::Plg::IDEPHP::vars qw(
	$php_net_subs
);
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);

our $htw=HTML::Work->new();

1;
 

