
use Module::Build;

Module::Build->new
    ( module_name     => 'Report::Trades',
      license         => 'perl',
      dist_abstract   => 'PostgreSQL database reporting tool',
      requires        =>  {
          'Class::Accessor::Complex' => 0,
          'DBI'                      => 0,
          'DBD::Pg'                  => 0,
          'Data::Dumper'             => 0,
          'Pod::Usage'               => 0,
          'Getopt::Long'             => 0,
          'IO::String'               => 0,
          'Mojolicious'              => 0,
          'List::MoreUtils'          => 0,
      },
      script_files    => 'scripts',
      recursive_test_files => 1,
    )->create_build_script;
