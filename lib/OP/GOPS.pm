package OP::GOPS;

use warnings;
use strict;
use OP::Base;

require Exporter;

our $VERSION='0.01';
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

our(@coor);

1; 
# POD documentation {{{

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

OP::GOPS - Basic Perl functions and variables for the GOPS package

=head1 SYNOPSIS

  use OP::GOPS;

=head1 DESCRIPTION

Stub documentation for OP::Base, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Oleksandr Poplavskyy, E<lt>op@cantab.net<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Oleksandr Poplavskyy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
# }}}
