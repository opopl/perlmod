
package OP::apache::eforms;

use strict;
use warnings;

=head1 NAME

Apache::eforms 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

use Apache2::RequestRec (); # for $r->content_type
use Apache2::Const  qw(OK);
use CGI ':standard'; 
use Data::Dumper;

sub handler {
    my $r = shift;

    #$r->content_type('text/plain');
    $r->content_type('text/html');
    #$r->print("mod_perl rules!\n");

    #$r->print(Dumper($r));
    #$r->print($r->path_info);
    #$r->print($r->method);
    my $lines=[
        start_html,
        h1('aaa'),
        end_html,
    ];

    $r->print($_) for(@$lines);

    return OK;

}

1;
