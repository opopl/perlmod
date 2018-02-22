
package Vim::Dbi;

=head1 NAME

Vim::Dbi

=cut

use strict;
use warnings;

use utf8;
use open qw(:std :utf8);

use Encode;

use Vim::Perl qw( :vars :funcs );

use Data::Dumper qw(Dumper);
use DBI;

our $LastResult;
our ($dbh,$sth);

=head1 METHODS

=cut

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

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}
}

=head2 connect

=head3 Usage

	$vimdbi->connect();

	my $ref={
		dsn 	=> $dsn,
		user 	=> $user, 
		pwd 	=> $pwd, 
		attr 	=> {},
	};
	$vimdbi->connect($ref);

=cut

sub connect {
	my $self = shift;

	my $ref  = shift || {};

	my $silent_save=$Vim::Perl::SILENT;
	$Vim::Perl::SILENT=VimVar('silent');

	my $atend = sub{ 
		my $ref=shift; 
		my $m=$ref->{m} || []; 
		
		VimMsg($_) for(@$m);
		$Vim::Perl::SILENT=$silent_save; 
	};

	my (@fref,@fconn,@vconn);

	@fref=qw(dsn db user pwd attr);
	@fconn=qw(dsn user pwd attr);

	for(@fref){ $ref->{$_}=$self->{$_} unless defined $ref->{$_}; }
	@vconn=@{$ref}{@fconn};

	#VimMsg(Dumper($ref));

	my $silent_save;

	eval { $dbh = DBI->connect(@vconn); };
	if($@){
		my $m;
		push @$m, 'Errors while calling DBI->connect(...): ',$@;
		$atend->({ m => $m});
		return;
	}
	defined $dbh or do { 
		my $m;
		push @$m,'dbh undefined, $DBI::errstr=',$DBI::errstr; 
		$atend->({ m => $m});
		return; 
	};

	VimMsg('Connected to database ' . $ref->{db});
	$dbh->do('set names utf8');
		
	$atend->();

	$self;

}

sub disconnect {
	my $self=shift;

	VimMsg('Disconnecting...');
	eval {$dbh->disconnect(); };
	if ($@) {
		VimMsg(['Errors while calling $dbh->disconnect():', $@]);
	}

	$self;
}

=head2 list_from_query_index

=head3 Usage

	my $ref={
		'listvar' => 'list',
		'query'   => 'select * from table',
		'index'   => 0,
	};

	$vimdbi->list_from_query_index($ref);

=cut

sub list_from_query_index {
	my $self=shift;

	my $ref=shift || {};

	my ($index,$query,$listvar)=@{$ref}{qw(index query listvar)};
	my $list;
	my $res;
	
	eval { $res = $dbh->selectall_arrayref($query); };
	if ($@) { VimMsg($@); }
	unless(defined $res){ VimMsg($dbh->errstr); return; }

	@$list  = map { (defined $_->[$index]) ? encode('utf8',$_->[$index]) : () } @$res;
	VimListExtend('list',$list);

}


1;
 

