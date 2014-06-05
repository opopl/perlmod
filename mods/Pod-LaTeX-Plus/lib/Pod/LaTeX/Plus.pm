
package Pod::LaTeX::Plus;

=head1 NAME 
 
Pod::LaTeX::Plus
 
=cut
 
use warnings;
use strict;

use Pod::LaTeX; 
use Text::Generate::TeX;
use Carp;

our @ISA=qw( Pod::LaTeX );
our $TEX;

our %HTML_Escapes;

*HTML_Escapes=*Pod::LaTeX::HTML_Escapes;

BEGIN {
	$TEX=Text::Generate::TeX->new;
}

=head3 interior_sequence

X<interior_sequence,Pod::LaTeX::Plus>
 
=head4 Usage
 
  	interior_sequence( $seq_command, $seq_argument, $pod_seq );
 
=head4 Purpose

Interior sequence expansion
 
=head4 Input
 
=over 4
 
=item * C<$seq_command> 

=item * C<$seq_argument> 

=item * C<$pod_seq> 
 
=back
 
=head4 Returns
 
=head4 See also
 
=cut
 

sub interior_sequence {
  my $self = shift;

  my ($seq_command, $seq_argument, $pod_seq) = @_;

  $TEX->_clear;

  if ( $seq_command ~~ [qw( B I C F X )] ){

	  if ($seq_command eq 'B') {
		$TEX->textbf($seq_argument);
	
	  } elsif ($seq_command eq 'I') {
		$TEX->textit($seq_argument);
	
	  } elsif ($seq_command eq 'C') {
		$TEX->texttt($seq_argument);
	
	  } elsif ($seq_command eq 'F') {
		$TEX->emph($seq_argument);
	
	  } elsif ($seq_command eq 'X') {
	    # Index entries
	
	    # use \index command
	    # I will let '!' go through for now
	    # not sure how sub categories are handled in X<>
		#
		$seq_argument =~ s/,/!/g;

	    my $index = $self->_create_index($seq_argument);
	
		$TEX->index($index);
	
	 }
	 
	 return $TEX->text;

  } elsif ($seq_command eq 'E') {

    # If it is simply a number
    if ($seq_argument =~ /^\d+$/) {
      return chr($seq_argument);
    # Look up escape in hash table
    } elsif (exists $HTML_Escapes{$seq_argument}) {
      return $HTML_Escapes{$seq_argument};

    } else {
      my ($file, $line) = $pod_seq->file_line();
      warn "Escape sequence $seq_argument not recognised at line $line of file $file\n";
      return;
    }

  } elsif ($seq_command eq 'Z') {

    # Zero width space
    return '{}';

  } elsif ($seq_command eq 'S') {
    # non breakable spaces
    my $nbsp = '~';

    $seq_argument =~ s/\s/$nbsp/g;
    return $seq_argument;

  } elsif ($seq_command eq 'L') {
    my $link = new Pod::Hyperlink($seq_argument);

    # undef on failure
    unless (defined $link) {
      carp $@;
      return;
    }

    # Handle internal links differently
    my $type = $link->type;
    my $page = $link->page;

    if ($type eq 'section' && $page eq '') {
      # Use internal latex reference 
      my $node = $link->node;

      # Convert to a label
      $node = $self->_create_label($node);

      return "\\S\\ref{$node}";

    } else {
      # Use default markup for external references
      # (although Starlink would use \xlabel)
      my $markup = $link->markup;
      my ($file, $line) = $pod_seq->file_line();

      return $self->interpolate($link->markup, $line);
    }


  } elsif ($seq_command eq 'P') {
    # Special markup for Pod::Hyperlink
    # Replace :: with / - but not sure if I want to do this
    # any more.
    my $link = $seq_argument;
    $link =~ s|::|/|g;

    my $ref = "\\emph{$seq_argument}";
    return $ref;

  } elsif ($seq_command eq 'Q') {
    # Special markup for Pod::Hyperlink
    return "\\textsf{$seq_argument}";



  } else {
    carp "Unknown sequence $seq_command<$seq_argument>";
  }

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
    $paragraph = $self->Label() . '!' . $paragraph;
  }

  $paragraph =~ s{\*_}{\_}g;

  return $paragraph;

}


=head3 head
 
X<head,Pod::LaTeX::Plus>
 
=head4 Usage

	my $latex=Pod::LaTeX::Plus->new;
	
  	$latex->head($num,$paragraph,$parobj);
 
=head4 Purpose
 
=head4 Input
 
=over 4
 
=item * C<$num> 

=item * C<$paragraph> 

=item * C<$parobj> 
 
=back
 
=head4 Returns
 
=head4 See also
 
=cut
 

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
  #$TEX->index($index);

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
