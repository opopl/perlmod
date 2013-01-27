
package OP::TEX::LATEX2HTML;
# Intro {{{

use strict;
use warnings;

use OP::Base qw/:vars :funcs/;
use parent qw(OP::Script);

# }}}
# Methods {{{

sub new(){
	my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);

	$self->_init();

    return $self;
}

sub _init(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name};

	my $dopts={
		print_file_mode => "a"
	};

	$self->_h_set("default_options",$dopts);

}

# }}}
1;

