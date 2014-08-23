
use Module::Build;

Module::Build->new
    ( dist_name             => 'Pod-Display',
      module_name           => 'Pod::Display::Pdf',
      dist_author           => 'Oleksandr Poplavskyy',
      dist_abstract         => 'Classes for displaying Pod in different formats',
      license               => 'perl',
      dist_version          => '0.01',
      requires => {
		  'Pod::LaTeX::Plus' 		=> 0,
		  'TeX::Driver::PDFLATEX' 	=> 0,
		  'Term::ShellUI'		 	=> 0,
		  'Text::Generate::TeX'		=> 0,
		  'File::Temp'				=> 0,
	  },
      recursive_test_files  => 1,
 	)->create_build_script;
