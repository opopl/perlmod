
use Module::Build;

Module::Build->new
    ( dist_name     		=> 'Text-Generate',
	  module_name 			=> 'Text::Generate::Base',
      dist_author     		=> 'O. Poplavskyy',
      dist_abstract   		=> 'Base class for formatted text generation',
      license         		=> 'perl',
      dist_version    	=> '0.01',
	  requires => {
		  'List::Compare' 				=> 0,
		  'Test::More' 					=> 0,
		  'File::Spec::Functions' 		=> 0,
		  'File::Temp' 					=> 0,
		  'Class::Accessor::Complex' 	=> 0,
		  'File::Slurp'				 	=> 0,
		  'IO::String'				 	=> 0,
		  'Try::Tiny'				 	=> 0,
	  },
	  recursive_test_files 	=> 1,
 	)->create_build_script;
