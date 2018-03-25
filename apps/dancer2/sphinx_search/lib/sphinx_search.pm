
package sphinx_search;

use Dancer2;
use Dancer2::Plugin::Database;

use Data::Dumper qw(Dumper);

use HTML::Entities qw( encode_entities );
use DBI;

our $VERSION = '0.1';

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
	my @sql=qw( drop_documents create_documents );
	my $query = $sql_queries{$sql_id};

	if ($query) {
		database->do($query);
	}
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
	        
	    if (my $document = $sth->fetchrow_hashref) {
	        return template( 
				'viewer', { 
					contents_html => $document->{'contents_html'},
				}
			);
	    }
	    else {
	        status 404;
	        return "Document not found";
	    }
	};

get '/' => sub {
	my @ret;
	push @ret, template( 'search_form' => {} );
	return join("",@ret);
};

###post /search
post '/search' => sub {
	my $params = params('query') || {};

	my @ret;
	push @ret,Dumper($params).$br;

	my $index="test";

	my $phrase = $params->{'query'};
	my $results={};

	my @e = ($phrase);

	my ($query,$sth);
	
	$query = qq{ select * from $index where match(?) };
	eval { $sth = $shx->prepare($query)
		or push @ret, $DBI::errstr;};
	if ($@) { push @ret,$@,$DBI::errstr; }
	
	@e=($phrase);
	eval { $sth->execute(@e) or push @ret, $DBI::errstr;};
	if ($@) { push @ret,$@,$DBI::errstr; }
	
	my $fetch='fetchrow_arrayref';
	my $total_count=0;
	my @ids;

	while(my $row = $sth->$fetch){
		$total_count++;
		push @ids, @$row;
	}

    my $retrieved_count = @ids;

    if (@ids) {
		my $ids_j = join ',', @ids;
		my $q = qq{
			SELECT id, title FROM documents WHERE id IN ($ids_j) ORDER BY FIELD(id, $ids_j)
		};
		my $sth=database->prepare($q);
		$sth->execute;

		## Fetch all results as an arrayref of hashrefs
		my $documents = $sth->fetchall_arrayref({});

		my $i  = 0;
		my $sz = scalar @$documents;
		foreach my $doc (@$documents) {
			$doc->{prev}=$documents->[$i-1];
			$doc->{next}=$documents->[( $i+1 ) % $sz];

			$i++;
		}

		my $fields=[qw(id time_added title)];
		@$fields = map { ($params->{'checked_'.$_}) ? $_ : () } @$fields;

		push @ret,
			template( 'results', {
				phrase          => encode_entities($phrase),
				retrieved_count => $retrieved_count,
				total_count     => $total_count,
				documents       => $documents,
				fields          => $fields,
			});
	}else{
		push @ret,
			template( 'not_found' , { phrase => $phrase });
	}

	return join("",@ret);

};

true;
