
package OP::TEX::LATEX2HTML;
# Intro {{{

use strict;
use warnings;

use OP::Base qw/:vars :funcs/;
use parent qw(OP::Script);

# }}}
# Methods {{{

=head3 new()

=cut

sub new(){
	my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);

	$self->_init(\%parameters);

    return $self;
}

=head3 _init()

=cut

sub _init(){
	my $self=shift;

	my $opts=shift // '';

	# Needed for subroutine(s): 
	#	out()
	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name};

	# Init default options and apply also
	#	options specified with $opts (if non-zero)
	$self->init_options($opts);

}

=head3 init_options()

=cut

sub init_options(){
	my $self=shift;

	my $opts=shift // '';

	$self->init_default_options();

	$self->set_options($opts);

}

=head3 set_options()

=cut

sub set_options(){
	my $self=shift;

	my $opts=shift // '';

	$self->_h_change_values("options",$opts);
}

=head3 init_default_options()

=cut

sub init_default_options() {
	my $self=shift;

	my $default_options={
		#address => "<I>$address_data[0] <BR>\n$address_data[1]</I>",
		anti_alias      => 0,
		anti_alias_text => 1,
		ascii_mode  	=> 0,
		auto_navigation => 1,
		auto_prefix  => 0,
		bottom_navigation  => 0,
		childline 		=> "<BR> <HR>\n",
		can_fork  		=> 1,
		contents_in_navigation => 1,
		debug  				=> 0,
		default_language 	=> "english",
		destdir  			=> '',
		external_images  	=> 0,
		external_up_link 	=> "",
		external_up_title 	=> "",
		external_down_link 		=> "",
		external_down_title 	=> "",
		external_prev_link 		=> "",
		external_prev_title 	=> "",
		figure_scale_factor => 1.6,
		index_in_navigation => 1,
		info 				=> 1,              
		latex_dump          => 0,
		line_width 			=> 500,
		local_icons 		=> 1,
		math_scale_factor 	=> 1.6,
		max_link_depth 		=> 4, 
		max_split_depth 	=> 8,
		netscape_html 		=> 0,
		numbered_footnotes  => 0,
		next_page_in_navigation => 1,
		no_navigation 		=> 0,
		no_subdir 			=> 0,
		nolatex 			=> 0,   
		papersize 			=> "a4",
		prefix 	 			=> '',
		previous_page_in_navigation => 1,
		ps_images 			=> 0,
		reuse 				=> 2,
		show_section_numbers  => 0,
		shortexn  			=> 0,
		texdefs  			=> 1,
		title 				=> "No title",
		titles_language 	=> "english",
		top_navigation  	=> 1,
		verbosity  			=> 1,
		words_in_navigation_panel_titles => 4,
		words_in_page 		=> 300,
		short_index  		=> 0,
		images_only  		=> 0,
		discard_ps  		=> 1,
		no_images  			=> 0,
		reuse  				=> 2
	};

	$self->set_options($default_options);
}

=head3 make_init_file()

Write an init file which will be then used by
latex2html

=cut

sub write_init_file(){
	my $self=shift;

	my $opts=$self->_h_get("options");

	#my $fh=IO::File	

	while(my($k,$v)=each %{$opts}){
		
	}

}

=head3 run()

=cut

sub run() {
	my $self=shift;

	my $ref=shift // '';

	return 1 unless $ref;

	my $opts=$ref->{opts};

	my $l2h=$self->_v_get("exe");
	my $log=$self->_v_get("log_file");
	my $run_opts=$self->_v_get("run_opts");

	# Input tex source
	my $if=$opts->{input};

	my $cmd="$l2h $opts $if";

	$self->exec({ cmd => $cmd, log => $log });

}

# }}}
1;

