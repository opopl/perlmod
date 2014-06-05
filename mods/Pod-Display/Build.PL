
use Module::Build;

Module::Build->new
    ( dist_name             => 'Pod-Display',
      module_name           => 'Pod::Display::Pdf',
      dist_author           => 'Oleksandr Poplavskyy',
      dist_abstract         => 'Classes for displaying Pod in different formats',
      license               => 'perl',
      dist_version          => '0.01',
      requires => { },
      recursive_test_files  => 1,
    )->create_build_script;
