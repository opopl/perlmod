package Base::CSV_DBI;

use strict;
use warnings;

use LaTeX::Table;
use LaTeX::Encode;
use DBI;

use Data::Dumper;
use File::stat;

use File::Find qw(find);
use File::Path qw(mkpath);
use File::Spec::Functions qw(catfile);

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={
		sub_log  => sub { print $_ . "\n" for(@_); },
		sub_warn => sub { warn $_ . "\n" for(@_); },
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }
}

=head2  

=head3 Usage

	use Base::CSV_DBI;
	use FindBin qw($Bin $Script);

	my $dir   = $Bin;
	my $bcsv  = Base::CSV_DBI->new( csv_dir => $dir);

	$bcsv->select_to_latex_table({
		table   => $table,
		csv_dir => $dir,
	});

=head3 Purpose

=cut

sub select_to_latex_table  {
	my $self = shift;
	my $ref  = shift;
	
	my $dir     = $ref->{csv_dir} || $self->{csv_dir} || '';
	my $fields  = $ref->{fields} || '*';
	my $table   = $ref->{table} || '';
	my $warn    = sub { $self->warn(@_) };

	# LaTeX::Table options
	my $opts         = $ref->{options_latex_table} || {};
		
	my $caption      = $opts->{caption} ||'';
	my $caption_main = $opts->{caption_main} ||$caption||'';
	my $label        = $opts->{label} ||'';
	my $file_tex     = $opts->{file_tex} ||'';

	my $cb_latex_table = $opts->{cb} || undef; 
	#########################
	my $out_tex_dir  = $ref->{out_tex_dir} ||'';
	#########################
	my $cb_texfile  = $ref->{cb_texfile} || 
		sub { 
			my ($table)=@_; 
			return 'tab_'.$table.'.tex';
		};


	my $output = $ref->{output} || undef;

	my @tables;
	
	my @exts=qw(csv);
	my @dirs;
	push @dirs,$dir;
	
	find({ 
		wanted => sub { 
			foreach my $ext (@exts) {
				if (/(\w+)\.$ext$/) {
					push @tables,$1;
				}
			}
		} 
	},@dirs
	);

	# loop over all existing tables in the given csv directory
	unless ($table) {
		foreach my $table (@tables) {
			$self->select_to_latex_table({ 
				%$ref,
				output              => $output,
				table               => $table,
				options_latex_table => $opts,
			});
		}
		return $self;
	}
	
	$self->log('Connecting via DBI to CSV directory:',$dir);
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

	if (($out_tex_dir) && (!$file_tex)) {
		unless (-d $out_tex_dir) {
			mkpath $out_tex_dir;
		}
		my $bname = $cb_texfile->($table) || 'tab_'.$table . '.tex';
		$file_tex = catfile($out_tex_dir,$bname);
	}

	my $lt = LaTeX::Table->new(
		{   
			filename    => $file_tex,
			maincaption => $caption_main,
			caption     => $caption,
			label       => $label,
			position    => 'tbp',
			header      => $header,
			data        => $data,
		}
	);

	if ($cb_latex_table) {
		$lt->set_callback($cb_latex_table);
	}

	if ($file_tex) {
		my ($mtime_before,$mtime);
		my $fmode='';
		if (! -e $file_tex){ 
			$fmode='anew'; 
		}else{
			$fmode='rewrite'; 
			my $st           = stat($file_tex);
			$mtime_before = $st->mtime;
		}
		$lt->generate();

		if ( -e $file_tex){ 
			if ( $fmode eq 'anew') {
				$self->log('Have written latex file:',$file_tex);
			} elsif ( $fmode eq 'rewrite' ) {
				my $st           = stat($file_tex);
				if ($st->mtime > $mtime_before ) {
					$self->log('Have re-written latex file:',$file_tex);
				}
			}
		}

	}

	my $tex = $lt->generate_string();
	my @tex = split("\n",$tex);

	$self->{tex_lines}=[@tex];

	if ($output) {
		$output->{$table}=[@tex];
	}

	$self;

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
 

