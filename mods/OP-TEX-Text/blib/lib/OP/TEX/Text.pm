
package OP::TEX::Text;
# Intro {{{

use strict;
use warnings;

use OP::Base qw/:vars :funcs/;
use parent qw(OP::Script Class::Accessor::Complex);
use Data::Dumper;

__PACKAGE__
	->mk_scalar_accessors(qw(texroot));

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
	my $ref=shift // '';

	my @options=qw(check_exists);

	unless($ref){
		$self->_add_line("\\input{$file}");
	}elsif(ref $ref eq "HASH"){
		while(my($k,$v)=each %{$ref}){
			foreach($k) {
				/^check_exists$/ && do 
					{ 
					$self->_add_line("\\input{$file}")
						if (-e $file);
						next; 
					};
			}
		}
	}
}

sub end(){
	my $self=shift;

	my $x=shift // '';
	return 1 unless $x;

	$self->_cmd("end", $x );

}

sub date(){
	my $self=shift;

	my $x=shift // '';
	return 1 unless $x;

	$self->_cmd("date", $x );

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

# lof() {{{

sub lof() {
	my $self=shift;

	my $ref=shift // '';

	my $opts={
		title 			=> "List of Figures",
		hypertarget  	=> "lof",
		sec		 		=> "chapter"
	};

	unless (ref $ref) {
		# body...
	}elsif(ref $ref eq "HASH"){
		while(my($k,$v)=each %{$ref}){
			$opts->{$k}=$ref->{$k};
		}
	}elsif(ref $ref eq "ARRAY"){
		# body...
	}	
	
	$self->_c_delim;
	$self->_c("List of Figures");
	$self->_c_delim;

	my $s="\\clearpage"
	. "\n" . "\\phantomsection"
	. "\n" . "\\hypertarget{$opts->{hypertarget}}{}"
	. "\n" . "\\listoffigures"
	. "\n" . "\\nc{\\pagenumlof}{\\thepage}"
	. "\n" . "\\addcontentsline{lof}{$opts->{sec}}{$opts->{title}}";

###LOF_TEXT

	$self->_add_line("$s");
	$self->_c_delim;

}

# }}}
# lot() {{{

sub lot() {
	my $self=shift;

	my $ref=shift // '';

	my $opts={
		title 			=> "List of Tables",
		hypertarget  	=> "lot",
		sec		 		=> "chapter"
	};

	unless (ref $ref) {
		# body...
	}elsif(ref $ref eq "HASH"){
		while(my($k,$v)=each %{$ref}){
			$opts->{$k}=$ref->{$k};
		}
	}elsif(ref $ref eq "ARRAY"){
		# body...
	}	
	
	$self->_c_delim;
	$self->_c("List of Tables");
	$self->_c_delim;

	my $s="\\clearpage"
	. "\n" . "\\phantomsection"
	. "\n" . "\\hypertarget{$opts->{hypertarget}}{}"
	. "\n" . "\\listoftables"
	. "\n" . "\\nc{\\pagenumlot}{\\thepage}"
	. "\n" . "\\addcontentsline{lot}{$opts->{sec}}{$opts->{title}}";

###LOT_TEXT

	$self->_add_line("$s");
	$self->_c_delim;

}

# }}}

sub toc() {
	my $self=shift;

	my $ref=shift // '';

	my $opts={
		title 			=> "Table of Contents",
		hypertarget  	=> "toc",
		sec		 		=> "chapter"
	};

	unless (ref $ref) {
		# body...
	}elsif(ref $ref eq "HASH"){
		while(my($k,$v)=each %{$ref}){
			$opts->{$k}=$ref->{$k};
		}
	}elsif(ref $ref eq "ARRAY"){
		# body...
	}	

	$self->_c_delim;
	$self->_c("Table of Contents");
	$self->_c_delim;

	my $s="\\clearpage"
	. "\n" . "\\phantomsection"
	. "\n" . "\\hypertarget{$opts->{hypertarget}}{}"
	. "\n" . "\\tableofcontents"
	. "\n" . "\\nc{\\pagenumtoc}{\\thepage}"
	. "\n" . "\\addcontentsline{toc}{$opts->{sec}}{$opts->{title}}";

###TOC_TEXT

	$self->_add_line("$s");
	$self->_c_delim;

}

sub bibliography() {
	my $self=shift;

	my $ref=shift // '';

	die "No arguments to bibliography()"
		unless $ref;

	my @input_opts=qw(
			hypertarget title bibstyle inputs bibfiles sec
	);

	my $opts={
		title 			=> "Bibliography",
		hypertarget  	=> "lot",
		sec		 		=> "chapter"
	};

	unless (ref $ref) {
		# body...
	}elsif(ref $ref eq "HASH"){
		foreach my $k (@input_opts) {
			$opts->{$k}=$ref->{$k} // '' ;
		}
	}elsif(ref $ref eq "ARRAY"){
		# body...
	}	

###Bibliography
	my $text="\\cleardoublepage"
	. "\n" ."\\phantomsection"
	. "\n" ."\\hypertarget{$opts->{hypertarget}}{}"
	. "\n" .""
	. "\n" ."\\addcontentsline{toc}{$opts->{sec}}{Bibliography}"
	. "\n" .""
	. "\n" ."\\bibliographystyle{$opts->{bibstyle}}";

	$self->_c_delim;
	$self->_c("Bibliography section");
	$self->_c_delim;
	$self->_add_line("$text");

	# Additional input files, if specified
	if($opts->{inputs}){
		unless(ref $opts->{inputs}){
			$self->input($opts->{inputs});
		}elsif(ref $opts->{inputs} eq "ARRAY"){
			foreach my $if (@{$opts->{inputs}}) {
				$self->input($if);
			}
		}
	}

	$self->_add_line("\\nc{\\pagenumbib}{\\thepage}");

	# Bibliography files (*.bib)
	if($opts->{bibfiles}){
		unless(ref $opts->{bibfiles}){
			my $if=$opts->{bibfiles};
			$self->_add_line("\\bibliography{$if}");
		}elsif(ref $opts->{bibfiles} eq "ARRAY"){
			foreach my $if (@{$opts->{bibfiles}}) {
				$self->_add_line("\\bibliography{$if}");
			}
		}
	}
	$self->_c_delim;

}

sub printindex(){
	my $self=shift;

	my $s='
	\clearpage
	\phantomsection
	\nc{\pagenumindex}{\thepage}
	\hypertarget{index}{}
	
	\addcontentsline{toc}{chapter}{Index}
	\printindex';

	$self->_c_delim;
	$self->_c("Index");
	$self->_c_delim;
	$self->_add_line($s);
	$self->_c_delim;

}

=head3 preamble()

=cut

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
###Preamble_Define_Input_Opts
		# Process the contents of the subroutine's
		#	input hash
		my @input_opts=qw( 
			dclass 
			doctitle
			packopts
			usedpacks
			makeindex
			put_today_date
			ncfiles
		);

###Preamble_Process_Input_Opts
		foreach my $k (@input_opts) {

			unless (defined $ref->{$k}){
				$ref->{$k}=''; 
				next; 
			}

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
###Preamble_NC
		# New-commands files
		if ($ref->{ncfiles}){
			$self->_c_delim;
			$self->_c("New commands");
			$self->_c_delim;
			foreach my $x (@{$ref->{ncfiles}}) {
				$self->input("$x");
			}
			$self->_c_delim;
		}
###Preamble_Doc_Title
		# Document's title
		if ($doctitle){
			$self->_add_line("\\title{$doctitle}");
		}
###Preamble_Doc_Today_Date
		if ($ref->{put_today_date}){
			$self->date("\\today");
		}
###Preamble_Make_Index
		# Makeindex
		if ($ref->{makeindex}){
			$self->_add_line("\\makeindex");
		}
###Preamble_Hyper_Setup
		if ($ref->{hypsetup}){
			$self->hypsetup($ref->{hypsetup});
		}

	}
}

sub hypsetup() {
	my $self=shift;

	my $ref=shift // '';

	$self->_die("Author name was not specified in hypsetup()")
		unless defined $ref->{author};
	$self->_die("Title was not specified in hypsetup()")
		unless defined $ref->{title};

	my $text;

	$text="\\ifpdf"
	. "\n" ."\\pdfinfo{"
	. "\n" ."   /Author ($ref->{author})"
	. "\n" ."   /Title  ($ref->{title})"
	. "\n" ."}"
	. "\n" ."\\else"
	. "\n" ."\\hypersetup{"
	. "\n" ."	pdftitle={$ref->{title}},"
	. "\n" ."	pdfauthor={$ref->{author}},"
	. "\n" ."	pdfsubject={},"
	. "\n" ."	pdfkeywords={},"
	. "\n" ."	bookmarksnumbered,"
	. "\n" ."	hyperfigures=true,"
	. "\n" ."	bookmarksdepth=subparagraph"
	. "\n" ."}"
	. "\n" ."\\fi";

	$self->_c_delim;
	$self->_c("Hypersetup (for hyperlinked PDFs)");
	$self->_c_delim;
	$self->_add_line("$text");
	$self->_c_delim;

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

	$opts->{fmode}=$self->_defaults("print_file_mode") unless defined $opts->{fmode};

	if (ref $opts eq "HASH"){
		if (defined $opts->{file}){

			my $file=$opts->{file};

			foreach ($opts->{fmode}){
				/^w$/ && do { open(F, ">$file") || die $!; next; };
				/^a$/ && do { 
					open(F, ">>$file") || die $!; next; 
				};
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

