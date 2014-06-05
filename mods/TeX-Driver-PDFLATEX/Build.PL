use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( dist_name             => 'Text-Driver-PDFLATEX',
      module_name           => 'Text::Driver::PDFLATEX',
      dist_author           => 'Oleksandr Poplavskyy',
      dist_abstract         => 'Perl wrapper around pdflatex TeX driver',
      license               => 'perl',
      dist_version          => '0.01',
      requires => {
          'List::Compare'   => 0,
      },
      recursive_test_files  => 1,
    )->create_build_script;
