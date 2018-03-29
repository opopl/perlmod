

package Base::CV;

use strict;
use warnings;
use utf8;

use Data::Dumper;

use LaTeX::Table;
use TeX::Escape;

use FindBin qw($Bin $Script);
use File::Find qw(find);
use File::Spec::Functions qw(catfile);
use File::Basename qw(basename);

use DBI;
use Base::CSV_DBI;
use Tie::File;

use XML::LibXML;
use XML::Simple qw(XMLin);
use XML::LibXML::PrettyPrint;

use SQL::SplitStatement;

our $proj = "cv_eng";
our $root = $Bin;

our $coltype='varchar(200)';

our @csv_files;
our (@tablenames,%tabledata);

our $xmlfile      = catfile($Bin,'cv_eng.xml');
our $xmlfile_save = catfile($Bin,'cv_eng_save.xml');


our $header_map = {
	education => {
	},
	technologies => {
	},
};

our %cb_latex_table;


sub init {
	my $self=shift;

	my $h={
		csv_dir  => catfile($root,'csv',$proj),
		sub_warn => sub { warn $_ . "\n" for(@_) },
		sub_log  => sub { print $_ . "\n" for(@_) },
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self
		->init_cb
		->init_db_mysql
		->load_xml_to_dom
		->dom_to_tabledata
		;
}

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub warn {
	my ($self,@args)=@_;

	my $sub = $self->{sub_warn} || $self->{sub_log} ||undef;
	$sub && $sub->(@args);

	return $self;
}

sub log {
	my ($self,@args)=@_;

	my $sub = $self->{sub_log} ||undef;
	$sub && $sub->(@args);

	return $self;
}


sub load_xml_to_dom {
	my $self=shift;

	my $prs = XML::LibXML->new;
	
	open my $fh, '<', $xmlfile;
	binmode $fh;
	my $inp={
		IO          	=> $fh,
		recover         => 1,
		suppress_errors => 1,
	};
	my $dom = $self->{dom} = $prs->load_xml(%$inp);
	close $fh;

	$self->init_tablenames_from_dom;

	$self;
}

sub init_tablenames_from_dom {
	my ($self,$ref) = @_;

	my $dom = $self->{dom};
	my @n   = $dom->findnodes('/root/tables/table') ;
	my @tn  = map { $_->getAttribute('name') } @n;

	$self->{tablenames_dom}=[@tn];

	$self;
}

sub dom_to_tabledata {
	my $self = shift;
	my $ref  = shift;

	my $dom = $ref->{dom} || $self->{dom};

	my @nodes_table = $dom->findnodes('/root/tables/table');
	foreach my $node_table (@nodes_table) {
		my ($table,$data);
		
		$table = $node_table->getAttribute('name');
		push @tablenames,$table;

		$data = {
			title => $node_table->getAttribute('title') || ucfirst $table,
		};

		my $node_options=$node_table->findnodes('./options')->get_node(1);
		my $options={};
		if ($node_options) {
			foreach my $n_opt ($node_options->findnodes('./option')) {
				my $name  = $n_opt->getAttribute('name');
				my $value = $n_opt->getAttribute('value');
				$options->{$name}=$value;
			}
			$data->{cols_latex_format}||={};
			foreach my $n_x ($node_options->findnodes(qq{./latex_formatting/columns/column})) {
				my $col    = $n_x->getAttribute('name');

				my %f      = map {  $_ => $n_x->getAttribute($_) } qw(format perl);

				if (keys %f) {
					$data->{cols_latex_format}->{$col} = { %f };
				}
			}
		}
		$data->{options}=$options;

		my (@coldata,@colnames);
		for my $node_col ( $node_table->findnodes('./columns/column') ){
			my %col = map { $_ => $node_col->getAttribute($_) } qw(name type title);
			$col{type} ||= $coltype;
			$col{title} ||= ucfirst $col{name};
			push @coldata, {%col};

			push @colnames, $node_col->getAttribute('name');
		}

		$data->{coldata}  = [@coldata];
		$data->{colnames} = [@colnames];

		my @rows;
		foreach my $node_entry ( $node_table->findnodes('./entry') ) {
			my $row_h={};
			foreach my $col (@colnames) {
				for my $node_cell ( $node_entry->findnodes('./'.$col) ){
					$row_h->{$col} = $node_cell->textContent;
				}
			}
			my $row = @{$row_h}{@colnames};
			push @rows,$row_h;
		}
		$data->{rows_h}=[@rows];

		$tabledata{$table}=$data;
	}
	
	# save
	#
	$self;
}


sub dom_save_to_mysql {
	my $self = shift;
	my $ref  = shift;

	my $dom = $ref->{dom} || $self->{dom};

	my @nodes_table = $dom->findnodes('/root/tables/table');
	foreach my $node_table (@nodes_table) {
		my ($table,$data);
		
		$table = $node_table->getAttribute('name');
		push @tablenames,$table;

		$data = {
			title => $node_table->getAttribute('title') || ucfirst $table,
		};

		my (@coldata,@colnames);
		for my $node_col ( $node_table->findnodes('./columns/column') ){
			my %col = map { $_ => $node_col->getAttribute($_) } qw(name type title);
			$col{'type'} ||= $coltype;
			push @coldata, {%col};

			push @colnames, $node_col->getAttribute('name');
		}

		$data->{coldata}  = [@coldata];
		$data->{colnames} = [@colnames];

		my $dbh_mysql = $self->{dbh_mysql};
		if ($dbh_mysql) {
			$self->dbh_create_table({ 
				table   => $table,
				dbh     => $dbh_mysql,
				coldata => [@coldata],
				drop_if_exist => 1,
			});
		}

		my @rows;
		foreach my $node_entry ($node_table->findnodes('./entry')) {
			my $row_h={};
			foreach my $col (@colnames) {
				for my $node_cell ( $node_entry->findnodes('./'.$col) ){
					$row_h->{$col} = $node_cell->textContent;
				}
			}
			my $row = @{$row_h}{@colnames};
			push @rows,$row_h;
		}
		$data->{rows}=[@rows];

		if ($dbh_mysql) {
			foreach my $rh (@rows) {
				my @fields = keys %$rh;
				my @values = @{$rh}{@fields};

				$self->dbh_table_insert({
					dbh    => $dbh_mysql,
					table  => $table,
					fields => [@fields],
					values => [@values],
				});
			}
		}

		$tabledata{$table}=$data;
	}
	
	# save
	#
	$self;
}

sub init_db_mysql {
	my $self=shift;
	
	my ($dsn,$db,$user,$pwd,%attr);
	%attr=(
		RaiseError        => 1,
		PrintError        => 1,
		mysql_enable_utf8 => 1,
	);
	$user = 'root';
	$pwd  = '';
	$db   = 'cv_eng';
	
	$dsn="DBI:mysql:database=$db;host=localhost";
	my $dbh;

	eval { $dbh = $self->{dbh_mysql} = DBI->connect($dsn,$user,$pwd,\%attr)
		or do { $self->warn($DBI::errstr); };
	};
	if ($@) { $self->warn($DBI::errstr,$@); }

	$self;

}




sub dbh_csv_save_to_mysql {
	my $self = shift;
	my $ref  = shift;

	my $dbh_csv   = $self->{dbh_csv};
	my $dbh_mysql = $self->{dbh_mysql};

	unless ($dbh_csv) { $self->warn('NO CSV DBH!'); return $self; }
	unless ($dbh_mysql) { $self->warn('NO mysql DBH!'); return $self; }

	my @csv_tables = @{$self->{csv_tables} || []};
	my $dbh        = $dbh_csv;

	foreach my $table (@csv_tables) {
		my $cols=[];
		$self->dbh_cols({ table => $table, cols => $cols, dbh => $dbh });

		$self->log('Processing CSV table: ' . $table);

		my @coldata=map { { name => $_, type => $coltype } } @$cols; 
		my $exists;
		$self->dbh_table_exists({ 
			table   => $table,
			dbh     => $dbh_mysql,
			exists  => \$exists,
		});

		$self->log('creating mysql table:',$table);

		$self->dbh_create_table({ 
			table         => $table,
			dbh           => $dbh_mysql,
			coldata       => [@coldata],
			drop_if_exist => 1,
		});

		my @fields = ('*');
		my $f      = join(","   => @fields);
		my @e      = ();
		my $q      = qq{select $f from $table};
		my $sth;
		eval { $sth    = $dbh->prepare($q) or do { $self->warn($q,$dbh->errstr) }; };
		if($@){ $self->warn($@,$dbh->errstr,$q); }
		
		eval { $sth->execute(@e) or do { $self->warn($dbh->errstr,$q,Dumper([@e])); }; };
		if($@){ $self->warn($@,$dbh->errstr,$q,Dumper([@e])); }

		my $fetch='fetchrow_arrayref';
		
		{
			my $dbh=$dbh_mysql;
			while(my $row=$sth->$fetch){
				$self->dbh_table_insert({  
					dbh    => $dbh,
					table  => $table,
					fields => $cols,
					values => $row
				});
			}	
		}
		
	}

	$self;
}

sub dbh_table_coldata {
	my $self = shift;
	my $ref  = shift;

	my $dbh    = $ref->{dbh};
	my $table    = $ref->{table};

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

sub dbh_mysql_save_to_xml {
	my $self = shift;

	my $ref  = shift;

	my $has_dom;
	my $dom = $self->{dom};
   
	if($dom) {
		$has_dom=1;
	}else{	
		my $xml = qq{<?xml version="1.0" encoding="UTF-8"?>
<root>
	<tables>
	</tables>
</root>
		};
      	$dom = XML::LibXML->load_xml(string => $xml);
	}

	my $dbh = $ref->{dbh} || $self->{dbh_mysql};

	my $list_sql=[];
	$self->dbh_list_of_tables({ 
		list => $list_sql,
		dbh  => $dbh,
	});

	my %nodes_table=
		map { 
			my $name = $_->getAttribute('name');
	    	($name) ? ( "$name" => $_ ) : () ;
		}
	( $dom->findnodes('/root/tables/table') );

	my $has_tables;
	my $node_tables=$dom
		->findnodes('/root/tables')
		->get_node(1);

	if ($node_tables){ $has_tables=1; }else{
		$node_tables=XML::LibXML::Element->new('tables');
	}

	foreach my $table (@$list_sql) {
		my $coldata=[];

		my ($node_table,$node_columns);

		my ($has_columns,$has_table);
		if (exists $nodes_table{$table}) {
			$has_table=1;

			$node_table = $nodes_table{$table};

			$node_columns = $node_table
				->findnodes('./columns')
				->get_node(1);

			if ($node_columns) {
				$has_columns=1;
			}
		}else{
			# create table anew
			$node_table = XML::LibXML::Element->new('table');
      		$node_table->setAttribute( 'name' => $table );
		}

		$node_columns ||= XML::LibXML::Element->new('columns');

		# receive columns information from MySQL
		$self->dbh_table_coldata({ 
			table   => $table,
			dbh     => $dbh,
			coldata => $coldata,
		});

		# insert column information to XML
		my @colnames=();

		my (%colhas,@colhas_order);
			if ($has_columns) {
				my @coldata;
				for my $node_col ( $node_columns->findnodes('./column') ){
					my %xmlcol=map { $_ => $node_col->getAttribute($_) } qw(name type);
					$xmlcol{'type'} ||= $coltype;
					push @coldata, {%xmlcol};

					my $name=$xmlcol{name};
					$colhas{$name}=1;
					push @colhas_order,$name;
			}
			push @colnames,@colhas_order;
		}

		foreach my $col	( @$coldata ){
			my $el_col=XML::LibXML::Element->new('column');

			my $name = $col->{'name'};
			next if $colhas{$name};

			foreach my $x (qw(name type)) {
				my $val = $col->{$x} || '';
      			$el_col->setAttribute( $x, $val );
			}
			$node_columns->appendChild($el_col);
			$colhas{$name}=1;
			push @colnames,$name;
		}
		
		if (! $has_columns ){
			$node_table->appendChild($node_columns);
		}

		# ---------------
		# end column data handling
		# ---------------
		$self->dbh_table_fetch({
			dbh    => $dbh	,
			table  => $table,
			fields => [@colnames],
		});
		my $sth = $self->{sth};
		while (my $row = $sth->fetchrow_hashref) {
			my $el_entry=XML::LibXML::Element->new('entry');
			foreach my $col (@colnames) {
				my $el_cell = XML::LibXML::Element->new($col);
				my $value   = $row->{$col};

      			my $el_text = XML::LibXML::Text->new( $value );
				$el_cell->appendChild($el_text);
				$el_entry->appendChild($el_cell);
			}
			$node_table->appendChild($el_entry);
		}

		if (! $has_table ) {
			$node_tables->appendChild($node_table);
		}
	}# end loop over @$list_sql

	$self->dom_pretty;


	$self;
}

sub dom_save_to_file {
	my $self=shift;

	my $dom = $self->{dom};

	open my $out, '>', $xmlfile_save;
	binmode $out; # as above
	$dom->toFH($out);
	close($out);

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

sub table_texfile {
	my ($self,$table)=@_;

	my $dot = '.';
	my $texfile = join $dot => ($proj, 'tab_'.$table, 'tex');
	return $texfile;
}

sub dbh_mysql_print_to_latex {
	my $self = shift;

	my $ref  = shift;

	my $dbh = $self->{dbh_mysql}; 


	$self;
}

sub table_texfile_postprocess {
	my $self=shift;

	my $ref      = shift;

	my $file_tex = $ref->{file_tex};
	my $table    = $ref->{table};
	my $dom      = $ref->{dom} || $self->{dom};

	unless (-e $file_tex) {
		$self->warn('no file:',$file_tex);
		return;
	}

	my @lines;
	tie @lines, 'Tie::File', $file_tex
		or do { $self->warn($!,$file_tex); return; };

	my (@before,@after);

	push @before,
		'','%%file tab_'.$table,'',
		'% '. '-' x 50,
		map { '%'.$_} ( 'Generated by :',$Script,'on: ',"".gmtime."" ),
		'% '. '-' x 50,
		;

	push @before, split("\n", $self->table_tex_before({table=>$table}) || '' );
	push @before,'\ii{header_tab}','';

	unshift @lines,@before;

	push @after,'','\ii{footer_tab}','';
	push @lines,@after;

	$self;
}

sub trim
{
	my $self=shift;
	my $ref=shift;
	local $_=${$ref};
	s/^\s*//g; s/\s*$//g;
	${$ref}=$_;
}

sub tex_escape {
	my $self=shift;
	local $_=shift;
	TeX::Escape->new->escape($_);
}

sub data_r2c {
	my ($self,$ref) = @_;

	my $data    = $ref->{data};
	my @cols    = @{$ref->{cols}||[]};
		
	my $dbh = DBI->connect("dbi:SQLite:dbname=:memory:","","");

	my $table= $ref->{table} || 'tmp';
	$table.='_r2c';

	my $coldata_r2c=[ 
		{ name => 'key', type => $coltype }, 
		{ name => 'value' , type => $coltype },
	];
	my $cols_r2c=[qw(key value)];

	$self->dbh_create_table({ 
		dbh     => $dbh,
		table   => $table,
		coldata => $coldata_r2c,
		drop_if_exist => 1,
	});

	foreach my $row (@$data) {
		
		my $i=0;
		foreach my $col (@cols) {
			$self->dbh_table_insert({
				dbh    => $dbh,
				table  => $table,
				values => [ $col, $row->[$i] ],
				fields => $cols_r2c,
			});

			$i++;
		}
	}

	my $res = $self->dbh_table_selectall({ 
		dbh    => $dbh,
		table  => $table,
		fields => $cols_r2c,
	});

	($res,$coldata_r2c);
}

sub table_tex_before {
	my ($self,$ref) = @_;

	my $dom   = $self->{dom};
	my $table = $ref->{table};

	my $title = $dom
		->findnodes(qq{//tables/table[\@name="$table"]})
		->get_node(1)
		->getAttribute('title');
	$title ||= ucfirst $self->tex_escape( $table );

	my $node_tex_before = $dom
		->findnodes(qq{//tables/table[\@name="$table"]/tex/postprocess/before})
		->get_node(1)
		;
		
	my @a=();
	push @a,qq/\\hd{$table}{$title}/;
	
	if ($node_tex_before){
		local $_ = $node_tex_before->textContent;
		s/^\s*//g;
		s/\s*$//g;
		push @a,$_;
	}
	my $tex_before=join("\n",@a);
	return $tex_before;

}

sub init_cb {
	my $self=shift;

	%cb_latex_table = (
		'projects_open_source'	=> sub { 
		    my ($row, $col, $value, $is_header ) = @_;
			$self->trim(\$value);

		    if ($is_header ) { return '\textbf{' . $value . '}'; }

		    if ($col == 1){ 
		       $value = '\url{' . $value . '}';
		    }
		    elsif ($col == 0){ 
		       $value = '\cellcolor{gray}\textbf{' . $value . '}';
		    }
		    
		    return $value;
	    },
		'personal'	=> sub { 
		    my ($row, $col, $value, $is_header ) = @_;

		    if ($is_header ) { return '\textbf{' . $value . '}'; }
		    return $value;
		},
		'technologies'	=> sub { 
		    my ($row, $col, $value, $is_header ) = @_;

		    if ($is_header ) { return '\textbf{' . $value . '}'; }
		    return $value;
		},
		'education'	=> sub { 
		    my ($row, $col, $value, $is_header ) = @_;

		    if ($is_header ) { return '\textbf{' . $value . '}'; }
		    return $value;
		},	
	);

	$self;
}

sub node_get_opts {
	my ($self,$ref) = @_;

	my $node  = $ref->{node};
	my $xpath = $ref->{xpath};
	my $opts  = $ref->{opts} || {};

	my @attr  = @{$ref->{attr} || [qw(name value)]};

	eval { 
		$node
			->findnodes($xpath)
			->map( sub 
				{ 
					my $n=shift;
					return unless $n;
					my ($name,$value)  = map { $n->getAttribute($_) } @attr;

					if (defined $name) {
						if (defined $value) {
							$opts->{$name}=$value;
						}
					}
	
					my $r;
					my @childnodes=$n->findnodes('./child::*');
					if (@childnodes) {
						foreach my $cn (@childnodes) {
							my $name   = $cn->nodeName;
							my $value  = $cn->textContent;
							my ($n,$v) = map { $cn->getAttribute($_) } qw(name value);
							$self->trim(\$value);

							if (defined $n && $n) {
								if (defined $v) { $r->{$n}=$v; }
							}else{
								$r->{$name} = $value;
							}
						}
						$opts->{$name}=$r;
					}
				}); 
	};
	$opts;
}

sub node_textcontent_split {
	my ($self,$node,$ref) = @_;

	my $sep  = $ref->{sep} || ',';
	my $trim = ( defined $ref->{trim} ) ? $ref->{trim} : 1;

	my @content;
	unless ($node) {
		return ();
	}
	@content = map { if ($trim){ s/^\s*//g; s/\s*$//g; } $_ } split ($sep => $node->textContent || '' );

	return @content;
}

sub dom_pretty {
	my $self = shift;

	my $dom = $self->{dom};

	my @block = qw/table tables columns entry latex_table options/;
	my %cb = (
	    compact =>	sub {
			my $node = shift;
			my $name = $node->nodeName;
			return 0 if grep { /^$name$/ } @block;
			return 1;
		},
	);
    my $pp = XML::LibXML::PrettyPrint->new(
		indent_string => "  ",
        element => {
			inline   => [qw//],
			block    => [@block],
			compact  => [qw//,$cb{compact}],
			preserves_whitespace => [qw//],
        }
	);
    $pp->pretty_print($dom); # modified in-place

	$self;
}


sub dom_print_to_tex {
	my $self = shift;

	my $dom         = $self->{dom};
	my @nodes_table = $dom->findnodes('//tables/table');

	foreach my $n_table (@nodes_table) {
		my $table = $n_table->getAttribute('name');

		my $tb_data = $tabledata{$table} || {};
		my $tb_opts = {
			print_header => 1,
			r2c          => 0,
		};

		while(my($k,$v)=each %{ $tb_data->{options} || {} }){
			$tb_opts->{$k}=$v;
		}

		# LaTeX::Table
		my (@colnames);

		@colnames=map { $_->{'name'} } @{ $tb_data->{coldata} || [] };

		my $node_columns=$n_table
			->findnodes(qq{./columns})
			->get_node(1);

		my @forprint;
		my $n_forprint = $node_columns
			->findnodes('./forprint')
			->get_node(1);

		@forprint = $self->node_textcontent_split($n_forprint);
		@forprint = @colnames unless(@forprint);

		my $header=[[@forprint]];

		my $cb_cell = sub { 
			my $cell = shift;
			TeX::Escape->new->escape($cell);
		};

		my $data_h=$tb_data->{rows_h};
		foreach my $rh (@$data_h) {
			while(my($k,$v)=each %{$rh}){
				$rh->{$k} = $cb_cell->($v);
			}
		}
			
		my $lt_opts={};
		my @xpath=(
			"//tables/latex_table/opt",
			"//tables/table[\@name='$table']/latex_table/opt",
		);
		foreach my $xp (@xpath) {
			$self->node_get_opts({ 
				node  => $dom,
				xpath => $xp,
				opts  => $lt_opts,
			});
		}
		my $file_tex = $self->table_texfile($table);

		my $tb_format  = $tb_data->{cols_latex_format} || {};
		my $tb_coldata = $tb_data->{coldata};

		my $num=0;

		while( my($col,$f) = each %{$tb_format} ){

			my $cb_format = sub { 
				my ($cell,$rh) = @_;
				local $_=$f->{format};

				eval { 
					s/%CELL%/$cell/g;

					s/%CELL\{(\w+)\}%/$rh->{$1}/ge;
				};
				if ($@) { $self->warn($@); }

				$cell = $_;
				return $cell;
			};

			my $rownum=0;
			foreach my $rh (@$data_h) {
				my $cell     = $rh->{$col};
				$rh->{$col} = $cb_format->($cell,$rh);

				$rownum++;
			}
			
		}

		my $cb = sub {
		    my ($row, $col, $value, $is_header ) = @_;
			$self->trim(\$value);
			#if ( $is_header ) { return '\textbf{' . $value . '}'; }
			return $value;
		};

		my $rows_a=[];
		foreach my $rh (@$data_h) {
			push @$rows_a,[ map { $rh->{$_} } @forprint ];
		}

		my @cols = map { $_->{name} } @$tb_coldata;

		my $table_opts = $self->node_get_opts(
		{ 	node  => $n_table,
			xpath => q{./options/option},
		});
		my $r2c=$table_opts->{r2c};

		if ($r2c) {
			($rows_a,$tb_coldata) = $self->data_r2c({ 
				data    => $rows_a,
				cols    => [@forprint],
				table   => $table,
			});
			@cols   = map { $_->{name} } @$tb_coldata;
			$header = [[@cols]];
		}

		my $r2c_opts = $self->node_get_opts(
		{ 	node  => $n_table,
			xpath => q{./options/r2c/option},
		});

		my $ref = {   
			filename => $file_tex,
			data     => $rows_a,
			header   => $tb_opts->{print_header} ? $header : [],
			callback => $cb,
			%$lt_opts,
			# my options, start with my_
			my_cols  => [@cols],
			my_table => $table,
		};

		$self->lt_generate($ref);

	}

	$self;
}


sub lt_generate {
	my ($self,$ref) = @_;

	my $rows   = $ref->{data};
	my $header = $ref->{header};
	
	my $cols  = $ref->{my_cols} || [];
	my $table = $ref->{my_table} || '';
	my $delim = $ref->{my_delim} || '';

	my $pats = $ref->{my_pats} || {};
	use Data::Dumper qw(Dumper);
	
	if ($table eq 'projects_completed') {
		print Dumper($ref);
	}

	my ($delim_a);

	if (@$cols) {
		my ($start,$end) = (1,scalar @$cols);
	    $delim_a = [ qq/\\cmidrule(r){$start-$end}/ ];
		if ($delim) {
			local $_=$delim;
			eval { 
				s/%NCOLS%/scalar(@$cols)/ge; 
				s/$/\\\\/g;
			};
			$delim_a=[ $_ ];
		}
	}
	
	if ($ref->{my_add_delim}) {
		my $nrows=[];
		foreach my $row (@$rows) {
			push @$nrows,$delim_a,$row;
		}
		$ref->{data}=$nrows;
	}

	if (my $pat = $pats->{splittables}) {
		# body...
	}


	my $lt = LaTeX::Table->new($ref);
	$lt->generate();

	$self;
}

sub tex_postprocess {
	my $self=shift;

	my @tn=@{$self->{tablenames_dom} || []};
	unless (@tn) { $self->warn('No tablenames!');return; }

	foreach my $table (@tn) {
		my $file_tex = $self->table_texfile($table);

		$self->table_texfile_postprocess({ 
			file_tex => $file_tex,
			table    => $table,
		});
	}
}

sub dbh_create_table {
	my $self = shift;

	my $ref  = shift;

	my $table   = $ref->{table};
	my $dbh     = $ref->{dbh};
	my $coldata = $ref->{coldata};

	if ($ref->{skip_if_exist}) {
		return $self;
	}

	my @q= ( 
		($ref->{drop_if_exist}) ? qq/ drop table if exists `$table`; / : (),
		qq/ create table `$table` ( / ,
	); 
	my @q_cols;
	foreach my $column (@$coldata) {
		my ($var,$type) = @{$column}{qw(name type)};
		push @q_cols, qq{ `$var` $type }, 
	}
	push @q, join(",\n" => @q_cols)."\n" , qq/ ); /;
	my $q = join("\n",@q);
	
	my $spl = SQL::SplitStatement->new;
	my @sql = $spl->split($q);
	foreach my $query (@sql) {
		eval { $dbh->do($query) or $self->warn($dbh->errstr,'>>>>query: ' . $query); };
		if ($@) { $self->warn($@,$dbh->errstr,'>>>>query: ' . $query);  }
	}
	$self;
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
	eval { $res    = $dbh->selectall_arrayref($q,@e); };
	if($@){ $self->warn($@,$dbh->errstr,$q); }

	$res;
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
	eval { $sth    = $dbh->prepare($q) or do { $self->warn($q,$dbh->errstr) }; };
	if($@){ $self->warn($@,$dbh->errstr,$q); }
	
	eval { $sth->execute(@e) or do { $self->warn($dbh->errstr,$q,Dumper([@e])); }; };
	if($@){ $self->warn($@,$dbh->errstr,$q,Dumper([@e])); }

	@$cols = @{$sth->{NAME_lc}||[]};
	
	$self;
}

sub dbh_csv_connect {
	my $self = shift;
	my $ref  = shift;

	my $proj    = $ref->{proj} || $self->{proj};
	my $csv_dir = $self->{csv_dir} || catfile($root,'csv',$proj);

	my $dbh = $self->{dbh_csv} = DBI->connect("dbi:CSV:", undef, undef, {
		f_schema         => undef,
		f_dir            => "$csv_dir",
		f_dir_search     => [],
		f_ext            => ".csv",
		f_lock           => 2,
		f_encoding       => "utf8",
		csv_eol          => "\n",
		csv_sep_char     => ",",
		csv_quote_char   => '"',
		csv_escape_char  => '"',
		csv_class        => "Text::CSV_XS",
		csv_null         => 0,
		csv_allow_whitespace => 1,
		#RaiseError       => 1,
		PrintError       => 1,
	}) or $self->warn($DBI::errstr,$csv_dir);

	$self;
}

sub find_csv {
	my $self = shift;
	my $ref  = shift;

	my $proj    = $ref->{proj} || $self->{proj};
	my $csv_dir = $self->{csv_dir} || catfile($root,'csv',$proj);

	my @files;
	my @exts=qw(csv);
	my @dirs;
	push @dirs,$csv_dir;
	
	my @csv_tables;
	find({ 
		wanted => sub { 
		foreach my $ext (@exts) {
			if (/\.$ext$/) {
				my $table;
				push @files,$File::Find::name;

				$table=$_;
				$table =~ s/\.$ext//g;
				push @csv_tables,$table;
			}
		}
		} 
	},@dirs
	);

	foreach my $table (@csv_tables) {
		#my $fields = $fields_per_table->{$table};
   #     my $map    = $header_map->{$table};
		#my $fields;
	
		   #my @h = map { defined($map->{$_}) ? $map->{$_} : ucfirst } @$fields;
		#$headers->{$table} = [@h];
	}

	$self->{csv_files}=[@files];
	$self->{csv_tables}=[@csv_tables];

	$self;

}


sub run {
	my $self=shift;

	$self
	#->dom_pretty
	#->dom_save_to_file
		->dom_print_to_tex
		->tex_postprocess
		;

	$self;
}

1;

