
package OP::Projs::Generate;

use strict;
use warnings;

use Carp;

use OP::Projs::Tex;
use OP::Base qw(readarr);

use File::Spec::Functions qw(catfile);

use parent qw( OP::Projs::Base );
our @ISA;

###__ACCESSORS_SCALAR
my @scalar_accessors=qw( tex sec sectitle );

###__ACCESSORS_HASH
my @hash_accessors=qw(
	SECTITLES
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
	SECS_TO_GENERATE
	OSECS
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);
	
sub main {
    my $self=shift;

    $self->init_vars;
    $self->generate;
    
}

sub g_preamble {
	my $self=shift;

	my $tex=$self->tex;

	$tex->_empty_lines;
	$tex->documentclass('report',{ 'opts' => [ qw(a4paper 10pt )]});
	$tex->_empty_lines;

	$tex->ii('packages');
	$tex->ii('makeatletter');
	$tex->ii('preamble_page_geometry');
	$tex->ii('preamble_text_formatting');

	$tex->_empty_lines;
	$tex->ii('defs');
	$tex->_empty_lines;

	$tex->_add_line('\setcounter{page}{1}');
	$tex->_empty_lines;

}

sub g__main_ {
	my $self=shift;

	my $tex=$self->tex;

	$tex->_empty_lines;
	$tex->def('PROJ',$self->PROJ);
	$tex->input('_common.defs.tex');
	$tex->_empty_lines;
	
	$tex->ii('preamble');
	$tex->ii('begin');
	$tex->ii('body');

	$tex->_empty_lines;

	$tex->end('document');

	$tex->_empty_lines;

}

sub g_cfg {
	my $self=shift;

	my $tex=$self->tex;

	$tex->_add_line(<<'EOF');

\Preamble{html,frames,4,index=2,next,pic-equation,pic-eqnarray,pic-align,charset=utf-8,javascript}

\icfg{frames-two}
\icfg{tabular}
\icfg{common}
\icfg{picmath}

\begin{document}

\icfg{HEAD.showHide}
\icfg{TOC}

\EndPreamble

EOF

}

sub g_body {
	my $self=shift;

	foreach my $sec ($self->OSECS) {
		$self->tex->ii($sec);
	}

}

sub g_begin {
	my $self=shift;

	$self->tex->begin('document');

	$self->tex->NextFile('title');

    $self->tex->_cmd('thispagestyle','plain');
    $self->tex->ii('title');
    $self->tex->_cmd('restoregeometry');

	$self->tex->NextFile('toc');
    $self->tex->input('toc');

}

sub generate_tex {
	my $self=shift;

	my $sec=shift // '';

	unless ($sec) {
		foreach my $sec (@{$self->SECS_TO_GENERATE}) {
			$self->generate_tex($sec);
		}
	}else{
		my $secfile;

		$self->sec($sec);

		if ($sec eq "_main_"){
			$secfile=catfile($self->PROJSDIR,$self->PROJ . '.tex');
		}else{
			$secfile=catfile($self->PROJSDIR,$self->PROJ . '.' . $sec . '.tex');
		}

		my $sectitle=$self->SECTITLES($self->sec) // '';
		$self->sectitle($sectitle);

		$self->tex->_clear;
		$self->tex->ofile($secfile);

		eval '$self->g_' . $sec;
		carp $@ if $@;

		$self->tex->_writefile;
	}

}


sub g_packages {
	my $self=shift;

	my $tex=$self->tex;

	unless($self->USEDPACKS_count){
		carp 'No used packages provided';
		return;
	}	

	foreach my $pack ($self->USEDPACKS) {
		my $opts=$self->PACKOPTS($pack) // '';

		my $ref={
			'package' => $pack,
			'options' => $opts,
		};

		$tex->usepackage($ref);
	}

}

sub init_vars {
	my $self=shift;

	my %seen;
	foreach my $parent (@ISA) {
		if (my $code=$parent->can('init_vars')) {
			$self->$code unless $seen{$code}++;
		}
	}

	$self->tex(OP::Projs::Tex->new);

	$self->OSECS( readarr($self->FILES('secorder')) );

	$self->SECS_TO_GENERATE(qw( _main_ ));
	$self->SECS_TO_GENERATE_push(qw( defs cfg body preamble begin packages ));

}

sub generate {
    my $self=shift;

	$self->generate_tex;
}

1;
