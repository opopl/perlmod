use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::PSH::PEF',
      license         => 'perl',
    )->create_build_script;
