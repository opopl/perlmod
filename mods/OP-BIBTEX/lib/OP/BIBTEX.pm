
package OP::BIBTEX;
# Intro {{{

use LaTeX::BibTeX;
use File::Spec;
use parent qw(OP::Script);

# }}}
# Methods {{{

=head1 METHODS 

=cut

# init_vars() {{{

sub init_vars(){
	my $self=shift;

	# 
	$self->_v_set("bibfname","repdoc.bib");

	# Initialize LaTeX::BibTeX stuff
	$self->_r_set("bibfile",LaTeX::BibTeX::File->new());
	$self->_r_get("bibfile")->open($self->_v_get("bibfname")) || die $!;

	# rmfields     - remove specific fields in a BibTeX entry, e.g. month={} etc.
	$self->_a_push("rmfields", 
		qw( month number owner timestamp numpages eprint url
			file issn language doc-delivery-number affiliation journal-iso pmid
			subject-category number-of-cited-references 
			times-cited unique-id type keywords-plus journal-iso 
			Funding-Acknowledgement Funding-Text 
	));

	# remove fields specific to the individual entry type, e.g.
	# some only for article etc...
	$self->_h_add( "rmfields_type",  "article" => "publisher" );

	# mfields - main fields
	$self->_a_push("mfields",qw( journal title author volume year pages abstract ));

}

# }}}
# run() {{{

=head3 run()

=cut

sub run(){
	my $self=shift;

	while (my $entry = new LaTeX::BibTeX::Entry->new($self->_r_get("bibfile"))){
    	next unless $entry->parse_ok;
	
		my $pkey=$entry->key;
		$self->_a_push("pkeys",$pkey);
		$self->_h_add("entries_pkey", $pkey => $entry );
	}

	$self->_a_sort("pkeys");
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

	$entry->delete(@{$self->{a}->{rmfields}});

	foreach (keys %{$self->{h}->{rmfields_type}}){	
		if ( m/$etype/i ){ $entry->delete($_); }
	}
}


# }}}
# list_keys() {{{

=head3 list_keys()

=cut

sub list_keys(){
	my $self=shift;

	$self->_a_list("pkeys");
}

# }}}
# print_entry() {{{

sub print_entry(){
	my $self=shift;

	my $pkey=shift;
	my $entry=$self->_h_get_value("entries_pkey",$pkey);

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

sub entry_pdf_file_exists(){
	my $self=shift;

	my $pkey=shift;
	my $papdir=$self->_d_get("papdir") // "$ENV{hm}/doc/papers/ChemPhys";

	my $file=File::Spec->catfile($papdir,"$pkey.pdf");

	return 1 if (-e $file);
	return 0;
}
# }}}
# }}}
1;

