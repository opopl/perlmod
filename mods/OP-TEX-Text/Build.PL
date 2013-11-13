use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'OP::TEX::Text',
      license         => 'perl',
	  dist_abstract	  => 'Perl module for writing LaTeX text',
      requires  => {
          OP::Writer  => 0,
          OP::Base  => 0,
          Data::Dumper  => 0,
          File::Slurp  => 0,
          File::Spec::Functions  => 0,
      },
    )->create_build_script;
