
use Module::Build;

Module::Build->new
    ( module_name     		=> 'Text::Generator::Base',
      license         		=> 'perl',
      dist_version    		=> '0.01',
      dist_author     		=> 'O. Poplavskyy',
      dist_abstract   		=> 'Base class for formatted text generation',
	  recursive_test_files 	=> 1,
 	)->create_build_script;
