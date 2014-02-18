#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

use OP::Perl::Installer;

my $installer=OP::Perl::Installer->new();

$installer->main();

