
package OP::PAPERS::mktex;

use strict;
use warnings;

use File::Basename;
use File::Path qw(mkpath);
use File::Slurp;
use Getopt::Long::Descriptive;

use FindBin qw($Bin $Script);

use OP::Base qw( 
    readarr 
    readhash
);

###our
our $opt;
our $usage;
our $pref=$Script . ">";
our %bibplace;
our($target,$desc);
our(%flags);
our($texexe,$texopts);

our(%fold);

#folds {{{
%fold=( 
	o => "{{{",
	c => "}}}",
);

my $fo=$fold{o};
my $fc=$fold{c};

#}}}

our(%nc);
our(%pdfopts);
our($bibfile);
our($bibstyle);
our($varname);
our($ndelim);
our(@papers);
our($pname,@pnames,%parts,@trg,%pall,%ttex,%pdftargets);
our(%figs,%tabs);
our($printend);
our($time);
our($pfile,$hsfile,$bkfile);
our($pdftitle);

our %files=( 
	vars	=>	"vars.i.dat"
);
our(@used_packages,%packopts,@optpacks);
our($maintitle);
# --sec, e.g. blnall, pullex etc.
our($sec);
# those sections which contribute to $pname
our(@sects);
our $author="op";
our @F;
our(%vars);

###subs


=head3 init_vars

=cut

sub init_vars {
	# define in the perl-script
	# $pname, files {{{
    %vars=readhash($files{vars});

	$vars{"texexe"}="latex";
	$vars{"texopts"}='--nosafe';
	$texexe=$vars{"texexe"};
	$texopts=$vars{"texopts"};
	
	$pname=$vars{"pname"};
	@pnames=$vars{"pnames"};
	$bibfile=$vars{"bibfile"};

	$bibstyle=$vars{"bibstyle"};

	$pfile="$pname.tex";
	$bkfile="$pname-bookmarks.tex";
	$hsfile="$pname-hypsetup.tex";

	# }}}
	# %flags {{{
	%flags=(
		print_index	=> 1,
		print_title	=> 0
	);
	# }}}
	# %tabs {{{
	%tabs=( 
		#"pf.gopairs"  =>	"List of native contacts in the Go-like model",
		"res.bln.g46.ef"	  			=> 	"Go-like model, lowest energy vs applied force",
		"res.bln.g46.ef.full"	  		=> 	"--//--, with job numbers",
		"res.bln.g46.zf.le"		=>	"BLN model, lowest energy conformations "
	);
	# }}}
	# %figs {{{
	
	my %figs_res=( 
		"res.bln.gopairs"			=> "(bln.0.1) Native-state contacts",
		"res.bln.g46.ns" 			=> "(bln.1.1) Different three-dimensional views on the BLN native state",
		"res.bln.g46.zf.le"			=> "(bln.1.2) Lowest energy conformations",
		"res.bln.g46.nzf"			=> "(bln.2.1) Non-zero force conformations"
	);
	
	my %figs_pes=( 
	    "pes.rate-theory"		=> "Transition state theory",
		"pes.MLtheorem"			=> "Illustration for the Murrel-Laidler theorem",
		"pes.1d-dg"				=> "1D energy landscapes and the related disconnectivity graphs",
		"pes.1d-bh"				=> "Basin-hopping transformation for a 1D energy landscape"
	);
	my %figs_pf=( 
		"pf.bln.dihedral.angle" => "Dihedral angle definition",
		"pf.dgbln" 				=> "Disconnectivity graphs for the Go-like and WT models",
	);
	
	%figs=( %figs_res );
	#}}}
	# %parts {{{

	open(S,"<$pname.parts.i.dat") or die $!;
	while(<S>){ chomp; next if ( /^#/ || /^[\t\s]+$/ ); 
			my @F=split;
			my $key=shift @F;
			my $val=join(' ',@F);
			if (defined($key) && defined($val)){ $parts{$key}=$val; }
	}
	close S;
	#}}}
	# %ttex {{{
	#open(S,"<$pname.ttex.i.dat") or die $!;
	open(S,"<ttex.i.dat") or die $!;
	while(<S>){ 
		chomp; 
		next if ( /^#/ || /^[\t\s]+$/ ); 
		@F=split;
		my $key=shift(@F);
		my $val=join(' ',@F);
		if (defined($key)){ $ttex{$key}=$val;}
	}
	close S;
	#}}}
	# @sects @papers {{{
	
	open(S,"<$pname.sects.i.dat") or die $!;
	while(<S>){ chomp; next if ( /^#/ || /^[\t\s]+$/ ); push(@sects,$_); }
	close S;
	
	#}}}
	# sort: %key_sort {{{
	#}}}
	# latex_packages {{{
	
	# used packages
	open(UP,"<$pname.usedpacks.i.dat") or die $!;
	while(<UP>){ 
		chomp; 
		next if ( /^#/ || /^[\t\s]+$/ ); 
		@F=split;
		push(@used_packages,@F); 
		if ( grep { "perltex" eq $_ } @F ){ 
			$vars{"texexe"}="perltex";
			$texexe="perltex";
			$texopts="--nosafe";
			eval `ch texexe $texexe`;
			#eval `ch texopts $texopts`;
		}
	}
	close UP;
	
	# package options
	open(PO,"<$pname.packopts.i.dat") or die $!;
	while(<PO>){ 
		chomp; 
		next if ( /^#/ || /^[\t\s]+$/ ); 
		@F=split;
		my $key=shift(@F);
		my $val=join(' ',@F);
		if (defined($key)){ $packopts{$key}=$val;}
	}
	close PO;
	# }}}
	# nc (new commands) {{{
	# defnc  \nc
	eval `cat nc.i.pl | sed '/^#/d'`;
	
	# }}}
	# other {{{
	
	$maintitle="Pulling a protein: a basin-hopping search for the global energy minimum";
	
	$ndelim=50;
	
	%pdftargets=( 
		%parts
	);
	
	%pall=( %pdftargets, $pname => "1-year report", %figs, %tabs, %ttex );
	
	@trg=keys %parts;
	
	# \defbibplace \bibplace
	for my $t (@trg){ $bibplace{$t}="each"; }
	#for my $t (@trg){ $bibplace{$t}="common"; }
	# }}}
}
#}}}
# get_papers() {{{

=head3 get_papers()

=cut

sub get_papers {
	my	@papers=grep { !/^\s*$/ } map { m/^p\.([^\.]*)\.tex$/ && $1 } glob("p.*.tex");
	my %files;
	my($pname,$sec)=@_;

	if (defined $sec){
		$files{paps}="$pname.paps.$sec.i.dat";
		if (!-e $files{paps})
		{
			warn "$pref No file with papers for the section: $sec\n";
		}else{
			@papers=@{&readarr("$files{paps}")};
		}
	}
	return \@papers;
}
# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt {

	# describe_options() {{{
	
	if ( !@ARGV ){ 
		print "Type --help for more help\n";
		exit 0;
	}else{
		($opt,$usage)=Getopt::Long::Descriptive::describe_options(
			 "$FindBin::Script %o",
				[ "isec",	"" ],
				[ "listtex", "List available TeX target names" ],
				[ "listlong",  "" ],
				[ "listsects",  "" ],
				[ "list|l",  "" ],
				[ "listpapers",  "" ],
				[ "listvars",  "List variables defined through vars.i.dat" ],
				[ "target|t=s", "" ],
				[ "help|h", "Display this help message" ],
				[ "bib=s", "" ],
				[ "bibstyle=s", "" ],
				[ "pname=s", "" ],
				[ "var=s", "" ],
				[ "papers=s", "" ],
				[ "sec=s",  "" ],
				[ "use=s", "" ]
			);
	
			print($usage->text), exit if $opt->help;
				
			$sec=$opt->sec if defined $opt->sec;
	
			@papers=@{$opt->papers} if defined $opt->papers;
			@optpacks=@{$opt->use} if defined $opt->use;
	
			@papers=@{&get_papers($pname,$sec)};
	
	#}}}
# --var {{{

if (defined($opt->var)){
	if(defined($vars{$opt->var})){
		if ($opt->var eq "ltmopts"){
			my $val=$vars{$opt->var};
			if ($val ne ""){
				$val =~ s/(\w+)/--$1/g;
				print "--$val\n";
			}
		}else{
			print $vars{$opt->var} . "\n";
		}
		exit 0;
	}
}
# }}}
	# --listlong --list --listtex --listpapers {{{
	
	if ($opt->listlong ){
			my $fmt2="%20s %20s";
			print "=" x $ndelim . "\n";
			printf($fmt2, "Target",	"Description\n");
			print "=" x $ndelim . "\n";
			for my $t (keys %pdftargets) {
				printf($fmt2, "$t", "$pall{$t} \n");
			}
			print "=" x $ndelim . "\n";
			exit;
	} 
	
	if ($opt->listvars ){
			for my $var (keys %vars) {
				print "$var\n";
			}
			exit;
	} 

	&get_papers();

	if ($opt->listpapers ){
			for my $p (@papers) {
				print "$p \n";
			}
			exit;
	}
	if ($opt->list) {
			for my $t (keys %pdftargets) {
				print("$t\n");
			}
			exit;
	} 
	if ($opt->listsects) {
			for my $t (@sects) {
				print("$t\n");
			}
			exit;
	} 
	if ($opt->listtex){
			for my $t (keys %ttex) {
				print("$t\n");
			}
			exit;
	}
	#}}}
	# process latex packages {{{
	
	# s_pack: package name
	# s_opt: string with package options
	
	my($s_opt,$s_pack);
	for my $optpack(@optpacks){
		$optpack =~ m/^(\w+)\s*\[\s*(\w+)\s*\]/g ;
		if (defined($1)){ $s_pack=$1; push(@used_packages,$s_pack); }
		if (defined($2)){ $s_opt=$2; $packopts{$s_pack}=$s_opt; }
	}
	
	# }}}
	# get the target name, and relevant properties {{{
		
		 if(defined $opt->target){
		 	$target=$opt->target;
		}else{
			die "Target is not defined!\n";
		 }
		 $desc="$pall{$target}";
		 $bibplace{$target}=$opt->bib; 
		 #if ( grep { $_ eq $target } @trg ) { $bibplace{$target}=$opt->bib; }
	#}}}

 }
 }
#}}}
# hx() dhelp() {{{
sub hx { &dhelp(@_); exit; }
# \\dhelp
sub dhelp {
# print help message {{{
	my $htopic=$_[0];
	if  ( ( defined($htopic) && ( $htopic =~ /^[all]?$/ ) ) || ( ! defined($htopic) )) {
		# all help {{{
print STDERR << "HELPALL";
=========================================================
PURPOSE: 
	Generate a tex file from an input target specifier
USAGE: 
	$Script T
		T is a target, one of the following:
			@trg
OPTIONS:
	-l, --list			List all targets to standard output
	-t, --target T		Print a tex file, corresponding to 
							target T, to standard output

	--listtex			List tex-targets

DEFAULTS:
			
SCRIPT LOCATION:
	$0
=========================================================

HELPALL
#}}}
	}	
	elsif ( $htopic eq "%figs" ){
	#{{{
	for my $k (keys %figs) {
		print "$k\t $figs{$k}\n";
	}
#}}}
	}
	elsif ( $htopic eq "\%parts" ){
			for my $k (keys %parts) {
				print "$k\t $parts{$k}\n";
			}
	}
}
#}}}
#}}}

sub printtex {

# header - for all targets  {{{

$time=localtime;

print << "eof";
% Time: $time;
% Target: $target;
% Description: $desc;
% 
eof
#}}}
# process $target {{{
# \target 
# $pname, @trg {{{ 

if ( ( grep { $_ eq $target } @trg ) || ( $target eq $pname ) ){
	$printend=1;
print << "eof";
\\input{$pname-preamble}
\\begin{document}
eof

	if ( $target eq $pname ){
		# {{{
		for my $t (qw( start )){
			if ( -e "$pname-$t.tex" ) { print "\\inpp{$t}\n"; }
		}
		for my $t (@sects){ 
			if ( -e "nc.$pname-$t.tex" ){ print "\\inpnc{$t}"; }
			if ( -e "bib.$pname-$t.tex" ){ 
			}
			if ( -e "$pname-$t.tex" ){ print "\\inpp{$t}\n"; }
		}

		if ( -e "$pname-bib.tex" ) { print "\\input{$pname-bib}\n"; }
		for my $t (qw( end bm )){
			if ( -e "$pname-$t.tex" ) { print "\\inpp{$t}\n"; }
		}
		# }}}
	}else{
		for my $t (qw( start nc )){
            if ( -e "$t.$pname-$target.tex" ) { print "\\inp$t"."{$target}\n"; }
        }
		print "\\inpp{$target}\n";
		if ( -e "bib.$pname-$target.tex" ){
				print "\\inpbib{$target}\n";
		}
		
		for my $t (qw( bm end )){
            if ( -e "$t.$pname-$target.tex" ) { print "\\inp$t"."{$target}\n"; }
        }
		# pap: write the target file pap-TARGET.tex file {{{

		if ($pname eq "pap"){
			open(PFILE,">$pname-$target.tex");
		 	# loop over papers in $pname.paps.*.i.dat 	 {{{
			# 
			# @tpaps - this array contains all the papers 
			# 			associated with the given $sect.
			# 
			# 			The below line reads in the paper keys from e.g. pap.sects.bln.i.dat file
			# 			commented lines ('#'), and also lines with spaces only are ignored are ignored
			my @tpaps=map { ( /^[ \t]*#/ || /^[\t\s]+$/ ) ? () : split } 
					read_file("$pname.paps.$target.i.dat");
			# now include the given paper tex-file, e.g. "p.HT92.tex" into "pap.tex"
			for my $p (@tpaps){ 
				if (-e "p.$p.nc.tex"){ 
					print PFILE "\\ipnc{$p} \n";
				}
				if (-e "p.$p.tex"){ 
					print PFILE "\\ipnc{$p} \n";
				}
				# the paper to be included does not yet exist, so 
				# create all the necessary files anew, using the 'nwp' script.
				else{
					_say("File p.*.tex doesn't exist for: $p");
					_say("Creating anew p.*.tex file for: $p");
					system("$Bin/nwp $p");
				}
				print PFILE "\\ip{$p} \n";
			}
			# }}}
			# include anything else needed for the given $target
			my $f="$pname.sects.$target.i.dat";
			if ( -e $f ){
					my @tsects=map { ( /^[ \t]*#/ || /^[\t\s]+$/ ) ? () : split } 
						read_file("$f");
						foreach(@tsects){ 
							print PFILE "\\inpp{$target.$_}\n";
						}
			}
						close(PFILE);
		}
		#}}}
	}
}
#}}}
# fig.tex, tab.tex {{{ 
elsif ( $target eq "fig.tex" ){ # {{{
	$printend=0;
print << "eof";
\\phantomsection
\\pdfbookmark[0]{Figures}{figs}
eof
	for my $fig (keys %figs){
		print "% $figs{$fig}\n";
		print "\\clearpage\\inpfig{$fig}\n";
	}
} # }}}
elsif ( $target eq "tab.tex" ){ # {{{

print << "eof";
\\phantomsection
\\pdfbookmark[0]{Tables}{tabs}
eof
	$printend=0;
	for my $tab (keys %tabs){
		print "% $tabs{$tab}\n";
		print "\\clearpage\\inptab{$tab}\n";
	}
} # }}}
#}}}
# ft.tex {{{
elsif ( $target eq "ft.tex" ){ 
	$printend=0;
#tables {{{
print << "eof";
\\phantomsection
\\pdfbookmark[0]{Tables}{tabs}
eof
	for my $tab (sort keys %tabs){
		print "% $tabs{$tab}\n";
		print "\\clearpage\\inptab{$tab}\n";
	}
#}}}
print << "eof";
\\phantomsection
\\pdfbookmark[0]{Figures}{figs}
eof
	#while ( my ($fig, $dsc) = each(%figs) ) {
	for my $fig (keys %figs){
		print "% $figs{$fig}\n";
		print "\\clearpage\\inpfig{$fig}\n";
	}
}
# }}}
# nc {{{
# \printnctex
elsif ( $target eq "nc.tex" ){ eval `cat print.nc.i.pl`; }
elsif ( $target eq "bib.tex" ){ eval `cat print.bib.i.pl`; }
elsif ( $target eq "bm.tex" ){ eval `cat print.bm.i.pl`; }
elsif ( $target eq "end.tex" ){ eval `cat print.end.i.pl`; }
elsif ( $target eq "start.tex" ){ eval `cat print.start.i.pl`; }
elsif ( $target eq "preamble.tex" ){ &print_preamble(); }
elsif ( $target eq "hypsetup.tex" ){ &print_hypsetup(); }

# }}}
# }}}
# bib bookmarks end {{{
if ($printend){
	#if ( $bibplace{$target} eq "common" ){ print "\\inpp{bib}\n"; }
print << 'eof';
\end{document}
eof
}
# }}}
}

sub print_preamble {
	#{{{
	my($s_opt,@inp,@inpp);
	$printend=0;

	@inp=qw( nc preamble.tocloft ); push(@inp,"$pname-nc");
	@inpp=qw( hypsetup preamble.0 );

	print "\\documentclass[12pt,a4paper,dvips]{report}\n\n";
	for my $package ( @used_packages ){
		$s_opt=$packopts{$package};
		if (defined($s_opt)){ print "\\usepackage[$s_opt]{$package}\n"; }
		else { print "\\usepackage{$package}\n"; }
	}
	print "\n";
print << 'eof';
\sloppy
\def\baselinestretch{1}
\setcounter{page}{1}
eof
	if ($flags{print_index}){ print "\\makeindex\n";}
	print "\n";
	print "\\title{$maintitle}\n\n";
	for my $i (@inp){ print "\\input{$i}\n"; }
	print "\n";
	for my $i (@inpp){ print "\\inpp{$i}\n"; }
	print "\n";
#}}}
}

sub print_hypsetup {
	#{{{
	%pdfopts=(
		title 	=> "$pname"."_$sec",
		author	=> "$author"
	);
	if ($sec eq $pname ) { $pdfopts{title}="$pname"; }
print << "eof";
\\ifpdf
\\pdfinfo{
   /Author ($author)
   /Title  ($sec)
}
\\else
\\hypersetup{
	pdftitle={$pdfopts{title}},
	pdfauthor={$pdfopts{author}},
	pdfsubject={},
	pdfkeywords={},
	bookmarksnumbered,
	hyperfigures=true,
	bookmarksdepth=subparagraph,
%	pdfstartview={FitH},
%	citecolor={blue},
%	linkcolor={red},
%	urlcolor={black},
%	pdfpagemode={UseOutlines},
%	plainpages=false,
%	hyperindex=false
}
\\fi
eof
#}}}
}

sub set_flags {
	my $t=shift;
	
	if (defined($t)){
		if ($t eq "rep"){
			%flags=(
				print_index			=> 1,
				print_title			=> 1,
				print_abs			=> 1
			);
		}elsif($t eq "abs"){
			%flags=(
				print_index			=> 0,
				print_title			=> 1,
				print_abs			=> 0
			);
		}elsif(grep { /^$t$/ } qw( blnpull ) ){
			%flags=(
				include_own_start_page	=>	1
			);
		}
	}
}

sub main {

	init_vars;
	get_opt;
	set_flags($sec);
	printtex;
}

1;
