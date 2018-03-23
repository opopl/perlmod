package Base::Document;

use strict;
use warnings;
use DBI;

my ($dsn,$db,$user,$pwd,%attr);
my %attr=(
	RaiseError => 1,
	PrintError => 1,
);
$db   = 'docs_sphinx';
$user = 'root';
$pwd  = '';
$dsn  = "DBI:mysql:database=$db;host=localhost";

our $dbh = DBI->connect($dsn,$user,$pwd,\%attr)
	or warn $DBI::errstr;

1;
 

