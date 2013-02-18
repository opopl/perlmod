# Copyright (C) 2002-09  Stephane Galland <galland@arakhne.org>
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

package Bib2HTML::Main;
# intro {{{

=head1 NAME

Bib2HTML::Main 

=head1 DESCRIPTION

Bib2HTML::Main - Perl class which invokes the Bib2HTML engine
to do the actual BibTeX-to-HTML conversion.

=head1 SYNOPSIS

	use FindBin qw($Bin $Script);

	use Bib2HTML::Main;

	Bib2HTML::Main->new->launchBib2HTML("$Bin","$Script");

=head1 INHERITANCE

L<Class::Accessor::Complex>

=head1 USES

	use Pod::Usage;
	use Getopt::Long ;
	use File::Basename ;
	use File::Spec::Functions qw(catfile catdir curdir updir);
	use File::Path ;
	use FindBin qw($Bin $Script);

	use Bib2HTML::Release ;
	use Bib2HTML::General::Verbose ;
	use Bib2HTML::General::Error ;
	use Bib2HTML::General::Misc ;
	use Bib2HTML::Parser::Parser ;

=head1 ACCESSORS

=head2 Scalar accessors

=begin html 

<table border='1'>
	<tr><td>AUTHOR</td></td></tr>
	<tr><td>AUTHOR_EMAIL</td></tr>
	<tr><td>DEFAULT_GENERATOR</td></tr>
	<tr><td>DEFAULT_LANGUAGE</td></tr>
	<tr><td>DEFAULT_THEME</td></tr>
	<tr><td>GENERATOR</td></tr>
	<tr><td>PERLSCRIPT</td></tr>
	<tr><td>PERLSCRIPTDIR</td></tr>
	<tr><td>PERLSCRIPTNAME</td></tr>
	<tr><td>SUBMIT_BUG_URL</td></tr>
	<tr><td>URL</td></tr>
	<tr><td>VERSION</td></tr>
	<tr><td>VERSION_DATE</td></tr>
</table>

=end html

=head2 Array accessors

=head2 Hash accessors

=over 4 

=item CONTRIBUTORS

=item options - command-list options

=back

=cut

our @EXPORT = qw( &launchBib2HTML ) ;
our @EXPORT_OK = qw();

###_USE
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

use Pod::Usage;
use Getopt::Long ;
use File::Basename ;
use File::Spec::Functions qw(catfile catdir curdir updir);
use File::Path;
use FindBin qw($Bin $Script);

use lib("$Bin");

use Bib2HTML::Release;
use Bib2HTML::General::Verbose;
use Bib2HTML::General::Error;
use Bib2HTML::General::Misc;
use Bib2HTML::Parser::Parser;

use parent qw(Class::Accessor::Complex);

our $VERSION='op-1';

###_ACCESSORS_HASH
our @hash_accessors=qw(
	CONTRIBUTORS
	options
);

###_ACCESSORS_SCALAR
our @scalar_accessors=qw(
	AUTHOR
	AUTHOR_EMAIL
	DEFAULT_GENERATOR
	DEFAULT_LANGUAGE
	DEFAULT_THEME
	GENERATOR
	PERLSCRIPT
	PERLSCRIPTDIR
	PERLSCRIPTNAME
	SUBMIT_BUG_URL
	URL
	VERSION
	VERSION_DATE
);

our @array_accessors=qw();
###_ACCESSORS

__PACKAGE__
	->mk_new
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

# }}}
# check_output() {{{

=head3 check_output()

Returns the directory where the output HTMLs are stored.
By default, it is called bib2html.

=cut

sub check_output(){
  my $self=shift;

  my $output = $self->options("output");
  my $force = $self->options("force");

  $output = catdir( ".", "bib2html" )
   		unless $output;

  if ( ( -e "$output" ) && ( ! $force ) ) {
    Bib2HTML::General::Error::syserr( "The output '$output".
				      "' already exists. Use the -f option to force the overwrite\n" ) ;
  }
  return "$output" ;
}

# }}}
# show_usage() {{{

=head3 show_usage()

=cut

sub show_usage() {
  my $self=shift;

  my %opts=@_;

  my $mode=$opts{mode} // '';
  my $modes={
	  'help' 	=> 1,
	  'man' 	=> 2
  };
  my $modeval=$modes->{$mode} // '';

  return 1 unless $modeval;

  pod2usage( 
	  -input  		=> $self->PERLSCRIPT,
	  -exitval		=> 0,
	  -verbose	 	=> $modeval
  );

}

# }}}
# init_vars() {{{

=head3 init_vars()

=cut

sub init_vars() {
	my $self=shift;

	# Version number of bib2html

	#our $VERSION = Bib2HTML::Release::getVersionNumber() ;
	$self->VERSION($VERSION);

	# Date of this release of bib2html
	$self->VERSION_DATE(Bib2HTML::Release::getVersionDate());

	# URL from which the users can submit a bug
	$self->SUBMIT_BUG_URL(Bib2HTML::Release::getBugReportURL());

	# Email of the author of bib2html
	$self->AUTHOR(Bib2HTML::Release::getAuthorName());

	# Email of the author of bib2html
	$self->AUTHOR_EMAIL(Bib2HTML::Release::getAuthorEmail()) ;

	# Page of bib2html
	$self->URL(Bib2HTML::Release::getMainURL()) ;

	# Contributors to Bib2HTML
	my %CONTRIBUTORS = Bib2HTML::Release::getContributors() ;
	
	# Default Generator
	$self->DEFAULT_GENERATOR('HTML');
	# Default Language
	$self->DEFAULT_LANGUAGE('English');
	# Default Theme
	$self->DEFAULT_THEME('Simple') ;

	# Read the command line
	my $options={
		warnings 	=> 1,
		genphpdoc 	=> 1,
		generator 	=> $self->DEFAULT_GENERATOR,
		lang 		=> $self->DEFAULT_LANGUAGE,
		theme 		=> $self->DEFAULT_THEME,
		genparams 			=> {} ,
		'show-bibtex' 		=> 1 ,
		'verbose' 			=> 0,
		'quiet' 			=> 0,
		'genlist'  			=> 0,
		'tex-preamble'  	=> '',
		help  				=> 0
	};

###_OPTIONS_FALSE
	my @false=qw( 
		check-names
		genlist 
		genparamlist
		help 
		force
		jabref
		langlist
		manual
		quiet 
		show-bibtex 
		sort-warnings
		tex-commands
		title
		themelist
		version
		wintitle
		);
	my @true=qw(verbose);

	foreach (@false) { $options->{$_}=0; };
	foreach (@true) { $options->{$_}=1; };
	$self->options($options);

	#body ...
}

# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt(){
  my $self=shift;
 
  my %options=$self->options;

  Getopt::Long::Configure(qw(bundling));

  unless( GetOptions( "b|bibtex!" => \$options{'show-bibtex'},
		     "checknames" => \$options{'check-names'},
		     "cvs" => sub {
		       @{$options{'protected_files'}} = ()
		         unless ( exists $options{'protected_files'} ) ;
		       push @{$options{'protected_files'}}, ".cvs", "CVSROOT", "CVS" ;
		     },
		     "doctitle=s" => \$options{'title'},
		     "f|force" => \$options{'force'},
		     "generator|g=s" => \$options{'generator'},
		     'generatorparam|d:s%' => sub {
		       my $name = lc($_[1]) ;
		       @{$options{'genparams'}{"$name"}} = ()
		         unless ( exists $options{'genparams'}{"$name"} ) ;
		       push @{$options{'genparams'}{"$name"}}, $_[2] ;
		     },
		     "generatorparams!" => \$options{'genparamlist'},
		     "genlist" => \$options{'genlist'},
		     "h|help|?" => \$options{'help'},
		     "man|manual" => \$options{'manual'},
		     "jabref!" => \$options{'jabref'},
		     "lang=s" => \$options{'lang'},
		     "langlist" => \$options{'langlist'},
		     "o|output=s" => sub {
		       $options{'output'} = $_[1];
		       delete $options{'stdout'};
		     },
		     "p|preamble=s" => \$options{'tex-preamble'},
		     "protect=s" => sub {
		       my $regex = lc($_[1]) ;
		       @{$options{'protected_files'}} = ()
		         unless ( exists $options{'protected_files'} ) ;
		       push @{$options{'protected_files'}}, $regex ;
		     },
		     "q" => \$options{'quiet'},
		     "sortw!" => \$options{'sort-warnings'},
		     "stdout" => sub {
		       delete $options{'output'};
		       $options{'stdout'} = 1;
		     },
		     "svn" => sub {
		       @{$options{'protected_files'}} = ()
		         unless ( exists $options{'protected_files'} ) ;
		       push @{$options{'protected_files'}}, ".svn", "svn" ;
		     },
		     "texcmd" => \$options{'tex-commands'},
		     "theme=s" => \$options{'theme'},
		     "themelist" => \$options{'themelist'},
		     "v+" => \$options{'verbose'},
		     "version" => \$options{'version'},
		     "warning!" => \$options{'warnings'},
		     "windowtitle=s" => \$options{'wintitle'},
		   )) {
    $self->show_usage('help');
  }

  $self->options(%options);

}

# }}}
# launchBib2HTML() {{{

=head3 launchBib2HTML()

=cut

sub launchBib2HTML() {
  my $self=shift;

  $self->PERLSCRIPTDIR(shift);
  $self->PERLSCRIPTNAME(shift);

  $self->PERLSCRIPT(catdir($self->PERLSCRIPTDIR,$self->PERLSCRIPTNAME));

  die "Could not find the location of the script: " 
  	. $self->SCRIPT unless $self->PERLSCRIPT;

  $self->init_vars();

  $self->get_opt();

  # Command line options
  my %options = () ;

  # Generator class
  if ( $self->options('generator') !~ /::/ ) {
    $self->options(
		'generator' => "Bib2HTML::Generator::" .$self->options('generator') ."Gen" );
  }
  eval "require ".$self->options('generator').";" ;
  if ( $@ ) {
    Bib2HTML::General::Error::syserr( "Unable to find the generator class: "
		.$self->options('generator')
		."\n$@\n" ) ;
  }

  # Show the version number
  if ( $self->options("version") ) {

    my $final_copyright = 1998;
    if ($self->VERSION_DATE =~ /^([0-9]+)\/[0-9]+\/[0-9]+$/) {
      if ($1<=98) {
        $final_copyright = 2000 + $1;
      }
      elsif ($1==99) {
        $final_copyright = 1999;
      }
      else {
        $final_copyright = $1;
      }
    }

    if ($final_copyright!=1998) {
      $final_copyright = "1998-$final_copyright";
    }

    print "bib2html " .  $self->VERSION . ", " . $self->VERSION_DATE . "\n" ;
    print "Copyright (c) $final_copyright, " 
		. $self->AUTHOR 
		. " <" 
		. $self->AUTHOR_EMAIL
		. " > ,  under GPL " . "\n" ;

    print "Contributors:\n" ;
    while ( my ($email,$name) = each(%{$self->CONTRIBUTORS}) ) {
      print "  $name <$email>\n" ;
    }
    exit 1 ;
  }

  # Show the list of generators
###_OPTIONS_GENLIST
  if ( $self->options("genlist") ) {
    use Bib2HTML::Generator::AbstractGenerator;
    Bib2HTML::Generator::AbstractGenerator::display_supported_generators
		($self->PERLSCRIPTDIR,$self->DEFAULT_GENERATOR);
    exit 1 ;
  }

  # Show the list of languages
###_OPTIONS_LANGLIST
  if ( $self->options("langlist") ) {
    use Bib2HTML::Generator::AbstractGenerator ;
    Bib2HTML::Generator::AbstractGenerator::display_supported_languages(
		$self->PERLSCRIPTDIR,$self->DEFAULT_LANGUAGE);
    exit 1 ;
  }

  # Show the list of themes
  if ( $self->options('themelist') ) {
    use Bib2HTML::Generator::AbstractGenerator ;
    Bib2HTML::Generator::AbstractGenerator::display_supported_themes(
		$self->PERLSCRIPTDIR, $self->DEFAULT_THEME);
    exit 1 ;
  }

  # Show the list of themes
  if ( $self->options('tex-commands') ) {
    use Bib2HTML::Translator::TeX ;
    Bib2HTML::Translator::TeX::display_supported_commands($self->PERLSCRIPTDIR) ;
    exit 1 ;
  }

  # Show the list of generator params
  if ( $self->options('genparamlist') ) {
    ($self->options('generator'))->display_supported_generator_params() ;
    exit 1 ;
  }

  # Show the help screens
###_OPTIONS_HELP
  $self->show_usage(mode => 'man') if $self->options("manual");

  if ( $self->options("help") || ( $#ARGV < 0 ) ) {
    $self->show_usage(mode => 'help') ;
  }

  # Force the output to stdout
  if ( $self->options('stdout') ) {
     my $name = "stdout" ;
     $self->options('genparams')->{"stdout"} = [1];
  }

  #
  # Sets the default values of options
  #
  # Titles:

  # Verbosing:
  if ( $self->options("quiet") ) {
    $self->options(verbose => -1);
  }
  Bib2HTML::General::Verbose::setlevel( $self->options("verbose") ) ;

  # Error messages:
  if ( $self->options('warnings') ) {
    Bib2HTML::General::Error::unsetwarningaserror() ;
  }
  else {
    Bib2HTML::General::Error::setwarningaserror() ;
  }
  if ( $self->options('sort-warnings') ) {
    Bib2HTML::General::Error::setsortwarnings() ;
  }
  else {
    Bib2HTML::General::Error::unsetsortwarnings() ;
  }

  #
  # Create the output directory
  #
  unless ($self->options('stdout')) {
    $self->options('output' => $self->check_output());
  }

  # Read the BibTeX files
  my $parser = new Bib2HTML::Parser::Parser($self->options('show-bibtex')) ;
  if ( $self->options('tex-preamble') ) {
    $parser->read_preambles( $self->options('tex-preamble') ) ;
  }
  $parser->parse( \@ARGV ) ;

  # Check if the names of the authors are similars
  if ( $self->options('check-names') ) {
    eval "require Bib2HTML::Checker::Names;" ;
    if ( $@ ) {
      Bib2HTML::General::Error::syserr( "Unable to find the generator class: Bib2HTML::Checker::Names\n$@\n" ) ;
    }
    my $check = new Bib2HTML::Checker::Names() ;
    $check->check($parser->content()) ;
  }

  # Translate the entries according to the JabRef tool
###_OPTIONS_JABREF
  if ($self->options('jabref')) {
    use Bib2HTML::JabRef::JabRef;

    my $jabref = new Bib2HTML::JabRef::JabRef();

    $jabref->parse($parser->content());
  }

  # Create the generator
  #
###_GENERATOR_CREATE
  Bib2HTML::Generator::LangManager::set_default_lang($self->DEFAULT_LANGUAGE);

  my $generator = ($self->options('generator'))->new( $parser->content(),
					        $self->options('output'),
					        { 'VERSION' => $VERSION,
					  	  'BUG_URL' => $self->SUBMIT_BUG_URL,
						  'URL' => $self->URL,
						  'AUTHOR_EMAIL' => $self->AUTHOR_EMAIL,
						  'AUTHOR' => $self->AUTHOR,
						  'PERLSCRIPTDIR' => $self->PERLSCRIPTDIR,
					        },
					        { 'SHORT' => $self->options('wintitle'),
						  'LONG' => $self->options('title'),
					        },
					        $self->options('lang'),
					        $self->options('theme'),
					        $self->options('show-bibtex'),
					        $self->options('genparams') ) ;
  $self->GENERATOR($generator);

  if ($self->options('protected_files')) {
    $self->GENERATOR->set_unremovable_files(@{$self->options('protected_files')});
  }

  # Generates the HMTL pages
  #
###_GENERATOR_GENERATE
  $self->GENERATOR->generate();

  # Display the quantity of warnings
  Bib2HTML::General::Error::printwarningcount() ;

  exit 0 ;
}

# }}}

1;
__END__
