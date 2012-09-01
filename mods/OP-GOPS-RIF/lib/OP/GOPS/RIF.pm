package OP::GOPS::RIF;

# use ...{{{

use warnings;
use strict;

use FindBin;
use lib("$FindBin::Bin/../../inc/perl");
use File::Basename;
use File::Find ();
use File::Copy;
use Getopt::Long;
use Pod::Usage;
use Cwd;
use OP::Parse::BL;
use Data::Dumper;

use OP::Base qw/:vars :funcs/;
use OP::GOPS qw/:vars :funcs/;


BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

sub new()
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}
# }}}
# vars {{{

my(@fileprefs,%suffs);
my(@riffiles);
my @lfiles;
my $date;
my($var,$val);
my $nline;
# Parser::BL
my($oph,$opname,$boolparser);
my(%fortranops,%perlops);
# Regex
my(%reif,%re);
my(@matchkeys,@kreif);
my(%reend);
my %match;

my(%linevars);
my(%lvarkeys,@lvarkeysall);

my($ifile,@ifs,$if);
my $nextline;
my %printo;
my $nplines=3;
my $comment_char = '!';
my $cont_char = '&';
my $old = "";
my $prefix="rif.";
my $comment = "";
my(%elsearr,%printarr);
my $tabif;
my $new;
my($ifprint,$iif,$ifprev);
my($prog,$pwd);
my(%lgcond,%lgconds,$rest);
my(@res0,$res_and,%ares);
my $in_string = 1;

%vars=();

my %ncount;
my @bracks=( '\)', '\(' );
foreach my $w (@bracks){ $ncount{$w}=0; }

my(@true,@false);
my(%ind,%res);
my(@indk);
my($subname);
@indk=qw( if subroutine function do );

my %s=(
	"cf"	=> "!"."}" x 3,
	"of"	=> "!"."{" x 3,
	"ofhead"	=> " Header from: $this_script "."{" x 3
);

$ares{0}=[ 1, 1, 1 ];
$ares{-1}=[ 1, 1, 1 ];

if ($opts{i}){ $ifile=$opts{i}; }

$dirs{root}="$shd/../../";
$dirs{bin}="$dirs{root}/bin/";
$dirs{inc}="$dirs{root}/inc/";

$pwd=&cwd();
$prog=&basename($pwd);
$prog=$opt{prog} if (defined($opt{prog}));

if($opts{prefix}){
	$prefix=$opts{prefix};
}

if (defined($ifile)){
	$if="$ifile";
	$files{rif}=&dirname($if) . "/" . "$prefix" . &basename($if);
	$files{rif} =~ s/^\.\///g;
	
	if (! ($ifile =~ m/\.(f90|f)$/) ){
		$if="$ifile.f90";
		if ($opt{f77}){
				$if="$ifile.f";
			}	
	}
	@ifs=( "$if" );
}

# }}}
# subroutine declarations {{{

sub pcom;
sub print_head;
sub print_true;
sub print_plines;
sub pdebug;
sub evalp;
sub init_print;
sub init_bool_parser;
sub set_these_cmdopts;
sub set_these_vars;
sub set_these_regex_vars;
sub set_this_sdata;
sub set_arr_trues;
sub set_rif_files;
sub process_kw_data;
sub view_rif;
# read in: rif.ifs.i.dat
sub read_in_ifs;

# }}}
# subroutine bodies {{{

# init_print() - Initial printing {{{
sub init_print(){
	&eoolog("","begin_verbatim"=>1);
}
# }}}
# init_bool_parser(){{{
sub init_bool_parser(){
	#print "$opts{log}\n";exit 0;
	$boolparser = new Parse::BL( 
			operators 	=> [ qw( .and. .or. .not. )], 
			debug 		=> $opts{debugBL},
			fhlog		=> $fh{log},
			fhlogtex	=> $fh{logtex},
	   		'print'		=> 1
		);
		foreach(qw( log logname wBLmin wBLmax wBLcheck )){
			if (defined($opts{$_})){
				$boolparser->chvars($_=>$opts{$_});
			}
		}
	&eoolog("Parse::BL parser initialized.\n") if (defined $boolparser);
	
	$opname="op";
	
	$oph = sub {
		my $op=shift; 
		return { $opname => $op };
	};
}
# }}}
# pcom() print_head() print_true() print_plines() pdebug() {{{

sub pcom(){
	# {{{
	local *A=$_[0];
	if ($opts{com}){
		print A "! ($nline) $this_script> $_[1]\n";
	}
	# }}}
}

sub print_head {
# F90 header with useful conversion info {{{
	local *A=shift;
	my $fname=shift;
print A << "head";
! $s{ofhead}
! ==========================================
! 
! Fortran90 filename: 
! 	$fname
! Original Fortran file:
!	$if	
! Date cleaned
! 	$date
! Script used for conversion:
!	$0
! Commandline options supplied to the script:
!	$cmdline
!
! ==========================================
$s{cf}
head

# }}}
}
sub print_true {
# Print true logical values  {{{
	local *A=$_[0];
	print A "! True logical values $s{of}\n";
	print A "!";
	foreach (@true){
		print A "$_ ";
	}
	print A "\n";
	print A "! $s{cf}\n";
# }}}
}

sub print_plines(){
# {{{
if ($opts{plines}){
	if ($printo{this}){
		print PL "$new\n" if $new;
		print PL "! Old: $old\n" if $old;
	}else{
		print PL "! $old\n" if $old;
	}
		foreach my $i ((1..$nplines)){
			print PL "! ";
			foreach (@{$lvarkeys{$i}}){ 
				my $val= eval "\$$linevars{$_}" ;
				print PL "$_ " . $val . "; " if defined($val); 
			}
			print PL "\n";
		}
	}
# }}}
}

# }}}
	# evalp() callback {{{

my $callback = sub { 
	# {{{
	my($cond)=@_;
	my $lcond=$cond->{$opname};
	my($res,$not,$var,$val);
	$res=undef;
	$not=0;
	while(1){
		$lcond =~ s/^\s*//g; $lcond =~ s/\s*$//g;
		if (grep { uc($lcond) eq uc($_) } @false){ 
			$res=0;
		}
		if (grep { uc($lcond) eq uc($_) } @true){ 
			$res=1;
		}
		if ($lcond =~ /^(\w+)\s*(?:==|\.eq\.)\s*(\S*)/i){
			$var=$1;
			$val=$2;
			if ( &is_const($var) ){
				$res=1 if ($vars{$var} == $val);
				$res=0 if ($vars{$var} != $val);
				#print "$var $val, res: $res\n";
			}
		}
		if ($lcond =~ /^\.not\.(.*)/i){
			$not++;
			if (defined($1)){ $lcond=$1; next; }
		}
         #elsif ($lcond =~ s/\bx\b/\$vars{x}/ig){
			#my $y=eval( "$lcond" ) ? 1 : 0;
			#$res=$y;
			#print "$lcond\n";
		if (defined($res)){
			#print "$res\n";
			if (!$res && ($not % 2)){ $res=1; }
			if ($res && ($not % 2)){ $res=0; }
			return $res;
		}
		return $res;
	}
	# }}}
};

sub evalp(){
# {{{

	my(%cond,%conds);
	$subname=(caller(0))[3];
	$cond{input}=shift;
	my %evals;
	my $ev;
	my @res=( 1, 1, 1);
	my %oopts;

	$boolparser->chvars(nline=>$nline); 
	my $tree=$boolparser->as_array( $cond{input}, operand_cb => $oph );
	if ($opts{pdumper}){
		print D "#" . "=" x 50 . "\n";
		print D "# Line: $nline; Condition: $cond{input}" . "{" x 3 . "1" . "\n";
		print D Dumper($tree);
	}
	my $newtree=$boolparser->partial_solve( $tree, $callback);
	$cond{"fin"}=$boolparser->collect($newtree,$opname);
	$res[1]=$cond{"fin"};
	$res[1]="undef" if (($cond{fin} ne "0") && ($cond{fin} ne "1"));
	$res[0]=0 if (!$res[1]);
	$res[2]=$cond{"fin"};
	
	return @res;
# }}}
}
	# }}}
# %files {{{
%files=( %files,
   	flist		=>	"$dirs{inc}/flist_$prog.dat",
	false		=>	[ "$dirs{inc}/$prog.false.i.dat" ],
	true		=>	[ "$dirs{inc}/$prog.true.i.dat" ],
	initvars	=>	"$dirs{inc}/$prog.initvars.vars.i.f90",
	vars		=>	"v.f90",
	kw			=>	"$prog.kw.i.dat",
	kwperl		=>	"kw.pl",
	kw_setvars_perl		=>	"kw.setvars.i.pl",
	lfiles		=>	"$ts.lfiles.dat",
	constvars	=>	[ "$dirs{inc}/$prog.constvars.i.dat", "constvars.i.dat" ]
);
if ($opts{ikw}){ $files{kw}=$opts{ikw}; }
if ($opts{ikwperl}){ $files{kwperl}=$opts{ikwperl}; }

# }}}
# pdebug(){{{
sub pdebug(){
	my($type,$text)=@_[0,1];
	if ($opts{debug}){
		if ($type eq "sub"){
			# related to subroutine
			print "#$subname()> $text";
		}elsif($type eq "0"){
			# usual printing
			print "$text";
		}elsif($type eq "s"){
			# related to this script
			&eoolog("$text");
		}
	}
}
# }}}
# sub read_in_ifs(){{{
sub read_in_ifs(){
	@ifs=@{&readarr("$files{ifs}")} if (-e $files{ifs});
}
# }}}
# set_arr_trues() - specify array @true for true values  {{{
sub set_arr_trues(){
	foreach my $lvar ( sort(keys %vars) ){
		$lvar =~ s/\s*//g;
		push(@true,"$lvar") if ($vars{$lvar});
		push(@false,"$lvar") unless $vars{$lvar};
	}
	@true=sort(@true);
}
# }}}
# set_ops(){{{ - fortranops perlops 

sub set_ops(){
	%fortranops=(
		"and"		=>	".and.",
		"or"		=>	".or.",
		"not"		=>	".not."
	);
	%perlops=( 
			"lg"	=>	{
					".and."	=>	" and ",
					".or."	=>	" or ",
					".not."	=>	" not "
		},
			int		=>	{	
					".eq."	=>	" == ",
					".gt."	=>	" > ",
					'.lt.'	=>	" < ",
					".ge."	=>	" >= ",
					".le."	=>	" <= "
			}
	);
}

# }}}
# set_these_cmdopts(){{{ 
sub set_these_cmdopts(){ 
	my %optvals=( 
		"PREFIX"	=>	"prefix",
		"FILE"		=>	"ikw ikwperl",
		"PROG"		=>	"prog",
		"VAR"		=>	"true false"
	);
  my @mycmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{ name	=>	"prog", 		desc	=>	"Specify the program's name."	}
	,{ name	 =>	"debugBL",		desc	=> "Print debugging information " }
	,{ name	 =>	"r,run",		desc	=> "Just run the script" }
	,{ name	 =>	"v,view",		desc	=> "View the resulting rif-files" }
		,{ name => "wBLmax", desc => "Maximal line number for which Parse::BL debug printing is enabled" }
		,{ name => "wBLmin", desc => "Minimal line number for which Parse::BL debug printing is enabled" }
		,{ name => "ikw", 	 desc => "Read in keyword data from FILE. Default is PROG.kw.i.dat\n"
					. "where PROG is the name of the program" }
		,{ name => "ikwperl", desc => "Specify the Perl keyword-processing script. Default is kw.pl" }
		,{ name => "f77", desc => "Look for Fortran 77 files, instead of Fortran 90 ones" }
		,{ name => "flist", desc => "Use the 'flist' files" }
		,{ name => "prefix", desc => "Specify a prefix to the output cleaned files. Default is \"rif\"" }
		,{ name => "true", desc => "Set the value of variable VAR to .TRUE." }
		,{ name => "false", desc => "Set the value of variable VAR to .FALSE." }
		,{ name => "rinit", desc => "Read variable values from the init fortran file" }
		,{ name => "nocom", desc => "No comments in the final file" }
		,{ name => "maxline", desc => "Do not go above the given line number" }
		,{ name => "minline", desc => "Start from the given line number" }
		,{ name => "show", desc => "Show only information for the given logical variable LVAR" }
		,{ name => "evalp", desc => "Perform logical evaluation only on expressions containing LVAR" }
		,{ name => "debug", desc => "Print debugging information." }
		,{ name => "plines", desc => "Print information about each line." }
		,{ name => "userec", desc => "Use recursion in evalp()." }
		,{ name => "i", type=> "s", desc => "Specify an input F90 file (may skip extension)" }
  );
	# set %cmd_opts {{{
	
	%cmd_opts=( 
		bool 	=>		[ qw( f77 del all flist 
			rinit debug debugBL wBLcheck plines 
			userec pdumper lfiles
			endcom cutcom com
			log appendlog
			help man pod r ) ],
		s		=>	[ 	qw( prog i true false show evalp ikw ikwperl logname ) ],
		i		=>	[	qw( maxline minline wBLmax wBLmin ) ]
	);
	
	# }}}

	&cmd_opt_add(\@mycmdopts);
}
# }}}
# set_these_regex_vars(){{{

sub set_these_regex_vars(){
	%reif=( 
		"ifthen"		=>	qr/^(\s*)if\s*\((.*)\)\s*then(.*)$/i,
		"elseifthen"	=>	qr/^(\s*)else\s*if\s*\((.*)\)\s*then(.*)$/i,
		#"ifw"			=>	qr/^(\s*)if\s*\((.*)\)(call .*|.*=.*)$/i,
		"ifw"			=>	qr/^(\s*)if\s*\((.*)\)(.*)$/i,
		"elseifw"		=>	qr/^(\s*)else\s*if\s*\((.*)\)/i
	);
	%re=( 
		"else"		=>	qr/^\s*else\s*$/i
	);
	
	@matchkeys=qw( if w else elseif );
	@kreif=qw( ifthen elseifthen ifw elseifw );
	
	push(@matchkeys,@kreif);
	
	%linevars=(
		nline			=>	"nline",
		all				=>	"printo{all}",
		this			=>	"printo{this}",
		"if"			=>	"ind{if}",
		"ifprint"		=>	"printo{if}{\$ind{if}}",
		"ifprev"		=>	"printo{if}{\$ind{if}-1}"
	);
	
	foreach(@matchkeys){ $linevars{"match{$_}"}="match{$_}"; }
	foreach((0..2)){ $linevars{"ares[$_]"}="ares{\$ind{if}}->[$_]"; }
	
	%lvarkeys=( 
		1	=>	[ qw( nline all this if ifprint ifprev ) ]
	);
	
	foreach (qw( if ifthen w else )){ push(@{$lvarkeys{2}},"match{$_}");}
	foreach (( 0..2 )){ push(@{$lvarkeys{3}},"ares[$_]");}
	foreach ((1..$nplines)){ push(@lvarkeysall,@{$lvarkeys{$_}}); }
		
	 %reend=(
		"if"		=>	 qr/^\s*end\s*if\s*$/i
	);
}
#}}}
# set_these_vars(){{{ 
sub set_these_vars(){ 

	@fileprefs=qw( rif com plines pdumper diff );
	%suffs=( "pdumper"	=>	"pl");
}
# }}}
# set_this_sdata() {{{
sub set_this_sdata() {
	$sdata{desc}{short}="FORTRAN source code cleaning script";
	$sdata{desc}{long}=""
			."This script cleans up parts of FORTRAN source code,\n"
			."depending on the pre-initialized values of the logical variables\n"
			."used within the code. The motivation for developing this script\n"
			."was to simplify the overall source code of the Wales group programs \n"
			."(GMIN, OPTIM or PATHSAMPLE), in order to concentrate on those pieces\n"
			."of source most relevant to a particular scientific task.\n"
			."\n"
			."A typical example of source code which one wants to clean up\n"
			."is like this:\n"
			."\n"
			."=over 4\n"
			."\n"
			."IF (CHARMMT . ( some_other_condition )) THEN \n"
			."...\n"
			."...\n"
			."ENDIF\n"
			."\n"
			."=back \n"
			."\n"
			."If one does not use any of the CHARMM functionality, all\n"
			."the code contained in the above example within the IF () THEN ... ENDIF\n"
			."block is useless. \n";

	$sdata{usage}="...";
}
# }}}
# process_kw_data() -  process keyword data {{{
sub process_kw_data(){
	if (-e $files{kw}){
		&eoolog("Processing the keyword data file:\n");
		&eoolog("	$files{kw}\n");
		&eoolog("Perl keyword script is:\n");
		&eoolog("	$files{kwperl}\n");
		my @strue=map { chomp; $_; } grep { ! ( /^\s*#/ || /^\s*$/ ) } 
			`$files{kwperl} --prog $prog --rinit -i $files{kw} --true `;
		my @sfalse=map { chomp; $_; } grep { ! ( /^\s*#/ || /^\s*$/ ) } 
			`$files{kwperl} --prog $prog --rinit -i $files{kw} --false `;
		@true=split(" ",$strue[0]);
		@false=split(" ",$sfalse[0]);
		&eoolog("Re-setting the variables by invoking eval() on the perl file: \n");
		&eoolog("	$files{kw_setvars_perl}\n");
	
		if (-e $files{kw_setvars_perl}){
			&evali(files=>[ "$files{kw_setvars_perl}" ],dir=>"",pref=>"",suff=>"");
		}else{
			&eoolog("Setvars file does not exist!\n");
		}
	
	}else{
		&eoolog("Keyword data file not found!\n");
	}
	my $ntrue=scalar(@true);
	my $nfalse=scalar(@false);
	&eoolog("Number of true logical values:\n");
	&eoolog(" $ntrue\n"); 
	&eoolog("Number of false logical values:\n");
	&eoolog(" $nfalse\n");
	&eoolog("Number of Fortran input files to be processed:\n");
	&eoolog(" " . scalar @ifs . "\n");
}
# }}}
# sub view_rif(){{{
sub view_rif(){
	my @rifnames=split(",",$opt{i});
	foreach(@rifnames) { s/$/\.f90/g; }
	foreach my $if (@rifnames){
		&set_rif_files($if);
	}
	print @rifnames,"\n";
	system("gvim -n -p @riffiles");
	exit 0;
}
#}}}
# sub set_rif_files(){{{
sub set_rif_files(){	
	my $if=shift;
	foreach (@fileprefs){
		my $suff=$suffs{$_};
		my $pref=$_;
		$pref=$_.".rif" if ($_ ne "rif");
		$files{$_}=&dirname($if) . "/" . "$pref." . &basename($if);
		$files{$_}.=".$suff" if (defined ($suff));
		push(@riffiles,$files{$_});
	}
	foreach (keys %files){ $files{$_} =~ s/^\.\///g; }
}
#}}}
# handle_ifs(){{{

sub handle_ifs(){

	&view_rif() if ($opt{view});

	foreach (@ifs){
		$if=$_;
		# loop start {{{
	
	&eoolog("","end_verbatim"=>1,vspaces=>1);
	&eoolog("$if",sec=>"head2",vspaces=>1);
	&eoolog("","begin_verbatim"=>1,vspaces=>1);
	&eoolog("Processing: $if \n");
	&set_rif_files($if);

	&eoolog("Output file will be: $files{rif}\n");
	open(O,"<$if") || die $!;
	open(N,">$files{rif}");
	$date=`date`; chomp($date);
	if ($opts{com}){
		open(NC,">$files{com}");
		&eoolog("--com: additional comments, together with the code are written into file:\n");
		&eoolog("			$files{com}\n");
	}
	if ($opts{plines}){
		&eoolog("--plines: per-line commenting enabled.\n");
		&eoolog("		Output file with per-line comments: \n");
		&eoolog("			$files{plines}\n");
		open(PL,">$files{plines}");
		print PL "! Explanations $s{of}\n";
		print PL "!" . "=" x 50 . "\n";
		foreach ( @lvarkeysall ){
			print PL "! $_ = \$$linevars{$_}\n";
		}
		print PL "! $s{cf}\n";
		print PL "! ". "=" x 50 . "\n";
	}
	if ($opts{maxline}){
		&eoolog("--maxline: specified the maximal line number:\n");
		&eoolog("	$opts{maxline}\n");
	}
	if ($opts{minline}){
		&eoolog("--minline: specified the minimal line number:\n");
		&eoolog("	$opts{minline}\n");
	}
	if ($opts{pdumper}){
		&eoolog("--pdumper: use Data::Dumper for boolean trees printing.\n");
		&eoolog("		Tree will be printed into:\n");
		&eoolog("			$files{pdumper}\n");
		open(D,">$files{pdumper}") || die $!;
		&print_head(\*D,"$files{pdumper}"); 
	}
	if ($opts{debugBL}){
		&eoolog("--debugBL: print debugging information for the Parse::BL parser.\n");
	}
	if ($opts{wBLcheck}){
		&eoolog("--wBLcheck: Parse::BL checking for line numbers.\n");
	}
	if ($opts{lfiles}){
		push(@lfiles,$if);
		print L "$if\n";
		foreach(qw(pdumper com plines rif)){
			push(@lfiles,$files{$_});
			print L "$files{$_}\n";
		}
		
	}
	foreach(@indk){
		$ind{$_}=0;
	}
	# }}}
	
	print_head(\*N,"$files{rif}");

	if ($opts{com}){ print_head(\*NC,"$files{com}"); }
	if ($opts{plines}){ print_head(\*PL,"$files{plines}"); }
	if ($opts{plines}){ print_true(\*PL,"$files{plines}"); }
	
	# intro {{{
	$nline=0;
	$ind{"if"}=0;
	$printo{"if"}{0}=1;
	$printo{"if"}{-1}=1;
	$printo{"all"}=1;
	$printo{"this"}=1;
	# }}}
	
	@res0=( 1, 1 );
	while (<O>) {
		#{{{
	    $new = $_;
		chomp($new);
		$nline++;
		if (($opts{maxline}) && ($nline > $opts{maxline}) ){ last; }
		if (($opts{minline}) && ($nline < $opts{minline}) ){ next; }
	# Deal with continuations  {{{
		while( $new =~ /\&\s*$/ ){
			$new =~ s/\&\s*$//g;
			$nextline=<O>;
			chomp($nextline);
			$nline++;
			if ($nextline =~ s/^\s*\&//g ){
				$new = $new . "$nextline";
			}else{
				#&eoolog("Fortran syntax error:\n") ;
				#&eoolog("		Missing continuation sign (&) at the start of the next line\n");
				$new = $new . "$nextline";
			}
			#print "new: $new\n";
		}
	# }}}
	# Delete trailing blanks and tabs {{{
	
	    $new =~ s/[\s\t]*$//;
	    #$new =~ s/^\s+$//;
	#}}}
	# Save comments, converting to '!' comments.  {{{
	#Note that "comments"
	# include C preprocessor lines and blank lines.
	
	    if ($new =~ /^\s*[*c#!]|^$/i) {
			if ($new =~ /^\s*[*c]/i) {
		    	substr($new,0,1) = $comment_char;
			}
			$comment .= "$new\n";
			next;
	    }
	    
	#}}}
	# Replace tabs with spaces {{{
	
	    $new =~ s/\t/        /g;
	# }}}
		# process regex {{{
		$old=$new;
		$iif=$ind{if};
		$ifprint=$printo{"if"}{$iif};
		$ifprev=$printo{"if"}{$iif-1};
		$printo{"this"}=$printo{"all"};
	
		foreach (@matchkeys){ $match{$_}=0; }
	
		if(	$new =~ m/$re{else}/i){
			# {{{
				$match{"else"}=1;
						
				%elsearr=( 
						"\$printo{if}{$ind{if}}"	=>	"$ifprint",
						"\$printo{this}"			=>  "$printo{this}",
						"\$printo{all}"				=>  "$printo{all}",
						"\$res0[1]"					=>	"$ares{$ind{if}}->[1]",
						"\$res0[2]"					=>	"$ares{$ind{if}}->[2]"
					);
				%printarr=( 
						"\$printo{if}{$ind{if}}"	=>	"$printo{if}{$ind{if}}",
						"\$printo{this}"			=>  "$printo{this}",
						"\$printo{all}"				=>  "$printo{all}"
					);
	
				if(!$ifprint){
						# print below this line
						$printo{"all"}=$ifprev;
						# don't print this line
						$printo{"this"}=0;
						# print this level of "if"
						$printo{"if"}{$iif}=$ifprev;
				}else{
					if ($ares{$ind{"if"}}->[1] eq "undef"){
						$printo{"all"}=$ifprev;
						$printo{"this"}=$ifprev;
						$printo{"if"}{$iif}=$ifprev;
					}elsif($ares{$ind{"if"}}->[1] == 1){
						$printo{"all"}=0;
						$printo{"this"}=0;
						$printo{"if"}{$iif}=0;
					}
				}
			# }}}
		}elsif( $new =~ m/$reend{if}/){
			# {{{
			if(!$ifprint){
				$printo{"this"}=0;
				$new="";
			}else{
				if ($ares{$ind{"if"}}->[1] eq "undef"){
					$printo{"this"}=$ifprev;
				#}elsif($ares{$ind{"if"}}->[1] == 1){
				}else{
					$printo{"this"}=0;
				}
					#print "$new $printo{this} $lgconds{fortran}{$iif} \n";
			}
			$printo{"all"}=$ifprev;
			if (!$printo{this}){
				$new="";
				$printo{this}=1;
			}
			$ind{if}--;
			if ($opts{endcom}){
				if ($new){ $new=$new . "\n"; }
				if (!$opts{cutcom}){
					$new=$new . "! >>>". ">" x $iif . 
							" ENDIF-$iif ( $lgconds{fortran}{$iif} )";
				}
			}
			# }}}
		}elsif( ! $new =~ /^\s*(|else)\s*if/i ){
		}else{
				foreach my $k ( @kreif ){
					# {{{
						if (!$match{if}){
					 		if(	$new =~ m/$reif{$k}/){
								$match{$k}=1;
								$match{"if"}=1;
								if ( grep { lc($k) eq $_ } qw( elseifthen elseifw )){
									$match{"elseif"}=1;
								}
								if ( grep { lc($k) eq $_ } qw( ifw elseifw )){
									# {{{
									$match{"w"}=1;
									$new =~ m/(\s*)(if|else\s*if)\s*\((.*)\)(.*)/i;
									$tabif=$1; $lgcond{fortran}=$3; $rest=$4;
									my %ncount;
									my @bracks=( '\)', '\(' );
									foreach my $w (@bracks){ $ncount{$w}=0; }
									my($s,$slen,$is);
									$is=1;
									$s=substr($lgcond{fortran},0,1);
									while(length($s) < length($lgcond{fortran})){
										foreach my $w (@bracks){
									 		if	( $s =~ m/$w$/ ){ $ncount{$w}++;  }
										}
										if ($ncount{'\)'} > $ncount{'\('}){
											$rest=substr($lgcond{fortran},$is) . "\)" . $rest;
											( $lgcond{fortran}=$s ) =~ s/\)$//g;
											last;
										}
										$is++;
										$s=substr($lgcond{fortran},0,$is);
									}
									# }}}
								}else{
									if ( grep { lc($k) eq $_ } qw( ifthen )){
										$ind{if}++;
									}
									$tabif=$1;
									$lgcond{fortran}=$2;
									$rest=$3;
									$lgconds{fortran}{$ind{"if"}}=$lgcond{fortran};
									if ( grep { lc($k) eq $_ } qw( ifthen )){
										if ($opts{endcom}){
										$comment= $comment . 
											"! <<<" . "<" x $ind{if} .
											" IFTHEN-$ind{if} ($lgcond{fortran})";
										}
									}
								}
							}
						}
					# }}}
				}
				if ($match{"if"}){
					# {{{
					&pdebug("s","lgcond: $lgcond{fortran}\n");
					$lgcond{perl}=$lgcond{fortran};
					#foreach my $k (keys %{$perlops{lg}}){
						#$lgcond{perl} =~ s/$k/ $perlops{lg}{$k} /gi;
					#}
					#foreach my $var (keys %vars){
						#$lgcond{perl} =~ s/\b$var\b/ \$vars{$var} /gi;
					#}
					#$lgcond{perl} = "\(" . $lgcond{perl} . "\)";
					$lgconds{perl}{$ind{"if"}}=$lgcond{perl};
					if ( (($opts{evalp}) && ($lgcond{perl} =~ /\$vars{$opts{evalp}}/i )) 
							|| (!$opts{evalp})){
								@res0=&evalp($lgcond{perl}); 
							}else{
								@res0=( 1, "undef", "$lgcond{perl}" );
							};
					if (!$match{"w"}){
						@{$ares{ $ind{"if"}} }=@res0 if !$match{w}; 
						if ($ifprint){
								$printo{"if"}{$ind{"if"}}=$res0[0]*$ifprint;
								$printo{"all"}=$res0[0];
								if ($res0[1] eq "undef"){
									$printo{"this"}=1;
								}else{
									$printo{"this"}=0;
								}
						}else{
							$printo{"if"}{$ind{"if"}}=0;
							$printo{"all"}=0;
							$printo{"this"}=0;
						}
					}else{
								$printo{"this"}=$res0[0]*$ifprint;
					}
					# }}}
				}
		}
		# }}}
	
	# Print $old and any "comments" {{{
	
		if (  $comment !~ s/^[\s]*$// ) { 
			if (!$opts{cutcom}){
				print N "$comment\n"; 
			}
		} 
	    $comment = "";
	
		if((!$printo{"all"}) || (!$printo{"this"}) || ($match{"if"})) {
			# {{{
			###############
			# comments
			###############
			if ($opts{com}){
				if ($match{"if"} || $match{"else"} || $match{"elseif"}){
					&pcom(\*NC,"=" x 50);
					&pcom(\*NC,"If-level: $ind{if}");
					if (defined($lgcond{fortran})){
						&pcom(\*NC,"(\$lgcond{fortran})  Fortran condition: $lgcond{fortran}");
					}else{
						&pcom(\*NC,"(\$lgcond{fortran})  Fortran condition undefined!");
					}
					if (defined($lgcond{perl})){
						&pcom(\*NC,"(\$lgcond{perl})  Perl condition: $lgcond{perl}");
					}else{
						&pcom(\*NC,"(\$lgcond{perl})  Perl condition undefined!");
					}
					&pcom(\*NC,"(\$res0[1]) Evaluation: $res0[1]");
					&pcom(\*NC,"(\$res0[2]) Final expression: $res0[2]");
					&pcom(\*NC,"\$printo{this}: $printo{this}");
					&pcom(\*NC,"\$printo{all}: $printo{all}");
					foreach my $k ( qw( else elseifthen ifthen ifw elseifw) ){
						if ($match{$k}){
							&pcom(\*NC,"match type: $k");
						}
					}	
					if ($ind{if} > 0 ){ 
						&pcom(\*NC,"\$printo{if}{$iif}: $ifprint");
					}
					&pcom(\*NC,"=" x 50);
				}
				if ($ifprint){
					&pcom(\*NC,"$new");
				}else{
					&pcom(\*NC," NO($iif) $new");
				}
			}
			# }}}
		}
		if ($match{"else"}){
			&pcom(\*NC,"Match: else");
			&pcom(\*NC,"If-level: $ind{if}");
			&pcom(\*NC,"Values BEFORE else statement:");
			foreach(keys %elsearr){
				&pcom(\*NC,"	$_ $elsearr{$_}");
			}
			&pcom(\*NC,"Values AFTER else statement:");
			foreach(keys %printarr){
				&pcom(\*NC,"	$_ $printarr{$_}");
			}
		}
		
		if ($printo{"this"}){
			# {{{
			if ($match{"if"}){ 
				if ($res0[1] eq "undef"){
					$new=uc("if ( $res0[2] ) then") if $match{"ifthen"};
					$new=uc("elseif ( $res0[2] ) then") if $match{"elseifthen"};
					$new=uc("if ( $res0[2] )") . "$rest" if ($match{"ifw"} && defined($rest));
					$new=$tabif . $new;
					#foreach (keys %fortranops){
						#$new =~ s/\b$_\b/$fortranops{$_}/ig;
						#$new=$new;
					#}
				}elsif($res0[1] == 1){
					$new=$rest if ($match{"w"} && defined($rest));
					$new=undef if (!$match{"w"});
					$new=$tabif . $new if $new;
				}
			}
	
				print N "$new\n" if $new;
				if ($opts{com}){ print NC "$new\n" if $new; }
			# }}}
		}
	
		&print_plines;
			#################
		
	#}}}
	#}}}
	}
	# Print the last $old and "comments" {{{
	
	print N "$new\n";
	print N "$comment\n";
	if ($opts{com}){
		print NC "$new\n";
		print NC "$comment\n";
	}
	close N;
	if ($opts{com}){
		close NC;
	}
	if ($opts{plines}){
		close PL;
	}
	close O;
	if ($opts{del}){
		&eoolog("Deleting the original Fortran file...\n");
		unlink($if);
	}
	# }}}
	# reopen the file for additional editing {{{
	my $fnew="$files{rif}.new";
	###
	open(O,"<$files{rif}") || die $!;
	my $ftext= do { local $/; <O> };
	close(O);
	if ($opts{com}){ close(NC); }
	if ($opts{plines}){ close(PL); }
	if ($opts{pdumper}){ close(D); }
	
	my @flines= split "\n",$ftext;
	
	# N {{{
	open(N,">$fnew") || die $!;
	foreach my $line (@flines){
		$line =~ s/\r//g;
		print N "$line\n";
	}
	close(N);
	&eoolog("Diff the old and the new files...\n");
	`diff  $files{rif} $if > $files{diff} `;
	&eoolog("Output diff file is:\n");
	&eoolog("	$files{diff}\n");
	&eoolog("","end_verbatim"=>1,vspaces=>1);
	# }}}
	###
	move("$fnew","$files{rif}");
	# }}}
	}
}
# }}}
# main_close_files() - close files {{{
sub main_close_files(){
	if ($opts{log}){
		foreach(@logtypes){
			close($fh{$_});
		}
	}
	
	if ($opts{lfiles}){
		close(L);
	}
}
# }}}
# handle_lfiles(){{{
sub handle_lfiles(){
	if ($opts{lfiles}){
		&eoolog("--lfiles: print the list of output files to:\n");
		&eoolog("	$files{lfiles}\n");
		@lfiles=();
		open L, ">$files{lfiles}" || die $!;
		foreach (qw( tkw kw kwperl kw_setvars_perl flist logtex lfiles )){
			push(@lfiles,$files{$_});
			print L "$files{$_}\n";
		}
	}
}
# }}}

# }}}
# main() {{{

sub main(){
	my $self=shift;

	&OP::Base::read_kw_file();
	&OP::Base::open_files();

	$self->init_print();

	$self->set_these_vars();
	$self->set_these_regex_vars();
	$self->set_these_cmdopts();
	$self->set_this_sdata();

	&OP::Base::setcmdopts();
	&OP::Base::getopt();

	$self->init_bool_parser();

	$self->read_in_ifs();

	if (!@ifs){ @ifs=@{&OP::Base::read_in_flist()};}

	&OP::Base::read_const();
	&OP::Base::read_all_vars();
	&OP::Base::read_TF();
	&OP::Base::read_TF_cmd();
	&OP::Base::read_init_vars();

	$self->set_arr_trues();
	$self->process_kw_data();
	
	$self->handle_lfiles();
	$self->handle_ifs();
	$self->main_close_files();

}
#}}}

1;

