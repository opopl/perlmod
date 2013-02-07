use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::BIBTEX',
      license         => 'perl',
	  dist_abstract  => 'OP::BIBTEX package'
    )->create_build_script;
