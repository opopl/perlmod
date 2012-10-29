package OP::Perl::Installer;
# use ... {{{

use strict;
use warnings;

use lib ("/home/op/wrk/perlmod/mods/OP-Script/lib");

our $VERSION='0.01';
our @ISA=qw(OP::Script);
    
use OP::Script;
use File::Basename;
use File::Path qw(remove_tree);
use FindBin;
use Getopt::Long;
use Pod::Usage;
use Module::Build;
use lib("$FindBin::Bin/OP-Base/lib");
use OP::Base qw/:vars :funcs/;
use ExtUtils::ModuleMaker;
use Term::ShellUI;
use Data::Dumper;

# }}}
# Methods {{{

=head1 Methods

=cut

=head2 Initializations

=cut

sub new()
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);

	$self->init();

    return $self;
}

sub init(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__;
}

# module_to_path(){{{
sub module_to_path(){
	my $self=shift;
	# input: My::Module::Base
	# output My/Module/Base.pm
	my $module=shift;
	my @parts=split("::",$module);
	$parts[-1] =~ s/$/\.pm/g;
	my $path=join("/",@parts);
	return $path;
}
#}}}
# module_to_def(){{{
sub module_to_def(){
	my $self=shift;
	# input: My::Module::Base
	# output My-Module-Base
	my $module=shift;
	my $res=join("-",split("::",$module));
	return $res;
}
#}}}
# def_to_module(){{{
sub def_to_module(){
	my $self=shift;
	# input My-Module-Base
	# output: My::Module::Base
	my $def=shift;
	my $module=join("::",split("-",$def));
	return $module;
}
#}}}
# add_modules(){{{
sub add_modules(){
	my $self=shift;

	my(@modules,%mods,@files);

	my $s_modules_add=$opt{add} // shift;

	@modules=split(',',$s_modules_add);

	foreach my $module (@modules){ 
		push(@files,$self->module_to_def($module) . "/lib/" . $self->module_to_path($module)); 
		mkdir "$shd/mods/";
		mkdir "$shd/mods/" . $self->module_to_def($module);
		mkdir "$shd/mods/" . $self->module_to_def($module) . "/lib/";
		chdir "$shd/mods";
    	$mods{$module}=ExtUtils::ModuleMaker->new(
        	NAME 			=> "$module",
			LICENSE		 	=> "perl",
			BUILD_SYSTEM  	=> "Module::Build",
			COMPACT			=> 1
    	);
		$mods{$module}->complete_build();
	}
	foreach(@files){ s/^/$shd\/mods\//g; }
	print "@files\n";
	system("gvim -n -p --remote-tab-silent @files");
	exit 0;
}
# }}}
# remove_modules(){{{
sub remove_modules(){
	my $self=shift;
	my(@modules,%mods,@files);
	@modules=split(',',$opt{rm});

	foreach my $module (@modules){ 
		my $mdir="$shd/mods/" . $self->module_to_def($module);
		remove_tree($mdir) if ((-e $mdir) && (-d $mdir));
	}
	exit 0;
}
# }}}
# edit_modules(){{{
sub edit_modules(){
	my $self=shift;

	my(@emodules,@files);
	my $mfile;

	my $s_modules=$opt{edit} // shift;

	@emodules=split(',',$s_modules) if defined $s_modules;

	if($s_modules eq "_all"){
		@emodules=@{$self->{'modules'}};
	}elsif($s_modules eq "_sel"){
		@emodules=@{$self->{'select_modules'}};
	}

	foreach my $module (@emodules){ 
		$mfile=$self->module_to_def($module) . "/lib/" . $self->module_to_path($module);
		push(@files,$mfile);
   	}
	foreach(@files){ s/^/$shd\/mods\//g; }
	system("gvim -n -p --remote-tab-silent @files");
}
# }}}
# set_these_cmdopts(){{{ 
sub set_these_cmdopts(){ 
	my $self=shift;
  @cmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{ name	=>	"r", 			desc	=>	"Run the script"	}
	,{ name	=>	"l,list", 		desc	=>	"List the modules to be installed"	}
	,{ name	=>	"e,edit", 		desc	=>	"Edit the chosen modules", type=>"s"	}
	,{ name	=>	"a,add", 		desc	=>	"Create modules	 with the given names", type=>"s"	}
	,{ name	=>	"rm", 			desc	=>	"Remove module with the given names", type=>"s"	}
	,{ name =>  "sh",			desc    =>  "Run an interactive shell " }
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
} 
#}}}
# set_modules(){{{
sub set_modules(){
	my $self=shift;

  opendir(D,"$shd/mods/");
  while(my $file=readdir(D)){
	  next if $file =~ m/^\./;
	  push(@{$self->{mod_def_names}},$file);
	  push(@{$self->{modules}},$self->def_to_module($file));
  }
  
  $self->{select_modules}=[ qw( 
  	OP::Perl::Installer 
  	OP::GOPS::RIF
  	OP::Script
  )];

  closedir(D);
}
#}}}
# list_modules(){{{
sub list_modules(){
	my $self=shift;

	foreach my $mod (@{$self->{mod_def_names}}) {
		my $module=$self->def_to_module($mod);
		print "$module\n" ;
	}
}
# }}}
# run_build_install(){{{
sub run_build_install(){
	my $self=shift;
	my @exclude=qw( OP::Module::Build OP::GOPS );
	my @only=qw( 
		OP::GOPS::RIF 
		OP::Perl::Installer 
		OP::Script
		);

	foreach my $mod (@{$self->{mod_def_names}}) {
		my $dirmod="$shd/mods/" . $mod;
		my $module=$self->def_to_module($mod);

		next if (grep { /^$module$/ } @exclude );
		if (@only){
			next unless grep { /^$module$/ } @only;
		}

		chdir $dirmod;
	
	   	my $build=Module::Build->new(
			module_name => "$module"
			,license => 'perl'
		);
	
		$self->out( "Building module: $module\n" );

#		select $fh{log}; 
		$build->dispatch('build');

#		select STDOUT; 
		$self->out("Testing module: $module\n");

##		select $fh{log}; 
		$build->dispatch('test', quiet => 1);

##		select STDOUT; 
		$self->out("Installing module: $module\n");

##		select $fh{log};
		$build->dispatch('install', install_base => "$ENV{HOME}" );
	}
}
# }}}
# sub run_shell(){{{
sub run_shell(){
  my $self=shift;
  my $term = new Term::ShellUI(
      		commands => $self->{'shell_commands'},
			history_file => '~/.shellui-synopsis-history',
      );

  #print 'Using '.$term->{term}->ReadLine."\n";

  $term->prompt("i>");
  $term->run();
}
# }}}
# _complete_modules(){{{
sub _complete_modules(){
	my $self=shift;

	my $cmpl=shift;
	my $ref;

	if (defined $cmpl){
		foreach my $module (@{$self->{'modules'}}) {
			if ($module =~ m/^\s*$cmpl->{str}/i){
				print ref $cmpl->{str},"\n";
				push(@{$ref},"$module");
			}
		}
	}else{
		$ref=$self->{'modules'};
	}

	push(@{$ref},qw(_all _sel));
	return $ref;
}
# }}}
# init_vars(){{{

sub init_vars(){
	my $self=shift;

	$self->{'shell_commands'}=
		{ 
###cmd_help
			"help" => {
				desc => "Print helpful information",
				args => sub { shift->help_args(undef, @_); },
				method => sub { shift->help_call(undef, @_); }
			},
			 "h" =>  { alias => "help", exclude_from_completion => 1 },
             "q" => { alias => 'quit', exclude_from_completion => 1 },
###cmd_cd
			 "cd" => {
                  desc => "Change to directory DIR",
                  maxargs => 1, args => sub { shift->complete_onlydirs(@_); },
                  proc => sub { chdir($_[0] || $ENV{HOME} || $ENV{LOGDIR}); },
              },
###cmd_chdir
			 "chdir" => { alias => 'cd' },
              "lm" => { alias => 'list modules' },
###cmd_pwd
              "pwd" => {
                  desc => "Print the current working directory",
                  maxargs => 0, proc => sub { system('pwd'); },
              },
###scmd_rbi
              "rbi" => {
                  desc => "Run-build-install",
                  maxargs => 0, 
				  proc => sub { $self->run_build_install(); },
              },
###scmd_eam
              "eam" => {
                  desc => "Edit all Perl modules",
                  maxargs => 0, 
				  proc => sub { $self->edit_modules("_all"); },
              },
###scmd_esm
              "esm" => {
                  desc => "Edit selected Perl modules",
                  maxargs => 0, 
				  proc => sub { $self->edit_modules("_sel"); },
              },
###cmd_quit
              "quit" => {
                  desc => "Quit this program", 
				  maxargs => 0,
                  method => sub { shift->exit_requested(1); },
              },
###cmd_lm
			  "lm" => { 
				  desc => "List available modules",
				  proc => sub { $self->list_modules(); },
				  maxargs => 0
			  },
###cmd_list
			  "list" => {
				  desc => "List different things", 
				  cmds => {
				  		modules => {
							desc => "List available modules",
				  			proc => sub { $self->list_modules(); },
				  			maxargs => 0
						}
				  	}
			  },
###cmd_add
			  "add" => {
				  desc => "Add module",
				  maxargs => 1,
				  minargs => 1,
				  proc => sub { $self->add_modules(shift); },
				  args => sub { 
					  my $s=shift;
					  #$s->{debug_complete}=5;
					  $s->suppress_completion_append_character();
					  $self->_complete_modules(@_); 
				  }
			  },
###cmd_edit
			  "edit" => {
				  desc => "Edit module", 
				  maxargs => 1,
				  minargs => 1,
				  proc => sub { $self->edit_modules(shift); },
				  args => sub { 
					  my $s=shift;
					  #$s->{debug_complete}=5;
					  $s->suppress_completion_append_character();
					  $self->_complete_modules(@_); 
				  }
			  },

		  };

}
# }}}

# main() {{{

sub main(){
  my $self=shift;

  $self->get_opt();

  $self->init_vars();

  $self->set_modules();
  do { $self->run_build_install(); exit 0; } if ($opt{run} || $opt{r});
  do { $self->list_modules(); exit 0; } if ($opt{list} || $opt{l});
  do { $self->edit_modules(); exit 0; } if ($opt{edit} || $opt{e});
  $self->add_modules() if ($opt{add} || $opt{a});
  $self->remove_modules() if ($opt{rm});
  $self->run_shell() if ($opt{sh});
}
# }}}
# }}}
1;

