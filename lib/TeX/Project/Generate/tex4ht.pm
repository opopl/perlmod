
package OP::Projs::Generate::tex4ht;

use strict;
use warnings;

use File::Spec::Functions qw(catfile);
use Data::Dumper;
use OP::Base qw(readarr);
use File::Slurp qw(read_file write_file);
use FindBin qw($Bin);

use TeX::Project::GenerateTeX;

use Carp;

use parent qw( OP::Projs::Generate );

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);
	

sub init_vars {
	my $self=shift;

	$self->OP::Projs::Generate::init_vars;

	$self->SECTITLES( 
		'' => ''
	);

	$self->SECS_TO_GENERATE_push(qw( 
	));

}

sub g_preamble {
	my $self=shift;

	$self->OP::Projs::Generate::g_preamble;

	my $tex=$self->tex;

	$tex->_cmd('title','TeX4HT documentation');
	$tex->_cmd('date','\today');
	$tex->_cmd('author','Oleksandr Poplavskyy');

	$tex->_empty_lines;

}

sub g_defs {
	my $self=shift;

	my $tex=$self->tex;

	$tex->newenvironment({
			env 	=> 'ltab',
			begin  	=> '\begin{longtable}{p{.5\textwidth}p{.5\textwidth}}',
			end  	=> '\end{longtable}',
	});

	$tex->_add_line(<<'EOF');

\def\iorig#1{%
	\section{Point #1}%
	\input{\PROJ.orig_#1.tex}}

\def\COMMENT#1{%
	\subsection{COMMENT #1}
}

\def\NOCOMMENT{%
	\subsection{NO COMMENT}
}

\def\bmkroot#1#2{%
	\hypertarget{#1}{}%
	\bookmark[level=0,dest=#1,]{#2}%
}%

\newcounter{secbf}
\setcounter{secbf}{0}

\def\vgap{\vspace{0.5cm}}

\def\secbf#1#2{%
  \def\sectitle{#2}
	\hypertarget{secbf:#1}{}%
	\bookmark[view={FitB},dest=secbf:#1,level=1]{\sectitle}%
  \vspace{0.5cm}%
  \begingroup%
  \bf\sectitle \rm%
  \endgroup%
  \vspace{0.5cm}%
}%

EOF

}

1;
