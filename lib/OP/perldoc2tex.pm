
package OP::perldoc2tex;

use strict;
use warnings;

use FindBin qw($Bin $Script);
use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use Getopt::Long;
use Pod::LaTeX;
use OP::TEX::Text;
use Env qw($hm);

use parent qw( 
	OP::Script 
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	what
	texdir
	temdir
	poddir
	topic
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
	files
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

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

sub main() {
    my $self = shift;

    $self->init_vars;

    $self->get_opt;

    $self->process_opt;
    $self->run_perldoc;
    $self->parse_pod;
    $self->write_tex;


}

sub write_tex {
	my $self=shift;

	$self->write_texfile;

}

sub init_vars {
	my $self=shift;

	$self->temdir(catfile($hm, qw( templates latex )));
	$self->poddir(catfile($hm,qw( doc perl pod )));

	make_path($self->poddir);

	$self->texdir(catfile($hm,qw( doc perl tex )));



}

sub process_opt {
	my $self=shift;

	if ( !$self->_opt_true("what") ) {
	    die "Topic is not specified!\n";
	}

	$self->what( 
			$self->_opt_get("what"));

	$self->get_topic;

	$self->files( 
	    "tex_topic"    => catfile($self->texdir,
				"perldoc." . $self->topic . ".tex"),

	    "tex_preamble" => "perldoc.preamble.tex",
	    "tex_end"      => "perldoc.end.tex",
	    "tex_out"      => catfile($self->texdir,$self->topic . ".tex"),
	    "pod_topic"    => catfile($self->poddir,$self->topic . ".pod"),
	);

	if ( $self->_opt_true("texfile") ) {
	    $self->files( 
			"tex_out" => $self->_opt_get("texfile") );
	}

}

sub get_topic {
	my $self=shift;

	my $topic;

	if ( $self->what =~ m/^\s*-f\s+/ ) {
	    my @s = split( ' ', $self->what );
	    $topic = $s[1];
	}
	else {
	    $topic = $self->what;
	}

	$topic =~ s/::/-/g;

	$self->topic($topic);

}

my $poddirs = ("/usr/share/perl/5.10.1/pod");


###run_perldoc

sub run_perldoc {
	my $self=shift;

	system("perldoc -u " 
			. $self->what . " > "
			. $self->files("pod_topic"));

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
		$self->files("pod_topic"), 
		$self->files("tex_topic") );

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
	$tex->chapter($self->what);
	$tex->_empty_lines;
	$tex->input($self->files("tex_topic"));
	$tex->input($self->files("tex_end"));

	$tex->_writefile;

}

1;
