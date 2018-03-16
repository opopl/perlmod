package Vim::Xml;

use strict;
use warnings;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

use Vim::Perl qw( :vars :funcs );
use XML::LibXML;
use HTML::Entities;

###export_vars_scalar
my @ex_vars_scalar=qw(
	$PARSER $DOM $DOMCACHE $XPATHCACHE
);
###export_vars_hash
my @ex_vars_hash=qw(
	%nodetypes
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
	node_cdata2text
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

use vars qw( $PARSER $DOM $DOMCACHE $XPATHCACHE %nodetypes );

# XML::LibXML exported constants
%nodetypes=reverse (
	      XML_ELEMENT_NODE            => 1,
          XML_ATTRIBUTE_NODE          => 2,
          XML_TEXT_NODE               => 3,
          XML_CDATA_SECTION_NODE      => 4,
          XML_ENTITY_REF_NODE         => 5,
          XML_ENTITY_NODE             => 6,
          XML_PI_NODE                 => 7,
          XML_COMMENT_NODE            => 8,
          XML_DOCUMENT_NODE           => 9,
          XML_DOCUMENT_TYPE_NODE      => 10,
          XML_DOCUMENT_FRAG_NODE      => 11,
          XML_NOTATION_NODE           => 12,
          XML_HTML_DOCUMENT_NODE      => 13,
          XML_DTD_NODE                => 14,
          XML_ELEMENT_DECL            => 15,
          XML_ATTRIBUTE_DECL          => 16,
          XML_ENTITY_DECL             => 17,
          XML_NAMESPACE_DECL          => 18,
          XML_XINCLUDE_START          => 19,
          XML_XINCLUDE_END            => 20,
);

sub node_cdata2text {
	my ($node,$dom,$parser)=@_;

	#$dom->keep_blanks(0);
	my $ntype=$node->nodeType;
	if ($ntype == XML_CDATA_SECTION_NODE) {
		my $content = $node->textContent;
		$content=decode_entities($content);

		my $tx      = $dom->createTextNode($content);
		my $parent  = $node->parentNode;
		
		$parent->removeChild($node);
		$parent->appendChild($tx);

		$node=$tx;
		#print $tx->toString . "\n";
		return $node;
	}
	else {
		my @tn=$node->findnodes('./text()');
		foreach my $n (@tn) {
			if ($n->nodeType == XML_CDATA_SECTION_NODE) {
				$n = node_cdata2text($dom,$n,$parser);
			}
		}
	}
	return $node;

}

1;
 

