use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'File::Dat::Utils',
      license         => 'perl',
	  dist_version   => '0.01',
	  dist_abstract  => ' ',
    )->create_build_script;
