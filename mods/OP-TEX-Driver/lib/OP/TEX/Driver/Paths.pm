#============================================================= -*-perl-*-
#
# OP::TEX::Driver::Paths
#
# DESCRIPTION
#   Provides an interface to Latex from the Template Toolkit.
#
# AUTHOR
#   Andrew Ford    <a.ford@ford-mason.co.uk>
#
# COPYRIGHT
#   Copyright (C) 2007-2012 Andrew Ford.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# HISTORY
#   * Module extracted from Template::Latex module originally by Andy Wardley,
#     September 2007
#
#   $Id: Paths.pm 87 2012-08-31 19:10:26Z andrew $
#========================================================================
 
package OP::TEX::Driver::Paths;

use strict;
use warnings;

# LaTeX executable paths set at installation time by the Makefile.PL

our %program_path;

$program_path{latex}     = '/home/op/bin/perllatex';
$program_path{perltex}     = '/usr/bin/perltex';
$program_path{xelatex}   = '/usr/bin/xelatex';
$program_path{pdflatex}  = '/usr/local/texlive/2011/bin/i386-linux/pdflatex';
$program_path{bibtex}    = '/usr/local/texlive/2011/bin/i386-linux/bibtex';
$program_path{makeindex} = '/usr/local/texlive/2011/bin/i386-linux/makeindex';
$program_path{dvips}     = '/usr/local/texlive/2011/bin/i386-linux/dvips';
$program_path{dvipdfm}   = '/usr/local/texlive/2011/bin/i386-linux/dvipdfm';
$program_path{pdf2ps}    = '/usr/bin/pdf2ps';
$program_path{ps2pdf}    = '/usr/bin/ps2pdf';

1;

__END__

=head1 NAME

OP::TEX::Driver::Paths

=head1 SYNOPSIS

N/A - this file is only intended to be used from C<OP::TEX::Driver>

=head1 DESCRIPTION

This module defines the default paths for the LaTeX executables.  It
is updated by Makefile.PL.

=head1 AUTHOR

Andrew Ford E<lt>a.ford@ford-mason.co.ukE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2007 Andrew Ford.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
