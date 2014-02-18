
use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( 
      dist_abstract       => 'PERLMOD',
      dist_name           => 'PERLMOD',
      dist_version        => '0.01',
      dist_author         => 'O.Poplavskyy',
      module_name         => 'OP::Base',
      license             => 'restrictive',
      requires            => { 
            'perl'        => '5.10.1',
      },
      script_files => {
        'bin/PerlModScript.pl'          => 'Interactive shell wrapper for OP::Perl::Installer',
      },
    )->create_build_script;
