
package BibTeX::MySQL;

use strict;
use warnings;
#use diagnostics;

=head1 NAME

BibTeX::MySQL 

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use parent qw( Exporter Class::Accessor::Complex );
use LaTeX::BibTeX;
use LaTeX::BibTeX::NameFormat;
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

###our
our @EXPORT_OK=qw(@CONFKEYS %DESC);

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
	bib
	bibpath
	db
	dbh
	user 
	password
	table_keys
	table_bib
    conffile
);

our	@CONFKEYS=qw( 
		bibpath 
		db 
		password 
		user 
		table_keys table_bib
);

our	%DESC=(
		CONFKEYS => {
			bibpath 		=> 'Full path to the BibTeX file',
			db 				=> 'MySQL database name',
			password 		=> 'Password for connecting to the MySQL database',
			user			=> 'User name for connecting to the MySQL database',
			table_bib	 	=> 'Table specific for this BibTeX file ',
			table_keys	 	=> 'Table used for storing BibTeX keys',
		},
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

	$self->_debug('Initializing...');

    $self->readconf;

	# Initialize LaTeX::BibTeX stuff
	$self->bib(LaTeX::BibTeX::File->new());

	$self->connect;

	{
		no strict 'refs';
		foreach my $id (@scalar_accessors) {
			( defined $self->$id ) || $self->_die("scalar accessor not defined: " . $id);
		}
	}
	( defined $self->bibpath ) || $self->_die("bibpath not defined");

	( -e $self->bibpath ) || $self->_die("bib file does not exist: " . $self->bibpath);

	$self->bib->open($self->bibpath) || $self->_die($!);

}

sub connect {
	my $self=shift;

	my $dsn="dbi:mysql:" . $self->db;

	$self->_debug('Connecting to the database...');

	my %attr=( 
		RaiseError => 1, 
		AutoCommit => 0 
	);
	my $dbh = DBI->connect($dsn, $self->user, $self->password, \%attr )
					or $self->_die($DBI::errstr);

	$self->dbh( $dbh );

	1;
}

sub readconf {
	my $self=shift;

    my $conffile=shift // $self->conffile // '';

	$self->_debug('Reading configuration file...');

	unless ( $conffile ){
        $self->_warn('conffile is zero');
		return 0;
	}

	unless ( -e $conffile ){
        $self->_warn('provided conffile does not exist');
		return 0;
	}

	my $c=Config::YAML->new( 
		config => $conffile,
	);

	my %pars;
	
	foreach my $id (@CONFKEYS) {
		next unless defined $c->{$id};
	
		$self->$id( $c->{$id} );
	}

}

sub _say {
	my $self=shift;

	my $msg=shift;

	print "$Script> " . $msg . "\n";
	
}

sub _die {
	my $self=shift;

	my $msg=shift;

	print "$Script.Error> " . $msg . "\n";
    exit 1;
	
}

sub _warn {
	my $self=shift;

	my $msg=shift;

	print "$Script.Warning> " . $msg . "\n";
	
}

sub _debug {
	my $self=shift;

	my $msg=shift;

	print "$Script.Debug> " . $msg . "\n";
	
}

sub parsebib {
	my $self=shift;

	$self->_debug('Parsing BibTeX file...');

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
	$self->sql_filltable_authors;

    1;

}

sub sql_filltable_authors {
    my $self=shift;

	my $table='authors';

	$self->_debug('Filling table: ' . $table );

	my $dbh=$self->dbh;

	my $sql=[
		"drop table if exists $table",
		qq{ 
			create table if not exists $table ( 
				author char(50), 
				pkey char(50) 
			) 
		},
	];

	foreach my $cmd (@$sql) {
		$dbh->do($cmd) || $self->_die( $dbh->errstr );
	}

	$self->_debug('	Created table: ' . $table );

	my $cmd=qq{
		insert into $table ( author, pkey ) values ( ?, ? ); 
	};
	my $sth=$dbh->prepare($cmd);

	foreach my $pkey($self->pkeys) {
		my $entry=$self->entries_pkey($pkey);

        my $format = LaTeX::BibTeX::NameFormat->new( 'vljf', 1);
        my @authors=map { $format->apply($_) } $entry->names('author');

        foreach my $author (@authors) {
            my @bind=( $author, $pkey );
            $sth->execute(@bind) || $self->_die( $sth->errstr );
        }

	}

    1;
}

sub sql_filltable_pkeys {
	my $self=shift;

	$self->_debug('Filling table: ' . $self->table_bib );

	my $table=$self->table_bib;
	my $dbh=$self->dbh;

	my $sql=[
		"drop table if exists $table",
		qq{ 
			create table if not exists $table ( 
				pkey char(50) primary key, 
				title varchar(200),
				authors varchar(100),
				volume int, 
				year char(10)
			) 
		},
	];

	foreach my $cmd (@$sql) {
		$dbh->do($cmd) || $self->_die( $dbh->errstr ); 
	}

	$self->_debug('	Created table: ' . $self->table_bib );

	my $cmd=qq{
		insert into $table ( pkey, title, authors, volume, year ) values ( ?, ?, ?, ?, ? ); 
	};
	my $sth=$dbh->prepare($cmd);

	foreach my $pkey($self->pkeys) {
		my $entry=$self->entries_pkey($pkey);

		my @fields=qw( title author volume year );
		my @bind=( $pkey );

		foreach my $f (@fields) {
			my $val=$entry->get($f);
			push(@bind,$val);
		}

		$sth->execute(@bind) || $self->_die( $sth->errstr );

	}

    1;

}

1;
