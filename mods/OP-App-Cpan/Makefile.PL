use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.21";

WriteMakefile(
	'NAME'		    => 'OP::App::Cpan',
	'VERSION_FROM'  => 'lib/OP/App/Cpan.pm',
	'ABSTRACT'      => 'Interact with CPAN from the command line',
	'LICENSE'       => 'perl',
	'AUTHOR'        => '(OP) brian d foy <bdfoy@cpan.org>',

	'EXE_FILES' =>  [ 'script/opcpan' ],
	 
	'META_MERGE'    => {
		no_index => {
			directory => [qw(t inc examples)],
			}
		},
		
	'PREREQ_PM' => {
		'Test::More' => '0',
		'CPAN'       => '1.9301',
		},

	clean => { FILES => '*.bak App-* cpan-* cover_db' },
	);
