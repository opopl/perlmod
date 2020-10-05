
package OP::BIBTEX;
# Intro {{{

use BibTeX::Parser;
use File::Spec;

use File::Temp qw( tmpnam );
use File::Spec::Functions qw(catfile);

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    bibfile
    papdir
);

use base qw( 
    OP::Script 
    Class::Accessor::Complex 
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

# init() {{{

sub init {
    my ($self) = @_;

    # 
    $self->bibfile(
        catfile( $ENV{TexPapersRoot},qw( repdoc.bib ))
    );

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

    return $self;

}


sub run {
    my ($self) = @_;

    $self->load_from_file;

    return $self;
}

sub load_from_file {
    my ($self, $ref) = @_;

    my $fbib   = $ref->{file} || $self->bibfile;

    die "No file: $fbib" unless -e $fbib;

    my $fh     = IO::File->new("$fbib");
    my $parser = BibTeX::Parser->new($fh) || die $!;
 
    while (my $entry = $parser->next ) {
        if ($entry->parse_ok) {

            my $pkey=$entry->key;
            $self->pkeys_push($pkey);
            $self->entries_pkey( $pkey => $entry );
 
        } else {
            warn "Error parsing file: " . $entry->error;
        }
    }   

    $self->pkeys(sort $self->pkeys);

    return $self;
}

sub main {
    my $self=shift;

    $self
        ->init
        ->load_from_file;
}

sub new
{
    my ($class, %ipars) = @_;
    my $self = bless (\%ipars, ref ($class) || $class);

    $self->_begin if $self->can('_begin');
    $self->init if $self->can('init');

    return $self;
}

sub _begin {
    my $self=shift;

    $self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}
    
sub delete_fields {
    my $self=shift;

    my %opts=@_;

    my($entry,$etype);

    foreach my $id (qw( entry etype)){
        eval    '$' . $id . '=$opts{' . $id . '}'; 
    }

    $entry->delete($self->rmfields_clear);

    foreach ($self->rmfields_type_keys){    
        if ( m/$etype/i ){ $entry->delete($_); }
    }
}

sub list_keys {
    my $self=shift;

    print "$_\n" for($self->pkeys);
}


sub print_entry {
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

    print " type : " . $entry->type . "\n";

    foreach my $field (@fields){
        if ($entry->exists($field)){
            my $val=$entry->get($field);
            print " $field : $val \n ";
        }
    }
}


sub entry_pdf_file_exists(){
    my $self=shift;

    my $pkey=shift;
    my $papdir=$self->papdir || "$ENV{hm}/doc/papers/ChemPhys";

    my $file=File::Spec->catfile($papdir,"$pkey.pdf");

    return 1 if (-e $file);
    return 0;
}

1;

