
package OP::TEX::Text;
# Intro {{{

use strict;
use warnings;

use OP::Base qw/:vars :funcs/;
use parent qw(OP::Script Class::Accessor::Complex);

# }}}
# Methods {{{

sub _flush(){
	my $self=shift;

	$self->_v_set("text","");
}

sub _text(){
	my $self=shift;

	$self->_v_get("text") // '';
}

sub _cmd(){
	my $self=shift;

	my $ref=shift // '';
	my @opts=@_;

	return 1 unless $ref;

	my($text,$vars,$cmd);

	unless(ref $ref){
		$text="\\" . $ref;

		unless(@opts){
			$self->_die("_cmd(): Did not specify the list of variables!")
				unless $cmd;	
		}elsif (scalar @opts == 1){
			# Single variable
			$text.= "{$opts[0]}";
		}
	}elsif(ref $ref eq "HASH"){

		$cmd=$ref->{cmd} // '';
	
		$self->_die("_cmd(): Did not specify command name!")	
			unless $cmd;	
	
		$text="\\$cmd";
		$vars=$ref->{vars} // '';
	
		$self->_die("_cmd(): Did not specify the list of variables!")
			unless $cmd;	

		$text.= "{$vars}";
		
	}

	$self->_add_line("$text");

}

sub _c_delim() {
	my $self=shift;

	my $text="%" x 50;
	$self->_c("$text");
}

sub _c() {
	my $self=shift;

	my $ref=shift // '';

	my $text=$ref;

	$self->_add_line("%$text");
}

sub _empty_lines() {
	my $self=shift;

	my $num=shift // 1;

	for(1..$num){
		$self->_add_line(" ");
	}
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

sub end(){
	my $self=shift;

	my $x=shift // '';
	return 1 unless $x;

	$self->_cmd("end", $x );

}

sub begin(){
	my $self=shift;

	my $x=shift // '';
	return 1 unless $x;

	$self->_cmd("begin",$x);

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

sub preamble() {
	my $self=shift;

	my $ref=shift // '';

	die "No arguments to preamble()"
		unless $ref;

	# Print some comments in preamble
	my $date=localtime;

	$self->_c_delim;
	$self->_c("Generated on: $date");
	$self->_c_delim;
	
	unless(ref $ref){
	}elsif(ref $ref eq "HASH"){

		# Used packages related
		my $usedpacks=[];
		my $packopts={};

		# Title of the document
		my $doctitle='';

		# Process the contents of the subroutine's
		#	input hash
		my @input_opts=qw( 
			dclass 
			doctitle
			packopts
			usedpacks
		);

###Preamble_Process_Input_Opts
		foreach my $k (@input_opts) {

			next unless defined $ref->{$k};

			my $v=$ref->{$k};

			foreach($k) {
				/^dclass$/ && do {
					my $class_name=shift @$v;
					my $class_opts=join(',',@$v);
					my $text="\\documentclass[$class_opts]{$class_name}";
					$self->_empty_lines;
					$self->_add_line("$text");
					$self->_empty_lines;
					next;
				}; 
				/^usedpacks$/ && do {
					$usedpacks=$v;
					next;
				};
				/^packopts$/ && do {
					$packopts=$v;
					next;
				};
				/^doctitle$/ && do {
					$doctitle=$v;
					next;
				};
			}
		}
		# Once the input ref is processed, performs
		#	necessary actions

###Preamble_Used_Packs
		#	Generate LaTeX code for the list of used packages
		if ($usedpacks){

			$self->_c_delim;
			$self->_c("List of used packages");
			$self->_c_delim;

			foreach my $pack (@$usedpacks) {
				my $opts=$packopts->{$pack} // '';
				my $s_opts='';
				$s_opts="[$opts]" if $opts;
				my $text="\\usepackage" . $s_opts . "{$pack}";
				$self->_add_line("$text");
			}
			$self->_c_delim;
		}

###Preamble_Doc_Title
		# Document's title
		if ($doctitle){
			$self->_add_line("\\maketitle{$doctitle}");
		}
		# Other stuff
	}
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

