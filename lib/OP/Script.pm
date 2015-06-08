
package OP::Script;
#---------------------------------
# intro {{{

=head1 NAME

OP::Script - Base script class

X<NAME, OP::Script>

=head1 SYNOPSIS

X<SYNOPSIS, OP::Script>

=cut

use strict;
use warnings;

use FindBin qw($Bin $Script);

use File::Basename;
use File::Util;
use Getopt::Long;
use Pod::Usage;
use File::Spec::Functions qw(catfile);

use Term::ANSIColor;
use Data::Dumper;
use IPC::Cmd qw(can_run run);

use OP::Base qw( readarr readhash );

#use Vim::Perl qw(
    #VimMsg 
    #$UnderVim
#);
	
our $UnderVim=0;

our $VERSION     = '0.01';

=head1 METHODS

=cut

# }}}
#---------------------------------
# Methods {{{

#=================================
# Core: new() _begin() main() {{{

# new() {{{

=head3 new

=cut

sub new
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

=head3 _begin

=cut

sub _begin {
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}
# }}}
# main() {{{

=head3 main

=cut

sub main {
  my $self=shift;
  
  &OP::Base::sbvars();
  &OP::Base::setsdata();
  &OP::Base::set_FILES();

  $self->set_these_cmdopts();

  &OP::Base::setcmdopts();
  &OP::Base::getopt();

}
# }}}

# }}}
#=================================
# Output: _die out say warn {{{

# _die() {{{

=head3 _die

=cut

sub _die {
	my $self=shift;

	my $ref=shift || '';

	my $msg=$self->{package_name} . "> _ERROR_ " . $ref;
	die "$msg";

}

# }}}
# out() {{{

=head3 out

=cut

sub out {
    my $self=shift;

	my $ref=shift;
	my %opts=@_;
	my $text;

	my $prefix=$self->{package_name} . "> ";

	unless(ref $ref){
		$text="$prefix$ref";
	}	
    $self->outtext("$text",%opts);
}

sub saytext {
	my $self=shift;

	my $text=shift;
	my %opts=@_;

	$self->outtext("$text" . "\n", %opts);

}

sub outtext {
	my $self=shift;

	my $text=shift;

	my %opts=@_;

    my $usecolor=1;
    my $indent=0;
	my($color);

    eval '$color=$self->textcolor || ""; ';
    eval '$usecolor=$self->usecolor || ""; ';

    my $evs='';
    for my $opt (qw( usecolor color indent )){
        $evs.='$' . $opt . '=$opts{' . $opt . '} if defined $opts{' . $opt . '}; ' . "\n";
    }
    eval "$evs";
    die $@ if $@;

    if ($color && $usecolor){
        print color $color;
    }

    if ($indent){
        $text=' ' x $indent . $text;
    }

   #if ($UnderVim) {
      #VimMsg("$text",{color => $color});
   #}

    print "$text";

    if ($color && $usecolor){
        print color 'reset';
    }

}

sub debugout_var {
	my $self=shift;

	my $var=shift || '';
	my $val=shift || '';

	my $evs= '$self->debugout("_VAR_ \$" . ' . '"' . $var . '=$val' . '") ' ;

	eval $evs;
	die $@ if $@;

}

sub debugsay(){
	my $self=shift;

	my $text=shift || '';

    $self->debugout("$text" . "\n");

}

sub debugout {
	my $self=shift;

	my $text=shift || '';

	$self->out("_DEBUG_ " . $text) if $self->_opt_true("debug");

}
# }}}
# say() {{{

=head3 say 

=cut

sub say {
	my $self=shift;

	my $text=shift;
	my %opts=@_;

	$self->out("$text" . "\n", %opts);

}
# }}}
# warn() {{{

=head3 warn
 
=head4 Purpose
 
=head4 Usage
 
=head4 Input
 
=over 4
 
=item
 
=back
 
=head4 Returns
 
=head4 See also
 
=cut
 
sub warn {
	my $self=shift;

	my $text=shift;
	my %opts=@_;

    my $color='bold red';

    eval '$color=$self->warncolor if $self->warncolor';
	$self->say(" WARNING: $text", color  => $color, %opts);

}

sub warntext {
	my $self=shift;

	my $text=shift;
	my %opts=@_;

	$self->saytext("$text", (color  => 'bold red', %opts));

}
# }}}

# }}}
#=================================
# Command-line options {{{

# _opt_*  {{{

=head2 Command-line options handling 

=cut

# _opt_struct_check() {{{

=head3 _opt_struct_check()

=cut

sub _opt_struct_check(){
	my $self=shift;

	my $opt_struct=shift;

	my $opt_struct_fields=[ qw( type name desc ) ];

	die "Wrong opt_struct passed to _opt_struct_check() function!\n" 
		unless ref $opt_struct eq "HASH";
	
	foreach my $field (@$opt_struct_fields) {
		$opt_struct->{$field}="" unless defined $opt_struct->{$field};
	}

	return $opt_struct;

}

# }}}
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

   ( "$OP::Base::opts{$opt}" eq "$val" ) ? 1 : 0;

}

# }}}
# _opt_get() {{{

=head3 _opt_get

=cut

sub _opt_get {
	my $self=shift;

	my $opt=shift;

	my $val=$OP::Base::opts{$opt} || undef;
	return $val;
}

# }}}
# _opt_set() {{{

=head3 _opt_set()

=cut

sub _opt_set(){
	my $self=shift;

	my $opt=shift;
	my $val=shift;

	$OP::Base::opts{$opt}=$val;
}

# }}}
# _opt_defined() {{{

=head3 _opt_defined()

=cut

sub _opt_defined(){
	my $self=shift;

	my $opt=shift;

	my $val=$OP::Base::opts{$opt} || undef;

	return 1 if defined $val;
	return 0;
}

# }}}
# }}}
# get_opt() {{{

=head3 get_opt

=cut

sub get_opt {
	my $self=shift;

	my @argv=@_;

	&OP::Base::sbvars();
  	&OP::Base::setsdata();
  	&OP::Base::set_FILES();

  	$self->set_these_cmdopts();

  	&OP::Base::setcmdopts();
  	&OP::Base::getopt(@argv);

	$self->{v}->{cmdline}=$OP::Base::cmdline;

  	$self->get_opt_after();

}

=head3 print_help

=cut

sub print_help(){
	my $self=shift;

  	&OP::Base::printhelp();
}

=head3 print_man() 

=cut

sub print_man(){
	my $self=shift;

  	&OP::Base::printman();
}

sub acc_arr_sortuniq() {
	my $self=shift;

	my $arr=shift;
	my @a;

	my $evs;

	$evs.=  ' @a=$self->' . $arr . ';' . "\n";
	$evs.=  ' @a=sort(&uniq(@a)) if @a;';
	$evs.=  ' $self->' . $arr . '(@a);';

	eval $evs;
	die $@ if $@;

}

sub acc_arr_printarr(){
	my $self=shift;

	my $arr=shift;

	my $evs='print $_ . "\n" for($self->' . $arr . ');' ;
	eval $evs;
	die $@ if $@;

}

=head3 print_examples()

=cut

sub print_examples {
	my $self=shift;

  	&OP::Base::printexamples();
}

=head3 print_pod_options

=cut

sub print_pod_options(){
	my $self=shift;

  	&OP::Base::printpodoptions();
}

=head3 get_opt_after

=cut

sub get_opt_after {
	my $self=shift;

    #&OP::Base::getopt_after();

	$self->print_pod_options();
	$self->print_help() if $self->_opt_true("help");
	$self->print_man() if $self->_opt_true("man");
	$self->print_examples() if $self->_opt_true("examples");

	$self->_opt_set("debug",1) if $self->_opt_true("debug");

}

# }}}
# add_cmd_cmdsopts() {{{

=head3 add_cmd_cmdsopts()

=cut

sub add_cmd_opts(){
	my $self=shift;

	my $ref=shift || '';

	unless ($ref){
		return 1;
	}else{
		if (ref $ref eq "ARRAY") {
			foreach my $opt_struct (@$ref) {
				$self->_opt_struct_check($opt_struct);
				push(@OP::Base::cmdopts,$opt_struct);
			}
		}elsif(ref $ref eq "HASH"){
			my $opt_struct=$ref;
			$self->_opt_struct_check($opt_struct);
			push(@OP::Base::cmdopts,$opt_struct);
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

# }}}
#=================================

sub VARS_to_accessors {
    my $self=shift;

    my $vars=shift;

    foreach my $var (@$vars) {
        my $evs='$self->' . $var . '($self->VARS("' . $var . '"));' ; 
        eval "$evs";
        die $@ if $@;
    }

}

sub init_docstyles {
    my $self=shift;

    opendir(D,catfile($self->texroot,qw(docstyles)));
    $self->docstyles_clear;
    while(my $f=readdir(D)){
        next if (grep { /^$f$/ } qw( . .. ));

        my $ds=$f;
        $self->docstyles_push($ds);
    }
    closedir(D);
}


# opts_to_vars() {{{
#

sub opts_to_scalar_vars {
    my $self=shift;

    my @vars=@_;

    foreach my $var (@vars) {
        my $evs=''; 
        
        $evs.=join('','if ( $self->_opt_defined("' , $var, '") ){ ' . "\n");
        $evs.=join('','$self->',$var, '('  , '$self->_opt_get("' , $var,'") );');
        $evs.=join('','}' . "\n");

        eval($evs);
        die $@ if $@;
    }
}

sub apply_vars {
    my $self=shift;

    my $module=shift;
    my @vars=@_;

    foreach my $var (@vars) {
        my $evs=''; 
        
        $evs.='if (defined $' . $module . '::' .  $var . '){ ' . "\n";
        $evs.=join('','$self->',$var, '($'  , $module, '::' , $var,');');
        $evs.=join('','}' . "\n");

        eval($evs);
        die $@ if $@;
    }

}

sub opts_bool_to_scalar_vars(){
    my $self=shift;

    my @vars=@_;

    foreach my $var (@vars) {
        my $evs="";
        
        $evs.=join('','$self->',$var, '(0);',"\n");
        $evs.=join('','$self->',$var, '(1) if ' , '$self->_opt_true("' , $var,'");',"\n");

        eval "$evs";

        die $@ if $@;
    }
}


# }}}
# exec() {{{

=head3 exec()

=cut

sub exec(){
	my $self=shift;

	my $ref=shift || '';

	# Command to be executed
	my($cmd);

	# Logfile to which the command's 
	#	standard & error output may be written
	#	(if required)
	my($log);

	# Verbosity level for the command's output
	my($verbose);

	return 1 unless $ref;

	if (ref $ref eq "HASH"){
		$cmd=$ref->{cmd} || '';
		$log=$ref->{log} || '';
		$verbose=$ref->{verbose} || 0;

		unless($cmd){
			$self->out("No command provided for OP::Script::exec()!\n");
			exit 1;
		}

		$self->out("Running command: $cmd\n");

		my($ok, $err, $fullbuf, $stdout, $stderr) = 
			IPC::Cmd::run( command => $cmd, verbose => $verbose);

		my $s_fullbuf=join "",@$fullbuf;

		my $fu=File::Util->new();
		
		if($log){ 
			$fu->write_file(
				file => $log, 
				content => $s_fullbuf,
			   	mode => "write");
		}

		#print Dumper($fullbuf);
		#exit 0;

		unless ($ok){
			die "Failure\n";
		}
	}

}
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
# _a_get() {{{

sub _a_get(){
	my $self=shift;

	my $var=shift;

	return $self->{a}->{$var} if defined $self->{a}->{$var};
	return undef;

}

# }}}
# _a_set() {{{

sub _a_set(){
	my $self=shift;

	my($var,$val)=@_;

 	$self->{a}->{$var}=$val;

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
		if (@_){
			%opts=@_;
			while(my($k,$v)=each %opts){
				$self->{h}->{$ref}->{$k}=$v;
			}
		}else{
			$self->{h}->{$ref}={};
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
# _h_get() {{{

=head3 _h_get()

Retrieve the hash ref for the given key

=cut

sub _h_get(){
	my $self=shift;

	my($ref,$key)=@_;

	unless(ref $ref){
		my $val= $self->{h}->{$ref};
		return $val;
	}

}

# }}}
# _h_set(){{{

sub _h_set(){
	my $self=shift;

	my($var,$val)=@_;

	$self->{h}->{$var}=$val;

}

# }}}
# _h_dump() {{{

=head3 _h_dump()

Dump the hash

=cut

sub _h_dump(){
	my $self=shift;

	my($ref)=@_;

	unless(ref $ref){
		my $val= $self->{h}->{$ref};
		print Data::Dumper->Dump([ $val ],[ $ref ]);
		return $val;
	}

}

# }}}
# _h_get_value() {{{

=head3 _h_get_value()

Retrieve the value given the key

=cut

sub _h_get_value(){
	my $self=shift;

	my($ref,$key)=@_;

	unless(ref $ref){
		my $val= $self->{h}->{$ref}->{$key} || undef;
		return $val;
	}

}

# }}}
# _h_get_key_by_value() {{{

=head3 _h_get_key_by_value()

Retrieve the key given its key

=cut

sub _h_get_key_by_value(){
	my $self=shift;

	my($ref,$value)=@_;

	unless(ref $ref){
		my $keys=$self->_h_keys($ref);
		my $hash=$self->_h_get($ref);
		foreach my $k (@$keys) {
			return $k if ($hash->{$k} eq $value);
		}

		return undef;
	}

}

# }}}
# _h_set_value() {{{

=head3 _h_set_value()

Set the value given the key

=cut

sub _h_set_value(){
	my $self=shift;

	my($ref,$key,$val)=@_;

	unless(ref $ref){
		$val= $self->{h}->{$ref}->{$key}=$val;
	}

}

# }}}
# _h_change_values() {{{

=head3 _h_change_values()

=cut

sub _h_change_values(){
	my $self=shift;

	my $ref=shift || '';
	my $opts=shift || '';

	return 1 unless $ref;
	return 1 unless $opts;

	return 1 unless (ref $opts eq "HASH");

	while(my($k,$v)=each %{$opts}){
		$self->_h_set_value($ref,$k,$v);
	}

}

# }}}
# _h_keys() {{{

=head3 _h_keys()

Return the reference to the list of hash's keys

=cut

sub _h_keys(){
	my $self=shift;

	my($ref)=@_;

	unless(ref $ref){
		if($self->_h_defined("$ref")){
			my @keys=keys %{$self->{h}->{$ref}}; 
			return \@keys;
		}else{
			return undef;
		}
	}

}

# }}}
# _h_values() {{{

=head3 _h_values()

Return the reference to the list of hash's values

=cut

sub _h_values(){
	my $self=shift;

	my($ref)=@_;

	unless(ref $ref){
		if($self->_h_defined("$ref")){
			my @values=sort values %{$self->{h}->{$ref}}; 
			return \@values;
		}else{
			return undef;
		}
	}

}

# }}}
# _h_defined() {{{

=head3 _h_defined()

Check whether hash is defined

=cut

sub _h_defined(){
	my $self=shift;

	my($ref)=@_;

	unless(ref $ref){
		return 1 if defined $self->{h}->{$ref};
	}
	return 0;

}

# }}}
# _h_def_value() {{{

=head3 _h_def_value()

Check whether hash value is defined for the given key

=cut

sub _h_def_value(){
	my $self=shift;

	my($ref,$opt)=@_;

	unless(ref $ref){
		return 1 if defined $self->{h}->{$ref}->{$opt};
	}
	return 0;

}

# }}}

# }}}
# _v_* -  variable methods {{{

=head2 Variable methods

=cut

# _v_set(){{{

sub _v_set(){
	my $self=shift;

	my($var,$val)=@_;

	$self->{v}->{$var}=$val;

}

# }}}
# _v_get() {{{

sub _v_get(){
	my $self=shift;

	my($var)=@_;

	return $self->{v}->{$var} if defined $self->{v}->{$var};
	return undef;

}

# }}}
# _v_def() {{{

sub _v_def(){
	my $self=shift;

	my($var)=@_;

	return 1 if defined $self->{v}->{$var};
	return 0;

}

# }}}
# _v_eq() {{{

sub _v_eq(){
	my $self=shift;

	my($var,$val)=@_;

	return 1 if ("$val" eq $self->_v_get($var));
	return 0;
}
# }}}
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

sub _f_readarr {
	my $self=shift;

	my($ref)=@_;

	my $fname=$self->_f_get($ref);
	return readarr($fname);

}

sub _f_readhash {
	my $self=shift;

	my($ref)=@_;

	my $fname=$self->_f_get($ref);
	return readhash($fname);

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

	my($files,$viewer,$view_opts,$view_cmd);

	$files=$opts{files};
	$viewer=$opts{viewer} || '';
	$view_opts="";

	$viewer=$self->_v_get("viewer") || "gvim" unless $viewer;

	foreach($viewer){
		/^(gvim|vim|vi)$/ && do {
			$view_opts=$self->_v_get("$viewer" ."_view_opts")
		   		|| "-n -p --remote-tab-silent";
			next;
		};	
	}

	$view_cmd="$viewer $view_opts " . join(" ",@$files);

	system("$view_cmd &");

}
# }}}
#=================================
# }}}
#---------------------------------
#
1;
