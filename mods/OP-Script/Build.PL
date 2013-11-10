use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::Script',
      license         => 'perl',
      requires  => { 
		 File::Basename        => 0,
		 File::Util            => 0,
		 Getopt::Long          => 0,
		 Pod::Usage            => 0,
		 File::Spec::Functions => 0,
		 Term::ANSIColor       => 0,
		 Data::Dumper          => 0,
		 IPC::Cmd              => 0,
		 OP::Base              => 0,
		 OP::VIMPERL           => 0,
      },
    )->create_build_script;
