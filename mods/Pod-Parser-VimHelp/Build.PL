use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name       => 'Pod::Parser::VimHelp',
     dist_abstract     => 'Pod-to-VimHelp converter',
      license           => 'perl',
      script_files      => [qw( bin/pod2vimhelp.pl )],
    )->create_build_script;
