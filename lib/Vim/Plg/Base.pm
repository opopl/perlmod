
package Vim::Plg::Base;

use strict;
use warnings;

use Vim::Perl qw();
use File::Spec::Functions qw(catfile);
use File::Find qw(find);
use File::Dat::Utils qw(readarr);

use base qw( Class::Accessor::Complex );
use DBD::SQLite;
use DBI;

our $dbh;
our $dbfile;


sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;


	my $dirs = {
		plgroot => catfile($ENV{VIMRUNTIME},qw(plg base)),
	};

	my @types=qw(list dict listlines );
	$self->dattypes(@types);
	foreach my $type (@types) {
		$dirs->{'dat_'.$type} =catfile($dirs->{plgroot},qw(data),$type);
	}

	my $h={
		dirs => $dirs,
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self->db_init;
	$self->init_dat;
}

sub dat_add {
		my $self=shift;
		my $ref=shift;

		my $file = $ref->{datfile};
		my $key  = $ref->{key};
		my $type = $ref->{type};

		$self->datfiles($key => $file );

		$self->db_insert_datfiles($ref);
}

sub dat_locate {
	my $self = shift;
	my $ref  = shift;

	my @dirs   = grep { (-d $_) } @{$ref->{dirs} || []};
	return unless @dirs;

	my $prefix = $ref->{prefix} || '';
	my $type   = $ref->{type} || '';

	find({ 
		wanted => sub { 
			my $name=$File::Find::name;
			my $dir=$File::Find::dir;
			my $pat=qr/\.i\.dat$/;

			/$pat/ && do {
					s/$pat//g;
					my $k=$prefix . $_;
					$self->dat_add({ 
							key     => $k,
							type    => $type,
							datfile => $name,
					});
			};
			 
		} 
	},@dirs
	);
}

sub db_init {
	my $self=shift;

	$dbfile=":memory:";
	$dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");

	my @s=();
	
	push @s, 
				qq{
					create table plugins (
						plugin varchar(100)
					);
				},
				qq{
					create table datfiles (
						key varchar(100),
						type varchar(100),
						datfile varchar(100)
					);
				},
				;

	foreach my $s (@s) {
		$dbh->do($s);
	}

}

sub db_insert_plugins {
	my $self=shift;
	my @p=@_;

	my $sth = $dbh->prepare("insert into plugins(plugin) values(?)");
	$sth->execute($_) for(@p);
}

sub db_insert_datfiles {
	my $self=shift;
	my $ref=shift || {};

	my $sth = $dbh->prepare("insert into datfiles(key,type,datfile) values(?,?,?)");
	$sth->execute(@{$ref}{qw(key type datfile)});

}

sub db_select_datfiles {
	my $self=shift;
}

sub init_dat {
	my $self=shift;

	my @types=$self->dattypes;

	foreach my $type (@types) {
		my $dir = $self->{dirs}->{'dat_'.$type};
		next unless -d $dir;

		$self->dat_locate({dirs => [$dir],type => $type});
	}

	my $dat_plg = $self->datfiles('plugins');
	my @plugins = readarr($dat_plg);

	$self->plugins([@plugins]);
	$self->db_insert_plugins(@plugins);

	foreach my $p (@plugins) {
		foreach my $type (@types) {
			my $pdir = catfile($ENV{VIMRUNTIME},qw(plg),$p,qw(data),$type);
			$self->dat_locate({ 
				dirs   => [$pdir],
				type   => $type,
				prefix => $p . '_'
			});
		}
	}

}

BEGIN {
	###__ACCESSORS_SCALAR
	our @scalar_accessors=qw(
		dattypes
		plugins
	);
	
	###__ACCESSORS_HASH
	our @hash_accessors=qw(
		datfiles
		vars
	);
	
	###__ACCESSORS_ARRAY
	our @array_accessors=qw();

	__PACKAGE__
		->mk_scalar_accessors(@scalar_accessors)
		->mk_array_accessors(@array_accessors)
		->mk_hash_accessors(@hash_accessors)
		->mk_new;


	use Data::Dumper qw(Dumper);
	my $p = __PACKAGE__->new;
	#print Dumper({%{ $p->datfiles } }) . "\n";

	my $a ;
	
	$a = $dbh->selectall_hashref('select * from datfiles','key');
	#$a = $dbh->selectall_arrayref('select * from datfiles');
	print Dumper($a) . "\n";
}

1;
 

