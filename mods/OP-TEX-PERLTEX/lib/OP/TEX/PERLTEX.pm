#!/usr/bin/env perl

package OP::TEX::PERLTEX;

###_USE_
use strict;
use warnings;

use Safe;
use Opcode;
use Getopt::Long;
use Pod::Usage;
use Pod::Find qw(pod_where);
use File::Basename;
use Fcntl;
use POSIX;
use File::Spec;
use File::Slurp;
require IO::Handle;
use IO::File;
use Try::Tiny;
use Data::Dumper;
#use OP::TEX::Text;

require Debug::Simple;

use parent qw(Class::Accessor::Complex);
use Sub::Documentation 'add_documentation';

###_ACCESSORS_

__PACKAGE__
	->mk_new
###_ACCESSORS_SCALAR
	->mk_scalar_accessors(qw(
			debug_msg
			debug_outfile
			doneflag
			fromflag
			fromperl
			jobname
			latexprog
			logfile
			pipe
			pipestring
			package_name
			progname
			runsafely
			subname
			scriptname
			styfile
			toflag
			toperl
			usepipe
			workdir
		))
	->mk_integer_accessors(qw(
			debug_indent
		))
	->mk_array_accessors(qw(
		corefiles
		latexcmdline
		permittedops
		macroexpansions
		))
###_ACCESSORS_HASH
	->mk_hash_accessors(qw(
		fh
		debug_opts
		debug_opts_op
	));

our $sandbox = new Safe;
our $sandbox_eval;
our $latexpid;

$SIG{"ALRM"} = sub {
	    undef $latexpid;
	    exit 0;
};

$SIG{"PIPE"} = "IGNORE";

sub top_level_eval ($)
{

    return eval $_[0];
}

sub _begin(){
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}

#sub new
#{
	#my ($class, %ipars) = @_;
	#my $self = bless ({}, ref ($class) || $class);

	#$self->_begin();

	#return $self;
#}

###DONE_INIT_VARS

=head3 init_debug() 

=cut

sub init_debug() {
	my $self=shift;

	# Specify the working directory where the debug log file
	#	will be written
	$self->workdir(File::Spec->curdir()) unless $self->workdir;
	
	# Debug::Simple debug options

	my $debug_opts={
		quiet  => 0,
		debug  => 1,
		verbose  => 1,
		test  => 0
	};

	$self->debug_opts(%$debug_opts);
	Debug::Simple::debuglevels(\%{$self->debug_opts});

	### Debug options specific to this module

	# Indentation level used in _debug() printing subroutine
	$self->debug_indent(0);

	# Set the filename for the debug output log file
	$self->debug_outfile(
		File::Spec->catfile($self->workdir,$self->scriptname)
		.  "_log.tex"
	);
	$self->debug_outfile(File::Spec->rel2abs($self->debug_outfile));

	# Try to open the debug output log file

	my $fh=IO::File->new($self->debug_outfile, O_WRONLY | O_TRUNC | O_CREAT);
	$self->fh("debug_outfile"  => $fh );

	$self->_debug_begin("verbatim");

	$self->_debug("Opened debug log file for writing: " 
		. $self->debug_outfile);

}

=head3 _debug()

Debugging subroutine which is implemented as a simple
wrapper around Debug::Simple functions

=cut

sub _debug() {
	my $self=shift;

	my $ref=shift // '';

	return 1 unless $ref;

	unless(ref $ref){
		my $msg=$ref;
		$msg=$self->_debug_set_msg($msg);
		Debug::Simple::debug(1,$msg);
		$self->debug_msg($msg);
		$self->_debug_file_write($self->debug_msg);
	}elsif(ref $ref eq "HASH"){
	}
}

=head3 _debug_write_file()

=cut

sub _debug_file_write() {
	my $self=shift;

	my $msg=shift;

	$self->fh("debug_outfile")->print($msg);
}

sub _debug_begin(){
	my $self=shift;

	my $ref=shift // '';

	foreach($ref) {
		/^verbatim$/ && do {
			$self->_debug_file_write("\\begin{verbatim}\n");
			next;
		};
	}

}

sub _debug_dump_latexcmdline(){
	my $self=shift;

	$self->_debug('latexcmdline array is now: ' . "\n" . 
		Data::Dumper->Dump([ \@{$self->latexcmdline} ],[ qw($self->latexcmdline) ] )
	);
}

sub _debug_end(){
	my $self=shift;

	my $ref=shift // '';

	foreach($ref) {
		/^verbatim$/ && do {
			$self->_debug_file_write("\\end{verbatim}\n");
			next;
		};
	}

}


sub _debug_sub_start() {
	my $self=shift;

	$self->subname((caller(1))[3]);

	my $msg="Subroutine start: " . $self->subname;

	$self->_debug($msg);

	# Increase by 1 the debug printing indentation level
	$self->debug_indent_inc;

}

sub _debug_sub_end() {
	my $self=shift;

	# Decrease by 1 the debug printing indentation level
	$self->debug_indent_dec;

	$self->_debug("Subroutine end: " . $self->subname);


}

=head3 _warning()

=cut

sub _warning() {
	my $self=shift;

	my $ref=shift // '';

	return 1 unless $ref;

	unless(ref $ref){
		my $msg=$ref;
		$msg=$self->_debug_set_msg($msg);
		Debug::Simple::warning($msg);
	}elsif(ref $ref eq "HASH"){
	}
}

=head3 _debug_set_msg()

=cut

sub _debug_set_msg(){
	my $self=shift;

	my $msg=shift // '';

	$msg=" " x $self->debug_indent . $msg . "\n";

	return $msg unless defined $self->package_name;

	$msg="(" . $self->package_name . ")" . ": " .  $msg;

	return $msg;
}

=head3 init_vars()

=cut

sub init_vars() {
	my $self=shift;

	$self->package_name(__PACKAGE__);

	$self->_debug_sub_start;

	my $x=$ENV{"PERLTEX"} // "latex";
	$self->latexprog($x);

	$self->_debug("Set latexprog to: " . $self->latexprog );

	my $prgname = basename $0;

	my $default_options={
		usepipe 	=> 1,
		runsafely  	=> 0,
		progname    => $prgname,
		jobname     => "texput",
		pipestring	=> "\%\%\%\%\% Generated by $prgname\n\\\\endinput\n"
	};
	my @optorder=qw(usepipe runsafely progname jobname pipestring);

###_SET_COREFILES
	$self->corefiles(qw(toperl fromperl toflag fromflag doneflag pipe));

	foreach my $k (@optorder){
		my $v=$default_options->{$k};
		eval '$self->' . $k . '(' . "\"$v\"" . ');' ;
		die $@ if $@;
		$self->_debug("Set $k to: " . "$v" );
	}

	$self->_debug_sub_end;

}

=head3 main()

=cut

sub main() {
	my $self=shift;

	@ARGV=@_ if (@_);

	$self->init_debug;

	$self->init_vars;

	$self->get_opt;
	$self->run;

	$self->_debug_end("verbatim");

}

###DONE_GETOPT

=head3 get_opt()

=cut

sub get_opt(){
	my $self=shift;

	$self->_debug_sub_start;

	Getopt::Long::Configure(qw(require_order pass_through));

	my($latexprog,$runsafely,$pipestring,$usepipe,$styfile);
	my @permittedops;

	GetOptions("help"       => 
		sub{
			pod2usage( 
				-input 			=> pod_where({-inc => 1}, __PACKAGE__),
			   	-verbose 	 	=> 1
			);
		},
           "latex=s"    => \$latexprog,
           "safe!"      => \$runsafely,
           "pipe!"      => \$usepipe,
           "synctext=s" => \$pipestring,
           "makesty"    => sub {$styfile = "noperltex.sty"},
           "permit=s"   => \@permittedops) || pod2usage(2);

	$self->latexcmdline(@ARGV);

	$self->_debug('Read latexcmdline from @ARGV: ' 
			. join(' ',$self->latexcmdline))
			if $self->latexcmdline_count;

	$self->_warning('$self->latexcmdline has zero elements')
		unless $self->latexcmdline_count;
	
	for my $v(qw(
				latexprog 
				runsafely 
				pipestring
				usepipe
				styfile
			)){
		my $val;
		eval '$val=$' . $v; die $@ if $@;

		eval '$self->' . $v . '($' . $v . ') if defined $' . $v . ';' ;
		die $@ if $@;

		if (defined $val){
			$self->_debug("Set $v to: " . $val );
		}
	}

	$self->permittedops(@permittedops);

	$self->_debug_sub_end;

}

sub run(){
	my $self=shift;

	$self->_debug_sub_start;

###LOOP_LATEXCMDLINE

	# this loop searches through the LaTeX
	#	input command-line 
	#		(coded as the array $self->latexcmdline)
	#	for the input filename; skipping options
	#	beginning with '-';
	#	once the input filename is
	#	found, it is stored in variable $self->jobname
	my $firstcmd=0;

	$self->_debug('Looping over $self->latexcmdline...');

	foreach my $option ($self->latexcmdline) {

		do { $firstcmd++; next; } if $option =~ /^-/;

	    unless($option =~ /^\\/) {
	        $self->jobname( basename $option, ".tex" );
			my $inp='\\input ' . $option;
	        $self->latexcmdline_set($firstcmd => "$inp" );
	    }
	    last;
	}

	$self->latexcmdline_push("") unless($self->latexcmdline_count);

	my $separator = "";
	foreach (1 .. 20) {
	    $separator .= chr(ord("A") + rand(26));
	}
	
	$self->toperl($self->jobname . ".topl");
	$self->fromperl($self->jobname . ".frpl");
	$self->toflag($self->jobname . ".tfpl");
	$self->fromflag($self->jobname . ".ffpl");
	$self->doneflag($self->jobname . ".dfpl");
	$self->logfile($self->jobname . ".lgpl");
	$self->pipe($self->jobname . ".pipe");

	foreach my $id (qw( 
		toperl fromperl toflag fromflag doneflag logfile pipe)) {
		my $val; eval '$val=$self->' . $id; die $@ if $@;
		$self->_debug('Have set: $self->' . $id . " to: " . $val);
	}

	my $ss;
	my $del='\\';

###_SET_TEXMACROS
	$ss.='\makeatletter';
	$ss.='\def\plmac@tag{' . $separator . '}';
	foreach my $f ($self->corefiles) {
		my $val;
		eval '$val=$self->' . $f;
		die $@ if $@;
		$f=~ s/perl/file/g if ($f =~ /^toperl|fromperl$/);
		$ss.='\def\plmac@' . $f . '{' . $val . '}';
	}
	$ss.='\makeatother' . $self->latexcmdline_index($firstcmd);
	#$ss=~ s/\\/\\\\/g;
	#my @sse=map {  s/$/%/g ? $_ : ()   } split("\n",$ss);	

	$self->set_latexcmdline( $firstcmd, $ss );

	$self->_debug_dump_latexcmdline;

	$self->toperl( File::Spec->rel2abs($self->toperl));
	$self->fromperl( File::Spec->rel2abs($self->fromperl));
	$self->toflag( File::Spec->rel2abs($self->toflag));
	$self->fromflag( File::Spec->rel2abs($self->fromflag));
	$self->doneflag( File::Spec->rel2abs($self->doneflag));
	$self->logfile( File::Spec->rel2abs($self->logfile));
	$self->pipe( File::Spec->rel2abs($self->pipe));

###DONE_IN_RUN


	$self->delete_files(
		$self->toperl, 
		$self->fromperl, 
		$self->toflag, 
		$self->fromflag, 
		$self->doneflag, 
		$self->pipe);
###_FILE_OPEN_LOGFILE
	try{
		open (LOGFILE, ">", $self->logfile);
	}catch {
   	    die "open(" . $self->logfile . "): $!\n";
	};
	$self->_debug("Opened LOGFILE for writing for: " . $self->logfile);

	autoflush LOGFILE 1;

	if (defined $self->styfile) {
		try{
	    	open (STYFILE, ">", $self->styfile) 
		}catch{
   	    	die "open(" . $self->styfile . "): $!\n";
		};
	}

	unless ($self->usepipe && eval {mkfifo($self->pipe, 0600)}) {
	    sysopen PIPE, $self->pipe, O_WRONLY|O_CREAT, 0755;
	    autoflush PIPE 1;
	    print PIPE $self->pipestring;
	    close PIPE;
	    $self->usepipe = 0;
	}

	defined ($latexpid = fork) || die "fork: $!\n";
	$self->_debug("Made a fork: latexpid=" . $latexpid);

	$self->latexcmdline_unshift($self->latexprog);

	$self->_debug_dump_latexcmdline;

###_IF_LATEXPID_ZERO 
# 		$latexpid=0 is for parent process
	unless($latexpid) {

		my $exe=$self->latexcmdline_index(0);
		$self->_debug("latexpid=0, so will execute: " . $exe);
		exec {$exe} $self->latexcmdline;
		#exec  $self->latexcmdline;
	    die "exec('\$self->latexcmdline'): $!\n";
	}

	if ($self->runsafely) {
	    $self->permittedops(":browse") unless $self->count_permittedops;
	    $sandbox->permit_only ($self->permittedops);
	    $sandbox_eval = sub {$sandbox->reval($_[0])};
	}
	else {
	    $sandbox_eval = \&top_level_eval;
	}

###LOOP_WHILE_1

	$self->_debug("Starting the while(1){ ... } loop...\n");

	while (1) {
		$self->debug_indent_inc;

	    $self->awaitexists($self->toflag);

		$self->_debug("Using File::Slurp::read_file to" 
		   	. "\n" . " read in the contents of the input file: "
			. "\n" . $self->toperl);

	    my $entirefile=File::Slurp::read_file($self->toperl);
	    $entirefile =~ s/\r//g;

	    my ($optag, $macroname, @otherstuff) =
	        map {chomp; $_} split "$separator\n", $entirefile;
	    $macroname =~ s/^[^A-Za-z]+//;
	    $macroname =~ s/\W/_/g;
	    $macroname = "latex_" . $macroname;
	    if ($optag eq "USE") {
	      foreach (@otherstuff) {
	          s/\\/\\\\/g;
	          s/\'/\\\'/g;
	          $_ = "'$_'";
	      }
	    }
	    my $perlcode;
	    if ($optag eq "DEF") {
	        $perlcode =
	            sprintf "sub %s {%s}\n",
	            $macroname, $otherstuff[0];
	    }
	    elsif ($optag eq "USE") {
	        $perlcode = sprintf "%s (%s);\n", $macroname, join(", ", @otherstuff);
	    }
	    elsif ($optag eq "RUN") {
	        $perlcode = $otherstuff[0];
	    }
	    else {
	        die "$self->progname: Internal error -- unexpected operation tag \"$optag\"\n";
	    }
	    print LOGFILE "#" x 31, " PERL CODE ", "#" x 32, "\n";
	    print LOGFILE $perlcode, "\n";
	    undef $_;
	    my $result;
	    {
	        my $warningmsg;
	        local $SIG{__WARN__} =
	            sub {chomp ($warningmsg=$_[0]); return 0};
	        $result = $sandbox_eval->($perlcode);
	        if (defined $warningmsg) {
	            $warningmsg =~ s/at \(eval \d+\) line \d+\W+//;
	            print LOGFILE "# ===> $warningmsg\n\n";
	        }
	    }
	    $result = "" if !$result || $optag eq "RUN";

	    if ($@) {
	        my $msg = $@;
	        $msg =~ s/at \(eval \d+\) line \d+\W+//;
	        $msg =~ s/\n/\\MessageBreak\n/g;
	        $msg =~ s/\s+/ /;
	        $result = "\\PackageError{perltex}{$msg}";

	        my @helpstring;
###PERL_ERROR_MESSAGE
	        if ($msg =~ /\btrapped by\b/) {
	            @helpstring =
	                ("The preceding error message comes from Perl.  Apparently,",
	                 "the Perl code you tried to execute attempted to perform an",
	                 "`unsafe' operation.  If you trust the Perl code (e.g., if",
	                 "you wrote it) then you can invoke perltex with the --nosafe",
	                 "option to allow arbitrary Perl code to execute.",
	                 "Alternatively, you can selectively enable Perl features",
	                 "using perltex's --permit option.  Don't do this if you don't",
	                 "trust the Perl code, however; malicious Perl code can do a",
	                 "world of harm to your computer system.");
	        }
	        else {
	            @helpstring =
	              ("The preceding error message comes from Perl.  Apparently,",
	               "there's a bug in your Perl code.  You'll need to sort that",
	               "out in your document and re-run perltex.");
	        }
	        my $helpstring = join ("\\MessageBreak\n", @helpstring);
	        $helpstring =~ s/\.  /.\\space\\space /g;
	        $result .= "{$helpstring}";
	    }
	    $self->push_macroexpansions($result) 
			if (defined $self->styfile && $optag eq "USE");

	    print LOGFILE "%" x 30, " LATEX RESULT ", "%" x 30, "\n";
	    print LOGFILE $result, "\n\n";
	    $result .= '\endinput';

###_FILE_OPEN_FROMPERL
	    open (FROMPERL, ">",$self->fromperl) || die "open($self->fromperl): $!\n";
	    syswrite FROMPERL, $result;
	    close FROMPERL;

	    $self->delete_files($self->toflag, $self->toperl, $self->doneflag);
	    open (FROMFLAG, ">", $self->fromflag) || die "open($self->fromflag): $!\n";
	    close FROMFLAG;
	    if (open (PIPE, ">", $self->pipe)) {
	        autoflush PIPE 1;
	        print PIPE $self->pipestring;
	        close PIPE;
	    }
	    $self->awaitexists($self->toperl);

	    $self->delete_files($self->fromflag);

	    open (DONEFLAG, ">",$self->doneflag) || die "open($self->doneflag): $!\n";
	    close DONEFLAG;
	    alarm 1;
	    if (open (PIPE, ">", $self->pipe )) {
	        autoflush PIPE 1;
	        print PIPE $self->pipestring;
	        close PIPE;
	    }
	    alarm 0;
	}
	$self->debug_indent_dec;

	$self->_debug("Ended the while(1){ ... }\n");

	$self->atend(\*LOGFILE);
		
}

###DONE_AFTER

sub delete_files (@)
{
	my $self=shift;

    foreach my $filename (@_) {
        unlink $filename;
        while (-e $filename) {
            unlink $filename;
            sleep 0;
        }
    }
}

sub awaitexists ($)
{
	my $self=shift;

    while (!-e $_[0]) {
        sleep 0;
        if (waitpid($latexpid, &WNOHANG)==-1) {
			$self->_corefiles_delete;
            undef $latexpid;
            exit 0;
        }
    }
}


sub _corefiles_delete{
	my $self=shift;

	$self->delete_files($_)
		for($self->corefiles);

}

sub atend() {
	my $self=shift;

	$self->_debug_sub_start;

	local *LOGFILE=shift;

###_FILE_CLOSE_LOGFILE
    close LOGFILE;

	$self->fh("debug_outfile")->close;

	$self->_debug("Closed LOGFILE");

    if (defined $latexpid) {
        kill (9, $latexpid);
        exit 1;
    }

    if (defined $self->styfile) {
		my $jobname=$self->jobname;

        print STYFILE <<"STYFILEHEADER1";
\\NeedsTeXFormat{LaTeX2e}[1999/12/01]
\\ProvidesPackage{noperltex}
    [2007/09/29 v1.4 Perl-free version of PerlTeX specific to $jobname.tex]
STYFILEHEADER1
        ;
        print STYFILE <<'STYFILEHEADER2';
\RequirePackage{filecontents}

\let\noperltex@PackageError=\PackageError
\renewcommand{\PackageError}[3]{}
\RequirePackage{perltex}
\let\PackageError=\noperltex@PackageError

\newcount\plmac@macro@invocation@num
\gdef\plmac@show@placeholder#1#2\@empty{%
  \ifx#1U\relax
    \endgroup
    \advance\plmac@macro@invocation@num by 1\relax
    \global\plmac@macro@invocation@num=\plmac@macro@invocation@num
    \input{noperltex-\the\plmac@macro@invocation@num.tex}%
  \else
    \endgroup
  \fi
}
STYFILEHEADER2
        ;
		my @macroexpansions=$self->macroexpansions;
        foreach my $e (0 .. $#macroexpansions) {
            print STYFILE "\n";
            printf STYFILE "%% Invocation #%d\n", 1+$e;
                printf STYFILE "\\begin{filecontents}{noperltex-%d.tex}\n", 1+$e;
            print STYFILE $macroexpansions[$e], '\endinput' . "\n";
            print STYFILE "\\end{filecontents}\n";
        }
        print STYFILE '\endinput' . "\n";
        close STYFILE;
    }

	$self->_debug_sub_end;
}


1;

__END__

=head1 NAME

perltex - enable LaTeX macros to be defined in terms of Perl code

=head1 SYNOPSIS

perltex
[B<--help>]
[B<--latex>=I<program>]
[B<-->[B<no>]B<safe>]
[B<--permit>=I<feature>]
[B<--makesty>]
[I<latex options>]

=head1 DESCRIPTION

LaTeX -- through the underlying TeX typesetting system -- produces
beautifully typeset documents but has a macro language that is
difficult to program.  In particular, support for complex string
manipulation is largely lacking.  Perl is a popular general-purpose
programming language whose forte is string manipulation.  However, it
has no typesetting capabilities whatsoever.

Clearly, Perl's programmability could complement LaTeX's typesetting
strengths.  B<perltex> is the tool that enables a symbiosis between
the two systems.  All a user needs to do is compile a LaTeX document
using B<perltex> instead of B<latex>.  (B<perltex> is actually a
wrapper for B<latex>, so no B<latex> functionality is lost.)  If the
document includes a C<\usepackage{perltex}> in its preamble, then
C<\perlnewcommand> and C<\perlrenewcommand> macros will be made
available.  These behave just like LaTeX's C<\newcommand> and
C<\renewcommand> except that the macro body contains Perl code instead
of LaTeX code.

=head1 OPTIONS

B<perltex> accepts the following command-line options:

=over 4

=item B<--help>

Display basic usage information.

=item B<--latex>=I<program>

Specify a program to use instead of B<latex>.  For example,
C<--latex=pdflatex> would typeset the given document using
B<pdflatex> instead of ordinary B<latex>.

=item B<-->[B<no>]B<safe>

Enable or disable sandboxing.  With the default of B<--safe>,
B<perltex> executes the code from a C<\perlnewcommand> or
C<\perlrenewcommand> macro within a protected environment that
prohibits ``unsafe'' operations such as accessing files or executing
external programs.  Specifying B<--nosafe> gives the LaTeX document
I<carte blanche> to execute any arbitrary Perl code, including that
which can harm the user's files.  See L<Safe> for more information.

=item B<--permit>=I<feature>

Permit particular Perl operations to be performed.  The B<--permit>
option, which can be specified more than once on the command line,
enables finer-grained control over the B<perltex> sandbox.  See
L<Opcode> for more information.

=item B<--makesty>

Generate a LaTeX style file called F<noperltex.sty>.  Replacing the
document's C<\usepackage{perltex}> line with C<\usepackage{noperltex}>
produces the same output but does not require PerlTeX, making the
document suitable for distribution to people who do not have PerlTeX
installed.  The disadvantage is that F<noperltex.sty> is specific to
the document that produced it.  Any changes to the document's PerlTeX
macro definitions or macro invocations necessitates rerunning
B<perltex> with the B<--makesty> option.

=back

These options are then followed by whatever options are normally
passed to B<latex> (or whatever program was specified with
C<--latex>), including, for instance, the name of the F<.tex> file to
compile.

=head1 EXAMPLES

In its simplest form, B<perltex> is run just like B<latex>:

    perltex myfile.tex

To use B<pdflatex> instead of regular B<latex>, use the B<--latex>
option:

    perltex --latex=pdflatex myfile.tex

If LaTeX gives a ``C<trapped by operation mask>'' error and you trust
the F<.tex> file you're trying to compile not to execute malicious
Perl code (e.g., because you wrote it yourself), you can disable
B<perltex>'s safety mechansisms with B<--nosafe>:

    perltex --nosafe myfile.tex

The following command gives documents only B<perltex>'s default
permissions (C<:browse>) plus the ability to open files and invoke the
C<time> command:

    perltex --permit=:browse --permit=:filesys_open
      --permit=time myfile.tex

=head1 ENVIRONMENT

B<perltex> honors the following environment variables:

=over 4

=item PERLTEX

Specify the filename of the LaTeX compiler.  The LaTeX compiler
defaults to ``C<latex>''.  The C<PERLTEX> environment variable
overrides this default, and the B<--latex> command-line option (see
L</OPTIONS>) overrides that.

=back

=head1 FILES

While compiling F<jobname.tex>, B<perltex> makes use of the following
files:

=over 4

=item F<jobname.lgpl>

log file written by Perl; helpful for debugging Perl macros

=item F<jobname.topl>

information sent from LaTeX to Perl

=item F<jobname.frpl>

information sent from Perl to LaTeX

=item F<jobname.tfpl>

``flag'' file whose existence indicates that F<jobname.topl> contains
valid data

=item F<jobname.ffpl>

``flag'' file whose existence indicates that F<jobname.frpl> contains
valid data

=item F<jobname.dfpl>

``flag'' file whose existence indicates that F<jobname.ffpl> has been
deleted

=item F<noperltex-#.tex>

file generated by F<noperltex.sty> for each PerlTeX macro invocation

=back

=head1 NOTES

B<perltex>'s sandbox defaults to what L<Opcode> calls ``C<:browse>''.

=head1 SEE ALSO

latex(1), pdflatex(1), perl(1), Safe(3pm), Opcode(3pm)

=head1 AUTHOR

Scott Pakin, I<scott+pt@pakin.org>
=end

#vim: set makeprg=install.sh :
