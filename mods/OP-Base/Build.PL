use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::Base',
      license         => 'perl',
      requires        => { 
			File::Basename        => 0,
			Getopt::Long          => 0,
			Pod::Usage            => 0,
			Data::Dumper          => 0,
			FindBin               => 0,
			File::Spec::Functions => 0,
			File::Slurp           => 0,
      }
    )->create_build_script;
