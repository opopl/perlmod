use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::Perl::Installer',
      license         => 'perl',
      dist_abstract        => 'Perl module for managing installation process for local modules',
    )->create_build_script;
