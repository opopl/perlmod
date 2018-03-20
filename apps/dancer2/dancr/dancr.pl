#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use DBI;
use FindBin qw($Bin $Script);

use Dancer2;

sub connect_db {
	my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
		die $DBI::errstr;
	
	return $dbh;
}

sub init_db {
	my $db     = connect_db();
	my $schema = read_text("$Bin/schema.sql");

	$db->do($schema) or die $db->errstr;
}

get '/' => sub {
	my $db = connect_db();
	my $sql = 'select id, title, text from entries order by id desc';
	my $sth = $db->prepare($sql) or die $db->errstr;
	$sth->execute or die $sth->errstr;

	template 'show_entries.tt', {
		'msg'           => get_flash(),
		'add_entry_url' => uri_for('/add'),
		'entries'       => $sth->fetchall_hashref('id'),
	};
};

start;
