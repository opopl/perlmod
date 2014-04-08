
package OP::Pod::LaTeX;

=head1 NAME 
 
OP::Pod::LaTeX
 
=cut
 
use warnings;
use strict;

use Pod::LaTeX; 
use OP::TEX::Text;

our @ISA=qw(Pod::LaTeX);
our $TEX;

BEGIN {
	$TEX=OP::TEX::Text->new;
}

sub _create_index {
  my $self = shift;

  my $paragraph = shift;
  my $suppress = (@_ ? 1 : 0 );

  # Remove latex commands
  $paragraph = $self->_clean_latex_commands($paragraph);

  # If required need to make sure that the index entry is unique
  # since it is possible to have multiple pods in a single
  # document
  if (!$suppress && $self->UniqueLabels() && defined $self->Label) {
    $paragraph = $self->Label() .'!'. $paragraph;
  }

  $paragraph =~ s{\*_}{\_}g;

  return $paragraph;

}



sub head {
  my $self = shift;

  my ($num,$paragraph,$parobj) = @_;

  # If we are replace 'head1 NAME' with a section
  # we return immediately if we get it
  return 
    if ($self->{_CURRENT_HEAD1} =~ /^NAME/i && $self->ReplaceNAMEwithSection());

  # Create a label
  my $label = $self->_create_label($paragraph);

  # Create an index entry
  my $index = $self->_create_index($paragraph);

  # Work out position in the above array taking into account
  # that =head1 is equivalent to $self->Head1Level

  my $level = $self->Head1Level() - 1 + $num;

  # Warn if heading to large
  if ($num > $#Pod::LaTeX::LatexSections) {
    my $line = $parobj->file_line;
    my $file = $self->input_file;
    warn "Heading level too large ($level) for LaTeX at line $line of file $file\n";
    $level = $#Pod::LaTeX::LatexSections;
  }

  # Check to see whether section should be unnumbered
  my $star = ($level >= $self->LevelNoNum ? '*' : '');

  # Section
  my $secname=$Pod::LaTeX::LatexSections[$level] . $star;

  $TEX->_clear;

  $TEX->_cmd($secname,$paragraph);
  $TEX->label($label);
  $TEX->index($index);

  $self->_output($TEX->text);
  $TEX->_clear;

}

sub verbatim {
  my $self = shift;

  my ($paragraph, $line_num, $parobj) = @_;

  # Expand paragraph unless in =begin block
  if ($self->{_dont_modify_any_para}) {
    # Just print as is
    $self->_output($paragraph);

  } else {

    return if $paragraph =~ /^\s+$/;

    # Clean trailing space
    $paragraph =~ s/\s+$//;

    # Clean tabs. Routine taken from Tabs.pm
    # by David Muir Sharnoff muir@idiom.com,
    # slightly modified by hsmyers@sdragons.com 10/22/01
    my @l = split("\n",$paragraph);
    foreach (@l) {
      1 while s/(^|\n)([^\t\n]*)(\t+)/
	$1. $2 . (" " x 
		  (8 * length($3)
		   - (length($2) % 8)))
	  /sex;
    }
    $paragraph = join("\n",@l);
    # End of change.
	$TEX->_clear;

	$TEX->begin('lstlisting');
	$TEX->_add_line($paragraph);
	$TEX->end('lstlisting');
	
	$self->_output($TEX->text);
 	$TEX->_clear;

  }
}

1;
