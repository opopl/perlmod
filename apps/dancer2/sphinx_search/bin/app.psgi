#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use sphinx_search;

sphinx_search->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use sphinx_search;
use Plack::Builder;

builder {
    enable 'Deflater';
    sphinx_search->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use sphinx_search;
use sphinx_search_admin;

use Plack::Builder;

builder {
    mount '/'      => sphinx_search->to_app;
    mount '/admin'      => sphinx_search_admin->to_app;
}

=end comment

=cut

