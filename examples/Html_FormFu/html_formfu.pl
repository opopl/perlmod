#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;

use Plack;
use Plack::Request;
use Plack::Builder;

use Data::Dumper qw(Dumper);
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);

use HTML::FormFu;
use HTTP::Exception;
use Template;

my $app = sub {
    my $env    = shift;

    my $req    = Plack::Request->new($env);
    my $res    = $req->new_response(200);
    my $params = $req->parameters();

    my $body;

	my $form;
	eval {
		$form = HTML::FormFu->new;
		my $formconf = catfile($Bin,qw(form.yml));
		$form->load_config_file($formconf);
	};
	if ($@) { 
		my $e = HTTP::Exception::500->new;
		$e->status_message($@);
		$e->throw;
   	}

	my $config = {
		INTERPOLATE  => 1,
		POST_CHOMP   => 1,
		INCLUDE_PATH => catfile($Bin,qw(templates)),
	};

	my $t = Template->new($config);

	$t->process( 'index.tt', { form => $form }, \$body);
    $res->body($body);

    return $res->finalize();
};

builder {
    enable "HTTPExceptions", rethrow => 1;
    $app;
};
