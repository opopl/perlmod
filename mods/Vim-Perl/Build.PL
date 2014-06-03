use Module::Build;

Module::Build->new
    ( 	module_name     	=> 'Vim::Perl',
		dist_name 			=> 'Vim-Perl'
      	license         	=> 'perl',
      	requires  => {
	          'File::Spec::Functions' => 0,
	          'OP::Base'              => 0,
	          'Text::TabularDisplay'  => 0,
	          'Data::Dumper'          => 0,
	          'File::Basename'        => 0,
	          'File::Slurp'           => 0,
      	}
    )->create_build_script;
