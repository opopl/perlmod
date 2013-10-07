#!/usr/bin/env perl

# pminst -- find modules whose names match this pattern
# tchrist@perl.com

package OP::PERL::PMINST;

use strict;
use warnings;

use Getopt::Std qw(getopts);
use File::Find;

no lib '.';

use vars qw($opt_l $opt_s);

###our
our $PATTERN;
our $STARTDIR;
our @MODULES;

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    textcolor
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    MODULES
);

__PACKAGE__
    ->mk_new
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

sub main {
    my $self=shift;

    $self->init;
    $self->find_module_matches;
    $self->MODULES_print();

}

sub new()
{
    my ($class, %ipars) = @_;
    my $self = bless ({}, ref ($class) || $class);

    return $self;

}
    
sub init {
    my $self=shift;

	getopts('ls') || die "bad usage";
	
	if (@ARGV == 0) {
	    @ARGV = ('.');
	} 
	
	die "usage: $0 [-l] [-s] pattern\n" unless @ARGV == 1;
	
	$PATTERN = shift(@ARGV);
	$PATTERN =~ s/::/\//g;
	

}

sub find_module_matches {
    my $self=shift;
	
	for  $STARTDIR (@INC) { 
		next unless -d $STARTDIR; 
	    find(\&wanted, $STARTDIR);
	}

    $self->MODULES_push(@MODULES);
    $self->MODULES_uniq;

}

sub wanted {

    if (-d && /^[a-z]/) { 
	# this is so we don't go down site_perl etc too early
	    $File::Find::prune = 1;
	    return;
    }

    # skip files that do not end with .pm
    return unless /\.pm$/;

    local $_ = $File::Find::name;
    (my $tmpname = $_) =~ s{^\Q$STARTDIR/}{};
    return unless $tmpname =~ /$PATTERN/o;

    if ($opt_l) { 
	    s{^(\Q$STARTDIR\E)/}{$1 } if $opt_s;
    } 
    else {
	    s{^\Q$STARTDIR/}{};  
	    s/\.pm$//;
	    s{/}{::}g;
	    print "$STARTDIR " if $opt_s;
    } 

    push(@MODULES,$_);

} 

BEGIN { $^W = 1; }

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
