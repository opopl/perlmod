
package Report::Trades::App;

use warnings;
use strict;

use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  $r->namespaces([qw(Report::Trades::App::Controller)]);

  # Normal route to controller
  $r->get('/')->to('rootpage#welcome');

  $r->route('/help')->to( 
        cb => sub { shift->render( template=> 'help', format=>'html' ) } 
  );
}

1;
