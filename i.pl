#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;

use lib("$FindBin::Bin/mods/OP-Perl-Installer/lib");
use OP::Perl::Installer;

my $installer=OP::Perl::Installer->new();

$installer->main();

