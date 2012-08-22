# package OP::Base; {{{
package OP::Base;

use 5.010001;

use strict;
use warnings;

use File::Basename;
use Getopt::Long;
use Pod::Usage;
use FindBin;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use OP::Base ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

our %EXPORT_TAGS = ( 
		# 'funcs' {{{
		'funcs'		=> [ qw( 
						eoo 
						getopt 
						gettime
						printpod 
						readarr 
						readhash 
						sbvars 
						setfiles 
						setsdata 
						setcmdopts 
						) ],
		# }}}
		# 'vars' 		{{{
		'vars' 		=>  [ qw( 
					$shd 
					$this_script 
					$ts 
					$pref_eoo 
					%files
					%dirs
					@cmdopts
					$ncmdopts
					@opthaspar
					$cmdline
					%opt
					@optstr
					@longopts
					
				) ] 
		# }}}
	);


our @EXPORT_OK = ( 
		@{ $EXPORT_TAGS{'funcs'} },
		@{ $EXPORT_TAGS{'vars'} }
	);

our @EXPORT = qw( );

our $VERSION = '0.01';

# Preloaded methods go here.
# }}}
# vars{{{

our($this_script,$ts,$shd,$pref_eoo,@allowedpodoptions);
our(%files,%dirs,%sdata,@cmdopts,$ncmdopts,@opthaspar);
our(%opt,@optstr,@longopts);
our($cmdline);
our(%shortlongopts);

# }}}
# subroutine declarations {{{

sub eoo;
sub getopt;
sub gettime;
sub printpod;
sub readarr;
sub readhash;
sub sbvars;
sub setfiles;
sub setsdata;
sub setcmdopts;

# }}}
# subs {{{

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
# eoo() {{{
sub eoo(){ print "$pref_eoo $_[0]"; }
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
}

#}}}
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
				$argopt{type}="short" if ($o =~ m/^\w$/);
				if ($o =~ m/^\s*(\w)\s*,\s*(\w+)\s*$/){
					$argopt{type}="mixed";
					$argopt{short}=$1;
					$argopt{long}=$2;
				}
				$argopt{type}="long" if ($o =~ m/^\s*(\w{2,})\s*$/);
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
# main() {{{
#sub main(){
  #&sbvars();
  #&setsdata();
  #&setfiles();
  #&setcmdopts();
  #&getopt();
#}
# }}}

# }}}

1;
# POD documentation {{{
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

OP::Base - Perl extension for blah blah blah

=head1 SYNOPSIS

  use OP::Base;
  blah blah blah

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

op, E<lt>op@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by op

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
# }}}
