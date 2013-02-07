use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::TEX::Text',
      license         => 'perl',
	  dist_abstract	  => 'Perl module for writing LaTeX text'
    )->create_build_script;
