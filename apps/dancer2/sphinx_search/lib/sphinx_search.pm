
package sphinx_search;

use Dancer2;
use Dancer::Plugin::Database;
use HTML::Entities qw( encode_entities );
use Sphinx::Search;

our $VERSION = '0.1';

my $sph = Sphinx::Search->new;

# Match all words, sort by relevance, return the first 10 results

$sph->SetMatchMode(SPH_MATCH_ALL);
$sph->SetSortMode(SPH_SORT_RELEVANCE);
$sph->SetLimits(0, 10);


###get_document_id

get '/document/:id' => sub {
	    my $sth = database->prepare('SELECT contents_html FROM documents ' .
	        'WHERE id = ?');
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

get '/' => sub {
	template 'index' => { 'title' => 'sphinx_search' };
	
	if (my $phrase = params('query')->{'phrase'}) {
		# Send the search query to Sphinx
		my $results = $sph->Query($phrase);
	
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
		return template 'results', {
			phrase          => encode_entities($phrase),
			retrieved_count => $retrieved_count,
			total_count     => $total_count,
			documents       => $documents
		};
	}else{
		return template 'index';
	}

};

true;
