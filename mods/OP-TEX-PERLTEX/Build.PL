use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::TEX::PERLTEX',
      license         => 'perl',
	  requires 		 	=> {
	  	'OP::Script'	 			=> 0,
	  	'Safe'			 			=> 0,
	  	'Class::Accessor::Complex'	=> 0,
	  },
	  script_files     => [qw( scripts/perllatex )]
    )->create_build_script;
