package Pod::Parser::VimHelp;

use strict;
use warnings;

use feature qw(switch);

use parent qw(Pod::Parser);

sub command {
         my ($parser, $command, $paragraph, $line_num) = @_;
         ## Interpret the command and its text; sample actions might be:
         #
         given($command){
           when(/^head(\d+)/) { 
           }
           default { }
         }
         my $out_fh = $parser->output_handle();
         my $expansion = $parser->interpolate($paragraph, $line_num);
         print $out_fh $expansion;
}

sub verbatim {
         my ($parser, $paragraph, $line_num) = @_;
         ## Format verbatim paragraph; sample actions might be:
         my $out_fh = $parser->output_handle();
         print $out_fh $paragraph;
}

sub textblock {
         my ($parser, $paragraph, $line_num) = @_;
         ## Translate/Format this block of text; sample actions might be:
         my $out_fh = $parser->output_handle();
         my $expansion = $parser->interpolate($paragraph, $line_num);
         print $out_fh $expansion;
}

sub interior_sequence {
         my ($parser, $seq_command, $seq_argument) = @_;
         ## Expand an interior sequence; sample actions might be:
         return "*$seq_argument*"     if ($seq_command eq 'B');
         return "`$seq_argument'"     if ($seq_command eq 'C');
         return "_${seq_argument}_'"  if ($seq_command eq 'I');
         ## ... other sequence commands and their resulting text
}

1;

