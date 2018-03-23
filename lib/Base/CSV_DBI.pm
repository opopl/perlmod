package Base::CSV_DBI;

use strict;
use warnings;

use LaTeX::Table;
use LaTeX::Encode;
use DBI;
use Data::Dumper;

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
}

=head2  

=head3 Usage

	use Base::CSV_DBI;
	use FindBin qw($Bin $Script);

	my $dir   = $Bin;
	my $b_csv = Base::CSV_DBI->new( csv_dir => $dir);

=head3 Purpose

=cut

sub select_to_latex_table  {
	my $self = shift;
	my $ref  = shift;
	
	my $dir    = $ref->{dir} || $self->{csv_dir} || '';
	my $fields = $ref->{fields} || '*';
	my $table  = $ref->{table} || '';
	my $warn   = sub { $self->warn(@_) };
	
	my $dbh = DBI->connect("dbi:CSV:", undef, undef, {
		f_schema         => undef,
		f_dir            => "$dir",
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
		#RaiseError       => 1,
		PrintError       => 1,
	}) or $warn->($DBI::errstr);
	
	my $sth;
	my $q = qq{ select $fields from $table };
	my @e = ();
	
	eval { $sth = $dbh->prepare($q) or $warn->($dbh->errstr); };
	if ($@) { $warn->($q,$@,$dbh->errstr); }
	
	eval {$sth->execute(@e) or $warn->($dbh->errstr);};
	if ($@) { $warn->($q,$@,$dbh->errstr,Dumper(\@e)); }
	
	my $header = [];
	my $data   = [];
	
	my $cb_row = sub { 
		my $cell = shift;
		latex_encode($cell);
	};
	while (my $row = $sth->fetchrow_arrayref) {
			my $r;
			@$r = map { defined($_) ? $cb_row->($_) : '' } @$row;
			push @$data,$r;
	}
	
	my $table = LaTeX::Table->new(
		{   
			filename    => 'prices.tex',
			maincaption => 'Price List',
			caption     => 'Try our special offer today!',
			label       => 'table:prices',
			position    => 'tbp',
			header      => $header,
			data        => $data,
		}
	);

	my $tex = $table->generate_string();
	my @tex = split("\n",$tex);

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

1;
 

