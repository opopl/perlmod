package OP::GOPS::RIF;
# ==============================
# intro {{{

use warnings;
use strict;

=head1 INHERITANCE

L<Class::Accessor::Complex>, L<OP::Script>

=head1 USES

use FindBin qw($Bin $Script);
use lib("$Bin/../../inc/perl");

use File::Basename;
use File::Find ();
use File::Copy;
use Getopt::Long;
use Pod::Usage;
use Cwd;
use Data::Dumper;

use OP::Parse::BL;
use OP::Base qw/:vars :funcs/;
use OP::GOPS qw/:vars :funcs/;

use parent qw( OP::Script Class::Accessor::Complex );

=head1 ACCESSORS

=head2 Scalar Accessors

=head2 Array Accessors

=head2 Hash Accessors

=cut

use FindBin qw($Bin $Script);
use lib("$Bin/../../inc/perl");

use File::Basename;
use File::Find ();
use File::Copy;
use Getopt::Long;
use Pod::Usage;
use Cwd;
use Data::Dumper;

use OP::Parse::BL;
use OP::Base qw/:vars :funcs/;
use OP::GOPS qw/:vars :funcs/;

our $VERSION='0.01';

# }}}
# ==============================
# Accessors {{{

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    PROGNAME
    ROOT
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    suffs
    files
    dirs
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    fileprefs
    riffiles
    files
    lfiles
    true 
    false
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

# }}}
# ==============================
# Methods {{{
# _begin() {{{

=head3 _begin()

=cut

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

# }}}
# get_opt() {{{

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();
}

# }}}
# new()												{{{

=head3 new()

=cut

sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

# 													}}}
# }}}
# ==============================
# vars {{{


my $date;
my($var,$val);
my $nline;
# used in handle_ifs()

  %lvarkeys

my($ifile,$if);
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
my($pwd);
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

$self->PROGNAME(basename($pwd));
$self->PROGNAME=$opt{prog} if (defined($opt{prog}));

if($opts{prefix}){
	$prefix=$opts{prefix};
}

if (defined($ifile)){
	$if="$ifile";

	$self->files('rif'   => join(dirname($if), "/" , "$prefix" , basename($if)));
    
    #TODO
	#$self->files('rif'   => =~ s/^\.\///g;
	
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
sub _if_set_rif_files;
sub process_kw_data;
sub view_rif;
# read in: rif.ifs.i.dat
sub read_in_ifs;

# }}}
# subroutine bodies {{{

# init_print() - Initial printing {{{
sub init_print(){
	my $self=shift;
	&eoolog("","begin_verbatim"=>1);
}
# }}}
# init_bool_parser() {{{

=head3 init_bool_parser()

=cut

sub init_bool_parser(){
	my $self=shift;
	#print "$opts{log}\n";exit 0;
	$boolparser = new OP::Parse::BL( 
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
	my $self=shift;
	# {{{
	local *A=shift;
	if ($opts{com}){
		print A "! ($nline) $this_script> $_[1]\n";
	}
	# }}}
}

sub print_head {
	my $self=shift;
# F90 header with useful conversion info {{{
	my $fhandle=shift;
	my $fname=shift;

	my $string =<< "head";
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
	print $fhandle,$string;

# }}}
}

sub print_true(){
	my $self=shift;
# Print true logical values  {{{
	my $fhandle=shift;

	print $fhandle, "! True logical values $s{of}\n";
	print $fhandle, "!";
	foreach (@true){
		print $fhandle, "$_ ";
	}
	print $fhandle, "\n";
	print $fhandle, "! $s{cf}\n";
# }}}
}

# print_plines() {{{
sub print_plines(){
	my $self=shift;

	if ($opts{plines}){
		if ($printo{this}){
			print $fh{PL}, "$new\n" if $new;
			print $fh{PL}, "! Old: $old\n" if $old;
		}else{
			print $fh{PL}, "! $old\n" if $old;
		}
			foreach my $i ((1..$nplines)){
				print $fh{PL}, "! ";
				foreach (@{$lvarkeys{$i}}){ 
					my $val= eval "\$$linevars{$_}" ;
					print $fh{PL}, "$_ " . $val . "; " if defined($val); 
				}
				print $fh{PL}, "\n";
			}
		}
}
# }}}

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
	my $self=shift;
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

$self->files(
   	flist		=>	"$dirs{inc}/flist_$self->PROGNAME.dat",
	false		=>	[ "$dirs{inc}/$self->PROGNAME.false.i.dat" ],
	true		=>	[ "$dirs{inc}/$self->PROGNAME.true.i.dat" ],
	initvars	=>	"$dirs{inc}/$self->PROGNAME.initvars.vars.i.f90",
	vars		=>	"v.f90",
	kw			=>	"$self->PROGNAME.kw.i.dat",
	kwperl		=>	"kw.pl",
	kw_setvars_perl		=>	"kw.setvars.i.pl",
	lfiles		=>	"$Script.lfiles.dat",
	constvars	=>	[ "$dirs{inc}/$self->PROGNAME.constvars.i.dat", "constvars.i.dat" ]
);

if ($opts{ikw}){ $self->files(kw)=$opts{ikw}; }
if ($opts{ikwperl}){ $self->files(kwperl)=$opts{ikwperl}; }

# }}}
# pdebug(){{{

=head3 pdebug()

=cut

sub pdebug(){
	my $self=shift;

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
# read_in_ifs() {{{

=head3 read_in_ifs()

=cut

sub read_in_ifs(){
	my $self=shift;

	@ifs=@{&readarr("$self->files(ifs)")} if (-e $self->files(ifs));
}
# }}}
# set_arr_trues() - specify array @true for true values  {{{

=head3 set_arr_trues() 

=cut

sub set_arr_trues(){
	my $self=shift;

	foreach my $lvar ( sort(keys %vars) ){
		$lvar =~ s/\s*//g;
		push(@true,"$lvar") if ($vars{$lvar});
		push(@false,"$lvar") unless $vars{$lvar};
	}
	@true=sort(@true);
}
# }}}
# set_ops(){{{ - fortranops perlops 

=head3 set_ops()

=cut

sub set_ops(){
	my $self=shift;

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
# set_these_cmdopts() {{{ 

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts(){ 
	my $self=shift;

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
	my $self=shift;

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
	my $self=shift;

	$self->fileprefs(qw( rif com plines pdumper diff ));
	$self->suffs( "pdumper"	=>	"pl");
}
# }}}
# set_this_sdata() {{{
sub set_this_sdata() {
	my $self=shift;

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
	my $self=shift;

	if (-e $self->files(kw)){

		&eoolog("Processing the keyword data file: \n");
		&eoolog("	" . $self->files("kw") . "\n");
		&eoolog("Perl keyword script is: \n");
		&eoolog("	" . $self->files("kwperl") . "\n");

		my @strue=map { chomp; $_; } grep { ! ( /^\s*#/ || /^\s*$/ ) } 
			`$self->files("kwperl") --prog $self->PROGNAME --rinit -i $self->files("kw") --true `;

		my @sfalse=map { chomp; $_; } grep { ! ( /^\s*#/ || /^\s*$/ ) } 
			`$self->files("kwperl") --prog $self->PROGNAME --rinit -i $self->files("kw") --false `;
		@true=split(" ",$strue[0]);
		@false=split(" ",$sfalse[0]);
		&eoolog("Re-setting the variables by invoking eval() on the perl file: \n");
		&eoolog("	$self->files(kw_setvars_perl)\n");
	
		if (-e $self->files(kw_setvars_perl)){
			&evali(files=>[ "$self->files(kw_setvars_perl)" ],dir=>"",pref=>"",suff=>"");
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
# view_rif(){{{

=head3 view_rif()

=cut

sub view_rif(){
	my $self=shift;

	my @rifnames=split(",",$opt{i});
	foreach(@rifnames) { s/$/\.f90/g; }
	foreach my $if (@rifnames){
		$self->_if_set_rif_files($if);
	}
	print @rifnames,"\n";
	system("gvim -n -p $self->riffiles");
	exit 0;
}
#}}}
# _if_* () {{{

# _if_set_rif_files(){{{

=head3 _if_set_rif_files()

=cut

sub _if_set_rif_files(){	
	my $self=shift;

	foreach ($self->fileprefs){
		my $suff=$self->suffs($_);
		my $pref=$_;

		$pref=$_.".rif" if ($_ ne "rif");
		$self->files($_)=&dirname($if) . "/" . "$pref." . &basename($if);
		$self->files($_).=".$suff" if (defined ($suff));

		$self->riffiles_push($self->files($_));
	}
	foreach (keys %files){ $self->files($_) =~ s/^\.\///g; }
}
#}}}
# _if_print_opts_info() {{{

=head3 _if_print_opts_info()

=cut

sub _if_print_opts_info(){
	my $self=shift;

	if ($opts{com}){
		open($fh{NC},">$self->files(com)");
		&eoolog("--com: additional comments, together with the code are written into file:\n");
		&eoolog("			$self->files(com)\n");
	}
	if ($opts{plines}){
		&eoolog("--plines: per-line commenting enabled.\n");
		&eoolog("		Output file with per-line comments: \n");
		&eoolog("			$self->files(plines)\n");
		open($fh{PL},">$self->files(plines)");
		print $fh{PL}, "! Explanations $s{of}\n";
		print $fh{PL}, "!" . "=" x 50 . "\n";
		foreach ( @lvarkeysall ){
			print $fh{PL}, "! $_ = \$$linevars{$_}\n";
		}
		print $fh{PL}, "! $s{cf}\n";
		print $fh{PL}, "! ". "=" x 50 . "\n";
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
			&eoolog("			$self->files(pdumper)\n");
			open($fh{D},">$self->files(pdumper)") || die $!;
			$self->print_head($fh{D},"$self->files(pdumper)"); 
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
				push(@lfiles,$self->files($_));
				print L "$self->files($_)\n";
			}
		}
}
# }}}
# _if_print_verbatim() {{{

=head3 _if_print_verbatim()

=cut

sub _if_print_verbatim(){
	my $self=shift;

	&eoolog("","end_verbatim"=>1,vspaces=>1);
	&eoolog("$if",sec=>"head2",vspaces=>1);
	&eoolog("","begin_verbatim"=>1,vspaces=>1);
	&eoolog("Processing: $if \n");
}

# }}}
# _if_open_files() {{{

=head3 _if_open_files()

=cut

sub _if_open_files(){
	my $self=shift;

	&eoolog("Output file will be: $self->files(rif)\n");
	open($fh{O},"<$if") || die $!;
	open($fh{N},">$self->files(rif)");
}
# }}}
# _if_print_heads() {{{

=head3 _if_print_heads()

=cut

sub _if_print_heads(){
	my $self=shift;

	$self->print_head($fh{N},"$self->files(rif)");

	if ($opts{com}){ $self->print_head($fh{NC},"$self->files(com)"); }
	if ($opts{plines}){ $self->print_head($fh{PL},"$self->files(plines)"); }
	if ($opts{plines}){ $self->print_true($fh{PL},"$self->files(plines)"); }
}
# }}}
# _if_intro() {{{

=head3 _if_intro()

=cut

sub _if_intro(){

	my $self=shift;
	
	$nline=0;
	$ind{"if"}=0;
	$printo{"if"}{0}=1;
	$printo{"if"}{-1}=1;
	$printo{"all"}=1;
	$printo{"this"}=1;
	@res0=( 1, 1 );
}
# }}}
# _if_loop_FILE() {{{

=head3 _if_loop_FILE()

=cut

sub _if_loop_FILE(){
	my $self=shift;
	local *A=shift;

	while (<A>) {
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
}
# }}}
# _if_close_files() {{{

=head3 _if_close_files()

=cut

sub _if_close_files(){
	my $self=shift;

	close $fh{N};

	if ($opts{com}){
		close $fh{NC};
	}
	if ($opts{plines}){
		close $fh{PL};
	}
	close O;
	if ($opts{del}){
		&eoolog("Deleting the original Fortran file...\n");
		unlink($if);
	}

	if ($opts{com}){ close($fh{NC}); }
	if ($opts{plines}){ close($fh{PL}); }
	if ($opts{pdumper}){ close($fh{D}); }
}
# }}}
# _if_write_new() {{{

=head3 _if_write_new()

=cut

sub _if_write_new(){
	my $self=shift;

	open($fh{N},">$self->files(fnew)") || die $!;
	foreach my $line (@flines){
		$line =~ s/\r//g;
		print($fh{N},"$line\n");
	}
	close($fh{N});

	move("$self->files(fnew)","$self->files(rif)");
}
# }}}
# _if_final_output() {{{

=head3 _if_final_output()

=cut

sub _if_final_output(){
	my $self=shift;

	&eoolog("Diff the old and the new files...\n");
	`diff  $self->files(rif) $if > $self->files(diff) `;
	&eoolog("Output diff file is:\n");
	&eoolog("	$self->files(diff)\n");
	&eoolog("","end_verbatim"=>1,vspaces=>1);
}
# }}}
# _if_print_new_comment() {{{

=head3 _if_print_new_comment()

=cut 

sub _if_print_new_comment(){
	my $self=shift;

	print($fh{N}, "$new\n");
	print($fh{N}, "$comment\n");
	if ($opts{com}){
		print $fh{NC}, "$new\n";
		print $fh{NC}, "$comment\n";
	}
}
# }}}
# _if_reopen_files() {{{

=head3 _if_reopen_files()

=cut

sub _if_reopen_files(){
	my $self=shift;

	# reopen the file for additional editing
	$self->files(fnew)="$self->files(rif).new";
	###
	open(O,"<$self->files(rif)") || die $!;
	my $ftext= do { local $/; <O> };
	close(O);

	@flines= split "\n",$ftext;
}
# }}}

# }}}
# handle_ifs() {{{

=head3 handle_ifs()

=cut

sub handle_ifs(){
	my $self=shift;
	foreach (@ifs){
		$if=$_;
		$date=`date`; chomp($date);
		$ind{$_}=0 for(@indk);
	
		$self->_if_print_verbatim();
		$self->_if_set_rif_files();
		$self->_if_open_files();
		$self->_if_print_opts_info();
		$self->_if_print_heads();
		$self->_if_intro();
		$self->_if_loop_FILE(\*O);
		$self->_if_print_new_comment();
		$self->_if_close_files();
		$self->_if_reopen_files();
		$self->_if_write_new();
		$self->_if_final_output();
	}
}
# }}}
# main_close_files() - close files {{{

=head3 main_close_files()

=cut

sub main_close_files(){
	my $self=shift;

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
# handle_lfiles() {{{

=head3 handle_lfiles()

=cut

sub handle_lfiles(){
	my $self=shift;

	if ($opts{lfiles}){
		&eoolog("--lfiles: print the list of output files to:\n");
		&eoolog("	$self->files(lfiles)\n");

		$self->lfiles(qw());
		open L, ">", $self->files("lfiles") || die $!;

		foreach (qw( tkw kw kwperl kw_setvars_perl flist logtex lfiles )){
			$self->lfiles_push($self->files($_));
			print L $self->files($_) . "\n";
		}
	}
}

# }}}

# }}}
# main() {{{

=head3 main()

=cut

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
	$self->view_rif() if ($opt{view});
	$self->handle_ifs();
	$self->main_close_files();
	exit 0;
}
#}}}
# }}}

1;

