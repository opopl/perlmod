#!/usr/bin/env perl

# pminst -- find modules whose names match this pattern
# tchrist@perl.com

package OP::PERL::PMINST;

use strict;
use warnings;

use Getopt::Std qw(getopts);
use File::Find;
use Data::Dumper;
use Term::ANSIColor;
use File::Path qw(make_path remove_tree);

no lib '.';

use vars qw($opt_l $opt_s $opt_r);

###our
our $PATTERN;
our $INCDIR;
our @MODULES;
our @MPATHS;
our %OPTS;
our $CLOPTS;
our %RE;

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors = qw(
  textcolor
  PATTERN
);

###__ACCESSORS_HASH
our @hash_accessors = qw(
  accessors
  opts
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
  MODULES
  MPATHS
);

__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_array_accessors(@array_accessors)->mk_hash_accessors(@hash_accessors);

sub main {
    my $self = shift;

    my $o = shift // {};
    $self->opts($o);


    $self->init;

    $self->getopt unless($self->opts_count);

    $self->process_opts;

    $self->find_module_matches;

    $self->printout;

}

sub printout {
    my $self = shift;

    if ($OPTS{p}) {
        if ( $OPTS{l} ) {
            $self->print_MPATHS;
        }
        elsif ( $OPTS{s} ) {
        }
        else {
            $self->print_MODULES;
        }
    }
}

sub new() {
    my ( $class, %ipars ) = @_;
    my $self = bless( {}, ref($class) || $class );

    return $self;

}

sub getopt {
    my $self = shift;

    $CLOPTS = 'lsr';
    getopts("$CLOPTS") || die "bad usage";

    if ( @ARGV == 0 ) {
        @ARGV = ('.');
    }

    for ( split( "", $CLOPTS ) ) {
        my $evs = '$OPTS{' . $_ . '}=1 if $opt_' . $_ . ';';
        eval "$evs";
        die $@ if $@;
    }

    die "USAGE: $0 [-l] [-s] [-r] PATTERN\n" unless @ARGV == 1;

    $PATTERN = shift(@ARGV);
    $self->PATTERN($PATTERN);

}

sub init {
    my $self = shift;

    @MODULES     = ();
    @MPATHS      = ();
    $PATTERN     = '';
    %RE          = ();
    $INCDIR      = '';
    $OPTS{match} = '';

    $OPTS{p} = 1;
    $OPTS{p}=0 if $self->opts_count;

}

sub process_opts {
    my $self = shift;

    return unless $self->opts_count;

    foreach my $k ( $self->opts_keys ) {
        my $v = $self->opts("$k");

        if ( $k eq "mode" ) {
            for ($v) {
                ## list names
                /^name$/ && do {
                    %OPTS = ();
                    next;
                };
                ## list full paths
                /^fullpath$/ && do {
                    $OPTS{l} = 1;
                    next;
                };
                /^remove$/ && do {
                    $OPTS{r} = 1;
                    next;
                };
            }
###PATTERN
        }
        elsif ( $k eq "PATTERN" ) {
            $PATTERN = $v;
            $self->PATTERN($PATTERN);
        }
    }

}

sub find_module_matches {
    my $self = shift;

    $PATTERN =~ s/::/\//g;

    for ($PATTERN) {
        /\$\s*$/ && do {
            $self->opts( "endofline" => 1 );
            $OPTS{endofline} = 1;
            $OPTS{match}     = 'endofline';
            $PATTERN=~s/\$\s*$//g;
            next;
        };
    }

    $RE{PATTERN} = qr/$PATTERN/;

    for $INCDIR (@INC) {
        next unless -d $INCDIR;
        find( \&wanted, $INCDIR );
    }

    my $evs;
    foreach my $id (qw(MODULES MPATHS )) {
        $evs .= '$self->' . $id . '_push(@' . $id . ');';
    }
    eval "$evs";
    die $@ if $@;

    $self->MPATHS_uniq;

}

sub wanted {

    if ( -d && /^[a-z]/ ) {

        # this is so we don't go down site_perl etc too early
        $File::Find::prune = 1;
        return;
    }

    # skip files that do not end with .pm
    return unless /\.pm$/;

    local $_ = $File::Find::name;
    my $modpath=$_;

    $modpath =~ s{^\Q$INCDIR/}{};
    ( my $modslash=$modpath ) =~ s/\.pm$//g;

    unless ( $OPTS{match} ) {
        return unless $modslash =~ /$RE{PATTERN}/;
    }
    elsif ( $OPTS{endofline} ) {
        return unless $modslash =~ /$RE{PATTERN}$/;
    }

    if ( $OPTS{l} ) {
        s{^(\Q$INCDIR\E)/}{$1 } if $OPTS{s};
        push( @MPATHS, $_ );
    }
    elsif ( $OPTS{r} ) {
        remove_tree($_);
    }
    else {
        s{^\Q$INCDIR/}{};
        s/\.pm$//;
        s{/}{::}g;
        print "$INCDIR " if $OPTS{s};
        push( @MODULES, $_ );
    }

}

1;

__END__

=head1 NAME

pminst - find modules whose names match this pattern

=head1 SYNOPSIS

pminst [B<-s>] [B<-l>] [I<pattern>]

=head1 DESCRIPTION

Without arguments, show the names of all installed modules.  Given a
pattern, show all module names that match it.  The B<-l> flag will show
the full pathname.  The B<-s> flag will separate the base directory from
@INC from the module portion itself.


=head1 EXAMPLES

    $ pminst
    (lists all installed modules)

    $ pminst Carp
    CGI::Carp
    Carp

    $ pminst ^IO::
    IO::Socket::INET
    IO::Socket::UNIX
    IO::Select
    IO::Socket
    IO::Poll
    IO::Handle
    IO::Pipe
    IO::Seekable
    IO::Dir
    IO::File

    $ pminst '(?i)io'
    IO::Socket::INET
    IO::Socket::UNIX
    IO::Select
    IO::Socket
    IO::Poll
    IO::Handle
    IO::Pipe
    IO::Seekable
    IO::Dir
    IO::File
    IO
    Pod::Functions

  The -s flag provides output with the directory separated
  by a space:

    $ pminst -s | sort +1
    (lists all modules, sorted by name, but with where they 
     came from)

    $ oldperl -S pminst -s IO
    /usr/lib/perl5/i386-linux/5.00404 IO::File
    /usr/lib/perl5/i386-linux/5.00404 IO::Handle
    /usr/lib/perl5/i386-linux/5.00404 IO::Pipe
    /usr/lib/perl5/i386-linux/5.00404 IO::Seekable
    /usr/lib/perl5/i386-linux/5.00404 IO::Select
    /usr/lib/perl5/i386-linux/5.00404 IO::Socket
    /usr/lib/perl5/i386-linux/5.00404 IO
    /usr/lib/perl5/site_perl LWP::IO
    /usr/lib/perl5/site_perl LWP::TkIO
    /usr/lib/perl5/site_perl Tk::HTML::IO
    /usr/lib/perl5/site_perl Tk::IO
    /usr/lib/perl5/site_perl IO::Stringy
    /usr/lib/perl5/site_perl IO::Wrap
    /usr/lib/perl5/site_perl IO::ScalarArray
    /usr/lib/perl5/site_perl IO::Scalar
    /usr/lib/perl5/site_perl IO::Lines
    /usr/lib/perl5/site_perl IO::WrapTie
    /usr/lib/perl5/site_perl IO::AtomicFile

  The -l flag gives full paths:

    $ filsperl -S pminst -l Thread
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Queue.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Semaphore.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Signal.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread/Specific.pm
    /usr/local/filsperl/lib/5.00554/i686-linux-thread/Thread.pm

=head1 AUTHORS and COPYRIGHTS

Copyright (C) 1999 Tom Christiansen.

Copyright (C) 2006-2008 Mark Leighton Fisher.

This is free software; you can redistribute it and/or modify it
under the terms of either:
(a) the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or
(b) the Perl "Artistic License".
(This is the Perl 5 licensing scheme.)

Please note this is a change from the
original pmtools-1.00 (still available on CPAN),
as pmtools-1.00 were licensed only under the
Perl "Artistic License".
Class::Accessor::Complex
Directory::Iterator
Directory::Iterator::PP
File::Slurp
LaTeX::BibTeX
OP::BIBTEX
OP::Base
OP::ConvBib
OP::GOPS::BBH
OP::GOPS::KW
OP::GOPS::MKDEP
OP::GOPS::RIF
OP::GOPS::TEST
OP::Git
OP::MOD
OP::Module::Build
OP::PAPS::MKPAPPDF
OP::PERL::PMINST
OP::PMINST
OP::POD
OP::PackName
OP::PaperConf
OP::Parse::BL
OP::Perl::Edit
OP::Perl::Installer
OP::RENAME::PMOD
OP::Script
OP::TEX::NICE
OP::TEX::Text
OP::Time
OP::VIMPERL
OP::Viewer
OP::VimTag
PDL::Graphics::PLplot::0.62
Term::ShellUI
