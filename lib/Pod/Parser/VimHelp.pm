package Pod::Parser::VimHelp;

use strict;
use warnings;

use feature qw(switch);

use parent qw(
    Class::Accessor::Complex 
    Pod::Parser
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
    hookroot
    hooklinewidth
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

my @integer_accessors=qw(
    hookcounter
);


###__ACCESSORS_ARRAY
my @array_accessors=qw(
    hooks
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors)
    ->mk_integer_accessors(@integer_accessors)
    ->mk_new;

sub hook_enclose {
    my $self=shift;

    my $hook=shift;

    '*' . $hook . '*';
}

sub command {
    my $self=shift;
    
    my ($command, $paragraph, $line_num) = @_;

    #my $text = $self->interpolate($paragraph, $line_num);
    my $text='=' . $command . ' ';

    $paragraph .= "\n" unless substr($paragraph, -1) eq "\n";
	$paragraph .= "\n" unless substr($paragraph, -2) eq "\n\n";

    my $title=$paragraph;
    $title=~s/\n*$//g;

    given($command){
###cmd_head
       when(/^head(?<lev>\d+)/) { 
          my $subhook;
          my $lev=$+{lev};

          for($title){
               /^[A-Z ]+$/ && do {
                   $subhook = $title =~ s/\s/-/gr;
                   next;
               };
               $subhook = $self->hookcounter;
               $self->hookcounter_inc;
           }
          my $hook=$self->hookroot . '_' . $lev . '_' . $subhook;

          my $adjust='';
          while(length($text) < $self->hooklinewidth){
            $text=$title . $adjust ;
            $adjust.=' ';
          }
          $text.= $self->hook_enclose($hook);

          $text.="\n\n";
       }
###cmd_over
       when(/^over/) { 
       }
###cmd_item
       when(/^item/) { 
       }
       default { 
       }
    }
    my $outfh = $self->output_handle();

    print $outfh $text ;

}

sub verbatim {
         my ($self, $paragraph, $line_num) = @_;
         ## Format verbatim paragraph; sample actions might be:
         my $out_fh = $self->output_handle();
         print $out_fh $paragraph;
}

sub textblock {
         my ($self, $paragraph, $line_num) = @_;
         ## Translate/Format this block of text; sample actions might be:
         my $out_fh = $self->output_handle();
         my $expansion = $self->interpolate($paragraph, $line_num);
         print $out_fh $expansion;
}

sub interior_sequence {
         my ($self, $seq_command, $seq_argument) = @_;
         ## Expand an interior sequence; sample actions might be:
         return "*$seq_argument*"     if ($seq_command eq 'B');
         return "`$seq_argument'"     if ($seq_command eq 'C');
         return "_${seq_argument}_'"  if ($seq_command eq 'I');
         ## ... other sequence commands and their resulting text
}

1;

