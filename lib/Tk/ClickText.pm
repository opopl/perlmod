

package Tk::ClickText;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '1.0';

use Tk qw(Ev);
use Tk::widgets qw(Text);

use base qw(Tk::Derived Tk::Text);

Construct Tk::Widget 'ClickText';

sub ClassInit { 
	my ($self, $mw) = @_;  

	$self->SUPER::ClassInit($mw);
}

sub Populate { 
	my ($self, $args) = @_; 

	$self->SUPER::Populate($args);

	my $menu=$self->menu;
	my $m;
   # $m->{get} = $menu->cascade(
		#-label       => 'get',
		##-accelerator => 'Ctrl-n',
		#-underline   => 0,
	#);

	$menu->command(
	    -label       => "Get",
	    -underline   => 0,
	    -command     => sub { },
	);

	if ($self->tagRanges('sel')) {

	}
}


sub Contents
{
	my $t    = shift;
	my @items = @_;

	my $tag = "tag000";

	my $mw=$t->parent;

	my $process_link = sub {
	};

###manipulate_link
	my $manipulate_link = sub {
	
		# manipulate the link as you press the mouse key
	
		my ($a)      = shift;
		my ($tag)    = shift;
		my ($relief) = shift;
		my ($cursor) = shift;
		my ($after)  = shift;
	
		# by configuring the relief (to simulate a button press)
		$a->tagConfigure( $tag, -relief => $relief, -borderwidth => 1 );
	
		# by changing the cursor between hand and xterm
		$a->configure( -cursor => $cursor ) if ($cursor);
	
		# and by scheduling the specified action to run "soon"
		if ($after) {
			my ($s) = $a->get( $a->tagRanges($tag) );
			$mw->after( 200, [ $after, $a, $s, $tag, @_ ] ) if ($after);
		}
	};
	
	if (@items) {
		$t->delete('1.0','end');
		my $pat=qr/(https:\S+|http:\S+)/;
		for my $item (@items){
	    	my (@http) = split (/$pat/,$item);
			for(@http){
				if (/$pat/) {
		            $t->insert( 'end', $_, $tag );
		            $t->tagConfigure( $tag, -foreground => 'blue' );
		            $t->tagBind( $tag,
		                '<Any-Enter>' => [ 
							$manipulate_link, $tag, 'raised', 'hand2' ]
		            );
		            $t->tagBind( $tag,
		                '<Any-Leave>' => [ $manipulate_link, $tag, 'flat', 'xterm' ] );
		            $t->tagBind( $tag,
		                '<Button-1>' => [ $manipulate_link, $tag, 'sunken' ] );
		            $t->tagBind( $tag,
		                '<ButtonRelease-1>' =>
		                  [ $manipulate_link, $tag, 'raised', undef, 
							  $process_link ] );
		            $tag++;
				} else {
					$t->insert( 'end', $_ );
				}
			}
        }
	} else { 
		return $t->get('1.0','end -1c'); 
	}
}

1;



#sub printme {
    #local ($,) = " ";
    #print "printme:", @_, "\n";
#}


#__DATA__
#Hi there.  This is text.
#THis is more text but http://this.is.a/hyperlink in a line.
#http://this.is.another/hyperlink followed by
#http://this.is.a.third/hyperlink
#__END__

 

