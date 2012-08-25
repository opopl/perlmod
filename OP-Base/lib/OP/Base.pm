# package OP::Base; {{{

package OP::Base;

use 5.010001;

use strict;
use warnings;

use File::Basename;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use FindBin;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use OP::Base ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# }}}
# Export ... {{{

our %EXPORT_TAGS = ( 
		# 'funcs' {{{
		'funcs'		=> [ qw( 
						cmd_opt_add
						is_const
						is_log
						eoo 
						eoo_arr
						eoolog
					   	edelim	
						evali
						eval_fortran
						getopt 
						gettime
						open_files
						printpod 
						readarr 
						readhash 
						read_kw_file
						read_all_vars
						read_init_vars
						read_const
						read_TF
						read_TF_cmd
						read_line_vars
						skip_lines
						read_line_char_array
						sbvars 
						setfiles 
						setsdata 
						setcmdopts 
						uniq
						toLower
						) ],
		# }}}
		# 'vars' 		{{{
		'vars' 		=>  [ qw( 
					$cmdline
					$ncmdopts
					$pref_eoo 
					$shd 
					$this_script 
					$ts 
					%arrays
					%cmd_opts
					%dirs
					%eval_sw
					%files
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

# Preloaded methods go here.
# }}}
# vars{{{

our($this_script,$ts,$shd,$pref_eoo,@allowedpodoptions);
our(%files,%dirs,%sdata,@cmdopts,$ncmdopts,@opthaspar);
our(%opt,%opts,@optstr,@longopts);
our($cmdline);
our(%cmd_opts);
our(@constvars);
our(%shortlongopts);
our(%vars,%lgvars);

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

sub cmd_opt_add;
sub eoo;
sub eoo_arr;
sub eoolog;
sub evali;
sub eval_fortran;
sub edelim;
sub getopt;
sub gettime;
sub open_files;
sub printpod;
sub readarr;
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
sub sbvars;
sub setfiles;
sub setsdata;
sub setcmdopts;
sub uniq;
sub toLower;

# }}}
# subs {{{

# read_TF_cmd() - read in true/false from command line {{{
sub read_TF_cmd(){
	foreach my $switch (qw(false true)){
		if (defined($opt{$switch})){
			my @F=split(",",$opt{switch});
			foreach(@F){
				$vars{uc($_)}=$eval_sw{$switch};
			}
		}
	}
}
#}}}


# evali() {{{
sub evali() {
	use DB;
	my %O;
	%O=(
		pref	=>	"std.",
		suff	=>	".i.pl",
		dir		=>	"$shd"
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
# eoo_arr(){{{
sub eoo_arr(){
	my $msg=shift;
	my $arr=shift;
	&eoo("$msg\n");
	&eoo(" ");
	foreach(@{$arr}) { print "$_ "; } print "\n";
}
# }}}
# read_line_vars(){{{
sub read_line_vars(){
	local *A=shift;
	my $listvars=shift;
	my @F=split(<A>);
	foreach(@$listvars){ $vars{$_}=shift @F; }
}
# }}}
# skip_lines(){{{
sub skip_lines(){
	local *A=shift;
	my $count=shift;
	for(my $i=0;$i<$count;$i++){ my $line=<A>; }
}
# }}}
# read_line_char_array(){{{
sub read_line_char_array(){
	local *A=shift;
	my $name=shift;
	my $line=<A>;
	@{$arrays{$name}}=split('',$line);
}
# }}}

# eval_fortran(){{{
sub eval_fortran(){

my $x=$_[0];
$x =~ s/\s*//g;

return 1 if ($x =~ /^\.TRUE\.$/i);
return 0 if ($x =~ /^\.FALSE\.$/i);
return $x;
}
# }}}

# read_const(){{{
sub read_const(){

my @ifsconst=@{$files{constvars}};
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
sub read_TF(){

# read in true/false values
foreach my $switch (qw( false true )){
	if (-e "$switch.rif.dat" ){
		push(@{$files{$switch}},"$switch.rif.dat");
	}
	foreach (@{$files{$switch}}){
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
# read_init_vars(){{{
sub read_init_vars(){

	my $var;
	# read in initialized variable values 
	if ($opts{rinit}){
		open(IV,"<$files{initvars}") || die "$!";
		&eoolog("Reading in pre-initialized variable values...\n");
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
# read_all_vars() {{{
sub read_all_vars(){

if (-e $files{vars}){
	&eoolog("Reading in the list of variables from $files{vars}\n");
	open(V,"<$files{vars}") || die "$!";
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
# open_files(){{{
sub open_files(){

%files=( 
	%files,
	"log"			=> "$this_script.log",
	"logtex"		=> "log.$this_script.tex"	
);
if ($opts{"logname"}){
	$files{"log"}="$opts{logname}.log";
	$files{"logtex"}="log.$opts{logname}.tex";
}
# File handle for the testing-log file 
if ($opts{log}){
	foreach(@logtypes){
		if ($opts{appendlog}){
			open($fh{$_},">>$files{$_}") || die $!;
			&eoolog("Opening $_-file for appending:\n",echo=>1);
			&eoolog("	$files{$_}\n",echo=>1);
		}else{
			open($fh{$_},">$files{$_}") || die $!;
			&eoolog("Opening $_-file for write:\n",echo=>1);
			&eoolog("	$files{$_}\n",echo=>1);
		}
	}
}

}
# }}}
# cmd_opt_add(){{{
sub cmd_opt_add(){
	my @mycmdopts=@{$_[0]};
	my($type,$name);
	push(@cmdopts,@mycmdopts);
	foreach my $opt(@mycmdopts){
		$type=${$opt}{type} or $type='bool';
		$name=${$opt}{name};
		push(@{$cmd_opts{$type}},$name);
	}
}
# read_kw_file(){{{
sub read_kw_file(){

foreach my $type( qw(i s bool) ){
	next unless defined $cmd_opts{$type};
	foreach(@{$cmd_opts{$type}}){ 
		#print	;
		#$opts{$_}=0; 
	}
}

my $atype;
if (-e $files{tkw}){
	&eoolog("Reading in options for the script from the input keyword file:\n",out=>1);
	&eoolog("	$files{tkw}\n",out=>1);
	open(TKW,"<$files{tkw}") || die $!;
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
# edelim(){{{

sub edelim(){
	my $sfin;
	my $s="$_[0]";
	my $num=$_[1];
	$sfin=$s x $num . "\n";
	&eoolog($sfin);
}
# }}}
# eoo() {{{
sub eoo(){ print "$pref_eoo $_[0]"; }
# }}}
# eoolog() {{{
sub eoolog(){
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
# uniq() {{{
sub uniq() {
   my(@words,%h);
   %h  = map { $_ => 1 } @_;
   @words=keys %h;
   return @words;
}
#}}}
# setsdata() {{{

sub setsdata() {
	%sdata=( 
	  "desc"	=>	{ 
			short 	=> "do ...",
		  	long	=>	"...long description..."
		  },
	  "name" 	=>	"$this_script",
	  "sname"	=>	"$ts",
	  "usage"	=>	"This script performs ..."
	);
}
# }}}
# setcmdopts(){{{

sub setcmdopts(){
  my($o,$otype);
  
#  @cmdopts=( 
	#{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	#,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	#,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	#,{ name	=>	"i", 			desc	=>	"Short option"	}
	##,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  #);
  @opthaspar=qw( );
  $ncmdopts=scalar @cmdopts;
  for (my $iopt = 0; $iopt < $ncmdopts; $iopt++) {
	$o=$cmdopts[$iopt]{name};
	my @optnames=split(',',"$o");
	if ($#optnames eq 1){}
	push(@longopts,map { /^\w{2,}$/ } @optnames);
	if ( defined ($cmdopts[$iopt]{type}) ){
		$otype=$cmdopts[$iopt]{type};
		foreach (@optnames) {
			s/$/=$otype/g;
		}
	}	  
	push(@optstr,@optnames);
  }
}

# }}}
# getopt() {{{

sub getopt(){

	Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
	
	if ( !@ARGV ){ 
	  	pod2usage("Try '$this_script --help' for more information");
		exit 0;
	}else{
		$cmdline=join(' ',@ARGV);
		GetOptions(\%opt,@optstr);
	}
	foreach my $podo (@allowedpodoptions) {
		&printpod("$podo");
	}
	foreach (@longopts) {
		#if exists $shortlongopts{$_}
		#$opt{$_}=
	}
	pod2usage(-input=> $files{pod}{help}, -verbose => 1) if $opt{help};
	pod2usage(-input=> $files{pod}{help}, -verbose => 2) if $opt{man};
	pod2usage(-input=> $files{pod}{examples}, -verbose => 2) if $opt{examples};
	system("gvim -n -p $0") if $opt{vm};
	foreach my $k (keys %opt) {
		$opts{$k}=$opt{$k};
	}
}

#}}}
# is_log() is_const (){{{

sub is_log(){
	my $var=shift;
	if (defined($ftype{$var})){
		return 1 if ($ftype{$var} =~ /^logical/i) ;
	}
	return 0;
}

sub is_const(){
	my $var=shift;
	return 1 if (grep { uc($var) eq $_ } @constvars );
	return 0;
}
# }}}
# gettime () {{{

sub gettime(){
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
my $year = 1900 + $yearOffset;
my $time = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
return $time;
}

#}}}
# printpod(){{{
sub printpod(){
	my $topic=shift;
	my $o;
	open(POD,">$files{pod}{$topic}") || die $!;
		
	if (grep { $topic eq $_ } @allowedpodoptions ){
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
# readarr(){{{
sub readarr(){
 my $if=shift;
 open(FILE,"<$if") || die $!;
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
 return \@vars;
}
# }}}
# readhash(){{{
sub readhash(){
 my $if=shift;
 open(FILE,"<$if") || die $!;
 my %hash;
 while(<FILE>){
 	chomp;
 	s/^\s*//g;
 	s/\s*$//g;
 	next if (/^\s*#/ || /^\s*$/ );
 	my $line=$_;
 	my @F=split(' ',$line);
	my $var=shift @F;
	if (@F){ $hash{$var}=shift @F; }
 }
 close(FILE);
 return \%hash;
}
# }}}
# setfiles() {{{
sub setfiles() {
	foreach my $podo (@allowedpodoptions) {
		$files{pod}{$podo}="$sdata{sname}.$podo.pod";
	}
	$files{tkw}="$ts.kw.i.dat";
}
# }}}
# sbvars(){{{
sub sbvars(){
  $this_script=&basename($0);
( $ts=$this_script) =~ s/\.(\w+)$//g;
 $shd=&dirname($0);
 $pref_eoo="$this_script>";
 @allowedpodoptions=qw( help examples );
 %dirs=( 
	 pod	 => "pod"
 );
 foreach my $k (keys %dirs) {
 	mkdir $dirs{$k};
 }
}
# }}}

# &toLower(string); --- convert string into lower case

sub toLower {
   my($string) = $_[0];
   $string =~ tr/A-Z/a-z/;
   $string;
}

# }}}

# Module initialization
BEGIN { 
	&sbvars();
	&setsdata();
	&setfiles();
}

1;
# POD documentation {{{

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

OP::Base - Basic Perl functions and variables

=head1 SYNOPSIS

  use OP::Base;

=head1 DESCRIPTION

Stub documentation for OP::Base, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

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
