#!/usr/bin/perl 

package op::perlmod::mhtml;
# intro {{{

use strict;
use warnings;

use parent qw( Class::Accessor::Constructor OP::Script );

# }}}
# Methods {{{

=head1 METHODS

=cut

# Core {{{

=head2 CORE METHODS

=cut

# init_vars() {{{

=head3 init_vars()

=cut

sub init_vars(){
	my $self=shift;

	# Output tags file
	#my $optags="$ENV{HOME}/.ptags";

}

# }}}
# main() {{{

=head3 main()

=cut

sub main(){
	my $self=shift;

	# Initialize variables
	$self->init_vars();

	# Read command-line arguments
	$self->get_opt();

}

# }}}
# _begin() {{{

=head3 _begin()

=cut

sub _begin(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}
# }}}
# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts(){
	my $self=shift;

	$self->SUPER::set_these_cmdopts();

	my $opts=[];
	my $desc={};

	push(@$opts,{ name => "dirs" , 	desc => "Input directory(s) with Perl modules"});
	push(@$opts,{ name => "out" , 	desc => "Output Perl tags file"});

  	$self->add_cmd_opts($opts);

}
# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt(){
	my $self=shift;

	$self->SUPER::get_opt();
}

# }}}
# new() {{{

=head3 new()

=cut

sub new()
{
    my ($class, %ipars) = @_;
    my $self = bless ({}, ref ($class) || $class);

	$self->_begin();

	while (my($k,$v)=each %ipars) {
		$self->_v_set($k,$v);
	}

    return $self;
}

# }}}

# }}}

# }}}
package main;

op::perlmod::html->new->main;



