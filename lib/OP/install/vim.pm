#
package OP::install::vim;

use warnings;
use strict;

use feature qw(switch);

use warnings;
use strict;

 
use Exporter();
 
our $VERSION = "0.01";
our @ISA     = qw(Exporter);
 
our @EXPORT      = qw();
 
###export_vars_scalar
my @ex_vars_scalar=qw();
 
###export_vars_hash
my @ex_vars_hash=qw();
 
###export_vars_array
my @ex_vars_array=qw();
 
our %EXPORT_TAGS = (
###export_funcs
		funcs => [qw( 	
			main
		)],	
     vars  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);
 
our @EXPORT_OK = ( @{ $EXPORT_TAGS{funcs} }, @{ $EXPORT_TAGS{vars} } );
 


=head1 NAME

OP::install::vim 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut


###use
use Env qw( $hm $HOSTNAME $USER $hm );
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);
use File::Path qw(make_path);
use Term::ANSIColor;
use IPC::Cmd qw(run);
use OP::Time qw(fix_time elapsed_time );
use File::Slurp qw( write_file);
use OP::Base qw(readarr);

sub main;

###our
our @ACTIONS;
our $BDIR;
our $SEP_VIMOPT;
our %DEFAULT_OPTS;
our %BUILDS;
our @BUILDLIST;
our $VIMROOT;
our $CMD;
our $INDENT;
our $TEXTCOLOR;
our $BUILDROOT;

###subs
sub _action;
sub _say;

sub build;
sub build_write_iroot;
sub build_copy_source;
sub build_run;

sub init_vars;
sub opts_to_str;

sub set_BDIR;

sub set_BDIR {
	my $build=shift;

	$BDIR=catfile($hm,qw(builds vim),$build);
}

sub _say {
	my $text=shift;

	my $prefix=$Script . "> " . " " x $INDENT;

	eval "print color '" . $TEXTCOLOR . "';";
	die $@ if $@;

	print "$prefix$text" . "\n";
	print color 'reset';

}

sub opts_to_str {
	my %opts=@_;
	
	my @astr=();
	
		push(@astr," ");

		if($opts{perl}){
			push(@astr," --enable-perlinterp=yes"); 
		}

		if($opts{nogui} || !$opts{gui} ){
			push(@astr," --enable-gui=no"); 
			push(@astr," --without-x"); 
		}else{
			push(@astr," --enable-gui=gtk2"); 
			push(@astr," --with-x"); 
        }

		if($opts{ruby}){
			push(@astr," --enable-rubyinterp=yes"); 
		}

		if($opts{python}){
			push(@astr," --enable-pythoninterp=yes"); 
		}
		
		if($opts{cscope}){
			push(@astr," --enable-cscope=yes"); 
		}

		if($opts{xim}){
			push(@astr," --enable-xim=yes"); 
		}

		if($opts{"gtk2-check"}){
			push(@astr," --enable-gtk2-check"); 
		}

		if($opts{features}){
			push(@astr," --with-features=" . $opts{features}); 
		}
		
		if($opts{compiledby}){
			push(@astr," --with-compiledby=" . $opts{compiledby}); 
		}

	push(@astr,' --with-vim-name=vim' . $opts{suffix});

	my $str=join($SEP_VIMOPT,@astr);
	return $str;
}

sub main {

	init_vars;
	build;
}

sub init_vars {

    $VIMROOT=$ENV{VIM_ROOT_INSTALL} // catfile($hm,qw(wrk clones vim));

	$TEXTCOLOR="green";
	$INDENT=0;
	$SEP_VIMOPT="\\\n\t"; 

    $BUILDROOT=catfile($hm,qw(builds));
	
	%DEFAULT_OPTS=(
		suffix => '',
		perl => 1,
		python => 1,
		ruby => 1,
		gui => 1,
		cscope         => 1,
	    "xim"        => 1,
	    "gtk2-check" => 1,
	    "prefix"     => "$hm",
	    "features"   => 'huge',
	    "compiledby" => "$USER" . '@' . "$HOSTNAME",
	);
	
	# list of different vim builds
	%BUILDS=(
		default      => {
					features => 'huge',
					perl     => 1,
					python   => 0,
					ruby     => 0,
					gui      => 1,
		},
		tiny   => {
					features => 'tiny',
		},
		noperl => {
					perl     => 0,
					features => 'huge',
		},
		huge   => {
					features => 'huge',
		},
		normal => {
					features => 'normal',
		},
	);

	my $dat_builds=catfile($hm,qw(scripts inc installvim_builds.i.dat));
	my $dat_actions=catfile($hm,qw(scripts inc installvim_actions.i.dat));

	@BUILDLIST=readarr($dat_builds);
	@ACTIONS=readarr($dat_actions);

	foreach my $b (@BUILDLIST){
		next if ( grep { /^$b$/ } qw(default));

		$BUILDS{$b}->{suffix}="_$b";
	}
	
}

sub build_write_iroot {

	my $iroot=catfile($BUILDROOT,qw(iroot));
    make_path($BUILDROOT);
	_say "Writing root execution script: $iroot ";

	my @cmds=();
	push(@cmds,'#!/bin/bash');
	push(@cmds,' ');

	foreach my $build (@BUILDLIST){
		set_BDIR($build);

		push(@cmds,'if [ -d ' . $BDIR . ' ]; then ' );
		push(@cmds,'	cd ' . $BDIR);
		push(@cmds,'	./install.sh');
		push(@cmds,'fi');

	}
	write_file($iroot,join("\n",@cmds) . "\n" );
	system("chmod +rx $iroot");

}

sub build_copy_source {

###copy_source
	# first, copy the necessary file source files to the build
	#		directories
	foreach my $build (@BUILDLIST){

		$TEXTCOLOR="green";
		_say "Creating build directory for: $build ";

		set_BDIR($build);

		make_path($BDIR);
		chdir $BDIR;

		# create a separate directory for each build
		system("cp -r $VIMROOT/* .");

		my $log=catfile($VIMROOT,"i" . "_build_$build" . ".log");
		my $configure=catfile('.',qw(configure));
		my $installdir="$hm/vimdist/$build/";
		make_path $installdir;
		my $prefix="--prefix=$installdir";

		my @cmds;
		my %opts=%DEFAULT_OPTS;

		my %bopts=%{$BUILDS{$build}};
		foreach my $k(keys %bopts){
			$opts{$k}=$bopts{$k};
		}

		my $optstr=opts_to_str(%opts);
		$optstr.=$SEP_VIMOPT . $prefix;
		
        #### older version
	   # push(@cmds," ");
		#push(@cmds,'if (( $UID )); then ');

		#push(@cmds,"	make distclean");
		#push(@cmds,"	$configure $optstr | tee $log");
		
		#push(@cmds,"	make | tee -a $log");
		#push(@cmds,"	make install");

		#push(@cmds,'else ');
		#push(@cmds,'	cd src');
		#push(@cmds,'	make prefix=/usr/local installvimbin');
		#push(@cmds,'fi');

        #### newer version

        push(@cmds,"	make distclean");
        push(@cmds,"	$configure $optstr | tee $log");
        
        push(@cmds,"	make | tee -a $log");
        push(@cmds,"	make install");

		_say "Commands to be run: ";
		$INDENT++;
		$TEXTCOLOR="magenta";
		foreach my $cmd (@cmds) {
			_say "$cmd";
		}
		$INDENT--;

		unshift(@cmds,"#!/bin/bash");
		write_file("install.sh",join("\n",@cmds) . "\n");
		system("chmod +rx install.sh");

	}

}

sub build_run {

	foreach my $build (@BUILDLIST){
		$CMD="";

		_say "Processing build: ";
		$TEXTCOLOR="magenta";
		_say " " . $build ;
		$TEXTCOLOR="green";
		$INDENT++;

		set_BDIR($build);

		# change to the build's directory
		_say "Changed to $BDIR";
		chdir $BDIR;
		$CMD="install.sh";

		$TEXTCOLOR="bold green";
		_say "Running install.sh ...";
		
		my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
			IPC::Cmd::run( command => $CMD, verbose => 0 );

	}

}

sub _action {
	my $a=shift;

	eval 'build_' . $a;
	die $@ if $@;

}

sub build_intro_msg {

	_say "Actions to be performed: " ;
	$TEXTCOLOR="magenta";
	_say " " . join(' ',@ACTIONS);
	$TEXTCOLOR="green";
	
	_say "Builds to be done: " ;
	$TEXTCOLOR="magenta";
	_say " " . join(' ',@BUILDLIST);
	$TEXTCOLOR="green";

}

sub build {

	fix_time;
	
	foreach my $a (@ACTIONS) {
		_action($a);
	}

	_say "Total elapsed time is: " . elapsed_time();
}


1;
