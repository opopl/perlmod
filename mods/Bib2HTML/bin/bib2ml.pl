#!/usr/bin/env perl 

# bib2html script to generate an HTML document for BibTeX database
# Copyright (C) 1998-09  Stephane Galland <galland@arakhne.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

use strict;
use warnings;

use FindBin qw($Bin $Script);

use Bib2HTML::Main;

Bib2HTML::Main->new->launchBib2HTML("$Bin","$Script");

=head1 NAME

bib2ml.pl - A perl script that generates an HTML documentation for a BibTeX database

=head1 SYNOPSYS

bib2html [options] F<file> [F<file> ...]

=head1 DESCRIPTION

bib2html is a script which permits to generate a set of HTML pages for
the entries of BibTeX files.

=head1 OPTIONS

=over 4

=item B<-[no]b>

=item B<--[no]bibtex>

This option permits to generate, or not, a verbatim of the
BibTeX entry code.

=item B<--[no]checknames>

This option permits to check if the some author's names are
similar and generates a set of warnings about each of them.

=item B<--cvs>

If specified, this option disables the deletion of the subfiles
'.cvs', 'CVS' and 'CVSROOT' in the output directory.

=item B<-d> I<name>[=I<value>]

See B<--generatorparam>.

=item B<--doctitle> I<text>

Sets the title that appears in the main page.

=item B<-f>

=item B<--force>

Forces to overwrite into the output directory.

=item B<-g> I<class>

=item B<--generator> I<class>

Sets the generator to use. I<class> must be a valid Perl class.

=item B<--generatorparam> I<name>[=I<value>]

Sets a generator param. It must be a I<key>=I<value> pair or
simply a I<name>.
Example: "target=thisdirectory" defines the parameter target
with corresponding value "thisdirectory". The specified
parameters which are not supported by the generator are
ignored.

=item B<--generatorparams>

Shows the list of supported parameters, and their
semantics for the current generator.

=item B<--genlist>

Shows the list of supported generators.

=item B<-?>

=item B<-h>

Show the list of available options.

=item B<--help>

See B<--man>.

=item B<--jabref>

The generator will translate JabRef's groups
into Bib2HTML's domains.

=item B<--lang> I<name>

Sets the language used by the generator.

=item B<--langlist>

Shows the list of supported language.

=item B<--man>

=item B<--manual>

Show the manual page.

=item B<-o> F<file>

=item B<--output> F<file>

Sets the directory or the F<file> in which the documentation will be put.

=item B<-p> F<file>

=item B<--preamble> F<file>

Sets the name of the F<file> to read to include some TeX preambles.
You could use this option to dynamicaly defined some unsupported
LaTeX commands.

=item B<--protect> F<shell_wildcard>

If specified, this option disables the deletion in the target
directory of the subfiles that match the specified shell
expression.

=item B<-q>

Don't be verbose: only error messages are displayed.

=item B<--[no]sortw>

Shows (or not) a sorted list of warnings.

=item B<--stdout>

Force the output of the generated files onto the standard output.
This option is equivalent to C<-d stdout>.

=item B<--svn>

If specified, this option disables the deletion of the subfiles
'.svn' and 'svn' in the output directory.

=item B<--texcmd>

Shows the list of supported LaTeX commands.

=item B<--theme> I<name>

Sets the theme used by the generator.

=item B<--themelist>

Shows the list of supported themes.

=item B<-v>

Be more verbose.

=item B<--version>

Show the version of this script.

=item B<--[no]warning>

If false, the warning are converted to errors.

=item B<--windowtitle> I<text>

Sets the title that appears as the window's title.

=back

=head1 LICENSE

S<GNU Public License (GPL)>

=head1 COPYRIGHT

S<Copyright (c) 1998-06 Stйphane Galland E<lt>galland@arakhne.orgE<gt>>

=head1 CONTRIBUTORS

=over

=item S<Aurel GABRIS E<lt>L<gabrisa@optics.szfki.kfki.hu>E<gt>>

=item S<Gasper JAKLIC E<lt>L<gasper.jaklic@fmf.uni-lj.si>E<gt>>

=item S<Tobias LOEW E<lt>L<loew@mathematik.tu-darmstadt.de>E<gt>>

=item S<Joao LOURENCO E<lt>L<joao.lourenco@di.fct.unl.pt>E<gt>>

=item S<Dimitris MICHAIL E<lt>L<michail@mpi-sb.mpg.de>E<gt>>

=item S<Luca PAOLINI E<lt>L<paolini@di.unito.it>E<gt>>

=item S<Norbert PREINING E<lt>L<preining@logic.at>E<gt>>

=item S<Cristian RIGAMONTI E<lt>L<cri@linux.it>E<gt>>

=item S<Sebastian RODRIGUEZ E<lt>L<sebastian.rodriguez@utbm.fr>E<gt>>

=item S<Martin P.J. ZINSER E<lt>L<zinser@zinser.no-ip.info>E<gt>>

=item S<Olivier HUGHES E<lt>L<olivier.hugues@gmail.com>E<gt>>

=back

=head1 SEE ALSO

L<latex>, L<bibtex>

