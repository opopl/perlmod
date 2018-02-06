
package HTML::Tool::Config;

use strict;
use warnings;

use Data::Dumper qw(Dumper);
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catfile);

sub config_get_hash {
	my $self = shift;

	my $xpath = shift;
	my %opts  = @_;

	my $hash  = {};
	my $order = [];

	my $dom   = $self->{dom_config};
	my @nodes = $dom->findnodes($xpath);

	my $xml = $self->config_get_xml($xpath);

	my $cb_key=$opts{cb_key} || undef;
	foreach my $n (@nodes) {
		my @sn=$n->findnodes('./*');
		foreach my $sn (@sn) {
			my $value = $sn->textContent;
			my $key   = $sn->nodeName;

			push @$order,$key;

			if ($cb_key && ref $cb_key eq 'CODE') {
				$key = $cb_key->($key);
			}
			
			$hash->{$key}=$value;
		}

	}

	return ($hash,$order);
}

sub config_get_text {
	my $self=shift;

	my $xpath=shift;

	my $dom=$self->{dom_config};
	my @nodes=$dom->findnodes($xpath);

	my @values;
	foreach my $n (@nodes) {
		push @values,$n->textContent;
		#push @values,$n->toString;
	}
	wantarray ? @values : \@values;

}


sub config_dump {
	my $self=shift;
	my $xpath=shift;

	my $xml=$self->config_get_xml($xpath);

	print Dumper($xml);

}

sub config_get_xml {
	my $self  = shift;
	my $xpath = shift;

	my $dom   = $self->{dom_config};
	my @nodes = $dom->findnodes($xpath);

	my @values;
	foreach my $n (@nodes) {
		push @values,$n->toString;
	}
	my $xml=join("\n",@values);

	return $xml;
}


sub init_config {
	my $self=shift;

	my $bname = basename($Script);
	my $root  = $bname;

	$root=~s/\.(\w)$//g;

	my $file_xml = catfile($Bin,'config.xml');


	unless(-e $file_xml){ return; }

	my @out;
	open(F,"<$file_xml") || die $!;
	while(<F>){
		chomp;
		my $line=$_;
		push @out,$line;
	}
	close(F);
	my $xml=join("\n",@out);

	
    my $doc = XML::LibXML->load_xml(string => $xml);

	my @nodes   = $doc->findnodes('/root/php_net_pl/*');
	my @l;
	foreach my $n (@nodes) {
		push @l,$n->toString;
	}
	my $xml_conf = join("\n",@l);

    my $dom_conf = XML::LibXML->load_xml(string => $xml_conf);

	my $xs       = XML::LibXML::Simple->new;

	my $data = $xs->XMLin($xml_conf);

	$self->{config}     = $data;
	$self->{dom_config} = $dom_conf;

	return $self;		

}

sub config_get_nodes {
	my $self=shift;

	my $xpath=shift;

	my $dom   = $self->{dom_config};
	my @nodes = $dom->findnodes($xpath);

	wantarray ? @nodes : \@nodes;

}

sub config_get_text_split {
	my $self=shift;

	my $xpath=shift;
	my $delim=shift || ",";

	my $dom=$self->{dom_config};
	my @nodes=$dom->findnodes($xpath);

	my @values;
	foreach my $n (@nodes) {
		push @values,split($delim,$n->textContent);
	}
	wantarray ? @values : \@values;

}




 

1;
