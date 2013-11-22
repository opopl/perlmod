
package Report::Trades::App;

use warnings;
use strict;

use Mojo::Base qw( Mojolicious );

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('controller#welcome');

}

1;
