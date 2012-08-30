package OP::GOPS;

use warnings;
use strict;
use OP::Base;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 
	'funcs' => [ qw( ) ],
	'vars'	=> [ qw(
			   		@coor	
					) ]
);

our @EXPORT_OK = ( 
		@{ $EXPORT_TAGS{'funcs'} },
		@{ $EXPORT_TAGS{'vars'} }
	);

our @EXPORT = qw( );

our $VERSION = '0.01';


our(@coor);

1; 

