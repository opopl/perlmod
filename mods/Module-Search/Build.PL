
use Module::Build;

Module::Build->new
    ( dist_name             => 'Module-Search',
      module_name           => 'Module::Search',
      dist_author           => 'Oleksandr Poplavskyy',
      dist_abstract         => 'Simple perl module searching tool',
      license               => 'perl',
      dist_version          => '0.01',
      requires => {
          'File::Find'                  => 0,
      },
      recursive_test_files  => 1,
    )->create_build_script;
