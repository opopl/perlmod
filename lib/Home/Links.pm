package Home::Links;

use strict;
use warnings;

use utf8;
use open qw(:std :utf8);

use Encode;
use Encode::Locale;

use DBI;
use File::Fetch;

use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath rmtree);
use File::Copy qw(copy move);
use File::Basename qw(dirname basename);
use File::Slurp qw(read_file write_file);
use FindBin qw($Script $Bin);
use File::Fetch;

if (-t) 
{
	binmode(STDIN, ":encoding(console_in)");
	binmode(STDOUT, ":encoding(console_out)");
	binmode(STDERR, ":encoding(console_out)");
}

sub fetch_links {
	my $db   = 'library';
	my $tb   = 'links';
	my $dsn  = "DBI:mysql:database=$db;host=localhost";
	my $user = 'root';
	my $pwd  = '';
	
	my %attr=(
		RaiseError        => 1,
		PrintError        => 1,
	    mysql_enable_utf8 => 1,
	);
	
	my $storage = catfile($ENV{appdata},qw(perlmod Home_Links storage ));
	mkpath $storage unless -d $storage;
	
	my $dbh = DBI->connect($dsn,$user,$pwd,\%attr) 
		or die $DBI::errstr;
	
	my $lc = ( $^O eq 'MSWin32' )  ? 'local_win' : 'local_unix';
	my $query = qq{
		select remote,$lc from links
	};
	my $sth = $dbh->prepare($query)
		or die $DBI::errstr;
	
	my @e=();
	$sth->execute(@e)
		or die $DBI::errstr;
	
	my $fetch='fetchrow_hashref';
	
	
	while(my $row=$sth->$fetch()){
		my $url   = $row->{remote} || '';
		my $local = $row->{$lc} || '';
	
		next unless $url;
		next unless $local;
	
		if (-e $local) { next; }
	
		my $ff    = File::Fetch->new(uri => $url);
		print 'Fetching link:' . "\n";
		print '		  ' . $url . "\n";
	    my $wh = $ff->fetch( to => $storage )
			or warn $ff->error;
	
		if (-e $wh) {
			copy($wh,$local);
		}
	}

}

1;

