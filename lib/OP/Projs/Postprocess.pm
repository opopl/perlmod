
package OP::Projs::Postprocess;

use strict;
use warnings;

use parent qw( OP::Projs::Base );

sub main {
    my $self=shift;

    $self->init_vars;
    $self->postprocess;
    
}

sub postprocess {
    my $self=shift;
}


1;
