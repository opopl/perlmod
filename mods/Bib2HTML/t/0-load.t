
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use lib '../';

plan tests => 35;

BEGIN {
    use_ok( 'Bib2HTML::Main' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Checker::Names' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::General::Encode' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::General::Error' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::General::HTML' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::General::Misc' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::General::Title' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::General::Verbose' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::AbstractGenerator' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::DomainGen' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::ExtendedGen' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::FileWriter' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::HTMLGen' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::LangManager' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::Lang' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::SQLGen' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::StdOutWriter' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::Theme' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::Writer' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::XMLGen' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::SqlEngine::MySql' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::SqlEngine::PgSql' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::Theme::Dyna' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Generator::Theme::Simple' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::JabRef::JabRef' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Parser::BibScanner' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Parser::Parser' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Parser::Scanner' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Parser::StateMachine' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Main' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Parser::Parser' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Release' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Translator::BibTeXEntry' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Translator::BibTeXName' ) || print "Bail out!\n";
    use_ok( 'Bib2HTML::Translator::TeX' ) || print "Bail out!\n";
}

diag( "Testing Bib2HTML::Main $Bib2HTML::Main::VERSION, Perl $], $^X" );
