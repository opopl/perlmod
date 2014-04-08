
package OP::Pod::Parser;

use warnings;
use strict;
 
use parent qw(
	Class::Accessor::Complex
	Pod::Parser
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw();

###__ACCESSORS_HASH
my @hash_accessors=qw(
	iseqs
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);
	
sub main {
	my $self=shift;
	
	$self->init_vars;
}

sub init_vars {
	my $self=shift;
	
	$self->iseqs(
			'B'	=>	sub { '<B>' . shift . '</B>' },
			'C'	=>	sub { '<CODE>' . shift . '</CODE>' },
			'I'	=>	sub { '<IT>' . shift . '</IT>' },
	);
	
}

sub command { 
    my ($self, $command, $paragraph, $line_num) = @_;

    ## Interpret the command and its text; sample actions might be:
	for($command){
		/^head(\d+)/ && do {
			
			next;
		};
	}
        
    my $out_fh = $self->output_handle();
    my $expansion = $self->interpolate($paragraph, $line_num);
    print $out_fh $expansion;

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

	return $self->iseqs($seq_command)->($seq_argument);

} 

1;
