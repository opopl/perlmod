
package OP::Projs::Generate::reply_oia_complaint_outcome;

use strict;
use warnings;

use File::Spec::Functions qw(catfile);
use Data::Dumper;
use OP::Base qw(readarr);
use File::Slurp qw(read_file write_file);
use FindBin qw($Bin);

use OP::Projs::Tex;

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
		'Section_1_Background' 			=> 'Section 1: Background',
		'Section_2_OIA_Review_Process' 	=> 'Section 2: OIA Review Process',
		'Section_3_Review_of_Complaint_and_Conclusions' =>
			'Section 3: Review of Complaint and Conclusions',
	);


	$self->SECS_TO_GENERATE_push(qw( 
			Section_1_Background
			Section_2_OIA_Review_Process
			Section_3_Review_of_Complaint_and_Conclusions
	));


}


sub g_Section_1_Background {
	my $self=shift;

	my $tex=$self->tex;

	$tex->clearpage;
	$tex->chapter($self->sectitle);
	$tex->label($self->sec);

	$self->tex->_empty_lines;

	foreach my $i ((1..17)) {
		$self->tex->_cmd('iorig',$i);
	}

}

sub g_Section_2_OIA_Review_Process {
	my $self=shift;

	my $tex=$self->tex;

	$tex->clearpage;
	$self->tex->chapter($self->sectitle);
	$tex->label($self->sec);

	$self->tex->_empty_lines;

	foreach my $i ((18..21)) {
		$self->tex->_cmd('iorig',$i);
	}

}

sub g_Section_3_Review_of_Complaint_and_Conclusions {
	my $self=shift;

	my $tex=$self->tex;

	$tex->clearpage;
	$tex->chapter($self->sectitle);
	$tex->label($self->sec);

	$tex->_empty_lines;

	#$tex->chapter('irregularities in the conduct of the oral examination');

	foreach my $i ((22..27)) {
		$tex->_cmd('iorig',$i);
	}

	#$tex->section('Suitability and Bias of Examiners');

	foreach my $i ((28..35)) {
		$tex->_cmd('iorig',$i);
	}

	#$tex->section('Supervision');

	foreach my $i ((36..51)) {
		$tex->_cmd('iorig',$i);
	}

}

sub g_preamble {
	my $self=shift;

	$self->OP::Projs::Generate::g_preamble;

	my $tex=$self->tex;

	$tex->_cmd('title','Reply to the OIA outcome letter');
	$tex->_cmd('date','\today');
	$tex->_cmd('date','March 17, 2014');
	$tex->_cmd('author','Oleksandr Poplavskyy');

	$tex->_empty_lines;

}




sub split {
	my $self=shift;

	foreach my $sec (qw(
			Section_2_OIA_Review_Process 
			Section_3_Review_of_Complaint_and_Conclusions
	)){

		my $secfile=catfile($Bin,$self->PROJ . '.' . $sec . '.tex');

		my @lines=read_file $secfile;
		my $num=undef;
		my @loclines;

		foreach (@lines) {
			chomp;
			my $line=$_;

			if(/^(\d+)\./){
				$line =~ s/^(\d+)\.\s*//g;
				if (defined $num){
					my $nfile=catfile(
						$Bin,$self->PROJ . '.orig_' . $num . '.tex');

					if(@loclines){
						write_file($nfile,join("\n",@loclines) . "\n");
					}

				}

				@loclines=();
				$num=$1;
			}

			if (defined $num){
				push(@loclines,$line);
			}
	
		}

	}
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
