#!/usr/bin/perl 

use strict;
use warnings;
use Module::Build;

my $name=shift;
my $module=join(":",split('-',$name));

my $build=Module::Build->new(
	module_name => "$module"
	,license => 'perl'
);

$build->dispatch('build');
$build->dispatch('test', verbose => 1);
$build->dispatch('install');

