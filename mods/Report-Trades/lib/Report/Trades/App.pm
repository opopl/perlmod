
package Report::Trades::App;

use strict;
use warnings;

use Mojo::Base qw( Mojolicious );

sub startup {
    my $self = shift;

    $self->routes->get('/hello')->to('foo#hello');
}

1;
