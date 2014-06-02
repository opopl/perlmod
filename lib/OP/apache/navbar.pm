
package OP::apache::navbar;

use strict;
use warnings;

use Apache2::Const qw( OK DECLINED );
use Apache2::Response ();
use Apache2::RequestUtil ();
use Apache2::ServerUtil ();
use CGI ':standard';

use IO::File;
use File::Spec::Functions qw( catfile );

my %BARS = ();

my $TABLEATTS   = 'WIDTH="100%" BORDER=1';
my $TABLECOLOR  = '#C8FFFF';
my $ACTIVECOLOR = '#FF0000';

sub handler {
    my $r = shift;

    my $bar;

    $bar = read_configuration($r)         || return DECLINED;

    $r->content_type('text/html');
    $r->print(start_html,$r->content_type,end_html ); 

    #$r->content_type eq 'text/html'       || return DECLINED;

    my ($fh,$navbar);
    #my $fh = IO::File->new($r->filename)     || return DECLINED;
    #my $navbar = $bar->to_html($r->uri);

    return OK;
    
    $r->update_mtime($bar->modified);
    $r->set_last_modified;
    my $rc = $r->meets_conditions;
    return $rc unless $rc == OK;

    $r->send_http_header;
    return OK if $r->header_only;

    local $/ = "";
    while (<$fh>) {
       s:<!--NAVBAR-->:$navbar:oi;
    } continue { 
       $r->print($_); 
    }

    return OK;
}

# read the navigation bar configuration file and return it as a
# hash.
sub read_configuration {
    my $r = shift;

    my $conf_file;

    return unless $conf_file = $r->dir_config('NavConf');
    return unless -e ($conf_file = catfile( Apache2::ServerUtil::server_root() , $conf_file));

    my $mod_time = (stat _)[9];

    return $BARS{$conf_file} if $BARS{$conf_file} 
      && $BARS{$conf_file}->modified >= $mod_time;

    return $BARS{$conf_file} = NavBar->new($conf_file);
}

package NavBar;

use File::Slurp qw(read_file);

# create a new NavBar object
sub new {
    my ($class,$conf_file) = @_;

    my (@c,%c);
    my @lines = read_file($conf_file) || return;

    for (@lines) {
       chomp;
       s/^\s+//; s/\s+$//;   #fold leading and trailing whitespace

       next if /^#/ || /^$/; # skip comments and empty lines
       next unless my ($url, $label) = /^(\S+)\s+(.+)/;
       push @c, $url;     # keep the url in an ordered array
       $c{$url} = $label; # keep its label in a hash
    }

    return bless {  'urls'      => \@c,
                    'labels'    => \%c,
                    'modified'  => (stat $conf_file)[9]
                 }, $class;
}

# return ordered list of all the URIs in the navigation bar
sub urls  { return @{shift->{'urls'}}; }

# return the label for a particular URI in the navigation bar
sub label { return $_[0]->{'labels'}->{$_[1]} || $_[1]; }

# return the modification date of the configuration file
sub modified { return $_[0]->{'modified'}; }

sub to_html {
    my $self = shift;

    my $current_url = shift;

    my @cells;

    for my $url ($self->urls) {
       my $label = $self->label($url);

       my $is_current = $current_url =~ /^$url/;
       my $cell = $is_current ?
           qq(<FONT COLOR="$ACTIVECOLOR">$label</FONT>)
               : qq(<A HREF="$url">$label</A>);
       push @cells, 
       qq(<TD CLASS="navbar" ALIGN=CENTER BGCOLOR="$TABLECOLOR">$cell</TD>\n);
    }
    return qq(<TABLE $TABLEATTS><TR>@cells</TR></TABLE>\n);
}


1;
__END__

