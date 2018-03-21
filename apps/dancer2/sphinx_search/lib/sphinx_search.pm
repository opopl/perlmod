
package sphinx_search;

use Dancer2;
use Dancer2::Plugin::Database;

use Data::Dumper qw(Dumper);

use HTML::Entities qw( encode_entities );
use Sphinx::Search;

our $VERSION = '0.1';

my $sph = Sphinx::Search->new;

#my $dbname="docs_sphinx";

# Initialize database connection
#use DBI;
#my $dbh = DBI->connect("dbi:mysql:dbname=$dbname;host=localhost", "root","")
	#or die $!;

my %sql = (
	drop_documents => qq{ drop table if exists documents},
	create_documents => qq{
		create table if not exists documents (
		    id int NOT NULL AUTO_INCREMENT,
		    title varchar(200) NOT NULL,
		    contents_text text NOT NULL,
		    contents_html text NOT NULL,
		    PRIMARY KEY (id)
		);
	},
);

# Match all words, sort by relevance, return the first 10 results

#$sph->SetMatchMode(SPH_MATCH_ALL);
$sph->SetLimits(0, 10);
$sph->SetSortMode(SPH_SORT_RELEVANCE);


###get_document_id

get '/document/:id' => sub {
	    my $sth = database->prepare(q{SELECT contents_html FROM documents WHERE id = ?});
	    $sth->execute(params->{'id'});
	        
	    if (my $document = $sth->fetchrow_hashref) {
	        return $document->{'contents_html'};
	    }
	    else {
	        status 404;
	        return "Document not found";
	    }
	};

###get_
	#
my $br='<br>';

get '/' => sub {
	#template 'index' => { 'title' => 'sphinx_search' };
	my $params = params('query') || {};

	my @ret;
	push @ret,Dumper($params).$br;

	if (my $phrase = $params->{'query'}) {
		push @ret,Dumper($phrase);
		# Send the search query to Sphinx
		my $results={};
		
		eval { $results = $sph->Query($phrase)
			or push @ret,$sph->GetLastError.$br; };
		if ($@) {
			push @ret,Dumper($@).$br;
		}

		push @ret,Dumper($results).$br if $results;
	
		my $retrieved_count = 0;
		my $total_count;
		my $documents = [];
	
		if ($total_count = $results->{'total_found'}) {
			$retrieved_count = @{$results->{'matches'}};
			# Get the array of document IDs
			my @document_ids = map { $_->{'doc'} } @{$results->{'matches'}};
			# Join the IDs to use in SQL query (the IDs come from Sphinx, so we
			# can trust them to be safe)
			my $ids_joined = join ',', @document_ids;
	
			# Select documents, in the same order as returned by Sphinx
			# (the contents of $ids_joined comes from Sphinx)
			my $sth = database->prepare('SELECT id, title FROM documents ' .
				"WHERE id IN ($ids_joined) ORDER BY FIELD(id, $ids_joined)");
			$sth->execute;
	
			# Fetch all results as an arrayref of hashrefs
			$documents = $sth->fetchall_arrayref({});
		}
	
		# Show search results page
		push @ret,
		   	template( 'results', {
				phrase          => encode_entities($phrase),
				retrieved_count => $retrieved_count,
				total_count     => $total_count,
				documents       => $documents
			});
	}else{
		push @ret, 
			template( 'index' => {} );
	}
	return join("",@ret);

};

true;
