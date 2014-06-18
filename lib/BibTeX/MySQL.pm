
package BibTeX::MySQL;

use strict;
use warnings;

=head1 NAME

BibTeX::MySQL 

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use parent qw( Class::Accessor::Complex );
use LaTeX::BibTeX;
use DBI;

use FindBin qw($Script);

=head1 ACCESSORS

=head2 Scalar Accessors

=over 4

=item * C<bib> 

L<LaTeX::BibTeX::File> object;

=item * C<bibpath> 

Full path to the BibTeX file being loaded;

=item * C<dbh> 

L<DBI> database handle

=item * C<db>

Name of the MySQL database 

=item * C<user>

Username used for connecting to the MySQL database

=item * C<password>

Password for the MySQL connection

=back

=cut

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
	bib
	bibpath
	db
	dbh
	user 
	password
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
	entries_pkey
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
	pkeys
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors)
	->mk_new;

=head1 METHODS

=cut
	
sub main {
	my $self=shift;

	$self->connect;
	$self->parsebib;
	$self->fillsql;

	$self->end;

	exit 0;
	
}

sub end {
	my $self=shift;

	my $dbh=$self->dbh;

	$dbh->commit;
	$dbh->disconnect or warn $dbh->errstr;

}

sub init {
	my $self=shift;

	{
		no strict 'refs';
		foreach my $id (qw(bibpath user password db )) {
			( defined $self->$id ) || die "accessor not defined: " . $id;
		}
	}
	( defined $self->bibpath ) || die "bibpath not defined";

	( -e $self->bibpath ) || die "bib file does not exist: " . $self->bibpath;

	# Initialize LaTeX::BibTeX stuff
	$self->bib(LaTeX::BibTeX::File->new());

	$self->bib->open($self->bibpath) || die $!;

}

sub connect {
	my $self=shift;

	my $dsn="dbi:mysql:" . $self->db;

	my %attr=( 
		RaiseError => 1, 
		AutoCommit => 0 
	);
	my $dbh = DBI->connect($dsn, $self->user, $self->password, \%attr )
					or die $DBI::errstr;

	$self->dbh( $dbh );

	1;
}

sub say {
	my $self=shift;

	my $msg=shift;

	print "$Script> " . $msg . "\n";
	
}

sub parsebib {
	my $self=shift;

	$self->say('Parsing BibTeX file...');

	while (my $entry = new LaTeX::BibTeX::Entry->new($self->bib)){
    	next unless $entry->parse_ok;
	
		my $pkey=$entry->key;
		$self->pkeys_push($pkey);
		$self->entries_pkey( $pkey => $entry );
	}

	$self->pkeys(sort $self->pkeys);
	$self->pkeys_uniq;

	1;
}

sub fillsql {
	my $self=shift;

	$self->sql_filltable_pkeys;

}

sub sql_filltable_pkeys {
	my $self=shift;

	$self->say('Filling table: pkeys');

	my $table='pkeys';
	my $dbh=$self->dbh;

	my $sql=[
		"drop table if exists $table",
		qq{ 
			create table if not exists $table ( 
				pkey char(50) primary key, 
				title varchar(200),
				author varchar(100),
				volume int, 
				year char(10)
			) 
		},
	];

	foreach my $cmd (@$sql) {
		$dbh->do($cmd) || die $dbh->errstr;
	}

	$self->say('	Created table: pkeys');

	my $cmd=qq{
		insert into $table ( pkey, title, author, volume, year ) values ( ?, ?, ?, ?, ? ); 
	};
	my $sth=$dbh->prepare($cmd);

	foreach my $pkey($self->pkeys) {
		print 'Processing key: ' . $pkey . "\n";
		my $entry=$self->entries_pkey($pkey);

		my @fields=qw( title author volume year );
		my @bind=( $pkey );

		foreach my $f (@fields) {
			my $val=$entry->get($f);
			push(@bind,$val);
		}

		$sth->execute(@bind) || die $sth->errstr;

	}


}

1;
