#!/usr/bin/env perl

use warnings;
use strict;

package op::mkdist;

use parent qw(OP::Script);
use Module::Starter;

sub _begin(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 
}

sub main(){
	my $self=shift;
	
	my $distros=[ qw( Bib2HTML ) ];
	
	my $mods={ 
		Bib2HTML => [ qw(
			Bib2HTML::Checker::Names
			Bib2HTML::General::Encode
			Bib2HTML::General::Error 
			Bib2HTML::General::HTML
			Bib2HTML::General::Misc 
			Bib2HTML::General::Title
			Bib2HTML::General::Verbose 
			Bib2HTML::Generator::AbstractGenerator
			Bib2HTML::Generator::DomainGen
			Bib2HTML::Generator::ExtendedGen
			Bib2HTML::Generator::FileWriter
			Bib2HTML::Generator::HTMLGen
			Bib2HTML::Generator::LangManager
			Bib2HTML::Generator::Lang
			Bib2HTML::Generator::SQLGen
			Bib2HTML::Generator::StdOutWriter
			Bib2HTML::Generator::Theme
			Bib2HTML::Generator::Writer
			Bib2HTML::Generator::XMLGen
			Bib2HTML::Generator::SqlEngine::MySql
			Bib2HTML::Generator::SqlEngine::PgSql
			Bib2HTML::Generator::Theme::Dyna
			Bib2HTML::Generator::Theme::Simple
			Bib2HTML::JabRef::JabRef
			Bib2HTML::Parser::BibScanner
			Bib2HTML::Parser::Parser
			Bib2HTML::Parser::Scanner
			Bib2HTML::Parser::StateMachine
			Bib2HTML::Main
			Bib2HTML::Parser::Parser 
			Bib2HTML::Release
			Bib2HTML::Translator::BibTeXEntry
			Bib2HTML::Translator::BibTeXName
			Bib2HTML::Translator::TeX
				)]
	};
	
	foreach my $distro (@$distros) {
		my $list_mods=$mods->{$distro} // '';

		next unless $list_mods;

		my $pars={
			distro 		=> "$distro",
			modules  	=> $list_mods,
			builder  	=> "Module::Build",
			verbose  	=> 1,
			force  		=> 1,
			email  		=> "op"
		};
		$self->out("Creating distribution: $distro");
		Module::Starter->create_distro(%{$pars});
	}
}

package main;

op::mkdist->new->main;

