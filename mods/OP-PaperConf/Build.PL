use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::PaperConf',
      license         => 'perl',
      dist_abstract         => 'perl package for individual paper configurations',
    )->create_build_script;
