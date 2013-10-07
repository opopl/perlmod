use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::PackName',
      license         => 'perl',
      dist_abstract         => 'Perl package name extraction module',
    )->create_build_script;
