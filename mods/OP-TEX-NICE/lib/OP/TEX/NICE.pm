package OP::TEX::NICE;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = '0.01';
@ISA         = qw(Exporter);

#Give a hoot don't pollute, do not export more than needed by default

@EXPORT      = qw();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ();

sub new
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}


1;

