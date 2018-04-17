package Base::DBH;

use strict;
use warnings;

use DBI;
use Data::Dumper;

use base qw(Base::Logger);

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	if ($self->{connect}) {
		$self->dbh_connect;
	}
}

sub dbh_connect {
	my $self = shift;
	my $ref  = shift;

	my $cn = $ref || $self->{connect};
	eval { $self->{dbh} = DBI->connect(@{$cn}{qw(dsn user pwd attr)}) or
		do { 
			$self->warn($DBI::errstr,$!); 
		};
	};
	if ($@) {
		$self->warn($@,$DBI::errstr);
	}

	$self;
}

sub dbh_disconnect {
	my $self = shift;
	my $ref  = shift;

	my $dbh = $ref->{dbh} || $self->{dbh};
	$dbh->disconnect or 
		do { $self->warn($DBI::errstr,$!); };

	$self;
}

sub dbh_table_exists {
	my $self = shift;
	my $ref  = shift;

	my $table = $ref->{table};
	my $dbh   = $ref->{dbh} || $self->{dbh};

	my $ex    = $ref->{exists};

	my $q = qq{ select * from `$table` limit 1 };

	eval { local $dbh->{PrintError}=0; $dbh->do($q); } ;
	${$ex} = ( $dbh->err ) ? 0 : 1 ;
	
	$self;
}

sub dbh_table_coldata {
	my $self = shift;
	my $ref  = shift;

	my $dbh   = $ref->{dbh};
	my $table = $ref->{table};

	my $dbtype = $ref->{dbtype} || 'mysql';

	my $coldata  = $ref->{coldata};

	if ($dbtype eq 'mysql') {
		my $q=qq{ describe `$table`};
		@$coldata = map {  
			my %col = ( name => $_->[0], type => $_->[1]  ); 
			\%col
		} @{$dbh->selectall_arrayref($q)||[]};
	}

	$self;
}

sub dbh_table_fetch {
	my $self = shift;
	my $ref  = shift;

	my $dbh  = $ref->{dbh} || $self->{dbh};

	my $table  = $ref->{table};
	my $fields = $ref->{fields};
	
	my $f      = join(","   => map { '`'.$_.'`'} @$fields);
	my $q      = qq{select $f from `$table` };
	my $sth;
	my @e=();
	eval { $sth    = $dbh->prepare($q); };
	if($@){ $self->warn($@,$dbh->errstr,$q); }
	
	eval { $sth->execute(@e) or do { $self->warn($dbh->errstr,$q,Dumper([@e])); }; };
	if($@){ $self->warn($@,$dbh->errstr,$q,Dumper([@e])); }
	$self->{sth}=$sth;

	$self;
}

sub dbh_table_selectall {
	my $self = shift;
	my $ref  = shift;

	my $dbh  = $ref->{dbh} || $self->{dbh};

	my $table  = $ref->{table};
	my $fields = $ref->{fields};
	
	my $f      = join(","   => map { '`'.$_.'`'} @$fields);
	my $q      = qq{select $f from `$table` };
	my $res;
	my @e=();
	eval { $res = $dbh->selectall_arrayref($q,@e)
		or do {
			$self->warn($q,Dumper(\@e));
		};

	};
	if($@){ $self->warn($@,$dbh->errstr,$q,Dumper(\@e)); }

	$res;
}

sub dbh_table_insert {
	my $self = shift;
	my $ref  = shift;

	my $dbh  = $ref->{dbh} || $self->{dbh};

	my $table  = $ref->{table};
	my $values = $ref->{values};
	my $fields = $ref->{fields};
	
	my $f      = join(","   => map { '`'.$_.'`'} @$fields);
	my @e      = @$values;
	my $quot   = join "," => map { '?' } @$values;
	my $q      = qq{insert into `$table` ( $f ) values ( $quot ) };
	my $sth;
	eval { $sth    = $dbh->prepare($q); };
	if($@){ $self->warn($@,$dbh->errstr,$q); }
	
	eval { $sth->execute(@e) or do { $self->warn($dbh->errstr,$q,Dumper([@e])); }; };
	if($@){ $self->warn($@,$dbh->errstr,$q,Dumper([@e])); }

	$self;
}

sub dbh_cols {
	my $self = shift;

	my $ref   = shift;

	my $table = $ref->{table};
	my $cols  = $ref->{cols};
	my $dbh   = $ref->{dbh};

	my @fields = ('*');
	my $f      = join(","   => @fields);
	my @e      = ();
	my $q      = qq{select $f from $table limit 1};
	my $sth;
	eval { $sth    = $dbh->prepare($q) or
		do { 
			$self->warn($q,$dbh->errstr); 
			return $self;
		}; 
	};
	if($@){ 
		$self->warn($@,$dbh->errstr,$q);
		return $self;
   	}
	
	eval { $sth->execute(@e)  or
		do { 
			$self->warn($dbh->errstr,$q,Dumper([@e])); 
		}; 
	};
	if($@){ 
		$self->warn($@,$dbh->errstr,$q,Dumper([@e]));
		return $self;
   	}

	@$cols = @{$sth->{NAME_lc}||[]};
	
	$self;
}

sub dbh_list_of_tables {
	my ( $self,$ref) = @_;

	my $dbh  = $ref->{dbh} || $self->{dbh_mysql};
	my $list = $ref->{list};

	my $q = 'show tables';
	eval { @$list = map { $_->[0] } @{ $dbh->selectall_arrayref($q) || []  }; };

	$self;
}


1;
 

