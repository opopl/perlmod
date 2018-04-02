
package sphinx_search;

use Dancer2;
use Dancer2::Plugin::Database;

use Data::Dumper qw(Dumper);

use HTML::Entities qw( encode_entities );
use DBI;
use SQL::SplitStatement;

our $VERSION = '0.1';
our $spl = SQL::SplitStatement->new;

our @select_fields = qw(
	id title time_added file_local_text file_local_html
	tags url_remote
	doc_id
	local_id
);
our $search_results=[];

my $shx = DBI->connect('dbi:mysql:host=localhost;port=9306;mysql_enable_utf8=1') 
	or die "Failed to connect via DBI";

my $br='<br>';

###get /database/:sql_id

get '/database/:sql_id' => sub {
	my $sql_id = params->{'sql_id'};
	my %sql_queries = (
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
	my @sql   = qw( drop_documents create_documents );
	my $query = $sql_queries{$sql_id};

	if ($query) {
		database->do($query);
	}
};

###get /options
get '/options' => sub {
	return template 'options';
};

###get /status
#
get '/status' => sub {
	return template 'sphinx_status';
};

###get /document/:id

get '/document/:id' => sub {
		my $q= q{SELECT contents_html FROM documents WHERE id = ?};

	    my $sth = database->prepare($q);
		my $id  = params->{'id'};

	    $sth->execute($id);
	        
	    if (my $doc = $sth->fetchrow_hashref) {
			my $sz = scalar @$search_results;

			my %add;
			if ($sz) {

				my $id_next = ( $id + 1 ) % $sz;
				my $id_prev = ( $id - 1 ) % $sz;

				my $match_prev = $search_results->[$id_prev]->{'id'};
				my $match_next = $search_results->[$id_next]->{'id'};
	
				my $next = {
					href => '/document/'.$match_next,
					title => $search_results->[$id_next]->{'title'},
				};
				my $prev = {
					href => '/document/'.$match_prev,
					title => $search_results->[$id_prev]->{'title'},
				};

				%add=(
					prev => $prev,
					next => $next,
				);

			}

	        return template( 
				'viewer', { 
					contents_html => $doc->{'contents_html'},
					search_done   => ($sz > 0) ? 1 : 0 ,
					%add,
				}
			);
	    }
	    else {
	        status 404;
	        return "Document not found";
	    }
	};

###get /search_form
get '/search_form' => sub {
	my @ret;
	push @ret, template( 
		'search_form' => { 
			fields => \@select_fields,
		});
	return join("",@ret);
};

###get /
get '/' => sub {
	redirect('/search_form');
};

get '/search_online' => sub {
};

###get /add_document
get '/add_document' => sub {
	my @ret;
	push @ret, template( 
		'add_document' => { }
	);
	return join("",@ret);
};

###post /search_results
post '/search_results' => sub {
	my @ret;

	my $phrase      = body_parameters->get('phrase');

	push @ret, template( 'dumper', { var => $phrase } );

	my $index="test";

	my $max_matches = body_parameters->get('max_matches');

	my $results={};

	my @e = ($phrase);

	my ($query,$sth);

	my $fields=[];
	@$fields = map { $_->[0] } @{ database->selectall_arrayref("describe documents") };
	
	$query = qq{ 
		select * from $index 
		where match(?) limit $max_matches
	};

	eval { $sth = $shx->prepare($query)
		or push @ret, $DBI::errstr,$query;};
	if ($@) { push @ret,$@,$DBI::errstr,$query; }
	
	@e=($phrase);
	eval { $sth->execute(@e) or push @ret, $DBI::errstr;};
	if ($@) { push @ret,$@,$DBI::errstr; }
	
	my $fetch       = 'fetchrow_arrayref';
	my $total_count = 0;
	my @ids;

	while(my $row = $sth->$fetch){
		$total_count++;
		push @ids, @$row;
	}

    my $retrieved_count = @ids;

    if (@ids) {
		my $ids_j    = join ',', @ids;
		my $select_f = join(",",@select_fields);
		my $q = qq{
			DROP TABLE IF EXISTS search_results;
			CREATE TABLE 
				search_results
			AS
				SELECT $select_f
			FROM 
				documents 
			WHERE id IN ($ids_j) 
			ORDER BY 
				FIELD(id, $ids_j);
		};
		my @q=$spl->split($q);
		for(@q){
			database->do($_);
		}

		my $sth=database->prepare('select * from search_results');
		$sth->execute;

		## Fetch all results as an arrayref of hashrefs
		$search_results = $sth->fetchall_arrayref({});

		my $i  = 0;
		my $sz = scalar @$search_results;
		foreach my $doc (@$search_results) {
			$doc->{prev}=$search_results->[$i-1];
			$doc->{next}=$search_results->[( $i+1 ) % $sz];

			$i++;
		}

		@$fields = map { (body_parameters->get('checked_'.$_) ) ? $_ : () } @$fields;

		push @ret,
			template( 'results', {
				phrase          => encode_entities($phrase),
				retrieved_count => $retrieved_count,
				total_count     => $total_count,
				documents       => $search_results,
				fields          => $fields,
				captions        => 'Search results for: '. $phrase,
			});
	}else{
		push @ret,
			template( 'not_found' , { phrase => $phrase });
	}

	return join("",@ret);

};

true;
