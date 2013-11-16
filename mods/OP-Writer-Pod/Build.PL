use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name           => 'OP::Writer::Pod',
      license               => 'perl',
      dist_abstract         => 'Writer for Pod files',
      requires  => {
          'OP::Writer' => 0,
      },
    )->create_build_script;
