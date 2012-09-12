package OP::GOPS::MKDEP;

use strict;
use warnings;

our $VERSION='0.01';

# use... {{{
# 
# Changelog:
#
# Original makemake utility - Written by Michael Wester <wester@math.unm.edu> December 27, 1995
# Cotopaxi (Consulting), Albuquerque, New Mexico
#
# 14:19:31 (Sat, 26-Mar-2011):
#
# mkdep - put under git control by op
#

eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
if 0; #$running_under_some_shell

use File::Find ();
use Getopt::Long;
use Pod::Usage;
use Cwd;
use File::Basename;
use OP::Base qw/:vars :funcs/;
use File::Grep qw( fgrep fmap fdo );

# Set the variable $File::Find::dont_use_nlink if you're using AFS, since AFS cheats.
# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

my %regex=( 
	fortran =>	{
		"include_file" 			=> qr/^\s*include\s+["\']([^"\']+)["\']/i,
		"use_module" 				=> qr/^\s*use\s+([^\s,!]+)\s*,?/i,
		"declare_module" 		=> qr/\s*module\s+([^\s!]+)/i,
		"not_used_patterns" =>	qr/.*\.(inc|i|o|old|save|ref)\..*/,
		"prefix_slash"  		=> qr/^(.*)\//
	}
);

# }}}
# subroutine declarations {{{

sub set_these_cmdopts;
sub set_this_sdata;
sub main;
sub make_deps;
sub resolve_line;
sub remove_extension;
sub set_libs;

# }}}
# vars {{{

my %excluded=(
	"mpif.h" =>	"",
	"MPIF.H" =>	""
);

my(%libs,@libdirs,@modules);
my(%deps);
my($date);


# array for not-used fortran files which are taken from file nu.mk
my @nused;
# does the nu.mk file exist? 0 for no, 1 for yes
my $nu_exist;
my($PROGNAME);
my $fname;
my @nu_dirs;
my @fortranfiles;
my $fext;

# recursion level of calling a subroutine
my %lev_rec;
# makefile-related
my @mkfiles=qw( inc.mk t.mk def.mk );
my $VPATH;

# key - module name;
# value - in which files is used
my %usedin;

# all modules which were found 
# through the 'use' statement
my @aumods;
# those mods which are not in fortranfiles
my @exmods;
## additional fortran files, those
## which were not included in @fortranfiles and 
## originating from the list of all modules in
## @aumods
#my @addff;
#my @auff;
#my $auf;
#my $ff;
#my $iff;
#my %delff;
my $module_name;

my @source_search_dirs=qw( . );
# get the list of directories where to 
# search for used source
# 
my @used_source_search_dirs;
my($val,$var);

foreach my $f ( @mkfiles ){
		next unless -e $f;
		open(F,"<$f") || die $!;
		while(<F>){
			/^\s*USED_SOURCE_SEARCH_DIRS\s*:?=(.*)/;
			if (defined($1)){ 
				$val = $1;
				$val =~ s/\s*//g;
				push(@used_source_search_dirs,split(':',$val));
			}
		}
		close(F);
	}

# current project full path, e.g., /home/op226/gops/G
 $dirs{ppath}=&cwd();
# current program name, e.g., G
$PROGNAME=&basename($dirs{ppath});
# scripts/all/
$dirs{scripts}{all}=&dirname($0);
# $HOME/gops/
$dirs{root}="$dirs{scripts}{all}/../../";
$dirs{inc}="$dirs{root}/inc/";
$files{notused}="$dirs{inc}/nu_$PROGNAME.mk";

if (defined $opt{dpfile}){ $files{deps}="$dirs{ppath}/$opt{dpfile}"; }else{
	$files{deps}="deps.mk";}
open(DP, ">$files{deps}") or die $!; 
print DP "# Project dir: $dirs{ppath}\n";
print DP "# Program name: $PROGNAME\n";

#}}}
# subroutine bodies {{{

# new(){{{
sub new(){
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}
# }}}
# remove_extension(){{{
sub remove_extension(){
	my $self=shift;
	my $file=shift;
	$file =~ s/\.\w*$//g;
	return $file;
}
# }}}
# sets_this_sdata() {{{
sub set_this_sdata() {
	my $self=shift;

	$sdata{desc}{short}="Fortran dependency generator";
	$sdata{desc}{long}="...";
	$sdata{usage}="...";
}
# }}}
# set_these_cmdopts(){{{ 
sub set_these_cmdopts(){ 
  my $self=shift;

  my @mycmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{	name	=>	"dpfile", 		
			desc	=>	"Provide the filename of the dependency file", 
			type  =>	"s"
		}
	,{ 
			name	=>	"nolibs", 		
			desc	=>	"" }
	,{ 
			name	=>	"print_non_root", 			
			desc	=>	""	}
	,{ 
			name	=>	"flist", 			
			desc	=>	"Use the flist fortran files"	
		}
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
	&cmd_opt_add(\@mycmdopts);
}

#}}}
# wanted() get_unused() {{{

sub get_unused() {
	my $self=shift;
	#{{{
	$nu_exist=1;
  open(NUF, $files{notused}) or $nu_exist=0; 
  if ($nu_exist eq 1){
	  while(<NUF>){
		chomp;
		if( ! /^(#|d:)/ ){
			push(@nused,$_);
		}
		elsif( /^d:\s*(.*)/g ){
			push(@nu_dirs,$1);
			print DP "# Not used dir: $1\n";
		}
}
	foreach(@nused) { s/^\s+//; s/\s+$//; }
	close(NUF);
	}
# }}}
}

sub _used_source_wanted() {
	#{{{
    my ($dev,$ino,$mode,$nlink,$uid,$gid);
	my $dirname=$File::Find::dir;

    if ( ( /^.*\.(f90|f|F)\z/s) &&
    ( $nlink || (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) ) &&
    ( ! /^.*\.(save|o|old|ref)\..*\z/s ) &&
	( ! grep { $_ eq $dirname } @nu_dirs )
	) {
		$name=$_;
		if ( ! grep { $_ eq $name } @nused ) {
			if ( fgrep { /^\s*module\s+$module_name\s*$/i } "$name" ){
					#print "Pushing to \@fortranfiles: $dirname/$name\n";
					push(@fortranfiles,"$dirname/$name"); 
				}
			}
	}
#}}}
}

sub _wanted() {
	#{{{
    my ($dev,$ino,$mode,$nlink,$uid,$gid);
	( my $dirname = $File::Find::dir ) =~ s/$dirs{ppath}//g;
	$dirname =~ s/^(\.|\/)+//g;

    if ( ( /^.*\.(f90|f|F)\z/s) &&
    ( $nlink || (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) ) &&
    ( ! /^.*\.(save|o|old|ref)\..*\z/s ) &&
	( ! grep { $_ eq $dirname } @nu_dirs )
	) {
		$name =~ s/^\.\///; 
		if ( ! grep { $_ eq $name } @nused ) {
				push(@fortranfiles,"$name"); 
			}
	}
#}}}
}

#}}}
# PrintWords() {{{
sub PrintWords {
	my $self=shift;
	# &PrintWords(current output column, extra tab?, word list); --- print words nicely
   my($columns) = 78 - shift(@_);
   my($extratab) = shift(@_);
   my($wordlength);
   #
   print DP $_[0];
   $columns -= length(shift(@_));
   foreach my $word (@_) {
      $wordlength = length($word);
      if ($wordlength + 1 < $columns) {
	 print DP " $word";
	 $columns -= $wordlength + 1;
	 }
      else {
	 #
	 # Continue onto a new line
	 #
	 if ($extratab) {
	    print DP " \\\n\t\t$word";
	    $columns = 62 - $wordlength;
	    }
	 else {
	    print DP " \\\n\t$word";
	    $columns = 70 - $wordlength;
	    }
	 }
      }
}
# }}}
# resolve_line(){{{
sub resolve_line(){
	my $self=shift;
	my($line,$switch)=@_;
	if ( $line =~ m/$regex{fortran}{$switch}/ig ){ 
		if ($switch eq "include_file"){
				 if ( !exists $excluded{$1} ){
					# push(@incs, $1); 
					 my $include_file=$1;
					 open(IFILE,$include_file);
					 while(<IFILE>){
						chomp;	  
						$self->resolve_line($_,"use_module");
						$self->resolve_line($_,"include_file");
					 }
					close IFILE;
				 }
		 }elsif ($switch eq "use_module"){
				if (defined($1)){ 	
					my $mod=&toLower($1);
					push(@modules,$mod); 
					push(@aumods,$mod);
					if (!defined $usedin{$mod}){
						$usedin{$mod}=$fname;
					}else{
						$usedin{$mod}=$fname.' '.$usedin{$mod};
					}
					if ( ! grep { /$mod\.(f|f90)$/ } @fortranfiles ){
						push(@exmods,$mod);
					}
				}
		}
 	}
}
# }}}
# make_deps() {{{
sub make_deps() {
   my $self=shift;

   my $subname = (caller(0))[3];
   my(@dependencies);
   my(%filename);
   my($mo);
   my(@incs);
   my($mod);
   my($objfile);
	@aumods=qw();

	$date=localtime;

	print DP "#	-------------------------- \n";
	print DP "#	File: \n";
	print DP "#		$files{deps}\n";
	print DP "#	Program:\n";
	print DP "#		$PROGNAME\n";
	print DP "#	Purpose: \n";
	print DP "#		Contains Fortran object files dependencies\n";
	print DP "#	Created: \n";
	print DP "#		$date\n";
	print DP "#	Creating script:\n";
	print DP "#		$0\n";
	print DP "#	-------------------------- \n";


	if ( ! defined($lev_rec{$subname})){
		$lev_rec{$subname}=0;
	}else{
		$lev_rec{$subname}++;
	}

   # Associate each module with the name of the file that contains it {{{
   
   foreach my $file (@fortranfiles) {
      open(FILE, $file) || warn "Cannot open $file: $!\n";
      # get extension from the $file
      if ( $file =~ /.*\.(f|F|f90)$/ ){
				 $fext=$1;
      }
       # get the object name for the module
      while (<FILE>) {
	 			if (/^$regex{fortran}{declare_module}/){
					$mod=lc $1 if (defined($1));
		    		$filename{src}{$mod} = $file;
		    		($filename{obj}{$mod} = $file) =~ s/\.$fext$/.o/;
				}
	 		}
   }
   # }}}
   # Print the dependencies of each file that has one or more include's or
   # references one or more modules
   foreach my $file (@fortranfiles) {
      open(FILE, "<$file") || die $!;
	  $fname=$self->remove_extension($file);

      while(<FILE>){
	  		chomp; my $line=$_;
				next if (/^\s*!/ || /^\s*$/);
				$self->resolve_line($line,"use_module");
				$self->resolve_line($line,"include_file");
	  	}
	  	close(FILE);

      if ((@incs) || (@modules)) {
	 	 		($objfile = $file) =~ s/\.[^\.]+$/.o/g;
	 			if ( ( $objfile !~ /$regex{fortran}{prefix_slash}/ || $opt{print_non_root} ) 
			 		&& ( $objfile !~ /$regex{fortran}{not_used_patterns}/ )
	 				)
				{
					#{{{
	 				print DP "$objfile: ";
	 				undef @dependencies;
	 				foreach my $module (@modules) {
						if (defined $filename{src}{$module}){
	    				$mo=$filename{obj}{$module};

		    			foreach my $libdir (@libdirs){
		        		my $libname=$libs{$libdir};
								$mo =~ s/^$libdir\/.*/$libname/;
		    			}
			    		if ( ! exists $excluded{$mo} ){
				  			# check for not-used
				  			(my $moname=$mo) =~ s/\.o$//g;
					  			if ( ! grep { /^$filename{src}{$module}$/ } @nused ){
					    				push(@dependencies, $mo);
									}else{
											push(@{$deps{$file}{nused}},$mo);
									}
								}
		    		 }else{
								push(@{$deps{$file}{nexist}},$module);
						 }
	  			}
	 				if (@dependencies){
	 					@dependencies = &uniq(sort(@dependencies));
	 					$self->PrintWords(length($objfile) + 2, 0, @dependencies, &uniq(sort(@incs)));
	 				}
	 				print DP "\n";
 					#}}}
	 		}
	 		undef @incs;
	 		undef @modules;
	  	}
   }
	  foreach my $mode (qw( nexist nused)){
	 		print DP "# $mode dependencies:\n"; ;
	 		foreach my $file (@fortranfiles) {
				if (defined @{$deps{$file}{$mode}}){
					print DP "# 	$file =>  ";
					foreach (@{$deps{$file}{$mode}}) { print DP "$_ "; } 
					print DP "\n";
	 			}
			}
		}
	 	
			if ( ! @used_source_search_dirs){
				&eoo("Source search dirs were not given!\n");
			}
	  if (@exmods){
	  		@fortranfiles=qw();
			@exmods=sort(&uniq(sort(@exmods)));
			foreach (@exmods) {
					print("Ex Module: $_ $lev_rec{$subname}\n");
					$module_name=$_;
					if ( @used_source_search_dirs){
						File::Find::find({wanted => \&_used_source_wanted}, @used_source_search_dirs)  ;
					}
			}
			if (@fortranfiles) { 
				my $flist=join(' ',@fortranfiles);
				print "$flist\n";
				#&make_deps(); 
			}
		}
}
# }}}
# set_libs(){{{
sub set_libs(){
	my $self=shift;
	if (!$opt{nolibs}){
		%libs=(
			"CONNECT" 	=> "libnc.a",
			"NEB"		=> "libnn.a",
			"AMH"		=> "libamh.a",
			"libbowman.a"	=> "libbowman.a"
	     );
		@libdirs=keys %libs;
	}
}
# }}}
# get_fortranfiles(){{{
sub get_fortranfiles(){
	my $self=shift;
	if ($opt{flist}){
			@fortranfiles=map { chomp; $_; } `$shd/get_flist.pl --out --file`;
	}else{
			File::Find::find({wanted => \&_wanted}, @source_search_dirs)  ;
	}
}
# }}}

# }}}
# main() {{{

sub main() {
	my $self=shift;

  	$self->set_this_sdata();
  	$self->set_these_cmdopts();

    &OP::Base::setcmdopts();
  	&OP::Base::getopt();

	$self->set_libs();
  	$self->get_unused();
	$self->get_fortranfiles();

	$lev_rec{make_deps}=-1;

	$self->make_deps();

	print DP "# Level of recursion, make_deps:\n";
	print DP "#		 $lev_rec{make_deps}\n";
	
	close DP;
}
#}}}
			
1;
