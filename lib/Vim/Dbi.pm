
package Vim::Dbi;

=head1 NAME

Vim::Dbi

=cut

use strict;
use warnings;

use utf8;
use open qw(:std :utf8);

if (-t) 
{
	binmode(STDIN, ":encoding(console_in)");
	binmode(STDOUT, ":encoding(console_out)");
	binmode(STDERR, ":encoding(console_out)");
}

use Encode;

use Vim::Perl qw( 
	VimListExtend 
	VimMsg
	VimVar
	$SILENT
);

use DBI;
use Data::Dumper qw(Dumper);

our $withvim;

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
	$self;
}

=head2 withvim 

=over

=item Usage

=back

=cut

sub withvim {
	my $self=shift;

	eval 'VIM::Eval("1")';
	
	my $uv = ($@) ? 0 : 1;
	return $uv;
}

sub log {
	my $self=shift;

	my $text=shift;
    return $self unless $text;

    my @o   = @_;
    my $ref = shift @o;

	if ($withvim) { VimMsg($text,$ref);return;}

    if ( ref $text eq "ARRAY" ) {
		foreach my $msg (@$text) {
			$self->log($msg,$ref);
		}
		return $self;
	}

	print $text . "\n";
	return $self;

}

sub isvim {
	my $self=shift;
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

	my $silent_save=$SILENT;

	$withvim && do { $SILENT=VimVar('silent'); };

	my $atend = sub { 
		my $ref = shift;
		my $m   = $ref->{m} || [];
		
		$self->log($_) for(@$m);

		$SILENT=$silent_save; 
	};

	my (@fref,@fconn,@vconn);

	@fref  = qw(dsn db user pwd attr);
	@fconn = qw(dsn user pwd attr);

	for(@fref){ $ref->{$_}=$self->{$_} unless defined $ref->{$_}; }
	@vconn=@{$ref}{@fconn};

	#$self->log(Dumper($ref));

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

	$self->log('Connected to database ' . $ref->{db});
	$dbh->do('set names utf8');
		
	$atend->();

	$self;

}

sub disconnect {
	my $self=shift;

	$self->log('Disconnecting...');
	eval {$dbh->disconnect(); };
	if ($@) {
		$self->log(['Errors while calling $dbh->disconnect():', $@]);
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
	if ($@) { $self->log($@); }
	unless(defined $res){ $self->log($dbh->errstr); return; }

	@$list  = map { (defined $_->[$index]) ? encode('utf8',$_->[$index]) : () } @$res;

	if ($withvim) {
		VimListExtend('list',$list);
	}

	$self;

}

BEGIN {
	$withvim=__PACKAGE__->withvim;
}


1;
 

