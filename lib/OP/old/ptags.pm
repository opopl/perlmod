package OP::old::ptags;

use strict;
use warnings;

use parent qw( OP::VimTag OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
	dirs
	indir
	ptagsfile
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
    );

###__ACCESSORS_ARRAY
our @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors)
	->mk_new;

# Methods {{{

=head1 METHODS

=head2 CORE METHODS

=cut

# init_vars() {{{

=head3 init_vars

=cut

sub init_vars {
	my $self=shift;

	# Output tags file
	#my $optags="$ENV{HOME}/.ptags";

}

# }}}
# main() {{{

=head3 main

=cut

sub main {
	my $self=shift;

	# Initialize variables
	$self->init_vars();

	# Read command-line arguments
	$self->get_opt();

	# Generate tags
	$self->OP::VimTag::main() if $self->_opt_true("run");

}

# }}}
# _begin() {{{

=head3 _begin

=cut

sub _begin {
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 
    
    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}
# }}}
# set_these_cmdopts() {{{

=head3 set_these_cmdopts

=cut

sub set_these_cmdopts(){
	my $self=shift;

	$self->OP::Script::set_these_cmdopts();

	my $opts=[];
	my $desc={};

	push(@$opts,{ name => "dirs" , 	type => 's', desc => "Input directory(s) with Perl modules"});
	push(@$opts,{ name => "out" , 	type => 's', desc => "Output Perl tags file"});
	push(@$opts,{ name => "run" , 	desc => "Run"});

  	$self->add_cmd_opts($opts);

}
# }}}
# get_opt() {{{

=head3 get_opt

=cut

sub get_opt {
	my $self=shift;

	$self->OP::Script::get_opt();

	$self->dirs($self->_opt_get("dirs") // '');
	$self->ptagsfile($self->_opt_get("out") // '~/tags/perl.tags');

}

# }}}

# }}}
#
