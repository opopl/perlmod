use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Bib2HTML::Main',
    license             => 'perl',
    release_status      => 'stable',
    script_files         => [ qw( bin/bib2ml.pl 
								bin/bib2sql.pl 
								bin/bib2xml.pl ) ],
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     		=> [ 'Bib2HTML-*' ],
    create_makefile_pl 		=> 'traditional',
    dist_author          	=> ' ',
    dist_abstract          	=> ' ',
    dist_version_from   => 'lib/Bib2HTML/Main.pm'
);

$builder->create_build_script();
