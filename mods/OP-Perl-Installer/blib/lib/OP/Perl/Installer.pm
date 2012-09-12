package OP::Perl::Installer;

# package intro{{{
use strict;
use warnings;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

sub new
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}
# }}}
# use ... {{{


use File::Basename;
use File::Path qw(remove_tree);
use FindBin;
use Getopt::Long;
use Pod::Usage;
use Module::Build;
use lib("$FindBin::Bin/OP-Base/lib");
use OP::Base qw/:vars :funcs/;
use ExtUtils::ModuleMaker;

# }}}
# vars {{{
my(@modules);
# }}}
# subs {{{
# declarations {{{
sub add_modules;
sub remove_modules;
sub list_modules;
sub edit_modules;
sub set_these_cmdopts;
sub set_modules;
sub main;
sub module_to_path;
sub module_to_def;
sub def_to_module;
# }}}
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
	@modules=split(',',$opt{add});

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
	my(@emods,@files);
	@emods=split(',',$opt{edit});
	foreach my $module (@emods){ push(@files,$self->module_to_def($module) . "/lib/" . $self->module_to_path($module)); }
	foreach(@files){ s/^/$shd\/mods\//g; }
	system("gvim -n -p --remote-tab-silent @files");
	exit 0;
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
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
} 
#}}}
# set_modules(){{{
sub set_modules(){
	my $self=shift;
  #$files{mods}="$shd/inc/modules_to_install.i.dat";
  #@modules=@{&readarr($files{mods})};
  opendir(D,"$shd/mods/");
  while(my $file=readdir(D)){
	  next if $file =~ m/^\./;
	  push(@modules,$file);
  }
  closedir(D);
}
#}}}
# list_modules(){{{
sub list_modules(){
	my $self=shift;
	foreach my $mod (@modules) {
		my $module=$self->def_to_module($mod);
		print "$module\n" ;
	}
	exit 0;
}
# }}}
# run_build_install(){{{
sub run_build_install(){
	my $self=shift;
	my @exclude=qw( OP::Module::Build OP::GOPS );

	foreach my $mod (@modules) {
		my $dirmod="$shd/mods/" . $mod;
		my $module=$self->def_to_module($mod);
		print "$module\n";

		next if (grep { /^$module$/ } @exclude );

		chdir $dirmod;
	
	   	my $build=Module::Build->new(
			module_name => "$module"
			,license => 'perl'
		);
	
		&eoo("Building module: $module\n");

#		select $fh{log}; 
		$build->dispatch('build');

#		select STDOUT; 
		#&eoo("Testing module: $module\n");

##		select $fh{log}; 
		$build->dispatch('test', quiet => 1);

##		select STDOUT; 
		&eoo("Installing module: $module\n");

##		select $fh{log};
		$build->dispatch('install', install_base => "$ENV{HOME}" );
	}
	exit 0;
}
# }}}
# }}}
# main() {{{

sub main(){
  my $self=shift;

  &OP::Base::sbvars();
  &OP::Base::setsdata();
  &OP::Base::setfiles();

  $self->set_these_cmdopts();

  &OP::Base::setcmdopts();
  &OP::Base::getopt();

  $self->set_modules();
  $self->run_build_install() if ($opt{run} || $opt{r});
  $self->list_modules() if ($opt{list} || $opt{l});
  $self->edit_modules() if ($opt{edit} || $opt{e});
  $self->add_modules() if ($opt{add} || $opt{a});
  $self->remove_modules() if ($opt{rm});
}
# }}}

1;

