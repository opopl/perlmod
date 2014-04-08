
package OP::PAPERS::mktex;

use strict;
use warnings;

###use
use Exporter ();

use File::Basename;
use File::Path qw(mkpath);
use File::Slurp qw(read_file);
use Getopt::Long::Descriptive;
use Data::Dumper;

use FindBin qw($Bin $Script);

use OP::Base qw( 
    readarr 
    readhash
);

use OP::Script::Simple qw( _say );
use OP::PAPERS::chvar;

###our
our @ISA     = qw(Exporter);
our @EXPORT_OK = qw( main);
our @EXPORT  = qw( );
our $VERSION = '0.01';

our $opt;
our $usage;
our $pref=$Script . ">";
our %bibplace;
our($target,$desc);
our(%flags);

our(%fold);

%fold=( 
	o => "{{{",
	c => "}}}",
);

our $fo=$fold{o};
our $fc=$fold{c};

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

our %files;
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
sub dhelp;
sub get_opt;
sub get_papers;
sub hx;
sub init_vars;
sub main;
sub print_hypsetup;
sub print_preamble;
sub printtex;
sub print_bm;
sub print_bib;
sub print_end;
sub print_nc;
sub print_start;
sub set_flags;

=head3 init_vars

=cut

sub init_vars {

    %files=( 
	    vars	=>	"vars.i.dat"
    );
    %vars=readhash($files{vars});

	$pname=$vars{"pname"};
	@pnames=$vars{"pnames"};
	$bibfile=$vars{"bibfile"};

	$bibstyle=$vars{"bibstyle"};

	$pfile="$pname.tex";
	$bkfile="$pname-bookmarks.tex";
	$hsfile="$pname-hypsetup.tex";

	%flags=(
		print_index	=> 1,
		print_title	=> 0
	);

	%tabs=( 
		#"pf.gopairs"  =>	"List of native contacts in the Go-like model",
		"res.bln.g46.ef"	  			=> 	"Go-like model, lowest energy vs applied force",
		"res.bln.g46.ef.full"	  		=> 	"--//--, with job numbers",
		"res.bln.g46.zf.le"		=>	"BLN model, lowest energy conformations "
	);
	
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

    %parts=readhash("$pname.parts.i.dat");
    %ttex=readhash('ttex.i.dat');
	
    @sects=readarr("$pname.sects.i.dat");
	
    @used_packages=readarr("$pname.usedpacks.i.dat");

	if ( grep { "perltex" eq $_ } @used_packages ){ 
        unless($vars{"texexe"} eq "perltex"){
			$vars{"texexe"}="perltex";
	        OP::PAPERS::chvar::main('texexe' ,'perltex' );
        }
	}

    %packopts=readhash("$pname.packopts.i.dat");

    %nc=( 
	    "min" => {  
			"ak" 	=> '\alpha_k',
			"xk" 	=> 'x_k',
			"pk" 	=> 'p_k',
			"xlong"	=> '(x_1,\ldots,x_n)',
			'gk'	=> '\nabla f_k'
	    },
    );
	
	$maintitle="Pulling a protein: a basin-hopping search for the global energy minimum";
	
	$ndelim=50;
	
	%pdftargets=( 
		%parts
	);
	
	%pall=( %pdftargets, $pname => "1-year report", %figs, %tabs, %ttex );
	
	@trg=keys %parts;
	
	# \defbibplace \bibplace
	for my $t (@trg){ $bibplace{$t}="each"; }
}

=head3 get_papers

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
			@papers=readarr("$files{paps}");
		}
	}
	return \@papers;
}

=head3 get_opt

=cut

sub get_opt {

	unless( @ARGV ){ 
		print "Type --help for more help\n";
		exit 0;
	}else{
		($opt,$usage)=Getopt::Long::Descriptive::describe_options(
			 "$Script %o",
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

sub hx { dhelp(@_); exit; }

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
			my @tpaps= readarr("$pname.paps.$target.i.dat");
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
				my @tsects=readarr("$f");
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
elsif ( grep { /^$target$/ } map { $_ . '.tex' } qw( nc bib bm end start preamble hypsetup ) ){ 
    my $id = $target =~ s/\.tex$//gr;
    eval 'print_' . $id; 
    die $@ if $@;
}

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

sub print_end {

	if ($flags{print_index}){ 

	print << "eof";
\\clearpage
\\phantomsection
\\nc{\\pagenumindex}{\\thepage}
\\hypertarget{index}{}\n
\\addcontentsline{toc}{chapter}{Index}
\\printindex
eof

	}

}

sub print_bib {

	my(%bib);
	
	%bib=( 
		name	=>	"Bibliography",
		style	=>	"thesis",
		#file	=>	"$pname-$sec"
		file	=>	"$bibfile"
	);
	
	if (defined($opt->bibstyle)){
		$bib{style}=$opt->bibstyle;
	}
	
	if ($sec eq $pname){
		$bib{file}= "$bibfile";
	}
	
	print << "eof";

%\\cleardoublepage
\\phantomsection
\\hypertarget{bib}{}

\\addcontentsline{toc}{chapter}{$bib{name}}

\\bibliographystyle{$bib{style}}
\\input{jnames}
%\\nc{\\pagenumbib}{\\thepage}
\\bibliography{$bib{file}}

eof
}

sub print_nc {

	# definitions and variables {{{

	my($nnc,$s_nc);
	my(@bnc,@inpnc,@refnc,%refnames);

	@inpnc=qw( p fig tab eq bib nc bm start end alg ap );
	@refnc=qw( eq tab fig alg sec ap bp );
	%refnames=(
			"eq"		=>	"Eq.",
			"tab"		=>	"Table",
			"fig"		=> 	"Fig.",
			"alg"		=> 	"Algorithm",
			"sec"		=> 	"Section",
			"ap"		=> 	"Appendix",
			"bp"		=> 	"Page"
	);
	#}}}

	print "% Section: $sec \n\n";

# base {{{
	if ( $sec eq "base" ){
# initial  {{{

print << 'eof';
\nc{\nn}{\nonumber}

\newcommand{\loeq}{List of Equations}
\newlistof{myeq}{equ}{\loeq}

\newcommand{\myeq}[1]{%
\addcontentsline{equ}{myeq}{\protect\numberline{\theequation}#1}\par}

eof
# }}}

if ($pname eq "rep"){
	for my $c (@refnc){ 
		print "\\nc{\\ref$c}[1]{$refnames{$c}\ \\ref{$c\:#1}}\n"; 
		print "\\nc{\\label$c}[1]{\\label{$c\:#1}\\hypertarget{$c\:#1}{}}\n"; 
	}
}elsif($pname eq "pap"){
	for my $c (@refnc){ 
		print "\\nc{\\ref$c}{}\n"; 
		print "\\nc{\\label$c}{}\n"; 
	}
}
for my $c (@inpnc){ print "\\nc{\\inp$c}{}\n"; }
# @bnc: bare (empty) new commands
my @bnc=qw( fn rkey hl );
for my $c (@bnc){ print "\\nc{\\$c}{}\n"; }

}

# }}}
# $pname {{{
	
	if ( $sec eq "rep" ){
		print "\\rnc{\\fn}{$pname}\n\n";
		for my $c (@inpnc){
			my $c1="$c\.";
			if ($c eq "p"){ $c1=""; }
				print "\\rnc{\\inp$c}[1]{\\input{$c1\\fn-#1}}\n";
		}
	}
	if ( $sec eq "pap" ){

print << "eof";
\\rnc{\\fn}{$sec}
\\rnc{\\inpp}[1]{\\input{\\fn-#1}}
\\nc{\\ipnc}[1]{\\input{p.#1.nc.tex}}
eof

	@inpnc=qw( bib nc bm start end );
	for my $c (@inpnc){
			my $c1="$c\.";
			if ($c eq "p"){ $c1=""; }
			print "\\rnc{\\inp$c}[1]{\\input{$c1\\fn-#1}}\n";
	}

	print "\\input{$sec-nc.0.tex}\n";

	}
	#}}}
	# min {{{
	if ($sec eq "min"){
#print << 'eof';
#%\DeclareMathOperator{\min}{min}
#%\operatorname{rank}
#eof
	}
	# }}}
	# print out %nc defined in nc.i.pl {{{
	if (defined($nc{$sec})){ 
		my %nc1=%{$nc{$sec}};
		my $nnc="";
		for my $k (keys %nc1) {
			( $s_nc=$nc1{$k} ) =~ s/^\s*\[(\w+)\]//g;
			if (defined($1)){ $nnc="[$1]"; }else{ $nnc=""; }
			print "\\nc{\\$k}$nnc\{$s_nc\}\n";
		}
	}
	# }}}
}

sub print_bm {

	print "\\bookmark[level=0,named=FirstPage]{Bookmarks}\n";
	
	my(%bmid,%bm,@usedbm,%lst1,%nm,$bm_opt,@bm_opts);
	
	@usedbm=qw( abs title lof lot loeq loa toc bib index ); 
	
	# define %bm %bmid {{{
	%bm=(
		"lof"	=> "List of figures",
		"loa"	=> "List of algorithms",
		"loeq"	=> "List of equations",
		"lot"	=> "List of tables",
		"toc"	=> "Table of contents",
		"bib"	=> "Bibliography",
		"title"	=> "Title",
		"abs"	=> "Abstract",
		"index"	=> "Index"
	);
	
	%bmid=( 
		"lof"	=> "fig",
		"lot"	=> "tab",
		"loa"	=> "alg",
		"loeq"	=> "eq"
	);
	# }}}
	if ($pname eq "pap"){
		@usedbm=qw( lof lot loeq loa toc bib index ); 
		if ($sec eq "blnpull"){
			push(@usedbm,"title");
		}
	}
	
	if ( $sec eq "$pname" ){  
		@usedbm=qw( abs title toc lof lot loa bib index ); 
	}
	
	if ( $sec eq "abs" ){  
		@usedbm=qw( abs title bib ); 
	}
	if ( grep { $_ eq $sec } qw( in pes pf ) ){
		@usedbm=qw( bib toc ); 
	}
	if ( $sec eq "ft" ){  
		@usedbm=qw( lof lot ); 
	}
	
	
	if ( $sec eq "min" ){  # {{{
		@usedbm=qw( loeq loa toc bib ); 
		%lst1=( 
			"loa"	=> [ "bfgs", "lbfgs" , "lbfgs.twoloop" ],
			"loeq"	=>	[ "wolfe", "bfgs.update" ]
		);
		%nm=(
			"bfgs"			=> "BFGS method",
			"bfgs.update"	=> "BFGS update formula",
			"lbfgs"			=> "L-BFGS method",
			"lbfgs.twoloop"	=> "L-BFGS two-loop recursion",
			"wolfe"			=> "Wolfe conditions"
		);
	}
	#}}}
	# print bookmarks in @usedbm {{{
	for my $b (@usedbm){ 
		@bm_opts=(
				"level=1",
				"dest=$b"
				#"page=\\pagenum$b"
			);
		$bm_opt=join(',',@bm_opts);
		print "\\bookmark[$bm_opt]{$bm{$b}}\n"; 
		if (defined $lst1{$b}){
			for my $elem (@{$lst1{$b}}){
				@bm_opts=( 
					"level=2",
					#"view=FitH 800",
					"view={XYZ 0 1000 null}",
					"dest=$bmid{$b}\:$elem"
				);
				$bm_opt=join(',',@bm_opts);
				print "\\bookmark[$bm_opt]{$nm{$elem}}\n"; 
			}
		}
	}
	#}}}
	
}

sub print_start {
    my(%lst,@usedlst);
	
	%lst=( 
		"toc"  => "tableofcontents",
		"lof"  => "listoffigures",
		"lot"  => "listoftables",
		"loeq" => "listofmyeq",
		"loa"  => "listofalgorithms"
	);
	
	if ($flags{print_title}){

print << "eof";
\\hypertarget{title}{}
\\inpp{title}
\\nc{\\pagenumtitle}{\\thepage}
eof

    }

	if ($flags{include_own_start_page}){

print << "eof";
\\inpstart{$sec.0} 

eof

	}

	if ($flags{print_abs}){
print << "eof";
\\hypertarget{abs}{}
\\inpp{abs}\n
\\nc{\\pagenumabs}{\\thepage}
eof
	}


	@usedlst=keys %lst;
	
	if ($pname eq "pap"){
		print "\\chapter{Papers}\n";
	}
	
	if ($sec eq $pname) {
		#@usedlst=keys %lst;
		@usedlst=qw( toc lof lot loa );
		@usedlst=qw( toc lof );
	} elsif($sec eq "abs") {
		@usedlst=qw( );
	}elsif ( grep { $_ eq $sec } qw( in pes pf ) ){
		@usedlst=qw( abs toc lof );
	} elsif($sec eq "min") {
		@usedlst=qw( toc loa );
	} elsif($sec eq "ft") {
		@usedlst=qw( lof lot );
	} elsif($sec eq "res") {
		@usedlst=qw( lof lot );
	} elsif($sec eq "tab") {
		@usedlst=qw( lot );
	} elsif($sec eq "fig") {
		@usedlst=qw( lof );
	}
#@usedlst=qw( toc lof lot loa );

	my $ai=0;
	for my $k (@usedlst){
		if ($ai == 0){ print "\\clearpage\n"; }

print << "eof";
\\phantomsection
\\hypertarget{$k}{}
\\$lst{$k}
\\nc{\\pagenum$k}{\\thepage}
\n
eof
	$ai++;
	}

}

sub main {

	init_vars;
	get_opt;
	set_flags($sec);
	printtex;

}

1;
