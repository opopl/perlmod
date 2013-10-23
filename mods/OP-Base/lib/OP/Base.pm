
package OP::Base;
# Intro {{{

=head1 NAME

OP::Base - Basic Perl functions and variables

=head1 SYNOPSIS

  use OP::Base qw/:vars :funcs/;

=head1 DESCRIPTION

=cut

use 5.010001;

use strict;
use warnings;

use File::Basename;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

require Exporter;

our @ISA = qw(Exporter);

# }}}
# Export ... {{{

our %EXPORT_TAGS = ( 
		# 'funcs' {{{
		'funcs'		=> [ qw( 
						_join
                        _hash_add
						cmd_opt_add
						is_const
						is_log
						eoo 
						eoo_arr
						eoo_vars
						eoolog
					   	edelim	
						evali
						eval_fortran
						getopt 
						getopt_after
						gettime
                        ListModuleSubs
						open_files
						printpod 
						printhelp
						printman
						printexamples
						readarr 
						readhash 
						read_kw_file
						read_all_vars
						read_in_flist
						read_init_vars
						read_const
						read_TF
						read_TF_cmd
						read_line_vars
                        remove_local_dirs_from_INC
						skip_lines
						read_line_char_array
						sbvars 
						set_FILES 
						setsdata 
						setcmdopts 
						uniq
						toLower
						) ],
		# }}}
		# 'vars' 		{{{
###export_vars
		'vars' 		=>  [ qw( 
					$cmdline
                    $endl
					$ncmdopts
					$pref_eoo 
					$ts 
					%arrays
					%cmd_opts
					%DIRS
					%eval_sw
					%FILES
					%DATFILES
					%fh
					%opt
					%opts
					%sdata
					%vars
					@cmdopts
					@longopts
					@logtypes
					@opthaspar
					@optstr
					@true
					@false
					
				) ] 
		# }}}
	);

our @EXPORT_OK = ( 
		@{ $EXPORT_TAGS{'funcs'} },
		@{ $EXPORT_TAGS{'vars'} }
	);

our @EXPORT = qw( );

our $VERSION = '0.01';
# }}}
# vars{{{

###our
our($ts,$pref_eoo,@allowed_pod_options);
our(%DATFILES,%FILES,%DIRS,%sdata,@cmdopts,$ncmdopts,@opthaspar);
our(%opt,%opts,@optstr,@longopts);
our($cmdline);
our(%cmd_opts);
our(@constvars);
our(%shortlongopts);
our(%vars,%lgvars);
our(@true,@false);

our $endl;

our %eval_sw=(
	true	=>	1,
	false	=>	0
);
our(%arrays);

# Types of log files
our @logtypes=qw( log logtex ); 
# Hash of filehandles
our %fh;
# Variable types, i.e. integer, logical etc.
our %ftype;

# }}}
# subroutine declarations {{{

sub _join($$);

sub _hash_add;

sub cmd_opt_add;
sub eoo;
sub eoo_arr;
sub eoo_vars;
sub eoolog;
sub evali;
sub eval_fortran;
sub edelim;
sub getopt;
sub getopt_init;
sub getopt_after;
sub gettime;
sub ListModuleSubs;
sub open_files;
sub printpod;
sub printhelp;
sub printexamples;
sub printman;
sub readarr;
sub read_in_flist;
sub readhash;
sub read_kw_file;
sub read_all_vars;
sub read_init_vars;
sub read_const;
# 
sub read_line_vars;
sub skip_lines;
sub read_line_char_array;
# 
sub read_TF;
sub read_TF_cmd;
sub remove_local_dirs_from_INC;
sub sbvars;
sub set_FILES;
sub setsdata;
sub setcmdopts;
sub uniq;
sub toLower;

# }}}
# subs {{{


sub _hash_add {
    my ($h,$ih)=@_;
    
    while(my($k,$v)=each %{$ih}){
        $h->{$k}=$ih->{$k};
    }
    wantarray ? %$h : $h;

}

# _join() {{{

=head3 _join()

=cut

sub _join($$){
	# separator
	my $sep=shift;

	# reference to an array structure to be joined
	my $ref=shift;

	if (ref $ref eq "ARRAY"){
		return join($sep,@$ref);
	}

}

# }}}
# cmd_opt_add() {{{

=head3 cmd_opt_add()

=cut

sub cmd_opt_add{
	my($type,$name);

    my $ref=shift;

	my @mycmdopts=@{$ref};

	push(@cmdopts,@mycmdopts);

	foreach my $opt(@mycmdopts){
		$type=${$opt}{type} or $type='bool';

		$name=${$opt}{name};

		push(@{$cmd_opts{$type}},$name);

	}
}
# }}}
# E {{{
# edelim() {{{

=head3 edelim()

=cut

sub edelim{
	my $sfin;
	my $s="$_[0]";
	my $num=$_[1];
	$sfin=$s x $num . "\n";
	&eoolog($sfin);
}
# }}}
# eoo() {{{

=head3 eoo()

=cut

sub eoo{ print "$pref_eoo $_[0]"; }
# }}}
# eoolog() {{{

=head3 eoolog()

=cut

sub eoolog{
	my $text=shift;
	my $nopts=scalar @_;
	my %o=@_;
	my $printed=0;
	my %sects=(
		tex	=>	{		
			head1	=> "chapter",
			head2	=> "section",
			head3	=> "subsection",
			head4	=> "subsubsection"
		}	
	);

	if ($o{echo}){
    		print "#$pref_eoo> $text";
		}
	elsif (
			defined($opts{log}) 
			&& ($opts{log}) 
			&& (defined $fh{log})
			&& (defined $fh{logtex})
		){
		if (!$nopts){
		}else{
			if ((defined($o{out})) && $o{out}){
	        	print "#$pref_eoo> $text";
			}
			if ((defined($o{sec})) && $o{sec}){
	        	print {  $fh{logtex} } "\\$sects{tex}{$o{sec}}\{$pref_eoo: $text\}\n";
				$printed=1;
			}
			if ((defined($o{begin_verbatim})) && $o{begin_verbatim}){
	        	print {  $fh{logtex} } "\\begin\{verbatim\}\n";
				$printed=1;
			}
			if ((defined($o{end_verbatim})) && $o{end_verbatim}){
	        	print {  $fh{logtex} } "\\end\{verbatim\}\n";
				$printed=1;
			}
			print {  $fh{logtex} } "\n" x $o{vspaces} if defined($o{vspaces});
		}
			if (!$printed){
	        	print {  $fh{log} } "$pref_eoo> $text";
	        	print {  $fh{logtex} } "$pref_eoo> $text";
			}
	}else{
		if ((!$nopts) || ($o{out})){
    		print "#$pref_eoo> $text";
		}
	}
}
	# }}}
# eoo_arr(){{{

sub eoo_arr{
	my $msg=shift;
	my $arr=shift;
	&eoo("$msg\n");
	&eoo(" 		");
	foreach(@{$arr}) { 
			print "$_ "; } print "\n";
}
# }}}
# eoo_vars(){{{

sub eoo_vars{
	my $msg=shift;
	my $arr=shift;
	&eoo("$msg\n");
	&eoo(" ");
	foreach(@{$arr}) { 
			print "$vars{$_} " if defined $vars{$_}; } print "\n";
}
# }}}
# eval_fortran(){{{
sub eval_fortran{

my $x=$_[0];
$x =~ s/\s*//g;

return 1 if ($x =~ /^\.TRUE\.$/i);
return 0 if ($x =~ /^\.FALSE\.$/i);
return $x;
}
# }}}
# evali() {{{

=head3 evali()

=cut

sub evali {
	use DB;
	my %O;
	%O=(
		pref	=>	"std.",
		suff	=>	".i.pl",
		dir		=>	"$Bin"
	);
	while(@_){
		my $key=shift;
		if (@_){ $O{$key}=shift; }
	}
	my @evalfiles=@{$O{files}};
	foreach(@evalfiles){ 
			s/^/$O{pref}/g if $O{pref}; 
			s/^/$O{dir}\//g if $O{dir}; 
			s/$/$O{suff}/g if $O{suff}; 
		}
	foreach(@evalfiles){
		open(RV,"<$_") || die $!; my $rv=do { local $/; <RV> }; close(RV);
		eval "$rv";
		die $@ if $@;
	}
	return 1;
}
	# }}}
# open_files(){{{
sub open_files{
	my %argopts=@_;
	my $echo=0;
	$echo=$argopts{echo} if defined $argopts{echo};

%FILES=( 
	%FILES,
	"log"			=> "$Script.log",
	"logtex"		=> "log.$Script.tex"	
);
if ($opts{"logname"}){
	$FILES{"log"}="$opts{logname}.log";
	$FILES{"logtex"}="log.$opts{logname}.tex";
}
# File handle for the testing-log file 
if ($opts{log}){
	foreach(@logtypes){
		if ($opts{appendlog}){
			open($fh{$_},">>$FILES{$_}") || die $!;
			&eoolog("Opening $_-file for appending:\n",echo=>$echo);
			&eoolog("	$FILES{$_}\n",echo=>$echo);
		}else{
			open($fh{$_},">$FILES{$_}") || die $!;
			&eoolog("Opening $_-file for write:\n",echo=>$echo);
			&eoolog("	$FILES{$_}\n",echo=>$echo);
		}
	}
}

}
# }}}
# }}}
# getopt() {{{

=head3 getopt_init()

=cut

sub getopt_init{
	Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
}

=head3 getopt()

=cut

sub getopt{

	my @argv=@_;
	@ARGV=@argv if (@argv);

	&getopt_init();

	unless (@ARGV){ 
        if ($Script =~ /^[\.\w]*$/){
              pod2usage("Try '$Script --help' for more information");
		      exit 0;
        }else{
              warn("Failed to run OP::Base::getopt() : no arguments and no script running");
        }
	}else{
		$cmdline=join(' ',@ARGV);
		GetOptions(\%opt,@optstr);
	}

	foreach my $k (keys %opt) {
		$opts{$k}=$opt{$k};
	}

	# view the script itself
	system("gvim -n -p --remote-tab-silent $0"),exit 0 if $opt{vm};

}

#}}}
# getopt_after() {{{

sub getopt_after{

	&printpodoptions();
	&printhelp() if $opt{help};
	&printman() if $opt{man};
	&printexamples() if $opt{examples};

}
sub printpodoptions {
	foreach my $pod_option (@allowed_pod_options) {
		&printpod("$pod_option");
	}
}

sub printhelp{
	pod2usage(-input=> $FILES{pod}{help}, -verbose => 1) if $opt{help};
}
sub printman{
	pod2usage(-input=> $FILES{pod}{help}, -verbose => 2) if $opt{man};
}
sub printexamples{
	pod2usage(-input=> $FILES{pod}{examples}, -verbose => 2) if $opt{examples};
}

# }}}
# gettime () {{{

sub gettime{
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
my $year = 1900 + $yearOffset;
my $time = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
return $time;
}

#}}}
# is_log() is_const (){{{

sub is_log{
	my $var=shift;
	if (defined($ftype{$var})){
		return 1 if ($ftype{$var} =~ /^logical/i) ;
	}
	return 0;
}

sub is_const{
	my $var=shift;
	return 1 if (grep { uc($var) eq $_ } @constvars );
	return 0;
}
# }}}
# printpod(){{{

=head3 printpod()

=cut

sub printpod{
	my $topic=shift;
	my $o;
	open(POD,">$FILES{pod}{$topic}") || die $!;
		
	if (grep { $topic eq $_ } @allowed_pod_options ){
		if ($topic eq "help"){
			print POD "=head1 NAME\n\n";
			print POD "$sdata{name} - $sdata{desc}{short} \n\n";
			print POD "=head1 SYNOPSIS\n\n";
			print POD "$sdata{name} [--help] [--man] [OPTIONS] \n\n";
			print POD "=head1 DESCRIPTION\n\n";
			print POD "$sdata{desc}{long} \n\n";
			print POD "=head1 OPTIONS\n\n";
			print POD "=over 4\n\n";
			for (my $iopt = 0; $iopt < $ncmdopts; $iopt++) {
			  	$o=$cmdopts[$iopt]{name};
				my %argopt;
				$argopt{type}="long";
				$argopt{type}="short" if ($o =~ m/^\w$/);
				if ($o =~ m/^\s*([^\s,])\s*,\s*([^\s,]{2,})\s*$/){
					$argopt{type}="mixed";
					$argopt{short}=$1;
					$argopt{long}=$2;
				}
				$argopt{type}="long" if ($o =~ m/^\s*([^\s,]{2,})\s*$/);
				my $odesc=$cmdopts[$iopt]{desc};
				if (grep { $o eq $_ } @opthaspar){
				  $o.=" " . uc $o;
				}elsif( defined $cmdopts[$iopt]{pars}){
				  $o.=" " . uc $cmdopts[$iopt]{pars}; 
				}
				if ($argopt{type} eq "long"){
					print POD "=item I<--$o>\n\n";
				}elsif ($argopt{type} eq "short"){
					print POD "=item I<-$o>\n\n";
				}elsif ($argopt{type} eq "mixed"){
					print POD "=item I<-$argopt{short}, --$argopt{long}>\n\n";
				}
				print POD "$odesc\n\n" if (defined $odesc);
				print POD "\n\n";
			}
			print POD "=back\n\n";
		}elsif($topic eq "examples"){
			print POD "=head1 EXAMPLES\n\n";
		}
		print POD "=cut\n\n";
  	}
	close(POD);
}
# }}}
# R {{{

# read_*  {{{
# read_const(){{{
sub read_const{

my @ifsconst=@{$FILES{constvars}};
foreach (@ifsconst){ 
	my $if=$_;
	if (-e $if){
		&eoolog("Reading in constant variables file:\n");
		&eoolog("	$if\n");
		open(F,"<$if") || die $!;
		while(<F>){
			chomp; next if ( /^\s*#/ || /^\s*$/ );
			my @F=split(' ',uc($_));
			push(@constvars,@F);
		}
		close(F);
	}
}

&eoolog("Number of constant variables:\n");
&eoolog(" " . scalar(@constvars) . "\n"); 
}
# }}}
# read_TF(){{{
sub read_TF{

# read in true/false values
foreach my $switch (qw( false true )){
	if (-e "$switch.rif.dat" ){
		push(@{$FILES{$switch}},"$switch.rif.dat");
	}
	foreach (@{$FILES{$switch}}){
		my $if=$_;
		if (-e $if){
			open(F,"<$if") || die "$!";
				&eoolog("Reading in $switch values from input file:\n");
				&eoolog("	$if\n");
				while(<F>){
					chomp; next if /^\s*#/ || /^\s*$/; 
					foreach my $lvar_s (split(',',$_)){
						my @F=split(' ',$lvar_s);
						my $lvar=uc($F[0]); $lvar =~ s/\s*//g;
						$vars{$lvar}=$eval_sw{$switch};
						#print "$lvar\n" if $vars{$lvar};
					}
				}
			close(F);
		}
	}
}

}
# }}}
# read_all_vars() {{{
sub read_all_vars{

if (-e $FILES{vars}){
	&eoolog("Reading in the list of variables from $FILES{vars}\n");
	open(V,"<$FILES{vars}") || die "$!";
	while(<V>){
		chomp; next if /^\s*!(.*)$/ || /^\s*$/;
		s/^\s*//g; s/\s*$//g;
		my @F=split('::',$_);
		next if (scalar @F==1);
	
		my @Ft=split(',',$F[0]);
		my @Fv=split(',',$F[1]);
		my($var,$ft);
		( $var=$Fv[0]) =~ s/[^\w]//g;
		$var =~ s/=(.*)$//g; 
		my $val=0;
		$val=$1 if (defined($1));
		$var =~ s/\s*//g;
		$var=uc($var);
		#$ftype{$var}=&get_ftype($Ft[0]);
		( $ft=$Ft[0] ) =~ s/[^\w\s]//g; 
		$ftype{$var}=$ft;
		if ($ft =~ /^double precision/i ){
			#$vars{$var}=0.0e0;	
		}
		elsif ($ft =~ /^logical/i ){
			$vars{$var}=&eval_fortran($val);
			$lgvars{$var}=$vars{$var};	
		}elsif ($ft =~ /^integer/i ){
			#$vars{$var}=0;	
		}elsif ($ft =~ /^character/i ){
			#$vars{$var}=' ';	
		}
	}
	close(V);
}

}
# }}}
# read_init_vars(){{{
sub read_init_vars{

	my $var;
	# read in initialized variable values 
	if ($opts{rinit}){
		open(IV,"<$FILES{initvars}") || die "$!";
		&eoolog("Reading in pre-initialized variable values...\n");
		&eoolog("	Input file: $FILES{initvars}\n");
		while(<IV>){
			chomp;
			next if /^\s*[!#](.*)$/;
			my @F=split('=',$_);
			$var=uc $F[0];
			if ( &is_log($var) || &is_const($var) ){
				$vars{$var}=&eval_fortran($F[1]);
			}
		}
		close(IV);
	}
}
#}}}
# read_in_flist() - read in flist {{{

sub read_in_flist{
	my @ifs=qw();
	if ($opts{flist}){
		&eoolog("--flist: fortran files are specified in a special flist-file.\n");
		&eoolog("		To see the list of files in this flist-file, invoke:\n");
		&eoolog("			get_flist.pl --out --file\n");
		if(! -e $FILES{flist}){
			&eoolog("Error: flist file does not exist.\n");
			die "\n";
		}else{
			&eoolog("Reading in the flist input file:\n");
			&eoolog("	$FILES{flist}\n");
			open(F,"<$FILES{flist}") || die $!;
			@ifs=map { chomp($_); $_; } 
					grep { (! ( /^\s*#/ || /^\s*$/  )) } <F>;
			@ifs=sort(uniq(@ifs));
			close(F);
			&eoolog("Number of flist-fortran files:\n");
			&eoolog(" ". scalar(@ifs) . "\n"	);
		}
	}
	return \@ifs;
}
# }}}
# read_line_char_array(){{{
sub read_line_char_array{
	local *A=shift;
	my $name=shift;
	my $line=<A>;
	@{$arrays{$name}}=split('',$line);
}
# }}}
# read_line_vars(){{{
sub read_line_vars{
	local *A=shift;
	my $listvars=shift;
	my $line=<A>;
	my @F=split(' ',$line);
	foreach(@$listvars){ 
		$vars{$_}=shift @F; 
	}
}
# }}}
# read_TF_cmd() - read in true/false from command line {{{
sub read_TF_cmd{
	foreach my $switch (qw(false true)){
		if (defined($opt{$switch})){
			my @F=split(",",$opt{$switch});
			foreach(@F){
				$vars{uc($_)}=$eval_sw{$switch};
			}
		}
	}
}
#}}}
# read_kw_file() {{{

=head3 read_kw_file()

=cut

sub read_kw_file{
	my %argopts=@_;
	my $echo=0;
	$echo=$argopts{echo} if defined $argopts{echo};

	foreach my $type( qw(i s bool) ){
		next unless defined $cmd_opts{$type};
		foreach(@{$cmd_opts{$type}}){ 
			#print	;
			#$opts{$_}=0; 
		}
	}
	
	my $atype;
	if (-e $FILES{tkw}){
		&eoolog("Reading in options for the script from the input keyword file:\n",out=>$echo);
		&eoolog("	$FILES{tkw}\n",out=>$echo);
		open(TKW,"<$FILES{tkw}") || die $!;
		while(<TKW>){
			chomp;
			my @F;
			if (/^\s*#\s*>>>\s*(\w+)opts/){
				$atype=$1;
			}else{
				next if (/^\s*#/ || /^\s*$/);
				@F=split(' ',$_);
			}
			if (@F){
				if ($atype eq "bool"){
					$opts{$F[0]}=1;
				}else{
					$opts{$F[0]}=$F[1];
				}
			}
		}
		close(TKW);
	}
}
# }}}
# }}}

sub ListModuleSubs {
    my $module=shift;

    my @subs=();

	my @loc=map { chomp; $_; } `pmi -l $module`;
	my $mfile=shift @loc;
	
    while(1){
        last unless $mfile;
        last unless -e $mfile;

		my @lines=read_file $mfile;
		foreach (@lines){
		    chomp;
		    next if /^\s*#/;
			#/^\s*sub\s*(?<subname>\w+)[\n\s]*(|\([\w\$,\n\s]*\))[\n\s]*{/ && do {
		    /^\s*sub\s*(?<subname>\w+)\s*(|\([\w\$,\s]*\))\s*{/ && do {
		        push(@subs,$+{subname});
		        next;
		    };
		}

        last;
    }

    @subs=sort(@subs);

    wantarray ? @subs : \@subs;
	
}


# readarr(){{{

=head3 readarr()

=cut

sub readarr {

 my $if=shift // '';

 unless ($if){
     warn "OP::Base::readarr(): empty file name provided: $if";
     return wantarray ? () : [];
 }

 unless (-e $if){
     warn "OP::Base::readarr(): file does not exist: $if";
     return wantarray ? () : [];
 }
    
 open(FILE,"<$if") || die "Opening $if : $!";

 my @vars;

 while(<FILE>){
 	chomp;
 	s/^\s*//g;
 	s/\s*$//g;
 	next if (/^\s*#/ || /^\s*$/ );
 	my $line=$_;
 	my @F=split(' ',$line);
 	push(@vars,@F);
 }
 close(FILE);

 @vars=uniq(@vars);

 wantarray ? @vars : \@vars;

}
# }}}
# readhash(){{{

=head3 readhash()

=cut

sub readhash{
 my $if=shift;

 my $opts=shift // {};

 my $sep=$opts->{sep} // ' ';

 unless(-e $if){
     if (wantarray) {
         return ();
     }else{
         return [];
     }
 }

 open(FILE,"<$if") || die $!;

 my %hash=();
 my(@F,$line,$var);

 my $mainline=1;

 while(<FILE>){
 	chomp;

 	s/\s*$//g;

 	next if (/^\s*#/ || /^\s*$/ );

	$mainline=1 if ( /^\w/ );
	$mainline=0 if ( /^\s+/ );

	$line=$_;

    $line =~ s/\s*$//g;
    $line =~ s/^\s*//g;

	if ($mainline){

	 	@F=split($sep,$line);

        for(@F){
            s/^\s*//g;
            s/\s*$//g;
        }
	
		$var=shift @F;

		if (@F){ 
			$hash{$var}=join($sep,@F); 
		}else{
			$hash{$var}=''; 
        }
	
	}else{
		$hash{$var}.=$line; 
	}

	$hash{$var} =~ s/\s+/ /g;

 }

 close(FILE);

 wantarray ? %hash : \%hash;
}
# }}}

# }}}
# setsdata() {{{

=head3 setsdata()

=cut

sub setsdata {
	%sdata=( 
	  "desc"	=>	{ 
			short 	=> "do ...",
		  	long	=>	"...long description..."
		  },
	  "name" 	=>	"$Script",
	  "sname"	=>	"$ts",
	  "usage"	=>	"This script performs ..."
	);
}
# }}}
# setcmdopts(){{{

=head3 setcmdopts()

=cut

sub setcmdopts{

  my($otype,@optnames);
  
  @opthaspar=qw( );

  $ncmdopts=scalar @cmdopts;

  foreach my $opt_struct (@cmdopts) {

	  if ( $opt_struct->{name} ){
			@optnames=split(',',$opt_struct->{name});
			push(@longopts, map { /^\w{2,}$/ } @optnames);
	  }
	
	  if( $opt_struct->{type}){
	  	unless( $opt_struct->{type} =~ /^(|bool)$/){
			$otype=$opt_struct->{type};
			s/$/=$otype/g for(@optnames);
		}
	  }	  
	  push(@optstr,@optnames);
  }
}

# }}}
# skip_lines(){{{
sub skip_lines{
	local *A=shift;
	my $count=shift;
	for(my $i=0;$i<$count;$i++){ my $line=<A>; }
}
# }}}
# sbvars(){{{

=head3 sbvars()

=cut

sub sbvars{

( $ts=$Script) =~ s/\.(\w+)$//g;
 $pref_eoo="$Script>";
 @allowed_pod_options=qw( help examples );

 %DIRS=( 
	 pod	 => "pod",
     PERLMOD  => $ENV{PERLMODDIR} // catfile($ENV{HOME}, qw(wrk perlmod)),
 );

 $endl="\n";


 foreach my $k (keys %DIRS) {
 	mkdir $DIRS{$k};
 }

}
# }}}

sub remove_local_dirs_from_INC {
    my @inc;
    foreach(@INC){
        unless (/^\Q$DIRS{PERLMOD}/) {
            push(@inc,shift @INC);
        }
    }
    @INC=@inc;

}

# set_FILES() {{{
sub set_FILES {
	foreach my $podo (@allowed_pod_options) {
		$FILES{pod}{$podo}="$sdata{sname}.$podo.pod";
	}
	$FILES{tkw}="$ts.kw.i.dat";
	$FILES{ifs}="$ts.ifs.i.dat";
}
sub set_DATFILES {
    %DATFILES=(
        modules_to_install  => catfile($DIRS{PERLMOD},qw(inc)),
    );

    while(my($k,$v)=each %DATFILES){
        $DATFILES{$k}=catfile($v,$k . '.i.dat');
    }

}
# }}}
# toLower() {{{

sub toLower {
   my($string) = $_[0];
   $string =~ tr/A-Z/a-z/;
   $string;
}

# }}}
# uniq() {{{

sub uniq {
   my(%h,@W);

   my @words=@_;

   foreach my $w (@words) {
       push(@W,$w) unless defined $h{$w};
       $h{$w}=1;
   }

   wantarray ? @W : \@W ;

}

#}}}

# }}}

# Module initialization

BEGIN { 
	&sbvars();
	&setsdata();

	&set_FILES();
	&set_DATFILES();
}

1;

# POD documentation {{{

__END__

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Oleksandr Poplavskyy, E<lt>op@cantab.net<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Oleksandr Poplavskyy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
# }}}
