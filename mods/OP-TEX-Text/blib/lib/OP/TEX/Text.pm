
package OP::TEX::Text;
# {{{

use strict;
use warnings;

use OP::Base qw/:vars :funcs/;
use parent qw(OP::Script);

sub _flush(){
	my $self=shift;

	$self->_v_set("text","");
}

sub _text(){
	my $self=shift;

	$self->_v_get("text") // '';
}

sub _add_line(){
	my $self=shift;

	my $ref=shift // '';
	my($addtext,$oldtext,$text);

	return 1 unless $ref;

	$oldtext=$self->_v_get("text")  // '';

	# In case a string is supplied, this
	#	string is passed as the value of the
	#	internal "text" variable
	unless (ref $ref){
		$addtext=$ref;
	}elsif(ref $ref eq "HASH"){
	}elsif(ref $ref eq "ARRAY"){
		my $c=shift @$ref;
		my $x=shift @$ref;
		$addtext="\\" . $c . '{' . $x . '}';
	}

	$text=$oldtext . $addtext . "\n";
	$self->_v_set("text",$text);
}

sub section(){
	my $self=shift;

	my $title=shift // '';

	$self->_add_line("\\section{$title}");
}

sub input(){
	my $self=shift;

	my $file=shift // '';

	$self->_add_line("\\input{$file}");
}

sub usepackage(){
	my $self=shift;

	my $ref=shift // '';

	return 1 unless $ref;

	my($pack,$opts);

	unless(ref $ref){
		 $pack=$ref;
		 $opts=shift // '';
	}elsif(ref $ref eq "HASH"){
		 $pack=$ref->{package} // '';
		 $opts=$ref->{options} // '';
	}

	return 1 unless $pack;

	if ($opts){
		$self->_add_line("\\usepackage[$opts]{$pack}");
	}else{
		$self->_add_line("\\usepackage{$pack}");
	}

}

sub nc(){
	my $self=shift;

	my($name,$cmd,$npars)=@_;

	unless (defined $npars){
		$self->_add_line("\\nc{$name}{$cmd}");
	}else{
		$self->_add_line("\\nc{$name}[$npars]{$cmd}");
	}
}

sub subsubsection(){
	my $self=shift;

	my $title=shift // '';

	$self->_add_line("\\subsubsection{$title}");
}

sub subsection(){
	my $self=shift;

	my $title=shift // '';

	$self->_add_line("\\subsection{$title}");
}

sub chapter(){
	my $self=shift;

	my $title=shift // '';

	$self->_add_line("\\chapter{$title}");
}

sub paragraph(){
	my $self=shift;

	my $title=shift // '';

	$self->_add_line("\\paragraph{$title}");
}

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

sub _defaults(){
	my $self=shift;

	my $opt=shift // '';

	return undef unless $opt;

	return $self->_h_get_value("default_options",$opt);

}

sub _print(){
	my $self=shift;

	my $opts;

	$opts=shift // '';

	unless($opts){
		print $self->_text;
		return 1;
	}

	$opts{fmode}=$self->_defaults("print_file_mode") unless defined $opts{fmode};

	if (ref $opts eq "HASH"){
		if (defined $opts->{file}){

			my $file=$opts->{file};

			foreach ($opts->{fmode}){
				/^w$/ && do { open(F, ">$file") || die $!; next; };
				/^a$/ && do { open(F, ">>$file") || die $!; next; };
			}

			print F $self->_text;

			close F;
		}else{
			print $self->_text;
		}
	}
}

# }}}

1;

