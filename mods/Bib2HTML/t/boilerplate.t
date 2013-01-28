#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 37;

sub not_in_file_ok {
    my ($filename, %regex) = @_;
    open( my $fh, '<', $filename )
        or die "couldn't open $filename for reading: $!";

    my %violated;

    while (my $line = <$fh>) {
        while (my ($desc, $regex) = each %regex) {
            if ($line =~ $regex) {
                push @{$violated{$desc}||=[]}, $.;
            }
        }
    }

    if (%violated) {
        fail("$filename contains boilerplate text");
        diag "$_ appears on lines @{$violated{$_}}" for keys %violated;
    } else {
        pass("$filename contains no boilerplate text");
    }
}

sub module_boilerplate_ok {
    my ($module) = @_;
    not_in_file_ok($module =>
        'the great new $MODULENAME'   => qr/ - The great new /,
        'boilerplate description'     => qr/Quick summary of what the module/,
        'stub function definition'    => qr/function[12]/,
    );
}

TODO: {
  local $TODO = "Need to replace the boilerplate text";

  not_in_file_ok(README =>
    "The README is used..."       => qr/The README is used/,
    "'version information here'"  => qr/to provide version information/,
  );

  not_in_file_ok(Changes =>
    "placeholder date/time"       => qr(Date/time)
  );

  module_boilerplate_ok('lib/Bib2HTML/Main.pm');
  module_boilerplate_ok('lib/Bib2HTML/Checker/Names.pm');
  module_boilerplate_ok('lib/Bib2HTML/General/Encode.pm');
  module_boilerplate_ok('lib/Bib2HTML/General/Error.pm');
  module_boilerplate_ok('lib/Bib2HTML/General/HTML.pm');
  module_boilerplate_ok('lib/Bib2HTML/General/Misc.pm');
  module_boilerplate_ok('lib/Bib2HTML/General/Title.pm');
  module_boilerplate_ok('lib/Bib2HTML/General/Verbose.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/AbstractGenerator.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/DomainGen.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/ExtendedGen.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/FileWriter.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/HTMLGen.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/LangManager.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/Lang.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/SQLGen.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/StdOutWriter.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/Theme.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/Writer.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/XMLGen.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/SqlEngine/MySql.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/SqlEngine/PgSql.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/Theme/Dyna.pm');
  module_boilerplate_ok('lib/Bib2HTML/Generator/Theme/Simple.pm');
  module_boilerplate_ok('lib/Bib2HTML/JabRef/JabRef.pm');
  module_boilerplate_ok('lib/Bib2HTML/Parser/BibScanner.pm');
  module_boilerplate_ok('lib/Bib2HTML/Parser/Parser.pm');
  module_boilerplate_ok('lib/Bib2HTML/Parser/Scanner.pm');
  module_boilerplate_ok('lib/Bib2HTML/Parser/StateMachine.pm');
  module_boilerplate_ok('lib/Bib2HTML/Main.pm');
  module_boilerplate_ok('lib/Bib2HTML/Parser/Parser.pm');
  module_boilerplate_ok('lib/Bib2HTML/Release.pm');
  module_boilerplate_ok('lib/Bib2HTML/Translator/BibTeXEntry.pm');
  module_boilerplate_ok('lib/Bib2HTML/Translator/BibTeXName.pm');
  module_boilerplate_ok('lib/Bib2HTML/Translator/TeX.pm');


}

