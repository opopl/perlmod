

# read https://habrahabr.ru/post/53578/ about encodings
# http://www.nestor.minsk.by/sr/2008/09/sr80902.html
	#
package HTML::Work;

use strict;
use warnings;

use Encode;
use utf8;

use URI;
use LWP;

use XML::LibXML;
use XML::LibXML::PrettyPrint;
use Data::Dumper;

use HTML::Entities;

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
		sub_log => sub { warn $_ for(@_); },
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

sub xpath {
	my ($self,$xpath)=@_;

	my $dom=$self->{dom};
}

sub log {
	my ($self,@args)=@_;

	my $sub = $self->{sub_log} || undef;
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

sub load_html_from_url {
	my $self = shift;
	my $ref  = shift;

	my $xpath = $ref->{xpath} || '';
	my $url   = $ref->{url} || '';

	my $uri = URI->new($url);
	my $ua  = LWP::UserAgent->new;

 	my $response = $ua->get($uri);

	my ($content,$statline);
 	if ($response->is_success) {
		 	$self->log('URL load OK');
		 	$content =  $response->decoded_content;
 	} else { 
		 	$statline = $response->status_line;
		 	$self->log('URL load Fail: '.$statline);
			return $self;
 	}

	my $dom = XML::LibXML->load_html(
			string          => $content,
			#string          => decode('utf-8',$content),
			recover         => 1,
			suppress_errors => 1,
	);
	$self->{dom}=$dom;

	return $self;
}

sub html_saveas {
	my $self = shift;
	my $ref  = shift;

	$self->log('aaaa');

	my $html = $self->html2str($ref);
	my $file = $ref->{file} || '';


	if ($file) {
		open(F,">$file") || die $!;
		print $html . "\n";
		close(F);
	}

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
		 if($@){ $self->log($@); }
	}

	return $self;
}

1;
 

