

# read https://habrahabr.ru/post/53578/ about encodings
# http://www.nestor.minsk.by/sr/2008/09/sr80902.html
	#
package HTML::Work;

use strict;
use warnings;

use utf8;
use Encode;

use XML::LibXML;
use XML::LibXML::PrettyPrint;
use Data::Dumper;

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init;

	return $self;
}

sub init {
	my $self=shift;

	my $h={
		alert => sub { warn $_ for(@_); },
	};
		
	my @k=keys %$h;

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}

	$self->init_dom;
}

sub init_dom {
	my $self=shift;

	my $html=$self->{html};

	if ($html) {
		my $dom = XML::LibXML->load_html(
				string          => decode('utf-8',$html),
				recover         => 1,
				suppress_errors => 1,
		);
		$self->{dom}=$dom;
	}

	return $self;


}

sub alert {
	my ($self,@args)=@_;

	my $sub = $self->{sub_alert} || undef;
	$sub && $sub->(@args);

	return $self;

}

sub html2str {
	my $self = shift;
	my $ref  = shift;

	my $dom = $self->{dom};

	my $xpath = $ref->{xpath} || '';
	my $text='';

	if ($xpath) {
		my @nodes = $dom->findnodes($xpath);
		$text = join "\n",map { $_->toString } @nodes;
	}else{
		$self->pretty;
		$text = $dom->toString;
	}		
	return $text;

}

sub html2lines {
	my $self = shift;
	my $ref  = shift || {};

	my $str = $self->html2str($ref);
	my @lines = split("\n",$str);

	wantarray ? @lines : \@lines;

}

sub pretty {
	my $self=shift;

	my $dom=$self->{dom};

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($dom);

	return $self;

}

sub replace_a {
	my $self=shift;

	my $dom=$self->{dom};

	my $xpath='//a';
	my @nodes=$dom->findnodes($xpath);

	for my $node(@nodes){
		 eval {
			 my $parent = $node->parentNode;
			 my $text   = $node->textContent;
			 my $new    = $dom->createTextNode($text);

			 $parent->replaceChild($new,$node);

		 };
		 if($@){ $self->alert($@); }
	}

	return $self;
}

1;
 

