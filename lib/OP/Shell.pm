
package OP::Shell;

use strict;
use warnings;

use feature qw(switch);
use Switch;

#------------------------------

use Env qw( $hm );

use Term::ShellUI;
use File::Spec::Functions qw(catfile rel2abs curdir);
use IPC::Cmd;

use OP::Base qw(uniq readarr uniq);

use File::Find qw( find finddepth);

use Try::Tiny;

use Data::Dumper;
use File::Copy qw(copy move);
use File::Path qw(make_path remove_tree);
use File::Basename;
use IO::File;

use File::Slurp qw(
  read_file
  write_file
);

use parent qw( 
	OP::Script 
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    inputcommands
    termcmd
    termcmdreset
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
    accdesc
    shellterm
    term_commands
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);
##our

###subs

=head3 _term_get_commands

=cut

sub _term_get_commands {
    my $self = shift;

    my $commands = {
        #########################
        # Aliases {{{
        #########################
        "q"   => { alias => "quit" },
        "h"   => { alias => "help" },
        # }}}
        #########################
        # General purpose {{{
        #########################
##cmd_quit
        "quit" => {
            desc    => "Quit",
            maxargs => 0,
            method  => sub {
                $self->_term_exit;
                shift->exit_requested(1);
            },
        },
##cmd_help
        "help" => {
            desc => "Print helpful information about the existing commands in this shell",
            args => sub { shift->help_args( undef, @_ ); },
            meth => sub {
                $self->termcmd_reset("help @_");
                shift->help_call( undef, @_ );
              }
        },
##cmd_pwd
        "pwd" => {
            desc => "Return the current directory",
            proc => sub {
                $self->termcmd_reset("pwd");
                print rel2abs( curdir() ) . "\n";
              }
        },
##cmd_sys
        "sys" => {
            desc => "Invoke system command",
            proc => sub { $self->_sys(@_) },
            args => sub { shift; $self->_complete_cmd( [qw( sys )], @_ ); },
        },
##cmd_clear
        "clear" => {
            desc => "Invoke clear ",
            proc => sub { $self->_sys('clear') },
        },
    };

    $self->term_commands($commands);
    $self->shellterm( commands => $commands );

}

=head3 _term_init

Initialize a shell terminal L<Term::ShellUI> instance.

=cut

sub _term_init {
    my $self = shift;

    $self->_term_get_commands;

	my $hist=catfile($hm,$self->{package_name} . ".history" );

	if (-e $hist) {
		chmod 755,$hist;
	}

    $self->shellterm( history_file => $hist );
    $self->shellterm( prompt       => $self->{package_name} . ">" );

    my $term = Term::ShellUI->new(
        commands     => $self->shellterm("commands"),
        history_file => $self->shellterm("history_file"),
        prompt       => $self->shellterm("prompt")
    );

    $self->shellterm( obj => $term );
}


=head3 _term_run

=cut

sub _term_run {
    my $self = shift;

    my $cmds = shift // [qw()];

    if (@$cmds) {

        # Single command with arguments
        unless ( ref $cmds ) {
            $self->shellterm("obj")->run($cmds);
        }
        elsif ( ref $cmds eq "ARRAY" ) {
            foreach my $cmd (@$cmds) {
                $self->shellterm("obj")->run($cmd);
            }
        }
    }
    else {
        $self->shellterm("obj")->run();
    }
}

=head3 _term_exit

=cut

sub _term_exit {
    my $self = shift;

}

sub termcmd_reset {
    my $self = shift;

    my $cmd  = shift;

    $self->termcmd($cmd);
    $self->termcmdreset(1);
}

=head3 _begin

=cut

sub _begin {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

sub get_opt {
    my $self = shift;

}

sub init_vars {
    my $self = shift;

    $self->_begin;
    $self->set_accessor_descriptions;

}

sub main {
    my $self = shift;

    $self->get_opt;

    $self->init_vars;

    $self->_term_init;
    $self->_term_run;

}

sub new {
    my $self = shift;

    $self->OP::Script::new;

}

sub runsyscmd {
    my $self=shift;

    my $cmd=shift;
    my @args=@_;

    system("$cmd @args");
}

=head3 _complete_cmd

=cut

sub _complete_cmd {
    my $self = shift;

    my $ref_cmds = shift // '';

    return [] unless $ref_cmds;

    my @comps = ();
    my $ref;

    return 1 unless ( ref $ref_cmds eq "ARRAY" );

    while ( my $cmd = shift @$ref_cmds ) {
        foreach ($cmd) {
            # List of targets 
            /^MKTARGETS$/ && do {
                push(@comps,$self->MKTARGETS);
                next;
            };
###complete_sys
            /^sys$/ && do {
                push(@comps,qw( clear ls  ));
                next;
            };
        }
    }
    @comps=sort(uniq(@comps));

    $ref = \@comps if @comps;

    return $ref;
}

sub _sys {
    my $self=shift;

    my $cmd=shift;

	system("$cmd");

}

sub set_accessor_descriptions {
    my $self=shift;

###_ACCDESC
    my ( %accdesc, %accdesc_array, %accdesc_scalar, %accdesc_hash );
###_ACCDESC_SCALAR
    %accdesc_scalar = (
    );

    foreach my $acc ( keys %accdesc_scalar ) {
        $accdesc{"scalar_$acc"} = $accdesc_scalar{$acc};
    }
###_ACCDESC_ARRAY
    %accdesc_array = ( );

    foreach my $acc ( keys %accdesc_array ) {
        $accdesc{"array_$acc"} = $accdesc_array{$acc};
    }
###_ACCDESC_HASH
    %accdesc_hash = ();

    foreach my $acc ( keys %accdesc_hash ) {
        $accdesc{"hash_$acc"} = $accdesc_hash{$acc};
    }

    $self->accdesc(%accdesc);

}

1;
