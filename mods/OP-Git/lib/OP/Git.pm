
package OP::Git;

use strict;
use warnings;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = '0.01';
@ISA         = qw(Exporter);

@EXPORT      = qw();
@EXPORT_OK   = qw($commands);
%EXPORT_TAGS = ();

our($commands);

sub new
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}

sub init_vars {

  $commands=[ qw(
		add
		st
		br
		ci
		co
		log
		lg
		lf
        rebase
		push
		pull
		pb
  )];
  
}

BEGIN {
   &init_vars();
}

1;

