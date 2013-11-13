
package OP::Git;

use warnings;
use strict;

###use
use Env qw($hm);
use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use File::Spec::Functions qw(catfile rel2abs curdir catdir );

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
    $commands
);
###export_vars_hash
my @ex_vars_hash=qw(
    %REPOS
    @ListRepos
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

###subs
sub init_vars;

###our
our($commands);
our(%REPOS);
our(@ListRepos);

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

  foreach my $repo (qw( gops vrt scripts config)) {
     $REPOS{$repo}->{path}= catfile($hm,$repo);
  }

  foreach my $repo (qw( p texdocs texinputs perlmod)) {
     $REPOS{$repo}->{path}= catfile($hm,qw(wrk),$repo);
  }

  @ListRepos=keys %REPOS;

  
}

BEGIN {
   init_vars();
}

1;

