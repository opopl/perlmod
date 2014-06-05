
package OP::perldoc2tex;

use strict;
use warnings;

=head1 NAME

OP::perldoc2tex - perldoc-to-LaTeX convertor module

=head1 SYNOPSIS

	#!/usr/bin/env perl 
	#
	use OP::perldoc2tex;
	
	OP::perldoc2tex->new->main;

=head1 INHERITANCE

	isa Class::Accessor::Complex
	isa OP::Script

=head1 ACCESSORS

=head2 Scalar

=over 4

=item * topic

=item * tex

=item * curtopic

=item * curtopicstring

=item * texdir

=item * texfile

=item * poddir

=item * topicstring

=back

=head2 Hash

=over 4

=item * files

=item * alltopics

=back

=cut

###use
use feature qw(switch);

use Env qw($hm);
use FindBin qw($Bin $Script);

use File::Basename qw(basename);
use File::Path qw( make_path );
use File::Spec::Functions qw(catfile);

use Getopt::Long;
use Pod::LaTeX::Plus;
use Data::Dumper;

use OP::Projs::Tex;
use OP::Base qw(readhash _join_dot run_cmd );

use PPI;
use Carp;

use parent qw( 
	OP::Script 
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	topic
	tex
	curtopic
	curtopicstring
	texdir
	texfile
	poddir
	topicstring
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
	files
	alltopics
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
	topics
	subsourcefiles
	texparts
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

sub set_these_cmdopts() {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts();

    my $opts = [];
    my $desc = {};

    push(
        @$opts,
        {
            name => "topic",
            desc => "perldoc topic to display",
            type => "s"
        },
        {
            name => "texfile",
            type => "s",
            desc => "name of the output LaTeX file",
        },
    );

    $self->add_cmd_opts($opts);

}

sub _begin {
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}

=head3 main
 
X<main,OP::perldoc2tex>
 
=head4 Usage
 
	main();
 
=head4 Purpose
 
=head4 Input
 
=over 4
 
=item * C< > 
 
=back
 
=head4 Returns
 
=head4 See also
 
=cut
 

sub main {
    my $self = shift;

    $self->init_vars;

    $self->get_opt;

    $self->process_opt;

	$self->_topics_update;

	$self->write_tex;

}

sub _module_write_tex {
	my $self=shift;

	my ($topic,$module,$prefix,$file);

	$topic=shift // $self->curtopic;

	my $tex=OP::Projs::Tex->new;

	if (-e $topic) {
		$file=$topic;
		$prefix = basename($topic) =~ s/\.(\w+)$//gr;

	}else{
		$module=$topic;

		my $res=run_cmd(command => "perldoc -l $module", verbose => 0 );
		if ($res->{ok}) {
			($file)=map { 
				chomp; my @vars=split(' ',$_); $vars[-1]; 
			} @{$res->{full_buf}};
		}else{
		}

		my $moddef = $module =~ s/::/-/gr;
		$prefix=$moddef;

	}

	if (not defined $file) {
		$self->warn("POD file is not defined for topicstring: " . $topic ) ;
		return;
	}

	if (not -e $file) {
		$self->_die("POD file does not exist for Perl topicstring: " . $topic ) ;
	}
	
	my @subnames;
	my %sublines;
	
	my $Document = PPI::Document->new($file) 
		or croak "Failed to PPI::Document->new for file: $file";

	$self->subsourcefiles_clear;

	for my $sub ( @{ $Document->find('PPI::Statement::Sub') || [] } ) {
		unless ( $sub->forward ) {
			push(@subnames,$sub->name);
			$sublines{ $sub->name } = $sub->content;
		}
	}

	foreach my $sub (@subnames) {

		my $texfile=catfile($self->texdir, 
			_join_dot($prefix,$sub, qw( subsource tex ))
		);

		$self->subsourcefiles_push($texfile);
	
		my $subname = $sub =~ s/(_)/\\$1/gr;
	
		$tex->_clear;
		$tex->ofile($texfile);
	
		$tex->clearpage;
		$tex->subsubsection($subname);
		$tex->_empty_lines;
		$tex->begin('lstlisting');
		$tex->_add_line($sublines{$sub});
		$tex->end('lstlisting');
	
		$tex->_writefile;
	
	}

	$self->subsourcefiles_uniq;
	$self->subsourcefiles_sort;

}

sub write_tex {
	my $self=shift;

	my $tex=OP::Projs::Tex->new;

	$self->tex($tex);

	$tex->ofile($self->files("tex_out")->());

    $self->write_tex_header;

    $self->write_tex_part([ $self->texparts ]);

    $self->write_tex_end;

	#------ other tex files -------------
    $self->write_tex_cfg;
}

sub write_tex_part {
	my $self=shift;

	my $tex=$self->tex;

	my $ref=shift;
	my $part;

	unless(ref $ref){
		$part=$ref;
	}elsif(ref $ref eq "ARRAY"){
		foreach my $part (@$ref) {
			$self->write_tex_part($part);
		}
		return;
	}

	$tex->part($part);
	$tex->_empty_lines;

	foreach my $topic (@{$self->topics}) {
		my $topicstring=$self->get_topicstring($topic);

		$self->curtopic($topic);
		$self->curtopicstring($topicstring);

		( my $c = $self->curtopicstring ) =~ s/-/::/g;
		$tex->chapter($c);

		for($part){
		    /^POD$/ && do { 
				$self->run_perldoc;
				$self->parse_pod;
				$self->write_tex_curtopic;
			    next;
			};
			/^SOURCE$/ && do { 
				$self->_module_write_tex;
				$self->write_tex_source;
			    next;
			};
		}
    	
	}

	$tex->_empty_lines;


}

sub write_tex_end {
	my $self=shift;

	my $tex=$self->tex;

	$tex->_add_line(<<'EOF');
\clearpage
\phantomsection
\addcontentsline{toc}{part}{\indexname}
\def\pagenumindex{\thepage}
\hypertarget{index}{}
\printindex

\end{document}

EOF


	$self->tex->_writefile;
}

sub write_tex_header_comments {
	my $self=shift;

	my $tex=$self->tex;

	my $date = localtime;

	$tex->_c_delim;
	$tex->_c("File:");
	$tex->_c("	" . $self->files("tex_out")->());
	$tex->_c("Purpose:");
	$tex->_c("	Latex file for the perldoc documentation");
	$tex->_c("Date created:");
	$tex->_c("	$date");
	$tex->_c("Creating script:");
	$tex->_c("	$Script");
	$tex->_c_delim;

}

sub write_tex_cfg {
	my $self=shift;

	my $tex=OP::Projs::Tex->new;

	$tex->ofile($self->files("tex_cfg")->());

	$tex->_add_line(<<'EOF');
\Preamble{html,frames,4,index=2,next,pic-equation,pic-eqnarray,pic-align,charset=utf-8,javascript}

\icfg{frames-two}
\icfg{tabular}
\icfg{common}
\icfg{picmath}

\begin{document}

\Css{div.lstlisting .ectt-1000 {font-family: monospace;color:blue}}
\Css{div.lstlisting .ecss-1000 {font-family: monospace;color:green}} 
\Css{div.lstlisting .ecbx-1000 {font-family: monospace;color:red}}

% basicstyle
\Css{div.lstlisting .cmtt-10 {font-family:monospace; color:DimGray}} 
% identifierstyle
\Css{div.lstlisting .cmss-10 {font-family:monospace; color:Black}} 
% keywordstyle
\Css{div.lstlisting .cmssbx-10 {font-family:monospace; color:Blue}} 
% commentstyle
\Css{div.lstlisting .cmr-10 {font-family:monospace; color:Green}} 
% stringstyle
\Css{div.lstlisting .cmti-10 {font-family:monospace; color:DarkRed}} 
% numberstyle
\Css{div.lstlisting .cmr-8 {display:inline-block; width:20px}}

\icfg{HEAD.showHide}
\icfg{TOC}

\EndPreamble
EOF

	$tex->_writefile;

}

sub write_tex_header {
	my $self=shift;

	my $tex=$self->tex;

	$self->write_tex_header_comments; 

	$tex->nonstopmode;
	
	$tex->def('PROJ','perldoc');
	$tex->input('_common.defs.tex');

	$tex->documentclass('book',{ opts => [qw( 10pt a4paper )]});

	$tex->ii([qw( packages hypersetup pagelayout )]);

	$tex->makeatletter;

	$tex->_add_line(<<'EOF');

\@ifpackageloaded{bookmark}{%
	\def\bmk#1#2{%
		\bookmark[#1]{#2}%
	}%
}{}

\renewcommand\paragraph{%
   \@startsection{paragraph}{4}{0mm}%
      {-\baselineskip}%
      {.5\baselineskip}%
      {\normalfont\normalsize\bfseries}}

EOF

	$tex->makeatother;
	$tex->nc('indexname','INDEX');

	$tex->_add_line(<<'EOF');

\setcounter{tocdepth}{5}
\setcounter{secnumdepth}{3}

\title{Perldoc}
\date{Last updated \today}

\makeindex

\begin{document}

\clearpage
\phantomsection
\hypertarget{toc}{}
%\label{toc}
\addcontentsline{toc}{chapter}{\contentsname}
\tableofcontents
\nc{\pagenumtoc}{\thepage}
\clearpage

EOF

}

sub init_vars {
	my $self=shift;

     #$self->texparts( qw(POD SOURCE) );
 	$self->texparts( qw(POD) );

	$self->poddir(catfile($hm,qw( doc perl pod )));

	make_path($self->poddir);

	$self->texdir(catfile(qw( /doc perl tex )));

	my $dat=catfile($hm,qw(config mk vimrc perldoc2tex_topicstrings.i.dat ));
	my $alltopics=readhash($dat,{ 'valtype' => 'array' });

	push(@{$alltopics->{perlfaq}},'perlfaq');
	foreach my $n ((1..9)) {
		push(@{$alltopics->{perlfaq}},'perlfaq' . $n );
	}

	$self->alltopics($alltopics);

}

sub process_opt {
	my $self=shift;

	$self->opts_to_scalar_vars(qw( topic texfile ));

	if ( not defined $self->topic ) {
	    $self->_die("topicstring is not specified!");
	}


	$self->topicstring($self->get_topicstring($self->topic));

	if ( not defined $self->texfile ) {
		$self->texfile($self->topicstring . '.tex');
	}

    $self->debugsay("topic to be processed: " . $self->topic );
    $self->debugsay("texfile: " . $self->texfile );

	$self->files( 
	    "tex_topicstring"    => sub { 
			catfile($self->texdir, "perldoc." . $self->curtopicstring . ".tex")
		},
	    "pod_topicstring"    => 
			sub { catfile($self->poddir,$self->curtopicstring . ".pod") },
	    "tex_out"      => 
			sub { catfile($self->texdir,$self->topicstring . ".tex") },
	    "tex_cfg"      => 
			sub { catfile($self->texdir,$self->topicstring . ".cfg.tex") },
	);

	if ( defined $self->texfile ) {
	    $self->files( "tex_out" => sub { $self->texfile } );
	}

}

sub get_topicstring {
	my $self=shift;

	my $topic=shift;

	my $topicstring;

	if ( $topic =~ m/^\s*-f\s+/ ) {
	    my @s = split( ' ', $topic );
	    $topicstring = $s[1];
	}
	else {
	    $topicstring = basename($topic) =~ s/\.$/_/gr;
	}

	$topicstring =~ s/::/-/g;

	$topicstring;

}

sub run_perldoc {
	my $self=shift;

	my $res=run_cmd(command => 
						"perldoc -u " 
							. $self->curtopic . " > "
				 			. $self->files('pod_topicstring')->(), 
					verbose => 0 );

	if($res->{ok}){
		
	}else{
		
	}

}

sub parse_pod {
	my $self=shift;

	my $parser = Pod::LaTeX::Plus->new();

	$parser->AddPreamble(0);
	$parser->AddPostamble(0);
	$parser->Head1Level(1);
	$parser->Label($self->topicstring);
	$parser->LevelNoNum(5);
	$parser->UniqueLabels(1);
	$parser->parse_from_file( 
		$self->files("pod_topicstring")->(), 
		$self->files("tex_topicstring")->(),
	);

}

sub _topics_update {
	my $self=shift;

	my $topic=$self->topic;

	if ($self->alltopics_exists($topic)) {
		$self->topics(@{$self->alltopics($topic)});
	}else{
		$self->topics($topic);
	}

}

sub write_tex_curtopic {
	my $self=shift;

	my $tex=$self->tex;

	$tex->_empty_lines;
	$tex->input( $self->files("tex_topicstring")->() );
	$tex->_empty_lines;

}

sub write_tex_source {
	my $self=shift;

	my $tex=$self->tex;

	foreach my $file (@{$self->subsourcefiles}) {
		$tex->input( $file );
	}

}

1;
