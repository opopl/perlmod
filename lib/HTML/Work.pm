
package HTML::Work;

use strict;
use warnings;

use utf8;
use Encode;

use XML::LibXML;
use XML::LibXML::PrettyPrint;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={};
		
	my @k=keys %$h;

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}
}

sub init_dom {
	my $self=shift;

	my $html=$self->{html} || shift;

	my $dom = XML::LibXML->load_html(
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);

}

sub alert {
	my $self=shift;
	my @args=@_;

	my $sub = $self->{sub_alert} || undef;
	$sub && $sub->(@args);
}

sub replace_a {
	my $self=shift;

	my $xpath='//a';
	my @nodes=$dom->findnodes($xpath);

	for my $node(@nodes){
		 eval {
			 $parent = $node->parentNode;
			 $text   = $node->textContent;
			 $new    = $dom->createTextNode($text);
			 $parent->replaceChild($node,$new);
		 };
		 if($@){ $self->alert($@); }
	}
}

1;
 

