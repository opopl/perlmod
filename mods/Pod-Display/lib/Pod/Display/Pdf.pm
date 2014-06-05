
package Pod::Display::Pdf;

use strict;
use warnings;

use Env qw($HOME);
use FindBin qw($Script);

use File::Spec::Functions qw( catfile );
use YAML qw( LoadFile );
use Term::ShellUI;
use Text::Generate::TeX;
use File::Temp qw(tmpnam);
use File::Path qw(make_path remove_tree);
use FindBin qw( $Script $Bin );
use Carp;

use Pod::LaTeX::Plus;
use TeX::Driver::PDFLATEX;

sub new
{
    my ($class, %pars) = @_;
    my $self = bless (\%pars, ref ($class) || $class);

    $self->init_vars; 

    return $self;
}


sub init_vars {
    my $self=shift;

    $self->{ID}='poddisplaypdf';

    $self->{files}={
        yamltopics => catfile($HOME, qw(config),  $self->{ID} . '.topics.yaml' ),
        yamlconfig => catfile($HOME, qw(config),  $self->{ID} . '.config.yaml' ),
    };

    $self->{topics}=LoadFile( $self->{files}->{yamltopics} );
    $self->{config}=LoadFile( $self->{files}->{yamlconfig} );

    $self->{dirs}->{tex}=$self->{config}->{texdir};
    $self->{dirs}->{pdf}=$self->{config}->{pdfdir};
    $self->{dirs}->{pod}=$self->{config}->{poddir};

    make_path $self->{dirs}->{pdf};
    make_path $self->{dirs}->{tex};

}

sub get_opt {
    my $self=shift;

    unless (@ARGV) {
        my $msg="USAGE: $Script COMMAND OPTIONS";

        print $msg . "\n";
        exit 0;
    }

    $self->{COMMAND}=shift @ARGV;
    $self->{OPTIONS}=\@ARGV;

    my $cmd = $self->{COMMAND};

    $self->{COMMANDS}=[qw(
        build
        help
        listmods
        listtopics
    )];

    eval '$self->cmd_' . $cmd ;
    die $@ if $@;

}

sub cmd_listmods {
    my $self=shift;

    $self->{topic}=shift @{$self->{OPTIONS}} // '';

    return 0 unless $self->{topic};

    my $topic=$self->{topic};

    $self->{itopics}=$self->{topics}->{$topic} // [];

    print $_ . "\n" for(@{$self->{itopics}});

    exit 0;
}

sub cmd_listtopics {
    my $self=shift;

    print $_ . "\n" for(sort keys %{$self->{topics}});

}

sub cmd_build {
    my $self=shift;

    $self->{topic}=shift @{$self->{OPTIONS}};

    $self->load_topic;
    
    $self->{tex}=Text::Generate::TeX->new;

    $self->{tex}->ofile($self->{files}->{topictex});

    $self->parse_pod_mods;

    $self->write_tex;

    $self->run_tex;


}

sub run_tex {
    my $self=shift;

    my $drv=TeX::Driver::PDFLATEX->new;

}

sub write_tex {
    my $self=shift;

    my $tex=$self->{tex};

    $self->write_tex_header;
    $self->write_tex_preamble;
    $self->write_tex_begin;
    $self->write_tex_mods;
    $self->write_tex_end;

    $tex->_writefile;
}

sub cmd_shell {
    my $self=shift;

}

sub load_topic {
    my $self=shift;

    my $topic=$self->{topic};

    if (! grep { /^$topic$/ } keys %{$self->{topics}}) {
        croak 'Topic does not exist';
    }

    # List of itopics for the given topic
    $self->{itopics}=$self->{topics}->{$topic};

    $self->{files}->{topictex}=catfile(
        $self->{dirs}->{tex},
        $self->{topic} . '.tex'
    );

}


sub write_tex_header {
    my $self=shift;

    $self->write_tex_header_comments;

    my $tex = $self->{tex};

    $tex->nonstopmode;
    $tex->def('TOPIC', $self->{topic} );

}

sub write_tex_header_comments {
    my $self=shift;

    my $tex=$self->{tex};

    my $date = localtime;

    $tex->_c_delim;
    $tex->_c("File:");
    $tex->_c("  " . $self->{files}->{topictex} );
    $tex->_c("Purpose:");
    $tex->_c("  LaTeX file for the perldoc documentation");
    $tex->_c("Topic:");
    $tex->_c("  " . $self->{topic} );
    $tex->_c("Date created:");
    $tex->_c("  $date");
    $tex->_c("Creating script:");
    $tex->_c("  $Script");
    $tex->_c("Creating script directory:");
    $tex->_c("  $Bin");
    $tex->_c("Creating module:");
    $tex->_c("  " . __PACKAGE__ );
    $tex->_c("Used configuration file:");
    $tex->_c("  " . $self->{files}->{yamlconfig} );
    $tex->_c("Used topics file:");
    $tex->_c("  " . $self->{files}->{yamltopics} );
    $tex->_c("Included topics (itopics):");
    foreach my $itopic ( @{$self->{itopics}} ) {
        $tex->_c("  " . $itopic );
    }
    $tex->_c_delim;

}

sub write_tex_preamble {
    my $self=shift;

    my $tex=$self->{tex};

    $tex->_empty_lines;

    $tex->documentclass('book',{ opts => [qw( 10pt a4paper )]});

    $tex->_empty_lines;

    $tex->usepackages(
        $self->{config}->{packages},
        $self->{config}->{packopts},
    );

    $tex->_empty_lines;

    $tex->_add_line(q(
        \definecolor{dkgreen}{rgb}{0,0.6,0}
        \definecolor{gray}{rgb}{0.5,0.5,0.5}
        \definecolor{mauve}{rgb}{0.58,0,0.82}
    ));

    $self->write_tex_preamble_makeatletter;
    $self->write_tex_preamble_hypersetup;
    $self->write_tex_preamble_lstset;
    $self->write_tex_preamble_pagelayout;


}

sub write_tex_end {
    my $self=shift;

    my $tex=$self->{tex};

    $tex->_empty_lines;
    $tex->end('document');

}

sub write_tex_begin {
    my $self=shift;

    my $tex=$self->{tex};

	$tex->_add_line(<<'EOF');

\setcounter{tocdepth}{5}
\setcounter{secnumdepth}{3}

\title{Perldoc}
\date{Last updated \today}

\makeindex

\begin{document}

\clearpage
\phantomsection
\hypertarget{toc}{}
%\label{toc}
\addcontentsline{toc}{chapter}{\contentsname}
\tableofcontents
\nc{\pagenumtoc}{\thepage}
\clearpage

EOF

}

sub write_tex_preamble_pagelayout {
    my $self=shift;

    my $tex=$self->{tex};

    $tex->_empty_lines;

    $tex->_add_line(q(
        \sloppy
        \def\baselinestretch{1}
        \setcounter{page}{1}

        \parindent 0pt
        \parskip 1ex
    ));

}

sub write_tex_preamble_makeatletter {
    my $self=shift;

    my $tex=$self->{tex};

	$tex->makeatletter;

	$tex->_add_line(<<'EOF');

\@ifpackageloaded{bookmark}{%
	\def\bmk#1#2{%
		\bookmark[#1]{#2}%
	}%
}{}

\renewcommand\paragraph{%
   \@startsection{paragraph}{4}{0mm}%
      {-\baselineskip}%
      {.5\baselineskip}%
      {\normalfont\normalsize\bfseries}}

EOF

	$tex->makeatother;
}

sub write_tex_preamble_lstset {
    my $self=shift;

    my $tex=$self->{tex};

    $tex->_add_line(' ');

    $tex->listopts({
            name => 'lstset',
            opts => $self->{config}->{lstset},
    });

}

sub write_tex_preamble_hypersetup {
    my $self=shift;

    my $tex=$self->{tex};

    $tex->_add_line(' ');

    $tex->listopts({
            name => 'hypersetup',
            opts => $self->{config}->{hypersetup},
    });

}

sub parse_pod_mods {
    my $self=shift;

    foreach my $itopic ( @{$self->{itopics}} ) {
        $self->itopic_reset($itopic);

        $self->{files}->{perldocpod}= catfile(
                $self->{dirs}->{pod},
                $self->{itopicstr} . '.pod',
        );

        system("perldoc -u " . $self->{itopic} 
            . '> '. $self->{files}->{perldocpod} );

        my $parser = Pod::LaTeX::Plus->new();

        $self->{files}->{perldoctex}= catfile(
                $self->{dirs}->{tex},
                'perldoc.' . $self->{itopicstr} . '.tex',
        );

        $parser->AddPreamble(0);
        $parser->AddPostamble(0);
        $parser->Head1Level(1);
        $parser->Label($self->{itopicstr});
        $parser->LevelNoNum(5);
        $parser->UniqueLabels(1);
        $parser->parse_from_file( 
            $self->{files}->{perldocpod}, 
            $self->{files}->{perldoctex}, 
        );

    }

}

sub itopic_reset {
    my $self=shift;

    my $itopic=shift;

    $self->{itopic}=$itopic;
    $self->{itopicstr} = $self->{itopic} =~ s/::/-/gr;

}


sub write_tex_mods {
    my $self=shift;

    my $tex=$self->{tex};

    foreach my $itopic (@{$self->{itopics}}) {
        $self->itopic_reset($itopic);

        $tex->_c_delim;

        $tex->chapter($self->{itopic});
        $tex->label($self->{itopic});
        $tex->_empty_lines;

        $tex->input('perldoc.' . $self->{itopicstr} . '.tex');
    }
}


sub main {
    my $self=shift;

    $self->get_opt;


}

1;
