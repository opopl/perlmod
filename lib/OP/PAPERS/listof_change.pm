package OP::PAPERS::listof_change;
# intro {{{

use strict;
use warnings;

use File::Basename;
use File::Copy;

use OP::Base qw/:vars :funcs/;

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw( 
    infile
    pname 
);

###__ACCESSORS_HASH
our @hash_accessors=qw( 
	packopts
	typeids 
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
	usedpacks
);

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

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

	push(@$opts,{ name => "part", "type" => "s", desc => "Part name, e.g. bln, blnpull etc."});
	push(@$opts,{ name => "dhelp", type => "" , desc => "Display old help"});
	push(@$opts,{ name => "pkey", "type" => "s", desc => "Paper key, e.g. HT92"});
	push(@$opts,{ name => "proj", "type" => "s", desc => "Project name, default is pap"});
	push(@$opts,{ name => "infile", "type" => "s", desc => "Input file name"});
	push(@$opts,{ name => "outfile", "type" => "s", desc => "Output file name"});
	push(@$opts,{ name => "type", "type" => "s", desc => "Type of the list-of stuff"});
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

	$self->{v}->{pkey}=$self->_opt_get("pkey");
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

	$self->typeids( 
			"figure"  		=> "fig",
			"table" 	 	=> "tab",
			"equation"  	=> "eq"
		);

	$self->pname("pap");

	$self->usedpacks( &readarr($self->pname . ".usedpacks.i.dat") );
	$self->packopts( &readhash($self->pname . ".packopts.i.dat"));
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
# dhelp() {{{

sub dhelp(){
	my $self=shift;

print << "HELP";
=========================================================
NAME:
	$FindBin::Script
PURPOSE: 
	In an *.lof, *.lot etc. file (Latex list-of-TYPEs file), 
	rename references to the TYPEs, so that the hyperlinks are correct 
USAGE: 
	$FindBin::Script --infile FILE --type TYPE
		FILE is the input *.lof file
		TYPE is the thing which "list-of" is changes, e.g.:
			fig, tab, eq etc.
SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}
# run() {{{

=head3 run()

=cut

sub run(){
	my $self=shift;

	my $TYPE=$self->_opt_get("type") // "figure";
	my $TYPEID=$self->typeids($TYPE);

	my $chline;
	my $pap_num;

	# "ms" means "matched string"
	my %ms;
	my $fig_num;
	my $infile_new=0;

	my($part,$proj,$pkey,$infile,$outfile);
		
###process_opts
	foreach my $var (qw( part proj pkey infile outfile )){
		my $s= '$' . $var . '=$self->_opt_get("' . $var  . '") // ' . "''" . ';';
		eval "$s";
		die $@ if $@;
	}

	unless($self->_opt_defined("outfile")){
		$infile_new=1;
		$outfile="$infile.new";
	}	

	die "Specify the input lof filename with the --infile option"
		unless $infile;

    unless(-e $infile){
        $self->say("Input file does not exit: $infile");
        exit 1;
    }

	open(INFILE,"<$infile") || die "Failed to open input file: $infile";

	if ($self->_opt_true("rw")){
		open OUTF,">$outfile" || die $!;
		select OUTF;
	}
	
	if ($self->_opt_true("debug")){
		$self->_opt_set("debug")
	}

	my $re={
		match_fig_line => 
		qr/
			^[ \t]*
			(?<start>
				\\contentsline[ \t]*\{$TYPE\}\{\\numberline[ \t]*
			)
				\{(?<pap_fig_label>.*)\}
				\{(?<middle>.*)\}
			\}
			\{(?<page_num>[0-9]*)\}
			\{$TYPE\.(?<old_fig_num>.*)\}/x
	};

	# spkey - short paper key
	my($spkey);
	
	while(<INFILE>){
			#{{{
			chomp; 
			next if /^\s*\\addvspace/;
		
			m/$re->{match_fig_line}/;
		
			if (defined($+{start})){
				%ms=%+;
				# get pkey, e.g., HT92 and fig_num ($TYPE number, e.g., 1  )
				$fig_num=$ms{pap_fig_label};

				$self->debugout_var("fig_num",$fig_num);

				( my $pkey = $+{pap_fig_label} ) =~ s/\-$TYPEID.*$//g ;

				my $prefix='';
				$prefix = $1 if ( $pkey =~ s/^(C-)//g );

				$fig_num =~ s/^.*\-fig//g ;
				chomp $pkey;

				# Command-line options to short_pap_key
				my $spopts="";
				my $spkey="";

				$spopts.=" --proj $proj " if $proj;
				$spopts.=" --pkey $pkey " if $pkey;

				$spkey=` short_pap_key $spopts `;
				$spkey=` short_pap_key $spopts --m usekdat ` unless $spkey;

				$self->_die("In op::listof_change::run(): Short paper key was not generated for $pkey ")
					unless $spkey;

				if ($proj && $part){
					$pap_num=` pap_num.pl --part $part --proj $proj --pkey $pkey `;
				}elsif($pkey){
					$pap_num="3";
				}
				chomp $pap_num;
				chomp $spkey;
				#print "$spkey $pkey\n";
				print "$ms{start}\{$prefix$spkey-$TYPEID$fig_num\}"
						."\{$ms{middle}\}\}"
						."\{$ms{page_num}\}"
						."\{$TYPE.$ms{old_fig_num}\}\n";
			}
			else{
				print "$_\n";
			}
		#}}}
	}
	
	close(INFILE);

	if ($self->_opt_true("rw") || $self->_opt_true("outfile") ){
		select STDOUT;

		if ($infile_new){
            unless (-e $outfile){
	                $self->warn("Output file does not exist: $outfile");
            }else{
	            use File::stat;
	            my $st = stat($outfile) or die "$!";
	
	            if ($st->size){
				    File::Copy::copy($outfile,$infile);
	            }else{
	                $self->warn("Zero file size");
	            }
            }
		}
	}

}
# }}}
# }}}

1;
