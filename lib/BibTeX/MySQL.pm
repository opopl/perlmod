
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
	entries
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

	$self->dbh->disconnect;
	
}


sub init_vars {
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

	my $dsn="DBD:mysql:" . $self->db;

	my $dbh = DBI->connect($dsn, $self->user, $self->password,
                    { RaiseError => 1, AutoCommit => 0 });

	$self->dbh( $dbh );

}

sub parsebib {
	my $self=shift;

	while (my $entry = new LaTeX::BibTeX::Entry->new($self->bib)){
    	next unless $entry->parse_ok;
	
		my $pkey=$entry->key;
		$self->pkeys_push($pkey);
		$self->entries_pkey( $pkey => $entry );
	}

	$self->pkeys(sort $self->pkeys);
}

1;
