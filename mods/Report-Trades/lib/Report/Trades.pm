package Report::Trades;

use strict;
use warnings;

###use
use DBI;
use Data::Dumper;
use DBD::Pg;

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    dbh
    dbname
    dbfile
    dbdata
    dbuser 
);

# dbh       - DBI database handler
# dbname    - name of the database, as understood by PostgreSQL
# dbfile    - full path to the dump of the database
# dbuser    - name of the user who connects to the database

###__ACCESSORS_HASH
our @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
our @array_accessors=qw();

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

my %attr=(
   RaiseError => 1, 
   AutoCommit => 0,
);

sub main {
    my $self=shift;

    $self->init_vars;

    $self->db_connect;

    $self->finish;

}

sub init_vars {
    my $self=shift;

}

sub db_connect {
    my $self=shift;

    my $data_source='dbi:Pg:dbname=mg';
    my $dbh=DBI->connect($data_source,'','',\%attr);

	if ($DBI::err != 0) {
	  print $DBI::errstr . "\n";
	  exit($DBI::err);
	}
}

sub finish {
    my $self=shift;

	$self->sth->finish;
	$self->dbh->disconnect;
}

my $query = "SELECT * FROM pg_tables";

my $sth = $dbh->prepare($query);
my $rv = $sth->execute();

if (!defined $rv) {
  print "При выполнении запроса '$query' возникла ошибка: " . $dbh->errstr . "\n";
  exit(0);
}

while (my $ref = $sth->fetchrow_hashref()) {
  my($tablename, $tableowner) = ($ref->{'tablename'}, $ref->{'tableowner'});
  print "$tablename\t$tableowner\n";
}


1;
