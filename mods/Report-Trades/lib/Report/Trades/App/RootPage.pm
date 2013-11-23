
package Report::Trades::App::Controller::RootPage;

use warnings;
use strict;

use Env qw( $hm $PERLMODDIR );
use Mojo::Base 'Mojolicious::Controller';
use File::Spec::Functions qw( catfile );

# This action will render a template
sub welcome {
  my $self = shift;

  # Render template 
  $self->render(
      msg       => 'Welcome to the Mojolicious real-time web framework!',
      template  =>  catfile($PERLMODDIR,qw(webserver templates RootPage)),
  );
}

1;
