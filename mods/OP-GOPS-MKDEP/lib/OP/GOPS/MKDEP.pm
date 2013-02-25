package OP::GOPS::MKDEP;
# intro {{{

=head1 INHERITANCE

L<Class::Accessor::Complex>, L<OP::Script>

=head1 USES

	use File::Find ();
	use Getopt::Long;
	use Pod::Usage;
	use Cwd;
	use File::Basename;
	use OP::Base qw/:vars :funcs/;
	use File::Grep qw( fgrep fmap fdo );

use OP::Base qw/:vars :funcs/;

=head1 ACCESSORS

=head2 Scalar Accessors

	nuexist - does the nu.mk file exist? 0 for no, 1 for yes

=head2 Array Accessors

	nused  -  array for not-used fortran files which are taken from file nu.mk
	nudirs -
	aumods -  all modules which were found through the 'use' statement
	exmods -  those mods which are not in fortranfiles

=head2 Hash Accessors

	rec_lev - recursion level of calling a subroutine

=cut

use strict;
use warnings;

our $VERSION='0.01';

###_USE
use File::Find ();
use Getopt::Long;
use Pod::Usage;
use Cwd;
use File::Basename qw(basename);
use OP::Base qw/:vars :funcs/;
use File::Grep qw( fgrep fmap fdo );

use OP::Base qw/:vars :funcs/;
use parent qw(OP::Script Class::Accessor::Complex);

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
	PROGNAME
	module_name
	nuexist
	val
	var
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
	deps
	dirs
	excluded
	files
	libs
	regex
	rec_lev
	usedin
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
	aumods
	exmods
	fortranfiles
	libdirs
	mkfiles
	modules
	nused
	nudirs
	source_search_dirs
	used_source_search_dirs

);

###_ACCESSORS
__PACKAGE__
	->mk_new
	->scalar_accessors(@scalar_accessors)
	->hash_accessors(@hash_accessors)
	->array_accessors(@array_accessors);

sub init_vars(){
	my $self=shift;

	$self->regex( 
		fortran =>	{
			"include_file" 				=> qr/^\s*include\s+["\']([^"\']+)["\']/i,
			"use_module" 				=> qr/^\s*use\s+([^\s,!]+)\s*,?/i,
			"declare_module" 			=> qr/\s*module\s+([^\s!]+)/i,
			"not_used_patterns" 		=> qr/.*\.(inc|i|o|old|save|ref)\..*/,
			"prefix_slash"  			=> qr/^(.*)\//
		}
	);

	# makefile-related
	$self->mkfiles(qw( inc.mk t.mk def.mk ));

	$self->source_search_dirs(qw( . ));
	
	# current project full path, e.g., /home/op226/gops/G
	$self->dirs( "ppath" => &cwd() );

	# current program name, e.g., G
	$self->PROGNAME( basename($self->dirs("ppath")) );

	$self->_set_ussd();
}

## scripts/all/
$dirs{scripts}{all}=&dirname($0);
# $HOME/gops/
$dirs{root}=catdir($dirs{scripts}{all},"..","..");
$dirs{inc}=catdir($dirs{root},"inc");

$$self->files( "notused" => "$dirs{inc}/nu_$PROGNAME.mk");

if (defined $opt{dpfile}){ $files{deps}="$dirs{ppath}/$opt{dpfile}"; }else{
	$files{deps}="deps.mk";}
open(DP, ">$files{deps}") or die $!; 
print DP "# Project dir: $dirs{ppath}\n";
print DP "# Program name: $PROGNAME\n";

#}}}
# Methods 											{{{

# new()												{{{

sub new(){
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}

# 													}}}
# remove_extension()								{{{

sub remove_extension(){
	my $self=shift;

	my $file=shift;

	$file =~ s/\.\w*$//g;

	return $file;
}
# }}}

sub _set_ussd(){
	my $self=shift;

	foreach my $f ( $self->mkfiles ){
			next unless -e $f;
			open(F,"<$f") || die $!;
			while(<F>){
				/^\s*USED_SOURCE_SEARCH_DIRS\s*:?=(.*)/;
				if (defined($1)){ 
					$val = $1;
					$val =~ s/\s*//g;
					$self->push_used_source_search_dirs(split(':',$val));
				}
			}
			close(F);
	}
}

# set_these_cmdopts()							{{{ 

sub set_these_cmdopts(){ 
  my $self=shift;

  my @mycmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{ name	=>	"dpfile", 		desc	=>	"Provide the filename of the dependency file", type  =>	"s" }
	,{ name	=>	"nolibs", 		desc	=>	"" }
   	,{ name	=>	"print_non_root", 			desc	=>	""	}
   	,{ name	=>	"flist", 			desc	=>	"Use the flist fortran files"	}
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
	&cmd_opt_add(\@mycmdopts);
}

#}}}
# wanted() _get_unused() 								{{{

sub _get_unused() {
	my $self=shift;

	$self->nuexist=1;
  open(NUF, $self->files("notused")) or $self->nuexist(0); 

  if ($self->nuexist eq 1){
	while(<NUF>){
		chomp;
		if( ! /^(#|d:)/ ){
			$self->nused_push($_);
		}
		elsif( /^d:\s*(.*)/g ){
			$self->nudirs_push($1);
			print DP "# Not used dir: $1\n";
		}
	}
	foreach($self->nused) { s/^\s+//; s/\s+$//; }
	close(NUF);
  }

}

sub _used_source_wanted() {
	#{{{
    my ($dev,$ino,$mode,$nlink,$uid,$gid);
	my $dirname=$File::Find::dir;

    if ( ( /^.*\.(f90|f|F)\z/s) &&
    ( $nlink || (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) ) &&
    ( ! /^.*\.(save|o|old|ref)\..*\z/s ) &&
	( ! grep { $_ eq $dirname } @{$self->nudirs} )
	) {
		$name=$_;
		if ( ! grep { $_ eq $name } @nused ) {
			if ( fgrep { /^\s*module\s+$module_name\s*$/i } "$name" ){
					#print "Pushing to \$self->fortranfiles: $dirname/$name\n";
					push($self->fortranfiles,"$dirname/$name"); 
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
	( ! grep { $_ eq $dirname } @{$self->nudirs} )
	) {
		$name =~ s/^\.\///; 
		if ( ! grep { $_ eq $name } @nused ) {
				push($self->fortranfiles,"$name"); 
			}
	}
#}}}
}

#}}}
# PrintWords() {{{

=head3 PrintWords()

=cut

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

=head3 resolve_line()

=cut

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
					if ( ! grep { /$mod\.(f|f90)$/ } $self->fortranfiles ){
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
	print DP "#		" . $self->PROGNAME . "\n";
	print DP "#	Purpose: \n";
	print DP "#		Contains Fortran object files dependencies\n";
	print DP "#	Created: \n";
	print DP "#		" . $self->date . "\n";
	print DP "#	Creating script:\n";
	print DP "#		$0\n";
	print DP "#	-------------------------- \n";


	if ( ! defined($rec_lev{$subname})){
		$rec_lev{$subname}=0;
	}else{
		$rec_lev{$subname}++;
	}

   # Associate each module with the name of the file that contains it {{{
   
   foreach my $file ($self->fortranfiles) {
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
   foreach my $file ($self->fortranfiles) {
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

		    			foreach my $libdir ($self->libdirs){
		        			my $libname=$libs{$libdir};
							$mo =~ s/^$libdir\/.*/$libname/;
		    			}
			    		unless( exists $excluded{$mo} ){
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
	 		foreach my $file ($self->fortranfiles) {
				if (@{$deps{$file}{$mode}}){
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
	  		$self->fortranfiles=qw();
			@exmods=sort(&uniq(sort(@exmods)));
			foreach (@exmods) {
					print("Ex Module: $_ $rec_lev{$subname}\n");
					$module_name=$_;
					if ( @used_source_search_dirs){
						File::Find::find({wanted => \&_used_source_wanted}, @used_source_search_dirs)  ;
					}
			}
			if ($self->fortranfiles) { 
				my $flist=join(' ',$self->fortranfiles);
				print "$flist\n";
				#&make_deps(); 
			}
		}
}
# }}}
# _set_libs()										{{{

sub _set_libs(){
	my $self=shift;

	unless ($self->_opt_true("nolibs")){
		$self->libs(
			"CONNECT" 	=> "libnc.a",
			"NEB"		=> "libnn.a",
			"AMH"		=> "libamh.a",
			"libbowman.a"	=> "libbowman.a"
	     );
		$self->libdirs( keys %libs );
	}
}
# 													}}}
# _get_fortranfiles()								{{{

=head3 _get_fortranfiles()

=cut

sub _get_fortranfiles(){
	my $self=shift;

	if ($self->_opt_true("flist")){
			$self->fortranfiles( map { chomp; $_; } `$shd/get_flist.pl --out --file` );
	}else{
			File::Find::find({wanted => \&_wanted}, @source_search_dirs)  ;
	}
}
# }}}

# }}}
# main() {{{

sub main() {
	my $self=shift;

	$self->init_vars();

	$self->get_opt();

	$self->_set_libs();
  	$self->_get_unused();
	$self->_get_fortranfiles();

	$self->make_deps();

	
	close DP;
}
#}}}
			
1;
__END__

=head1 CHANGELOG

Original makemake utility - Written by Michael Wester <wester@math.unm.edu> December 27, 1995
Cotopaxi (Consulting), Albuquerque, New Mexico

14:19:31 (Sat, 26-Mar-2011):

mkdep - put under git control by op

=cut
