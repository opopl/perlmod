

# read https://habrahabr.ru/post/53578/ about encodings
# http://www.nestor.minsk.by/sr/2008/09/sr80902.html
	#
package HTML::Work;

use strict;
use warnings;

use Encode;
use utf8;
use File::Temp qw( tempfile tempdir );

use URI;
use LWP;

use HTML::Strip;
use HTML::TreeBuilder;
use HTML::FormatText;

use XML::LibXML;
use XML::LibXML::PrettyPrint;
use Data::Dumper;
use File::Spec::Functions qw(catfile);
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

use HTML::Entities;

=head1 METHODS

=cut

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
		sub_log => sub { warn $_ . "\n" for(@_); },
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

sub log {
	my ($self,@args)=@_;

	my $sub = $self->{sub_log} || undef;
	$sub && $sub->(@args);

	return $self;
}

sub dom_replace_a {
	my $self = shift;

	my $dom  = $self->{dom};

	{
		my @nodes=$dom->findnodes('//a');
		for my $node (@nodes) {
			eval {
				 my $parent = $node->parentNode;
				 my $text   = $node->textContent;
				 my $new    = $dom->createTextNode($text);
		
				 $parent->replaceChild($new,$node);
			};
		if($@){ $self->log($@); }
		}
	}
	return $self;

}

sub save_to_vh {
	my ($self,$ref) = @_;

	my $tag     = $ref->{tag} || '';
	my $in_html = $ref->{in_html} || '';
	my $out_vh  = $ref->{out_vh} || '';

	my $tmpdir  = $ref->{tmpdir} || $ENV{TMP} || '';
	my $tmphtml = $ref->{tmphtml} || '';

	if ($in_html) {
		$self->load_html_from_file({ 
			file => $in_html,
		});
	}

	my $dom      = $self->{dom};
	$self->{dom} = $dom;

	my $actions = $ref->{actions} || [];
	foreach my $act (@$actions) {
		local $_=$act;
		/^replace_a$/ && do {
			$self->dom_replace_a;
			next;
		};
	}

	my $xpath_rm = $ref->{xpath_rm} || [];
	foreach my $xpath (@$xpath_rm) {
			my @nodes=$dom->findnodes($xpath);
			for my $node (@nodes) {
				eval {
					 my $parent = $node->parentNode;
					 $parent->removeChild($node);
				};
			}
			if($@){ $self->log($@); }
	}

	# xpath callbacks
	my $xpath_cb = $ref->{xpath_cb} || [];
	foreach (@$xpath_cb) {
		my $xpath = $_->{xpath} || '';
		my $cb    = $_->{cb} || sub {};

		next unless $xpath;

		my @nodes=$dom->findnodes($xpath);
		foreach my $node (@nodes) {
			$cb->($node);
		}
	}

	unless ($tmphtml) {
		(my $fh,$tmphtml) = tempfile(
			'HTML_Work_save_to_vh_XXXX',
			SUFFIX => '.htm',
			DIR    => $tmpdir,
		);

	}

	$self->save_to_html({
		file => $tmphtml,
	});

	my $pre=$ref->{insert_vh} || [
		' ',
		' *'.$tag.'*',
		'vim:ft=help:foldmethod=indent',
		' ',
	];

	my $cmd   = 'lynx -dump -force_html '.$tmphtml;
	my @lines = map { s/\n//g; $_ } qx{$cmd};
	
	unshift @lines,@$pre;

	if ($out_vh) {
		write_file($out_vh,join("\n",@lines) . "\n");
	}

	wantarray ? @lines : \@lines ;

}

sub htmlstr {
	my ($self,$ref) = @_;

	my $dom  = $self->{dom};

	my $xpath = $ref->{xpath} || '';
	my $text  = '';

	if ($xpath) {
		my @nodes = $dom->findnodes($xpath);
		$text     = join "\n",map { $_->toString } @nodes;
	}else{
		$self->pretty;
		$text = $dom->toString;
	}		
	return $text;

}

sub htmllines {
	my $self = shift;
	my $ref  = shift || {};

	my $str   = $self->htmlstr($ref);
	my @lines = split("\n",$str);

	wantarray ? @lines : \@lines;

}

sub list_h {
	my $self = shift;
	my $ref  = shift;

	my $sub = $ref->{sub} || sub { 1 };

	my @headnums=(1..6);
	my @xp_heads = map { 'self::h'.$_ } @headnums;
	my $xpath    = '//*['.join(' or ', @xp_heads) . ']';

	my @n=$self->nodes({
		xpath => $xpath,
	});

	my @heads;
	for my $node (@n){
		my $ok   = $sub->($node);

		local $_;

		$_=$node->textContent;
		$ok && push @heads,$_;
	}

	wantarray ? @heads: \@heads ;
}

sub download_href_from_url {
	my $self = shift;
	my $ref  = shift;

	my $url  = $ref->{url};

	$self->load_html_from_url($ref);

	my @href = $self->list_href;

	foreach my $url (@href) {
		next unless defined $url;
		$url =~ s/^\s*//g;
		$url =~ s/\s*$//g;
		next unless $url;
		my $uri = URI->new($url);

		my $path = $uri->path || '';
		my $host = $uri->host || '';

		print $host . "\n";
		print $path . "\n";

		#print $uri->as_string . "\n";
		#print $uri->host . "\n";
	}
}

sub list_href {
	my $self = shift;
	my $ref  = shift;

	my $sub = $ref->{sub} || sub { 1 };

	my @n=$self->nodes({xpath => '//a'});
	my @href;
	for(@n){
		my $a = $_->getAttribute('href');

		{
			local $_ = $a;
			my $ok   = $sub->($_);

			$ok && push @href,$_;
		}
	}
	wantarray ? @href : \@href ;
}

sub nodes { 
	my $self = shift;
	my $ref  = shift;

	#my $xpaths=$ref->{xpaths} || [];
	my $xpath=$ref->{xpath} || '';

	my $dom=$self->{dom};

	my @nodes=$dom->findnodes($xpath);

	wantarray ? @nodes : \@nodes ;
}

sub node_pretty {
	my $self=shift;
	my $node=shift;

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($node);

	return $self;

}

sub pretty {
	my $self=shift;

	my $dom=$self->{dom};

	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
 	$pp->pretty_print($dom);

	return $self;

}

sub url_saveas {
	my $self = shift;
	my $ref  = shift;

	my $url   = $ref->{url} || '';
	my $file  = $ref->{file} || '';
	my $rw = $ref->{rw} || 0;

	unless ($file) { $self->log('url_saveas: no file!');return; }

	my $savedir = $ref->{savedir}||$self->{savedir}||'';
	unless ($savedir) { $self->log('url_saveas: no savedir!');return; }

	my $fpath   = catfile($savedir,$file);

	if (-e $fpath and not $rw) {
		$self->log('url_saveas: saved file exists, will not rewrite!');
		return;
	}
	my ($uri,$ua,$response);

	$uri = URI->new($url);
	$ua  = LWP::UserAgent->new;
	
	#eval { $response = $ua->get($uri,$fpath); };
	eval { $response = $ua->get($uri); };
	if ($@) { $self->log('Failure to invoke $ua->get method:',$@);  }

	my ($content,$statline);
 	if ($response->is_success) {
		 	$self->log('URL load OK: '.$url);
		 	$content =  $response->decoded_content;
 	} else { 
		 	$statline = $response->status_line;
		 	$self->log('URL load Fail: '.$statline);
			return $self;
 	}
	#print $fpath . "\n";

	open(F,">$fpath") || die $!;
	print F $content . "\n";
	close(F);
}

sub load_html_from_file {
	my $self = shift;
	my $ref  = shift;

	my $file   = $ref->{file} || '';

	my $html = read_file $file;
	my $dom  = XML::LibXML->load_html(
			#string          => $content,
			string          => decode('utf-8',$html),
			recover         => 1,
			suppress_errors => 1,
	);
	$self->{dom}              = $dom;

}

sub url_was_loaded {
	my $self=shift;
	my $url=shift;

	my @loaded = @{$self->{loaded_urls}||[]};

	return (grep { /^$url$/ } @loaded ) ? 1 : 0;
}

=head2 load_html_from_url

=over

=item Usage

	my $htw=HTML::Work->new;

	$htw->load_html_from_url({ url => $url });
	$htw->load_html_from_url({ url => $url, xpath => $xpath });

=back

=cut

sub load_html_from_url {
	my $self = shift;
	my $ref  = shift;

	my $xpath  = $ref->{xpath} || '';
	my $url    = $ref->{url} || '';
	my $reload = $ref->{reload} || 0;

	if (!$reload && $self->url_was_loaded($url)) {
		$self->{dom}              = $self->{urls_dom}->{$url} || undef;
		$self->{content_from_url} = $self->{urls_content}->{$url} || undef;
		return;
	}

	my $uri = URI->new($url);
	my $ua  = LWP::UserAgent->new;

 	my $response = $ua->get($uri);

	my ($content,$statline);
 	if ($response->is_success) {
		 	$self->log('URL load OK:' . $url);
		 	$content =  $response->decoded_content;
			push @{$self->{loaded_urls}},$url;
 	} else { 
		 	$statline = $response->status_line;
		 	$self->log('URL load Fail: '.$url, 'Fail status: ' . $statline);
			return $self;
 	}

	my $dom = XML::LibXML->load_html(
			string          => $content,
			#string          => decode('utf-8',$content),
			recover         => 1,
			suppress_errors => 1,
	);

	$self->{dom}              = $dom;
	$self->{content_from_url} = $content;

	$self->{urls_dom}->{$url}     = $dom;
	$self->{urls_content}->{$url} = $content;

	return $self;
}

sub save_to_html {
	my $self = shift;
	my $ref  = shift;

	my $html = $self->htmlstr($ref);
	my $file = $ref->{file} || '';

	#use Data::Dumper qw(Dumper);
	#print Dumper($self->htmlstr({xpath => '//a'}));

	if ($file) {
		open(F,">$file") || die $!;
		print F $html . "\n";
		close(F);
	}

	return $self;
}

sub replace_a {
	my $self=shift;

	$self->replace_node_with_text({ 'xpath' => '//a' });
}

sub node2text {
	my $self=shift;
	my ($dom,$node)=@_;

	my $parent = $node->parentNode;
	my $html   = $node->toString;

	my $htb = HTML::TreeBuilder->new();
	$htb->parse($html);
				
	my $formatter = HTML::FormatText->new(
		leftmargin => 0, 
		rightmargin => 50);
	
	my $ascii = $formatter->format($htb);
	my @ascii = split("\n",$ascii);

	foreach my $a (@ascii) {
		my $br=$dom->createElement('br');
		my $brt=$dom->createTextNode($a);
		$br->addChild($brt);

    	$parent->insertBefore( $br, $node );
	}
	$parent->removeChild($node);


}

sub node_getascii {
	my $self=shift;
	my $ref=shift;

	my $xpath = $ref->{xpath} || undef;
	my $node  = $ref->{node} || undef;

	my $dom   = $self->{dom} || undef;

	my @ascii = ();
	my @nodes = $node->findnodes($xpath);

	foreach my $n (@nodes) {
		my $html   = $n->toString;
		my $parent = $n->parentNode;

		$self->node2text($dom,$n);

		my @br=$parent->findnodes('./br');
		foreach my $a (@br) {
			push @ascii,$a->textContent;
		}
	}
	return(\@ascii,\@nodes);
}

sub replace_node_with_text {
	my $self=shift;
	my $ref=shift;

	my $dom   = $self->{dom};
	my $xpath = $ref->{xpath} || '';

	unless ($xpath) {
		return $self;
	}

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
 

