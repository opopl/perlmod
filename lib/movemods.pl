#!/usr/bin/env perl

package OP::MOVEMODS;

use strict;
use warnings;

use Env qw( $hm $PERLMODDIR );
use FindBin qw( $Bin $Script );
use File::Find qw( find );
use File::Copy qw( copy );
use File::Spec::Functions qw( catfile );
use File::Path qw(make_path);
use Data::Dumper;

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
my @scalar_accessors=qw();

###__ACCESSORS_HASH
my @hash_accessors=qw(
	MODPATHS
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

our %MODPATHS;
our $ROOT;

sub main {
	my $self=shift;

	$ROOT=catfile($Bin,qw( .. mods ) );

	find({ wanted => \&wanted }, $ROOT );

	foreach my $module (keys(%MODPATHS)) {
		my $origin=$MODPATHS{$module};

        my ($mfirst,$mlast) = ( $module =~ /^(.*)::(\w+)$/ );

		my $mdir=catfile($Bin,split('::',$mfirst));
		make_path($mdir);

		copy($origin,catfile($mdir,$mlast . '.pm'));
	}

}

sub wanted  {

	my $dir=$File::Find::dir;
	my $fullpath=$File::Find::name;

	return unless (/\.pm$/);
	
	my $relpath = $fullpath  =~ s{\Q$ROOT/\E}{}gr;

	my $moddef=$relpath =~ s{^([\w-]+)\/.*$}{$1}r;
	my $module=$moddef =~ s/-/::/gr;

	if (($relpath =~ /^$moddef\/lib\//) && ($module =~ /^OP::/)){
		$MODPATHS{$module}=$fullpath;
	}

}

package main;

OP::MOVEMODS->new->main;
