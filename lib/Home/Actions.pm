package Home::Actions;

use strict;
use warnings;
use DBI;

use utf8;
use open qw(:std :utf8);

use Encode::Locale;
use Encode;
use Vim::Dbi;

if (-t) 
{
	binmode(STDIN, ":encoding(console_in)");
	binmode(STDOUT, ":encoding(console_out)");
	binmode(STDERR, ":encoding(console_out)");
}

our($dbh,$sth,$dsn);
our $vimdbi;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	$self->init_vimdbi;
}



sub init_vimdbi {
	my $self=shift;

	my ($user,$pwd,$db,%attr);
	
	$user = 'root';
	$pwd  = '';
	
	$db  = "information_schema";
	$db  = "хозяйство";
	
	%attr=(
		mysql_enable_utf8 => 1,
		PrintError        => 1,
		RaiseError        => 1,
	);
	
	# data source
	$dsn="DBI:mysql:database=$db;host=localhost";
	
	$vimdbi=Vim::Dbi->new(
		dsn  => $dsn,
		db   => $db,
		user => $user,
		pwd  => $pwd,
		attr => \%attr,
	);

	$self;
}

sub db_connect {
	my $self=shift;

	$vimdbi->connect;

	$self;
}


BEGIN {
	my $ha = __PACKAGE__->new;
	$ha->db_connect;
}

#

#use encoding 'utf8';
#my $str = 'Привет мир';



1;
 

