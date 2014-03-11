
package OP::perldoc2tex;

use strict;
use warnings;

use Env qw($hm);
use FindBin qw($Bin $Script);

use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use Getopt::Long;
use Pod::LaTeX;
use Data::Dumper;
use OP::TEX::Text;
use OP::Base qw(readhash);

use parent qw( 
	OP::Script 
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	what
	curwhat
	curtopic
	texdir
	texfile
	poddir
	topic
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
	files
	allwhats
);

###__ACCESSORS_ARRAY
my @array_accessors=qw(
	whats
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
            name => "what",
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

sub dhelp() {

    print << "HELP";
=========================================================
PURPOSE: 
  Convert perldoc help information into LaTeX files
USAGE: 
  $Script --what TOPIC --texfile TEXFILE 
OPTIONS:

  --what      perldoc topic to display

  --texfile   name of the output LaTeX file

EXAMPLES:
  
  $Script --what File::Slurp --texfile File-Slurp.tex

  The output of the 'cat' command on File-Slurp.tex shows:
HELP

    print << 'CAT';

% ===========================================
% File:
%   File-Slurp.tex
% Purpose:
%   Latex file for the perldoc documentation
% Date created:
%   Wed Sep 25 20:36:09 2013
% Creating script:
%   perldoc2tex.pl
% Command-line options for the creating script:
%   --what File::Slurp --texfile File-Slurp.tex
% ===========================================
\input{/home/op/templates/latex//perldoc.preamble.tex}

\chapter{File::Slurp}

\input{/home/op/doc/perl/tex/perldoc.File-Slurp.tex}
\input{/home/op/templates/latex//perldoc.end.tex}

CAT
    print << "HELP";

SCRIPT LOCATION:
  $0
=========================================================

HELP

}

sub _begin {
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}

sub main {
    my $self = shift;

    $self->init_vars;

    $self->get_opt;

    $self->process_opt;

	$self->_whats_update;

	foreach my $what (@{$self->whats}) {
		my $topic=$self->get_topic($what);

		$self->curwhat($what);
		$self->curtopic($topic);

    	$self->run_perldoc;

    	$self->parse_pod;
    	$self->write_tex;
	}

}

sub write_tex {
	my $self=shift;

	$self->write_texfile;

}

sub init_vars {
	my $self=shift;

	$self->poddir(catfile($hm,qw( doc perl pod )));

	make_path($self->poddir);

	$self->texdir(catfile($hm,qw( doc perl tex )));

	my $dat=catfile($hm,qw(config mk vimrc perldoc2tex_topics.i.dat ));
	my $allwhats=readhash($dat,{ 'valtype' => 'array' });

	push(@{$allwhats->{perlfaq}},'perlfaq');
	foreach my $n ((1..9)) {
		push(@{$allwhats->{perlfaq}},'perlfaq' . $n );
	}

	$self->allwhats($allwhats);

}

sub process_opt {
	my $self=shift;

	$self->opts_to_scalar_vars(qw( what texfile ));

	if ( not defined $self->what ) {
	    $self->_die("Topic is not specified!");
	}

	$self->topic($self->get_topic($self->what));

	if ( not defined $self->texfile ) {
		$self->texfile($self->topic . '.tex');
	}

	$self->files( 
	    "tex_topic"    => sub { 
			catfile($self->texdir, "perldoc." . $self->curtopic . ".tex")
		},
	    "pod_topic"    => 
			sub { catfile($self->poddir,$self->curtopic . ".pod") },
	    "tex_preamble" => "perldoc.preamble.tex",
	    "tex_end"      => "perldoc.end.tex",
	    "tex_out"      => catfile($self->texdir,$self->topic . ".tex"),
	);

	if ( defined $self->texfile ) {
	    $self->files( "tex_out" => $self->texfile );
	}

}

sub get_topic {
	my $self=shift;

	my $what=shift;

	my $topic;

	if ( $what =~ m/^\s*-f\s+/ ) {
	    my @s = split( ' ', $what );
	    $topic = $s[1];
	}
	else {
	    $topic = $what;
	}

	$topic =~ s/::/-/g;

	$topic;

}

sub run_perldoc {
	my $self=shift;



	system("perldoc -u " 
			. $self->curwhat . " > "
			. $self->files('pod_topic')->() );

}

sub parse_pod {
	my $self=shift;

	my $parser = Pod::LaTeX->new();

	$parser->AddPreamble(0);
	$parser->AddPostamble(0);
	$parser->Head1Level(1);
	$parser->Label($self->topic);
	$parser->LevelNoNum(5);
	$parser->UniqueLabels(1);
	$parser->parse_from_file( 
		$self->files("pod_topic")->(), 
		$self->files("tex_topic")->(),
	);

}

sub _whats_update {
	my $self=shift;

	my $what=$self->what;

	if ($self->allwhats_exists($what)) {
		$self->whats(@{$self->allwhats($what)});
	}else{
		$self->whats($what);
	}

}

sub write_texfile {
	my $self=shift;

	my $date = localtime;

	my $tex=OP::TEX::Text->new;

	$tex->ofile($self->files("tex_out"));

	$tex->_c_delim;
	$tex->_c("File:");
	$tex->_c("	" . $self->files("tex_out"));
	$tex->_c("Purpose:");
	$tex->_c("	Latex file for the perldoc documentation");
	$tex->_c("Date created:");
	$tex->_c("	$date");
	$tex->_c("Creating script:");
	$tex->_c("	$Script");
	$tex->_c_delim;

	$tex->input($self->files("tex_preamble"));

	foreach my $what (@{$self->whats}) {
		$self->what($what);

		my $topic = $what =~ s/::/-/gr;

		$tex->chapter($self->what);
		$tex->_empty_lines;
		$tex->input( $self->files("tex_topic")->() );
		$tex->_empty_lines;
	}
	$tex->input($self->files("tex_end"));

	$tex->_writefile;

}

1;
