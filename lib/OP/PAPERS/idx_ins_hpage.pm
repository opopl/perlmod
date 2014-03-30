package OP::PAPERS::idx_ins_hpage;
# use ... dhelp() {{{

use strict;
use warnings;

use File::Basename;
use File::Slurp qw( read_file write_file edit_file );
use FindBin qw($Script $Bin);
use OP::Base qw/:vars :funcs/;

use parent qw(OP::Script);

#}}}
# subs {{{
# dhelp() {{{

sub dhelp(){
	my $self=shift;

print << "HELP";
=========================================================
PURPOSE: 
	In an *.idx file (Latex index file), insert |hyperpage statement
	(for the purposes of hyperlinking).
	If the statement is already included, nothing is inserted.
USAGE: 
	$Script FILE
		FILE is the input *.idx file
SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}
# }}}
# Methods  {{{

# Core {{{

=head2 Core methods 

=cut

# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts(){
	my $self=shift;

	$self->SUPER::set_these_cmdopts();

	my $opts=[];
	my $desc={};

	push(@$opts,{ name => "dhelp", type => "" , desc => "Display old help"});
	push(@$opts,{ name => "infile", "type" => "s", desc => "Input file name"});
	push(@$opts,{ name => "rw", 	desc => "Write the output the input " 
										." file provided with the --infile option"});

  	$self->add_cmd_opts($opts);
}
# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt(){
	my $self=shift;

	$self->SUPER::get_opt();
	$self->dhelp(),exit 0 if $self->_opt_true("dhelp");

}

# }}}
# main() {{{

=head3 main()

=cut

sub main(){
	my $self=shift;

	# Initialize variables
	$self->init_vars();

	# Read command-line arguments
	$self->get_opt();

	# 
	$self->run();

}

# }}}
# _begin() {{{

=head3 _begin()

=cut

sub _begin(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}
# }}}
# init_vars() {{{

=head3 init_vars()

=cut 

sub init_vars(){
	my $self=shift;

	$self->{v}->{pname}="pap";

	$self->{a}->{usedpacks}=&readarr($self->{v}->{pname} . ".usedpacks.i.dat");
	$self->{h}->{packopts}=&readhash($self->{v}->{pname} . ".packopts.i.dat");
}

# }}}
# print_help() {{{

=head3 print_help()

=cut

sub print_help(){
	my $self=shift;

	$self->SUPER::print_help();

}
# }}}

# }}}
# run() {{{

=head3 run()

=cut

sub run() {
	my $self=shift;

	my $infile=$self->_opt_get("infile");

	my $word="hyperpage";
	my $chline;

	$self->_die("Input file does not exist: $infile")
		unless -e $infile;
	
	my @lines=read_file $infile;

	my @newlines;
	
	foreach(@lines) {
		chomp; 
		next if /^[\t ]*\%/;

		my $line=$_;

		if ( /\|\(?$word/ || /\|\)/ ){
			push(@newlines,$line);
			next;
		};
	
		m/^[ \t]*(\\indexentry)\{([\t\-\\ \w\{\}\(\)\!\|]*)\}(\{[0-9]*\})$/g;

		if (defined($3)){
			$chline="$1\{$2\|$word\}$3";
			push(@newlines,$chline);
		}
		else{
			push(@newlines,$line);
		}
	}

	foreach my $line (@newlines) { $line.="\n"; }

	@newlines=sort @newlines;

	if ($self->_opt_true("rw")){
		$self->out("Rewriting the same input file...\n");
		write_file $infile, @newlines;
	}else{
		foreach my $line (@newlines) {
			print $line;
		}
	}
}

# }}}
# }}}

1;
