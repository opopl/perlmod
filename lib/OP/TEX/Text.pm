
package OP::TEX::Text;

# Intro {{{

use strict;
use warnings;

use feature qw(switch);

use Data::Dumper;
use File::Slurp qw(read_file);
use File::Spec::Functions qw(catfile );

use OP::Base qw(_hash_add);

###begin
BEGIN {
    use Env qw( $hm $PERLMODDIR );

    use FindBin qw($Bin $Script);
    use File::Spec::Functions qw(catfile);
    
    use lib("$PERLMODDIR/mods/OP-Base/lib");
    use OP::Base qw( $endl );

    use lib("$PERLMODDIR/mods/OP-Writer/lib");
    use parent qw( OP::Writer );
    
}

=head1 NAME

OP::TEX::Text - Perl package for writing TeX documents

=head1 SYNOPSIS

use OP::TEX::Text;

my $t=OP::TEX::Text->new;

=head1 INHERITANCE

=over 4

=item L<OP::Writer>

=back
 
=head1 DEPENDENCIES
 
=over 4
 
=item L<Data::Dumper>
 
=item L<File::Slurp>
 
=item L<File::Spec::Functions>
 
=item L<OP::Base>
 
=item L<parent>
 
=item L<strict>
 
=item L<warnings>
 
=back
 
=cut
 

###subs
sub usepackage;
sub true;
sub toc;
sub subsubsection;
sub subsection;
sub setcounter;
sub section;
sub printindex;
sub preamble;
sub part;
sub paragraph;
sub newnc;
sub nc;
 
=head1 METHODS
 
=over 4
 
=item L<_cmd()>
 
=item L<_init()>
 
=item L<_insert_file()>
 
=item L<_write_fancyhdr_style()>
 
=item L<_write_hash()>
 
=item L<abstract()>
 
=item L<anchor()>
 
=item L<begin()>
 
=item L<bibliography()>
 
=item L<bookmark()>
 
=item L<chapter()>
 
=item L<clearpage()>
 
=item L<date()>
 
=item L<def()>
 
=item L<documentclass()>
 
=item L<end()>
 
=item L<figure()>
 
=item L<hypertarget()>
 
=item L<hypsetup()>
 
=item L<idef()>
 
=item L<input()>
 
=item L<lof()>
 
=item L<lot()>
 
=item L<nc()>
 
=item L<newnc()>
 
=item L<paragraph()>
 
=item L<part()>
 
=item L<preamble()>
 
=item L<printindex()>
 
=item L<section()>
 
=item L<setcounter()>
 
=item L<subsection()>
 
=item L<subsubsection()>
 
=item L<toc()>
 
=item L<true()>
 
=item L<usepackage()>
 
=back
 
=cut
 
sub lot;
sub lof;
sub input;
sub idef;
sub hypsetup;
sub hypertarget;
sub figure;
sub end;
sub documentclass;
sub def;
sub date;
sub clearpage;
sub chapter;
sub bookmark;
sub bibliography;
sub begin;
sub anchor;
sub abstract;
sub _write_hash;
sub _write_fancyhdr_style;
sub _insert_file;
sub _init;
sub _cmd;

###__ACCESSORS_SCALAR
our @scalar_accessors = qw(
  dclass
  dims
  docstyle
  doctitle
  makeindex
  ncfiles
  packopts
  put_today_date
  shift_parname
  texroot
  usedpacks
);

###__ACCESSORS_HASH
our @hash_accessors = qw(
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
    preamble_input_opts
    bibliography_input_opts
);

__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_array_accessors(@array_accessors)->mk_hash_accessors(@hash_accessors);

# }}}
# Methods {{{

=head3 _write_hash()

=cut

sub _write_hash {
    my $self = shift;

    my $ncname = shift // '';
    my $ref    = shift // '';
    my $str    = '';

    if ( ref $ref eq "HASH" ) {
        if (%$ref) {
            while ( my ( $k, $v ) = each %{$ref} ) {
                $str .=
                    '   \ifthenelse{\equal{#1}{'
                  . $k . '}}{'
                  . $v . '}{}%' . "\n";
            }
        }
        else {
            $self->warn("_write_hash: zero-size hash supplied");
        }

    }

    if ($str) {
        $str = "%\n" . $str;
        $self->_c_delim;
        $self->nc( $ncname, $str, 1 );
        $self->_c_delim;
    }

}

=head3 _cmd()

=head4 USAGE

=over 4

=item $TEX->_cmd('maketitle');

=item $TEX->_cmd('begin','document');

=item $TEX->_cmd('begin','section');

=back

=cut

sub _cmd {
    my $self = shift;

    my $ref = shift // '';
    my @opts = @_;

    return 1 unless $ref;

    my ( $text, $vars, $cmd, $optvars );

    $text='';

    unless ( ref $ref ) {
        $text = "\\" . $ref;

        unless (@opts) {
        }
        else{
            $text .= "{" . join("}{",map { length($_) ? $_ : ()  } @opts) . "}";
        }
    }
    elsif ( ref $ref eq "HASH" ) {

        $cmd = $ref->{cmd} // '';

        $self->_die("_cmd(): Did not specify command name!")
          unless $cmd;

        $text = "\\$cmd";

        # arguments enclosed as {...}
        $vars = $ref->{vars} // '';

        # optional arguments enclosed as [...]
        $optvars = $ref->{optvars} // '';

        $self->_die("_cmd(): Did not specify the list of variables!")
          unless $cmd;

        unless(ref $vars){
              $text.='{' . $vars . '}' ;
        }elsif(ref $vars eq "ARRAY"){

            ###first argument
            $text.='{' . shift(@$vars) . '}' ;

            if (@$vars){
                $text .= "{" . join("}{",map { length($_) ? $_ : ()  } @$vars) . "}";
            }
        }

        if($optvars){
               $text.='[' . $optvars . ']' ;
        }
    }

    if ($text){
        $self->_add_line("$text");
    }

}

=head3 def()

=head4 SYNOPSIS

=over 4

=item def('')                 -> returns 1 

=item def('PROJ','')          -> \def\PROJ{}

=item def('PROJ','hello')     -> \def\PROJ{hello}

=item def('PROJ','hello',2)   -> \def\PROJ#1#2{hello}

=back

=cut

sub def {
    my $self = shift;

    my $def   = shift // '';

    return 1 unless $def;

    my $src   = shift // '';
    my $nargs = shift // 0;

    unless ($nargs) {
        $self->_add_line( "\\def" . "\\$def" . "{$src}" );
    }else{
        my $argline='';
        foreach my $i ((1..$nargs)) {
            $argline.='#' . $i ;
        }
        $self->_add_line( "\\def" . "\\$def" . $argline .  "{$src}" );
    }

}

=head3 section()

=cut

sub section {
    my $self = shift;

    my $title = shift // '';

    $self->_cmd('section',"$title");

}

=head3 part()

=cut

sub part {
    my $self = shift;

    my $title = shift // '';

    $self->_cmd('part',"$title");
}

=head3 _insert_file()

=cut

sub _insert_file {
    my $self = shift;

    my $file = shift // '';

    return 1 unless -e $file;

    my @lines = read_file $file;

    foreach my $line (@lines) {
        chomp($line);
        $self->_add_line("$line");
    }
}

=head3 input()

=head4 USAGE 

=over 4

=item input($filename,{ %OPTIONS });

=back

=head4 EXAMPLES

=over 4

=item input('a',{ check_exists  => 1 } );
=item input('a');

=back

=cut

sub input {
    my $self = shift;

    my $file = shift // '';
    my $ref  = shift // '';

    my @options = qw(check_exists);

    unless ($ref) {
        $self->_add_line("\\input{$file}");
    }
    elsif ( ref $ref eq "HASH" ) {
        while ( my ( $k, $v ) = each %{$ref} ) {
            foreach ($k) {
                /^check_exists$/ && do {
                    $self->_cmd('input',$file)
                      if ( -e $file );
                    next;
                };
            }
        }
    }
}

=head3 end()

=cut

sub end() {
    my $self = shift;

    my $x = shift // '';
    return 1 unless $x;

    $self->minus('indent',2);

    $self->_cmd( "end", $x );


}

# documentclass () {{{

=head3 documentclass()

	documentclass({
		opts => 'a4paper,11pt',
	});
	
	documentclass({
		opts => [qw(a4paper 11pt)],
	});

=cut

sub documentclass() {
    my $self = shift;

    my $class = shift // '';
    my $ref   = shift // {};
    my $stropts;

    while ( my ( $k, $v ) = each %{$ref} ) {
        for ($k) {
            /^opts$/ && do {

                # string containing comma-delimited
                #   list of supplied options
                unless ( ref $v ) {
                    $stropts = $v;
                }
                elsif ( ref $v eq "ARRAY" ) {

                    # options are stored as an array
                    $stropts = join( ',', @$v );
                }
                next;
            };
        }
    }
    my $s;
    ##TODO documentclass

    if ($stropts) {
        $s = '\documentclass[' . $stropts . ']{' . $class . '}';
    }
    else {
        $s = '\documentclass{' . $class . '}';
    }
    $self->_add_line($s);

}

=head3 date()

=cut

sub date() {
    my $self = shift;

    my $x = shift // '';
    return 1 unless $x;

    $self->_cmd( "date", $x );

}

=head3 begin()

=cut

sub begin() {
    my $self = shift;

    my $what = shift // '';
    my $ref = shift // '';
    my @rest=@_;

    return 1 unless $what;
    
    my($vars,$optvars);

    push(@$vars,$what);

    if ($ref){
	    unless(ref $ref){
	        push(@$vars,$ref);
	        push(@$vars,@rest) if @rest;
	    }elsif(ref $ref eq "HASH"){
	        push(@$vars,@{$ref->{vars}}) if defined $ref->{vars};
	        $optvars=$ref->{optvars} // '';
	    }
    }

    $self->_cmd( { 
            cmd         => "begin", 
            vars        => $vars,
            optvars     => $optvars,
        } );

    $self->plus('indent',2);

}

=head3 usepackage()

=cut

sub usepackage() {
    my $self = shift;

    my $ref = shift // '';

    return 1 unless $ref;

    my ( $pack, $opts );

    unless ( ref $ref ) {
        $pack = $ref;
        $opts = shift // '';
    }
    elsif ( ref $ref eq "HASH" ) {
        $pack = $ref->{package} // '';
        $opts = $ref->{options} // '';
    }

    return 1 unless $pack;

    if ($opts) {
		unless(ref $opts){
        	$self->_add_line("\\usepackage[$opts]{$pack}");
		}elsif(ref $opts eq "ARRAY"){
        	$self->_add_line(
					"\\usepackage[" . join(',',@$opts) . "]{$pack}");
		}
    }
    else {
        $self->_add_line("\\usepackage{$pack}");
    }

}

sub usepackages {
    my $self=shift;

    my $packs=shift // [];

    foreach my $pack (@$packs) {
        $self->usepackage($pack);
    }
}

=head3 newnc()

=cut

sub newnc {
    my $self = shift;

    my $ref = shift;

    unless ( ref $ref ) {

    }
    elsif ( ref $ref eq "ARRAY" ) {
        my @ncs = @$ref;
        foreach my $nc (@ncs) {
            $self->nc( $nc, '' );
        }
    }
}

=head3 nc()

=cut

sub nc() {
    my $self = shift;

    my ( $name, $cmd, $npars ) = @_;

    unless ( defined $npars ) {
        $self->_add_line("\\nc{\\$name}{$cmd}");
    }
    else {
        $self->_add_line("\\nc{\\$name}[$npars]{$cmd}");
    }
}

=head3 idef()

=cut

sub idef() {
    my $self = shift;

    my $name = shift;

    $self->_add_line("\\idef{$name}");

}

=head3 figure()

=cut

sub figure() {
    my $self = shift;

    my %opts = @_;
    my $ostr = '';

    my $width = '10cm';

    # graphics file to be used in includegraphics statements
    my @gfiles;
    my @igs;
    my $pdir = 'ppics';
    my $pos  = '';

    while ( my ( $k, $v ) = each %opts ) {
        for ($k) {
            /^(width|pdir)$/ && do {
                my $evs = '$' . $k . '=$v';
                eval("$evs");
                die $@ if $@;
                next;
            };
            /^(position)$/ && do {
                $pos = $v;
                next;
            };
            /^(files)$/ && do {
                unless ( ref $v ) {
                    push( @gfiles, $v );
                }
                elsif ( ref $v eq "ARRAY" ) {
                    push( @gfiles, @$v );
                }
                next;
            };
        }
    }

    foreach my $gfile (@gfiles) {
        push( @igs,
                '\includegraphics[width='
              . $width . ']{'
              . catfile( $pdir, $gfile )
              . '}' );
    }

    $pos = '[' . $pos . ']' if ($pos);

    $ostr .= '\begin{figure}' . $pos . "\n";
    $ostr .= ' \begin{center}' . "\n";

    if ( @igs == 1 ) {
        $ostr .= shift(@igs) . "\n";
    }
    else {
    }

    $ostr .= '  \end{center}' . "\n";
    $ostr .= '\end{figure}' . "\n";

    $self->_add_line("$ostr");

}

=head3 bookmark()

=cut

sub bookmark() {
    my $self = shift;

    my %opts  = @_;
    my $ostr  = '';
    my $str   = '';
    my $title = '';

    #\bookmark[view={FitB},dest=sec:\SEC#1,level=2]{#2}%

    while ( my ( $k, $v ) = each %opts ) {
        for ($k) {
            /^(level|dest)$/ && do {
                $ostr .= "$k=" . "$v" . ',';
                next;
            };
            /^(title)$/ && do {
                $title = $v;
                next;
            };
        }
    }

    $str = "\\bookmark[$ostr]{$title}";

    $self->_add_line("$str");

}

=head3 subsubsection()

=cut

sub subsubsection() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\subsubsection{$title}");
}

=head3 subsection()

=cut

sub subsection() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\subsection{$title}");
}

=head3 chapter()

=cut

sub chapter() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\chapter{$title}");
}

=head3 paragraph()

=cut

sub paragraph() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\paragraph{$title}");
}

# lof() {{{

=head3 lof()

=cut

sub lof() {
    my $self = shift;

    my $ref = shift // '';

    my $opts = {
        title       => "List of Figures",
        hypertarget => "lof",
        sec         => "chapter"
    };

    unless ( ref $ref ) {

        # body...
    }
    elsif ( ref $ref eq "HASH" ) {
        while ( my ( $k, $v ) = each %{$ref} ) {
            $opts->{$k} = $ref->{$k};
        }
    }
    elsif ( ref $ref eq "ARRAY" ) {

        # body...
    }

    $self->_c_delim;
    $self->_c("List of Figures");
    $self->_c_delim;

    my $s =
        "\\clearpage" . "\n"
      . "\\phantomsection" . "\n"
      . "\\hypertarget{$opts->{hypertarget}}{}" . "\n"
      . "\\listoffigures" . "\n"
      . "\\nc{\\pagenumlof}{\\thepage}" . "\n"
      . "\\addcontentsline{toc}{$opts->{sec}}{$opts->{title}}";

###LOF_TEXT

    $self->_add_line("$s");
    $self->_c_delim;

}

# }}}
# lot() {{{

=head3 lot()

=cut

sub lot {
    my $self = shift;

    my $ref = shift // '';

    my $opts = {
        title       => "List of Tables",
        hypertarget => "lot",
        sec         => "chapter"
    };

    unless ( ref $ref ) {

        # body...
    }
    elsif ( ref $ref eq "HASH" ) {
        while ( my ( $k, $v ) = each %{$ref} ) {
            $opts->{$k} = $ref->{$k};
        }
    }
    elsif ( ref $ref eq "ARRAY" ) {

        # body...
    }

    $self->_c_delim;
    $self->_c("List of Tables");
    $self->_c_delim;

    my $s =
        "\\clearpage" . "\n"
      . "\\phantomsection" . "\n"
      . "\\hypertarget{$opts->{hypertarget}}{}" . "\n"
      . "\\listoftables" . "\n"
      . "\\nc{\\pagenumlot}{\\thepage}" . "\n"
      . "\\addcontentsline{toc}{$opts->{sec}}{$opts->{title}}";

###LOT_TEXT

    $self->_add_line("$s");
    $self->_c_delim;

}

# }}}

=head3 true()

=cut

sub true {
    my $self = shift;

    my @cmds = @_;

    foreach my $cmd (@cmds) {
        $self->_add_line( "\\" . $cmd . 'true' );
    }
}

=head3 toc()

=cut

sub toc() {
    my $self = shift;

    my $ref = shift // '';

    my $opts = {
        title       => "Table of Contents",
        hypertarget => "toc",
        sec         => "chapter"
    };

    unless ( ref $ref ) {

        # body...
    }
    elsif ( ref $ref eq "HASH" ) {
        while ( my ( $k, $v ) = each %{$ref} ) {
            $opts->{$k} = $ref->{$k};
        }
    }
    elsif ( ref $ref eq "ARRAY" ) {

        # body...
    }

    $self->_c_delim;
    $self->_c("Table of Contents");
    $self->_c_delim;

    my $s =
        "\\clearpage" . "\n"
      . "\\phantomsection" . "\n"
      . "\\hypertarget{$opts->{hypertarget}}{}" . "\n"
      . "\\tableofcontents" . "\n"
      . "\\nc{\\pagenumtoc}{\\thepage}" . "\n"
      . "\\addcontentsline{toc}{$opts->{sec}}{$opts->{title}}";

###TOC_TEXT

    $self->_add_line("$s");
    $self->_c_delim;

}

=head3 abstract()

=cut

sub abstract () {
    my $self = shift;

    my $text = shift;

    $self->begin('abstract');
    $self->_add_line("$text");
    $self->end('abstract');
}

=head3 anchor()

=cut

sub anchor () {
    my $self = shift;

    my $anchor = shift;

    $self->_add_line("%%%$anchor");
}

=head3 bibliography()

=cut

sub bibliography() {
    my $self = shift;

    my $ref = shift // '';

    die "No arguments to bibliography()"
      unless $ref;

    my $opts = {
        title       => "Bibliography",
        hypertarget => "lot",
        sec         => "chapter"
    };

    unless ( ref $ref ) {

        # body...
    }
    elsif ( ref $ref eq "HASH" ) {
        foreach my $k ($self->bibliography_input_opts) {
            $opts->{$k} = $ref->{$k} // '';
        }
    }
    elsif ( ref $ref eq "ARRAY" ) {

        # body...
    }

###Bibliography
    my $text =
        "\\cleardoublepage" . "\n"
      . "\\phantomsection" . "\n"
      . "\\hypertarget{$opts->{hypertarget}}{}" . "\n" . "" . "\n"
      . "\\addcontentsline{toc}{$opts->{sec}}{Bibliography}" . "\n" . ""
      . "\n"
      . "\\bibliographystyle{$opts->{bibstyle}}";

    $self->_c_delim;
    $self->_c("Bibliography section");
    $self->_c_delim;
    $self->_add_line("$text");

    # Additional input files, if specified
    if ( $opts->{inputs} ) {
        unless ( ref $opts->{inputs} ) {
            $self->input( $opts->{inputs} );
        }
        elsif ( ref $opts->{inputs} eq "ARRAY" ) {
            foreach my $if ( @{ $opts->{inputs} } ) {
                $self->input($if);
            }
        }
    }

    $self->_add_line("\\nc{\\pagenumbib}{\\thepage}");

    # Bibliography files (*.bib)
    if ( $opts->{bibfiles} ) {
        unless ( ref $opts->{bibfiles} ) {
            my $if = $opts->{bibfiles};
            $self->_add_line("\\bibliography{$if}");
        }
        elsif ( ref $opts->{bibfiles} eq "ARRAY" ) {
            foreach my $if ( @{ $opts->{bibfiles} } ) {
                $self->_add_line("\\bibliography{$if}");
            }
        }
    }
    $self->_c_delim;

}

=head3 _write_fancyhdr_style()

=cut

sub _write_fancyhdr_style {
    my $self=shift;

    my $ref=shift // {};

    while(my($k,$v)=each %{$ref}){
        if(grep { /^$k$/ } qw( 
						lhead
						chead
						rhead
						lfoot
						cfoot
						rfoot
                ))
        {
            $self->_add_line("\\$k\{$v\}");
        } elsif(grep { /^$k$/ } qw( 
	        			headrulewidth
			        	footrulewidth
                ))
        {
            $self->_add_line("\\renewcommand\{\\$k\}\{$v\}");
        
        }
    }


}


=head3 setcounter()

=cut

sub setcounter {
    my $self=shift;

    my $counter=shift;
    my $val=shift;

    $self->_add_line('\setcounter{' . $counter . '}{' . $val . '}');

}
=head3 setlength()

=cut

sub setlength {
    my $self=shift;

    my $length=shift;
    my $val=shift;

    $self->_add_line('\setlength{' . "\\" .  $length . '}{' . $val . '}');

}

=head3 clearpage()

=cut

sub clearpage() {
    my $self = shift;

    $self->_add_line('\clearpage');
}

=head3 printindex()

=cut

sub printindex() {
    my $self = shift;

    my $s = '
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
    my $self = shift;

    my $ref = shift // '';

    die "No arguments to preamble()"
      unless $ref;

    # Print some comments in preamble
    my $date = localtime;

    $self->_c_delim;
    $self->_c("Generated on: $date");
    $self->_c_delim;

    unless ( ref $ref ) {
    }
    elsif ( ref $ref eq "HASH" ) {

        # Used packages related
        my $usedpacks = [];
        my $packopts  = {};

        # Title of the document
        my $doctitle = '';
###Preamble_Define_Input_Opts
        # Process the contents of the subroutine's
        #	input hash

###Preamble_Process_Input_Opts
        foreach my $k ($self->preamble_input_opts) {

            unless ( defined $ref->{$k} ) {
                $ref->{$k} = '';
                next;
            }

            my $v = $ref->{$k};

            foreach ($k) {
                /^dclass$/ && do {
                    my ( $class_name, $class_opts, $text );

                    my @arr;

                    unless ( ref $v ) {
                        @arr = split( " ", $v );
                    }
                    elsif ( ref $v eq "ARRAY" ) {
                        @arr = @$v;
                    }

                    $class_name = shift @arr;
                    $class_opts = join( ',', @arr );

                    $text = "\\documentclass[$class_opts]{$class_name}";
                    $self->_empty_lines;
                    $self->_add_line("$text");
                    $self->_empty_lines;
                    next;
                };
                /^usedpacks$/ && do {
                    $usedpacks = $v;
                    next;
                };
                /^packopts$/ && do {
                    $packopts = $v;
                    next;
                };
                /^doctitle$/ && do {
                    $doctitle = $v;
                    next;
                };
            }
        }

        # Once the input ref is processed, performs
        #	necessary actions

###Preamble_Used_Packs
        #	Generate LaTeX code for the list of used packages
        if ($usedpacks) {

            my @packifs;

            $self->_c_delim;
            $self->_c("List of used packages");
            $self->_c_delim;
            $self->anchor("used_packages");

            foreach my $pack (@$usedpacks) {
                my $opts = $packopts->{$pack} // '';
                my $s_opts = '';
                $s_opts = "[$opts]" if $opts;
                my $text = "\\usepackage" . $s_opts . "{$pack}";
                $self->_add_line("$text");
                push(@packifs,"\\newif\\ifPACK$pack\\PACK$pack" . "true");
            }
            $self->_c_delim;
            foreach my $pif  (@packifs) {
                $self->_add_line("$pif");
            }
            $self->_c_delim;
        }
###Preamble_NC
        # New-commands files
        if ( $ref->{ncfiles} ) {
            $self->_c_delim;
            $self->_c("New commands");
            $self->_c_delim;
            foreach my $x ( @{ $ref->{ncfiles} } ) {
                $self->input("$x");
            }
            $self->_c_delim;
        }
###Preamble_Doc_Title
        # Document's title
        if ($doctitle) {
            $self->_add_line("\\title{$doctitle}");
        }
###Preamble_Doc_Today_Date
        if ( $ref->{put_today_date} ) {
            $self->date("\\today");
        }
###Preamble_Make_Index
        # Makeindex
        if ( $ref->{makeindex} ) {
            $self->_add_line("\\makeindex");
        }
###Preamble_Hyper_Setup
        if ( $ref->{hypsetup} ) {
            $self->hypsetup( $ref->{hypsetup} );
        }
###Preamble_Document_Dims - document layout controlling lengths
        if ( $ref->{dims} ) {
            my $dims = $ref->{dims};

            while ( my ( $k, $v ) = each %{$dims} ) {
                $self->_add_line("\\setlength{\\$k}{$v}");
            }
        }
        if ( $ref->{shift_parname} ) {
            my $s = <<'EOF';
%%%%%%%%%%%%%%%
\makeatletter
\renewcommand\paragraph{%
   \@startsection{paragraph}{4}{0mm}%
      {-\baselineskip}%
      {.5\baselineskip}%
      {\normalfont\normalsize\bfseries}}
\makeatother
%%%%%%%%%%%%%%%
EOF
            $self->_add_line($s);
        }
    }
}

=head3 hypertarget()

=cut

sub hypertarget() {
    my $self = shift;

    my $ref = shift // '';

    $self->_add_line( '\hypertarget{' . $ref . '}{}' );
}

sub includepdf {
    my $self = shift;

    my $iref = shift // '';
    my $ref;
    my $opts;
    my $optstr='';

    if(ref $iref eq "HASH"){
        $opts=$iref->{opts} // {};
    }

    $ref={
        pages => 'all',
    };

    given($ref->{pages}){
        when('all') { 
            $optstr.='pages=-';
        }
        default { }
    }

    my $pfile=$iref->{fname} . '.pdf' // '';
    return '' unless $pfile;

    $self->_add_line( '\includepdf[' . $optstr . ']{'  . $pfile . '}' );

}

=head3 hypsetup()

=cut

sub hypsetup() {
    my $self = shift;

    my $iref = shift // '';
    my $ref;

    my @keys=qw(pdfauthor pdftitle);
    foreach my $k (@keys) {
        $ref->{$k}='';
    }
    $ref=_hash_add($ref,$iref);

    $self->_die("Author name was not specified in hypsetup()")
      unless  $ref->{pdfauthor};
    $self->_die("Title was not specified in hypsetup()")
      unless  $ref->{pdftitle};

    my $text;

##TODO hypsetup
    $text='';

    $text.='\hypersetup{'                         .$endl ;

    my $indent=' ' x 5;

    while(my($k,$v)=each %{$ref}){
        if($v eq "1"){
            $text.=$indent . $k  . ','                  .$endl ;
        }elsif($k =~ /^pdf(title|author|view)$/){
            $text.=$indent . $k . "={" . $v . "},"      .$endl ;

        }else{
            $text.=$indent . $k . '=' . $v . ','        .$endl ;
        }
    }
    $text.='}'                                    .$endl ;

    $self->_c_delim;
    $self->_c("Hypersetup (for hyperlinked PDFs)");
    $self->_c_delim;
    $self->anchor("hypersetup");
    $self->_add_line("$text");
    $self->_c_delim;

}

=head3 _init()

=cut

sub _init {
    my $self = shift;

    $self->OP::Writer::_init;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->commentchar('%');

    $self->preamble_input_opts(qw(
          dclass
          doctitle
          docstyle
          packopts
          usedpacks
          makeindex
          put_today_date
          shift_parname
          dims
          ncfiles
     ));

    $self->bibliography_input_opts ( qw(
      hypertarget title bibstyle inputs bibfiles sec
    ));

}

# }}}
1;

