
package OP::TEX::Text;

# Intro {{{

use strict;
use warnings;

use OP::Base qw/:vars :funcs/;
use Data::Dumper;
use File::Slurp qw(read_file);
use File::Spec::Functions qw(catfile rel2abs curdir catdir );

use parent qw(OP::Script Class::Accessor::Complex);

use parent qw( OP::Script Class::Accessor::Complex );

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
  text
  texroot
  textcolor
  usedpacks
);

###__ACCESSORS_HASH
our @hash_accessors = qw(
  accessors
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

sub _write_hash() {
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

sub _flush() {
    my $self = shift;

    $self->_v_set( "text", "" );
}

sub _cmd() {
    my $self = shift;

    my $ref = shift // '';
    my @opts = @_;

    return 1 unless $ref;

    my ( $text, $vars, $cmd );

    unless ( ref $ref ) {
        $text = "\\" . $ref;

        unless (@opts) {
            $self->_die("_cmd(): Did not specify the list of variables!")
              unless $cmd;
        }
        elsif ( scalar @opts == 1 ) {

            # Single variable
            $text .= "{$opts[0]}";
        }
    }
    elsif ( ref $ref eq "HASH" ) {

        $cmd = $ref->{cmd} // '';

        $self->_die("_cmd(): Did not specify command name!")
          unless $cmd;

        $text = "\\$cmd";
        $vars = $ref->{vars} // '';

        $self->_die("_cmd(): Did not specify the list of variables!")
          unless $cmd;

        $text .= "{$vars}";

    }

    $self->_add_line("$text");

}

sub _c_delim() {
    my $self = shift;

    my $text = "%" x 50;
    $self->_c("$text");
}

sub _c() {
    my $self = shift;

    my $ref = shift // '';

    my $text = $ref;

    $self->_add_line("%$text");
}

sub _clear() {
    my $self = shift;

    $self->_v_set( 'text', '' );
}

sub _empty_lines() {
    my $self = shift;

    my $num = shift // 1;

    for ( 1 .. $num ) {
        $self->_add_line(" ");
    }
}

sub def() {
    my $self = shift;

    my $def   = shift;
    my $src   = shift;
    my $nargs = shift;

    $self->_add_line( "\\def" . "$def" . "{$src}" );
}

sub _add_line() {
    my $self = shift;

    my $ref = shift // '';
    my ( $addtext, $oldtext, $text );

    return 1 unless $ref;

    $oldtext = $self->text // '';

    # In case a string is supplied, this
    #	string is passed as the value of the
    #	internal "text" variable
    unless ( ref $ref ) {
        $addtext = $ref;
    }
    elsif ( ref $ref eq "HASH" ) {
    }
    elsif ( ref $ref eq "ARRAY" ) {
        my $c = shift @$ref;
        my $x = shift @$ref;
        $addtext = "\\" . $c . '{' . $x . '}';
    }

    $text = $oldtext . $addtext . "\n";
    $self->text( $text );
}

sub section() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\section{$title}");
}

sub part() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\part{$title}");
}

sub _insert_file() {
    my $self = shift;

    my $file = shift // '';

    return 1 unless -e $file;

    my @lines = read_file $file;

    foreach my $line (@lines) {
        chomp($line);
        $self->_add_line("$line");
    }
}

sub input() {
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
                    $self->_add_line("\\input{$file}")
                      if ( -e $file );
                    next;
                };
            }
        }
    }
}

sub end() {
    my $self = shift;

    my $x = shift // '';
    return 1 unless $x;

    $self->_cmd( "end", $x );

}

# documentclass () {{{

=head3 documentclass () {{{

=cut

sub documentclass() {
    my $self = shift;

    my $class = shift;
    my $ref   = shift;
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

# }}}

sub date() {
    my $self = shift;

    my $x = shift // '';
    return 1 unless $x;

    $self->_cmd( "date", $x );

}

sub begin() {
    my $self = shift;

    my $x = shift // '';
    return 1 unless $x;

    $self->_cmd( "begin", $x );

}

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
        $self->_add_line("\\usepackage[$opts]{$pack}");
    }
    else {
        $self->_add_line("\\usepackage{$pack}");
    }

}

sub newnc() {
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

sub idef() {
    my $self = shift;

    my $name = shift;

    $self->_add_line("\\idef{$name}");

}

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

sub subsubsection() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\subsubsection{$title}");
}

sub subsection() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\subsection{$title}");
}

sub chapter() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\chapter{$title}");
}

sub paragraph() {
    my $self = shift;

    my $title = shift // '';

    $self->_add_line("\\paragraph{$title}");
}

# lof() {{{

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

sub lot() {
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

sub true {
    my $self = shift;

    my @cmds = @_;

    foreach my $cmd (@cmds) {
        $self->_add_line( "\\" . $cmd . 'true' );
    }
}

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

sub abstract () {
    my $self = shift;

    my $text = shift;

    $self->begin('abstract');
    $self->_add_line("$text");
    $self->end('abstract');
}

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

sub clearpage() {
    my $self = shift;

    $self->_add_line('\clearpage');
}

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

            $self->_c_delim;
            $self->_c("List of used packages");
            $self->_c_delim;

            foreach my $pack (@$usedpacks) {
                my $opts = $packopts->{$pack} // '';
                my $s_opts = '';
                $s_opts = "[$opts]" if $opts;
                my $text = "\\usepackage" . $s_opts . "{$pack}";
                $self->_add_line("$text");
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

sub hypertarget() {
    my $self = shift;

    my $ref = shift // '';

    $self->_add_line( '\hypertarget{' . $ref . '}{}' );
}

sub hypsetup() {
    my $self = shift;

    my $ref = shift // '';

    $self->_die("Author name was not specified in hypsetup()")
      unless defined $ref->{author};
    $self->_die("Title was not specified in hypsetup()")
      unless defined $ref->{title};

    my $text;

    $text =
        "\\ifpdf" . "\n"
      . "\\pdfinfo{" . "\n"
      . "   /Author ($ref->{author})" . "\n"
      . "   /Title  ($ref->{title})" . "\n" . "}" . "\n"
      . "\\else" . "\n"
      . "\\hypersetup{" . "\n"
      . "	pdftitle={$ref->{title}}," . "\n"
      . "	pdfauthor={$ref->{author}},"
      . "	colorlinks=true,"
      . "	citecolor=blue,"
      . "	citebordercolor=green,"
      . "	linkbordercolor=red,"

      #. "\n" ."	pdfsubject={},"
      #. "\n" ."	pdfkeywords={},"
      #. "\n" ."	bookmarksnumbered,"
      #. "\n" ."	hyperfigures=true,"
      #. "\n" ."	bookmarksdepth=subparagraph"
      . "\n" . "}" . "\n" . "\\fi";

    $self->_c_delim;
    $self->_c("Hypersetup (for hyperlinked PDFs)");
    $self->_c_delim;
    $self->_add_line("$text");
    $self->_c_delim;

}

sub new() {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );

    $self->_init();

    $self->text('');

    return $self;
}

sub _init() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    my $dopts = { print_file_mode => "a" };

    $self->_h_set( "default_options", $dopts );

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

sub _defaults() {
    my $self = shift;

    my $opt = shift // '';

    return undef unless $opt;

    return $self->_h_get_value( "default_options", $opt );

}

sub _print() {
    my $self = shift;

    my $opts;

    $opts = shift // '';

    unless ($opts) {
        print $self->text;
        return 1;
    }

    $opts->{fmode} = $self->_defaults("print_file_mode")
      unless defined $opts->{fmode};

    if ( ref $opts eq "HASH" ) {
        if ( defined $opts->{file} ) {

            my $file = $opts->{file};

            foreach ( $opts->{fmode} ) {
                /^w$/ && do { open( F, ">$file" ) || die $!; next; };
                /^a$/ && do {
                    open( F, ">>$file" ) || die $!;
                    next;
                };
            }

            print F $self->text;

            close F;

        }
        elsif ( defined $opts{fh} ) {

            my $fh = $opts{fh};

            print $fh { $self->text };

        }
        else {
            print $self->text;
        }
    }
}

# }}}
1;

