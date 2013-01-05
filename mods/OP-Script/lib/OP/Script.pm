package OP::Script;
# intro {{{

=head1 NAME

OP::Script - Base script class

=cut

use strict;
use warnings;

use FindBin;
use lib("$ENV{hm}/wrk/perlmod/mods/OP-Base/lib");

use File::Basename;
use Getopt::Long;
use Pod::Usage;
use OP::Base qw/:vars :funcs/;
use Term::ANSIColor;
use Data::Dumper;

our $VERSION     = '0.01';

# }}}
# Methods {{{

=head1 METHODS

=cut

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
# _begin() {{{

=head3 _begin()

=cut

sub _begin(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}
# }}}
# out() {{{

=head3 out()

=cut

sub out(){
	my $self=shift;

	my($ref,$text,$prefix,$opts,%o);

	$prefix=$self->{package_name} . "> ";

	$ref=shift;

	unless(ref $ref){
		$text="$prefix$ref";
	}	
	print "$text";

}
# }}}
# _opt_* - methods for handling command-line options {{{

=head2 Command-line options handling 

=cut

# _opt_true() {{{

=head3 _opt_true()

=cut

sub _opt_true(){
	my $self=shift;

	my $opt=shift;

	return !! $OP::Base::opts{$opt};
}

# }}}
# _opt_false() {{{

=head3 _opt_false()

=cut

sub _opt_false(){
	my $self=shift;

	my $opt=shift;

	return 1 unless $self->_opt_true("$opt");
	return 0;
}

# }}}
# _opt_eq() {{{

=head3 _opt_eq()

=cut

sub _opt_eq(){
	my $self=shift;

	my $opt=shift;
	my $val=shift;

	return 1 if ( $OP::Base::opts{$opt} == $val );
	return 0;
}

# }}}
# _opt_get() {{{

=head3 _opt_get()

=cut

sub _opt_get(){
	my $self=shift;

	my $opt=shift;

	my $val=$OP::Base::opts{$opt} // undef;
	return $val;
}

# }}}
# _opt_defined() {{{

=head3 _opt_defined()

=cut

sub _opt_defined(){
	my $self=shift;

	my $opt=shift;

	my $val=$OP::Base::opts{$opt} // undef;

	return 1 if defined $val;
	return 0;
}

# }}}
# }}}
# _a_* -  array methods {{{

=head2 Array handling 

=cut

# _a_push() {{{

=head3 _a_push()

Add elements to an array

=cut

sub _a_push(){
	my $self=shift;

	my($ref,@elements);

	$ref=shift;

	unless(ref $ref){
		@elements=@_;
		push(@{$self->{a}->{$ref}},@elements);
	}

}

# }}}
# _a_push_ref() {{{

=head3 _a_push_ref()

=cut

sub _a_push_ref(){
	my $self=shift;

	my($ref,$refadd)=@_;

	unless(ref $ref){
		push(@{$self->{a}->{$ref}},@$refadd);
	}

}

# }}}
# _a_list() {{{

=head3 _a_list($ref)

List elements of an array specified by $ref

=cut

sub _a_list(){
	my $self=shift;

	my($ref);

	$ref=shift;

	unless(ref $ref){
		print "$_\n" for(@{$self->{a}->{$ref}});
	}

}

# }}}
# _a_sort() {{{

=head3 _a_sort($ref)

Sort elements of an array

=cut

sub _a_sort(){
	my $self=shift;

	my($ref,$arr);

	$ref=shift;

	unless(ref $ref){
		$arr=$self->{a}->{$ref};
		@$arr=sort @$arr;
	}

	$self->{a}->{$ref}=$arr;

}

# }}}


# }}}
# _h_* -  hash methods {{{

=head2 Hash methods

=cut

# _h_add() {{{

=head3 _h_add()

Add key-value pairs to a hash

=cut

sub _h_add(){
	my $self=shift;

	my($ref,%opts);

	$ref=shift;

	unless(ref $ref){
		%opts=@_;
		while(my($k,$v)=each %opts){
			$self->{h}->{$ref}->{$k}=$v;
		}
	}

}

# }}}
# _h_add_ref() {{{

=head3 _h_add_ref()

Add key-value pairs to a hash

=cut

sub _h_add_ref(){
	my $self=shift;

	my($ref,$ref_opts_add)=@_;

	unless(ref $ref){
		my %opts=%{$ref_opts_add};
		while(my($k,$v)=each %opts){
			$self->{h}->{$ref}->{$k}=$v;
		}
	}

}

# }}}

# }}}
# _v_* -  variable methods {{{

=head2 Variable methods

=cut

sub _v_set(){
	my $self=shift;

	my($var,$val)=@_;

	$self->{v}->{$var}=$val;

}

sub _v_get(){
	my $self=shift;

	my($var)=@_;

	return $self->{v}->{$var} if defined $self->{v}->{$var};
	return undef;

}


# }}}
# _r_* -  ref methods {{{

=head2 Ref methods

=cut

sub _r_set(){
	my $self=shift;

	my($var,$val)=@_;

	$self->{r}->{$var}=$val;

}

sub _r_get(){
	my $self=shift;

	my($var)=@_;

	return $self->{r}->{$var} if defined $self->{r}->{$var};
	return undef;

}


# }}}
# _f_* -  file methods {{{

=head2 File methods

=cut

sub _f_set(){
	my $self=shift;

	my($var,$val)=@_;

	$self->{f}->{$var}=$val;

}

sub _f_readarr(){
	my $self=shift;

	my($ref)=@_;

	my $fname=$self->_f_get($ref);
	return &readarr($fname);

}

sub _f_readhash(){
	my $self=shift;

	my($ref)=@_;

	my $fname=$self->_f_get($ref);
	return &readhash($fname);

}


sub _f_get(){
	my $self=shift;

	my($var)=@_;

	return $self->{f}->{$var} if defined $self->{f}->{$var};
	return undef;

}


# }}}
# _d_* -  directory methods {{{

=head2 Directory methods

=cut

sub _d_set(){
	my $self=shift;

	my($var,$val)=@_;

	$self->{d}->{$var}=$val;

}

sub _d_get(){
	my $self=shift;

	my($var)=@_;

	return $self->{d}->{$var} if defined $self->{d}->{$var};
	return undef;

}


# }}}
# _view() {{{

sub _view(){
	my $self=shift;
	my %opts=@_;

	return 1 unless defined $opts{files}; 

	my $files=$opts{files};

	my $viewer=$self->_v_get("viewer") // "gvim";
	my $view_opts=$self->_v_get("view_opts") // "-n -p --remote-tab-silent";

	my $cmd="$viewer $view_opts " . join(" ",@$files);

	system($cmd);

}
# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt(){
	my $self=shift;

	&OP::Base::sbvars();
  	&OP::Base::setsdata();
  	&OP::Base::setfiles();

  	$self->set_these_cmdopts();

  	&OP::Base::setcmdopts();
  	&OP::Base::getopt();

	$self->{v}->{cmdline}=$OP::Base::cmdline;
}
# }}}
# add_cmd_cmdsopts() {{{

=head3 add_cmd_cmdsopts()

=cut

sub add_cmd_opts(){
	my $self=shift;

	my $ref=shift // '';

	unless ($ref){
		return 1;
	}else{
		if (ref $ref eq "ARRAY") {
			push(@OP::Base::cmdopts,@$ref);
		}elsif(ref $ref eq "HASH"){
			push(@OP::Base::cmdopts,$ref);
		}
	}
}
# }}}
# set_these_cmdsopts() {{{

=head3 set_these_cmdsopts()

=cut

sub set_these_cmdopts(){ 
  my $self=shift;

  @OP::Base::cmdopts=( 
	{ name	=>	"h,help", 		desc	=>	"Print the help message"	}
	,{ name	=>	"man", 			desc	=>	"Print the man page"		}
	,{ name	=>	"examples", 	desc	=>	"Show examples of usage"	}
	,{ name	=>	"vm", 			desc	=>	"View myself"	}
	,{ name	=>	"d,debug",		desc	=>	"For debugging purposes"	}
	,{ name	=>	"i", 			desc	=>	"Short option"	}
	#,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
  );
}
# }}}
# main() {{{

=head3 main()

=cut

sub main(){
  my $self=shift;
  
  &OP::Base::sbvars();
  &OP::Base::setsdata();
  &OP::Base::setfiles();

  $self->set_these_cmdopts();

  &OP::Base::setcmdopts();
  &OP::Base::getopt();

}
# }}}

# }}}
1;
