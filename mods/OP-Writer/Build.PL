
use Module::Build;

Module::Build->new
    ( module_name     => 'OP::Writer',
      license         => 'perl',
      dist_abstract   => 'Base class for formatted text writing',
    )->create_build_script;
