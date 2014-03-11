
package OP::HTML::Tests;

use strict;
use warnings;

use Test::More;
use OP::HTML;
use OP::Base qw( _arrays_equal );

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
    $H
    $TEST
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
    @TESTS
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
    do_tests
    ok_lines
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

###our
our $H;
our $TEST;
our @TESTS;

###subs
sub ok_lines;
sub do_tests;

sub ok_lines {
  my $a=shift;
  my $msg=shift;

  ok( _arrays_equal($H->textlines_ref,$a ), $msg);

}

sub do_tests {

  foreach my $test (@TESTS) {
      eval '&test_' . $test . ';' ;
      warn $@ if $@;
  }

  done_testing;

}

BEGIN {
    $H=OP::HTML->new;
}


1;

