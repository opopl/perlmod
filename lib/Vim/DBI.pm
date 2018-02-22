
package Vim::Dbi;

use strict;
use warnings;

use Vim::Perl qw( :vars :funcs );
use DBI;

our $LastResult;
our ($dbh,$sth);

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
	my $self=shift;

	my $ref=shift || {};

	my $silent_save=$Vim::Perl::SILENT;
	$Vim::Perl::SILENT=VimVar('silent');

	my $atend = sub{ $Vim::Perl::SILENT=$silent_save; };

	my (@f,@v);

	@f=qw(dsn db user pwd attr);

	for(@f){ $ref->{$_}=$self->{$_} unless defined $ref->{$_}; }
	@v=@{$ref}{@f};

	my $silent_save;

	eval { $dbh = DBI->connect(@v); };
	if($@){
		VimMsg([$@]);
		$atend->();
		return;
	}
	defined $dbh or do { 
		VimMsg(['dbh undefined',$DBI::errstr]); 
		$atend->();
		return; 
	};

	VimMsg('Connected to database ' . $ref->{db});
	$dbh->do('set names utf8');
		
	$atend->();

	$self;

}



1;
 

