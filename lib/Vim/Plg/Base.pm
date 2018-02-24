
package Vim::Plg::Base;

=head1 NAME

Vim::Plg::Base

=cut

use strict;
use warnings;

use Vim::Perl qw();
use File::Spec::Functions qw(catfile);
use File::Find qw(find);
use File::Dat::Utils qw(readarr);
use DBD::SQLite;
use DBI;

use base qw( Class::Accessor::Complex );
use File::Path qw(make_path remove_tree mkpath rmtree);


our $dbh;
our $dbfile;

our $dbname = 'main';

=head1 SYNOPSIS

	my $plgbase=Vim::Plg::Base->new;

=head1 METHODS

=cut


sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

=head2 init 

=over

=item Usage

=back

=cut

sub init {
	my $self=shift;

	my $dirs = {
		plgroot => catfile($ENV{VIMRUNTIME},qw(plg base)),
		appdata => catfile($ENV{APPDATA},qw(vim plg base)),
	};

	my @types=qw(list dict listlines );
	foreach my $type (@types) {
		$dirs->{'dat_'.$type} = catfile($dirs->{plgroot},qw(data),$type);
	}

	my $dbname='main';
	my $dbfile=catfile($dirs->{appdata},$dbname.'.db');

	my $h={
		dbname       => $dbname,
		dbfile       => $dbfile,
		dattypes     => [@types],
		dirs         => $dirs,
		dbopts       => {
			tb_reset => {},
			tb_order => [qw(plugins datfiles)],
		},
		sqlstm => {
			create_table_plugins => qq{
				create table if not exists plugins (
					id int,
					plugin varchar(100)
				);
			},
			create_table_datfiles => qq{
				create table if not exists datfiles (
					id int,
					plugin varchar(100),
					key varchar(100),
					type varchar(100),
					datfile varchar(100)
				);
			},
		},
	};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self->db_init;
	$self->init_dat;

}

sub update {
	my $self=shift;
	my %o=@_;

	foreach my $k (keys %o) {
		$self->{$k}=$o{$k};
	}
	$self;
}

sub reload_from_fs {
	my $self=shift;

	my %o=(
		dbopts       => {
			tb_reset => {plugins => 1, datfiles => 1},
			tb_order => [qw(plugins datfiles)],
		},
	);
	$self->update(%o)->init_dat;

	$self;
}

sub dat_add {
	my $self=shift;

	my $ref=shift;

	my $datfile = $ref->{datfile};
	my $key     = $ref->{key};

	$self->datfiles($key => $datfile );

	$self->db_insert_datfiles($ref);
}

sub dat_locate {
	my $self = shift;
	my $ref  = shift;

	my @dirs   = grep { (-d $_) } @{$ref->{dirs} || []};
	return unless @dirs;

	my $prefix = $ref->{prefix} || '';
	my $type   = $ref->{type} || '';
	my $plugin = $ref->{plugin} || 'base';

	find({ 
		wanted => sub { 
			my $name = $File::Find::name;
			my $dir  = $File::Find::dir;
			my $pat  = qr/\.i\.dat$/;

			/$pat/ && do {
					s/$pat//g;
					my $k=$prefix . $_;
					$self->dat_add({ 
							key     => $k,
							type    => $type,
							plugin  => $plugin,
							datfile => $name,
					});
			};
			 
		} 
	},@dirs
	);
}

sub db_list_plugins {
	my $self=shift;

	my $dbh = $self->dbh;
	my $r   = $dbh->selectall_arrayref('select plugin from plugins');
	my @p   = map { $_->[0] } @$r;


	wantarray ? @p : \@p ;
}

sub get_plugins_from_db {
	my $self=shift;

	return if $self->done('get_plugins_from_db');

	my @p=$self->db_list_plugins;

	$self->plugins([@p]);

	$self->done('get_plugins_from_db' => 1);
}

sub get_datfiles_from_db {
	my $self=shift;

	return if $self->done('get_datfiles_from_db');

	my $dbh    = $self->dbh;
	my @fields = qw(key plugin datfile);
	my $f      = join(",",map { '`'.$_.'`'} @fields);
	my $q      = qq{select $f from datfiles};
	my $sth    = $dbh->prepare($q);
	$sth->execute();

	while (my $row=$sth->fetchrow_hashref()) {
		my ($key,$plugin,$datfile)=@{$row}{@fields};
		$key=join('_',$plugin,$key);

		$self->datfiles($key => $datfile);
	}

	$self->done('get_datfiles_from_db' => 1);
}

sub db_tables {
	my $self=shift;

	my $dbname = $self->dbname;
	my $dbh    = $self->dbh;

	my $pat    = qr/"$dbname"\."(\w+)"/;
    my @tables = map { /$pat/ ? $1 : () } $dbh->tables;

	wantarray ? @tables : \@tables ;
}

sub db_table_exists {
	my $self=shift;

	my $tb=shift;

	my %tables = map { (defined $_) ? ($_ => 1 ) : () } $self->db_tables;
	$tables{$tb} ? 1 : 0;


}

=head2 db_init 

=over

=item Usage

	$plgbase->db_init();

=back

=cut

sub db_init {
	my $self=shift;

	my $ref    = shift;

	$dbfile=":memory:";
	my $d=$self->dirs('appdata');
	mkpath $d unless -d $d;
	$dbfile=catfile($d,'main.db');

	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
	$self->dbh($dbh);

	$self->db_drop_tables
		->db_create_tables;

}

sub db_drop_tables {
	my $self=shift;

	my $dbopts = $self->dbopts;
	my @s;

	my $tb_reset=$dbopts->{tb_reset} || {};
	my $tb_order=$dbopts->{tb_order} || [];

	my $dbh=$self->dbh;

	foreach my $tb (@$tb_order) {
		if ($tb_reset->{$tb}) {
			push @s, qq{ drop table if exists $tb; };
		}
	}

	$dbh->do($_) for(@s);

	$self;
}

sub db_create_tables {
	my $self=shift;

	my $dbopts = $self->dbopts;
	my @s;

	my $tb_reset=$dbopts->{tb_reset} || {};
	my $tb_order=$dbopts->{tb_order} || [];

	my $dbh=$self->dbh;

	foreach my $tb (@$tb_order) {
		push @s,$self->sqlstm('create_table_'.$tb);
		
		if (! $self->db_table_exists($tb)) {
			$tb_reset->{$tb}=1;
		}
	}

	$dbh->do($_) for(@s);

	$self;
}

sub db_insert_plugins {
	my $self=shift;
	my @p=@_;

	my $dbh = $self->dbh;

	my $sth = $dbh->prepare("insert into plugins(plugin) values(?)");
	$sth->execute($_) for(@p);
}

sub db_insert_datfiles {
	my $self = shift;
	my $ref  = shift || {};

	my $dbh=$self->dbh;

	my $sth = $dbh->prepare("insert into datfiles(key,type,plugin,datfile) values(?,?,?,?)");
	$sth->execute(@{$ref}{qw(key type plugin datfile)});

}



sub init_dat_base {
	my $self=shift;

	my @types    = $self->dattypes;
	my $dbopts   = $self->dbopts_ref;

	my $tb_reset=$dbopts->{tb_reset} || {};

	if ($tb_reset->{datfiles}) {
		# find all *.i.dat files in base plugin directory
		foreach my $type (@types) {
			my $dir = $self->{dirs}->{'dat_'.$type};
			next unless -d $dir;
	
			$self->dat_locate({dirs => [$dir],type => $type});
		}
	}else{
		$self->get_datfiles_from_db;
	}
	$self;
}

sub init_dat_plugins {
	my $self=shift;

	my @plugins = $self->plugins;
	my @types   = $self->dattypes;

	my $dbopts   = $self->dbopts_ref;
	my $tb_reset = $dbopts->{tb_reset} || {};

	if ($tb_reset->{datfiles}) {
		# find all *.i.dat files for the rest of plugins, except  base plugin
		foreach my $p (@plugins) {
			next if $p eq 'base';

			foreach my $type (@types) {
				my $pdir = catfile($ENV{VIMRUNTIME},qw(plg),$p,qw(data),$type);
				$self->dat_locate({ 
					dirs   => [$pdir],
					type   => $type,
					plugin => $p,
					prefix => $p . '_'
				});
			}
		}
	}else{
		$self->get_datfiles_from_db;
	}

}

sub warn {
	my $self=shift;
	my @m=@_;

	warn $_ for (@m);
}

sub init_plugins {
	my $self=shift;

	my @types    = $self->dattypes;
	my $dbopts   = $self->dbopts_ref;

	my $tb_reset=$dbopts->{tb_reset} || {};
	my $tb_order=$dbopts->{tb_order} || [];

	if ($tb_reset->{plugins}) {

		my $dat_plg = $self->datfiles('plugins');
		unless ($dat_plg) {
			$self->warn('plugins DAT file NOT defined!!');
		}
		if (-e $dat_plg) {
			my @plugins = readarr($dat_plg);
		
			$self->plugins([@plugins]);
			$self->db_insert_plugins(@plugins);
		}
	}else{
		# 	fill plugins array
		$self->get_plugins_from_db;
	}

	$self;


}

sub init_dat {
	my $self = shift;
	my $ref  = shift || {};

	my @types    = $self->dattypes;
	my $dbopts   = $self->dbopts_ref;

	my $tb_reset=$dbopts->{tb_reset} || {};
	my $tb_order=$dbopts->{tb_order} || [];

	$self->init_dat_base
		->init_plugins
		->init_dat_plugins;

		#use Data::Dumper qw(Dumper);
		
		#print Dumper([$self->db_list_plugins]);
		#exit 0;
	
	$self;


}

BEGIN {
	###__ACCESSORS_SCALAR
	our @scalar_accessors=qw(
		dbh
		dbfile
		dbname
	);
	
	###__ACCESSORS_HASH
	our @hash_accessors=qw(
		dirs
		datfiles
		vars
		dbopts
		done
		sqlstm
	);
	
	###__ACCESSORS_ARRAY
	our @array_accessors=qw(
		dattypes
		plugins
	);

	__PACKAGE__
		->mk_scalar_accessors(@scalar_accessors)
		->mk_array_accessors(@array_accessors)
		->mk_hash_accessors(@hash_accessors)
		->mk_new;


	use Data::Dumper qw(Dumper);

	my %o=();
    my $p = __PACKAGE__->new(%o);
	#$p->reload_from_fs;
	#print Dumper([$p->plugins]) . "\n";
	#print Dumper([$p->db_list_plugins]) . "\n";
	#print Dumper($p->datfiles_ref) . "\n";

	##print Dumper({%{ $p->datfiles } }) . "\n";
}



1;
 

