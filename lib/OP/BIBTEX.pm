
package OP::BIBTEX;
# Intro {{{

#use LaTeX::BibTeX;
use BibTeX::Parser;
use File::Spec;

use File::Temp qw( tmpnam );
use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
	bibfile
	bibfname
	papdir
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
	pkeys
	mainfields
	rmfields
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
	entries_pkey
	rmfields_type
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);


# }}}
# Methods {{{

=head1 METHODS 

=cut

# init_vars() {{{

sub init_vars(){
	my $self=shift;

	# 
	$self->bibfname("$ENV{hm}/wrk/p/repdoc.bib");

	# Initialize LaTeX::BibTeX stuff
	$self->bibfile(LaTeX::BibTeX::File->new());

	my $blog=tmpnam();
	open(BLOG,">$blog") || die $!;
	select(BLOG);

	$self->bibfile->open($self->bibfname) || die $!;

	select(STDOUT);
	close(BLOG);

	# rmfields     - remove specific fields in a BibTeX entry, e.g. month={} etc.
	$self->rmfields_push( 
		qw( month number owner timestamp numpages eprint url
			file issn language doc-delivery-number affiliation journal-iso pmid
			subject-category number-of-cited-references 
			times-cited unique-id type keywords-plus journal-iso 
			Funding-Acknowledgement Funding-Text 
	));

	# remove fields specific to the individual entry type, e.g.
	# some only for article etc...
	$self->rmfields_type( "article" => "publisher" );

	# mainfields - main fields
	$self->mainfields_push(qw( journal title author volume year pages abstract ));

}

# }}}
# run() {{{

=head3 run()

=cut

sub run(){
	my $self=shift;

	while (my $entry = new LaTeX::BibTeX::Entry->new($self->bibfile)){
    	next unless $entry->parse_ok;
	
		my $pkey=$entry->key;
		$self->pkeys_push($pkey);
		$self->entries_pkey( $pkey => $entry );
	}

	$self->pkeys(sort $self->pkeys);
}

# }}}
# main() {{{

=head3 main()

=cut

sub main(){
	my $self=shift;

	$self->init_vars();
	$self->run();
}

# }}}
# _begin() {{{

=head3 _begin()

=cut

sub _begin(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}
# }}}
# delete_fields() {{{

=head3 delete_fields()

=cut
	
sub delete_fields(){
	my $self=shift;

	my %opts=@_;

	my($entry,$etype);

	foreach my $id (qw( entry etype)){
		eval	'$' . $id . '=$opts{' . $id . '}'; 
	}

	$entry->delete($self->rmfields_clear);

	foreach ($self->rmfields_type_keys){	
		if ( m/$etype/i ){ $entry->delete($_); }
	}
}


# }}}
# list_keys() {{{

=head3 list_keys()

=cut

sub list_keys(){
	my $self=shift;

	print "$_\n" for($self->pkeys);
}

# }}}
# print_entry() {{{

=head3 print_entry()

=cut

sub print_entry(){
	my $self=shift;

	my $pkey=shift;

	my $entry=$self->entries_pkey($pkey);

	my @fields=qw( key author title volume pages year journal );

	print "Paper key: $pkey\n\n";

	if ($self->entry_pdf_file_exists($pkey)){ 
			print "PDF file: Yes\n\n";
		}else{
			print "PDF file: No\n";
	}

	print "	type : " . $entry->type . "\n";

	foreach my $field (@fields){
		if ($entry->exists($field)){
			my $val=$entry->get($field);
			print "	$field : $val \n ";
		}
	}
}

# }}}

# entry_pdf_file_exists(){{{

=head3 entry_pdf_file_exists()

=cut

sub entry_pdf_file_exists(){
	my $self=shift;

	my $pkey=shift;
	my $papdir=$self->papdir || "$ENV{hm}/doc/papers/ChemPhys";

	my $file=File::Spec->catfile($papdir,"$pkey.pdf");

	return 1 if (-e $file);
	return 0;
}
# }}}
# }}}
1;

