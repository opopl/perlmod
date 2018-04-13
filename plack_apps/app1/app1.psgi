
use strict;

use Plack;
use Plack::Request;
use Plack::Builder;
		
my $app = sub {
    my $env = shift;

    my $req = Plack::Request->new($env);
    my $res = $req->new_response(200);
    $res->header('Content-Type' => 'text/html', charset => 'Utf-8');

    my $params = $req->parameters();
    my $body;
    if (my $string = $params->{string}) {
        $body = $string;
    }
    else {
        $body = 'empty string';
    }

    $res->body($body);

    return $res->finalize();
};

my $main_app = builder {
    mount "/" => builder { $app; };
};

