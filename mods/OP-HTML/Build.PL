
use Module::Build;

Module::Build->new
    ( module_name     => 'OP::HTML',
      license         => 'perl',
      dist_abstract  => 'Perl module for writing HTML',
      requires  => {
          OP::Writer  => 0,
      },
    )->create_build_script;
