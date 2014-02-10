package OP::PSH::PEF;
#------------------------------
# use ... {{{

use strict;
use warnings;

use Env qw($hm $EDITOR);

use Term::ShellUI;
use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use OP::Base qw/:funcs :vars/;
use Data::Dumper;
use File::Slurp qw(
append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);
use IPC::Cmd qw(can_run run run_forked);

use parent qw( OP::Script Class::Accessor::Complex );

# }}}
#------------------------------
### accessors {{{

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    inputcommands
    LOGFILE
    LOGFILE_PRINTED_TERMCMD
    LOGFILENAME
    termcmd
    termcmdreset
    viewcmd
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
    accdesc
    dirs
    files
    shellterm
    term_commands
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    shellterm_sys_commands
    MKTARGETS
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

# }}}
#------------------------------
# Methods {{{

# ============================
# Shell Terminal stuff {{{

# _term_get_commands()  {{{

=head3 _term_get_commands()

=cut

sub _term_get_commands() {
    my $self = shift;

    my $commands = {
        #########################
        # Aliases           {{{
        #########################
        "q"   => { alias => "quit" },
        "h"   => { alias => "help" },
        #               }}}
        #########################
        # General purpose        {{{
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
##cmd_cat
        "cat" => {
            desc => "Use the 'cat' system command"
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
        #                 }}}
        #########################
        # Compilation {{{
        #########################
##cmd_p
        "p" => {
            desc => "Display the current project info",
            proc => sub { print $self->PROJ . "\n"; }
        },
##cmd_make
        "make" => {
            desc => "Run make for the currently selected PROJ",
            args => sub { shift; $self->_complete_cmd( [qw(ALLPROJS MKTARGETS )], @_ ); },
            proc => sub { $self->make(@_); }
        },
##cmd_import
        "import" => {
            desc => "Import projects from other directory; usage: import DIRECTORY",
            args => sub { shift; $self->_complete_cmd( [qw(  )], @_ ); },
            proc => sub { $self->importprojs(@_); }
        },
##cmd_htmlview
        "htmlview" => {
            desc => "View HTML for the currently selected PROJ",
            args => sub { shift; $self->_complete_cmd( [qw(ALLPROJS)], @_ ); },
            proc => sub { $self->view_html(@_); }
        },
##cmd_vtex
        "vtex" => {
            desc => "View the tex files for the currently selected PROJ",
            args => sub { shift; $self->_complete_cmd( [qw( ALLPROJS )], @_ ); },
            proc => sub { $self->view_proj_tex(@_); }
        },
##cmd_pdfview
        "pdfview" => {
            desc => "View the PDF file for the currently selected PROJ",
            proc => sub { $self->make('vdoc'); }
        },
        "setproj" => {
		    desc => "Reset currently active project",
            maxargs  => 1,
            args => sub { shift; $self->_complete_cmd( [qw( ALLPROJS )], @_ ); },
		    proc => sub { $self->_proj_reset(@_); }
        },
##cmd_list
        "list" => {
            cmds => {
##cmd_list_projs
                projs  => {
		            desc => "List all projects (written in PROJS.i.dat)",
                    maxargs  => 0,
		            proc => sub { $self->cmd_list('projs'); }
                },
##cmd_list_targets
                targets  => {
		            desc => "List all available makefile targets",
                    maxargs  => 0,
		            proc => sub { $self->cmd_list('targets'); }
                },
##cmd_list_sections
                sections  => {
		            desc => "List available sections for the current project",
                    maxargs  => 0,
		            proc => sub { $self->cmd_list('sections'); }
                },
##cmd_list_mkprojs
                mkprojs  => {
		            desc => "List projects to be made (written in MKPROJS.i.dat)",
                    maxargs  => 0,
		            proc => sub { $self->cmd_list('mkprojs'); }
                },
            }
        },
        vm => {
            desc => "View myself",
            proc => sub { $self->view("vm"); }
        },
        #                 }}}
        #########################
    };

    #########################
    # System commands   {{{
###system_commands
    #########################
    $self->shellterm_sys_commands(qw( git cat less more ));

    foreach my $cmd ( $self->shellterm_sys_commands ) {
        $commands->{$cmd} = {
            desc => "Wrapper for the system command: $cmd",
            proc => sub { $self->runsyscmd("$cmd", @_); },
            args => sub { shift; $self->_complete_cmd([ $cmd ]); }
        };
    }

    #           }}}
    #########################

    $self->term_commands($commands);
    $self->shellterm( commands => $commands );

}

# }}}
# _term_list_commands() {{{

=head3 _term_list_commands()

=cut

sub _term_list_commands() {
    my $self = shift;
}

# }}}
# _term_init() {{{

=head3 _term_init()

Initialize a shell terminal L<Term::ShellUI> instance.

=cut

sub _term_init() {
    my $self = shift;

    $self->_term_get_commands();

    $self->shellterm( history_file => catfile($self->HOME,"ProjShell.history" ));
    $self->shellterm( prompt       => "ProjShell>" );

    my $term = Term::ShellUI->new(
        commands     => $self->shellterm("commands"),
        history_file => $self->shellterm("history_file"),
        prompt       => $self->shellterm("prompt")
    );

    $self->shellterm( obj => $term );
}

# }}}
# _term_run() {{{

=head3 _term_run()

=cut

sub _term_run() {
    my $self = shift;

    my $cmds = shift // [qw()];

    unless (@$cmds) {
        if ( $self->inputcommands ) {
            @$cmds = split( ';', $self->inputcommands );
        }
    }

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
        exit 0 unless $self->_opt_true("shell");
        $self->shellterm("obj")->run();
    }
}

# }}}
# _term_exit() {{{

=head3 _term_exit() {{{

=cut

sub _term_exit() {
    my $self = shift;

    $self->LOGFILE->close;
}

# }}}
# }}}
# termcmd_reset() {{{

sub termcmd_reset() {

    my $self = shift;
    my $cmd  = shift;

    $self->termcmd($cmd);
    $self->termcmdreset(1);
    $self->LOGFILE_PRINTED_TERMCMD(0);
}

# }}}

# }}}
# ============================
# Core: _begin() get_opt() init_vars() main() new() set_these_cmdopts() {{{

# _begin() {{{

=head3 _begin()

=cut

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

# }}}
# get_opt() {{{

=head3 get_opt()

=cut

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();

    if ( $self->_opt_true("shcmds") ) {
        $self->inputcommands( $self->_opt_get("shcmds") );
    }

}

# }}}

# init_vars() {{{

=head3 init_vars()

=cut

sub init_vars() {
    my $self = shift;

    $self->_begin();

    $self->viewcmd("$EDITOR");

}

# }}}
# main() {{{

sub main() {
    my $self = shift;

    $self->get_opt();

    $self->init_vars();

    $self->_term_init();
    $self->_term_run();
}

# }}}
# new() {{{

sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

# }}}
# runsyscmd() {{{

sub runsyscmd {
    my $self=shift;

    my $cmd=shift;
    my @args=@_;

    system("$cmd @args");
}

# }}}
# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts() {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts();

    my $opts = [];
    my $desc = {};

    push(
        @$opts,
        {
            name => "shcmds",
            desc => "Run command(s), then exit",
            type => "s"
        }
    );

    push( @$opts, { name => "shell", desc => "Start the interactive shell" } );

    $self->add_cmd_opts($opts);

}

# }}}

# }}}
# ============================
# Completions _complete_cmd() {{{

# _complete_cmd {{{

=head3 _complete_cmd()

=cut

sub _complete_cmd() {
    my $self = shift;

    my $ref_cmds = shift // '';

    return [] unless $ref_cmds;

    my @comps = ();
    my $ref;

    return 1 unless ( ref $ref_cmds eq "ARRAY" );

    while ( my $cmd = shift @$ref_cmds ) {
        foreach ($cmd) {
            # List of targets 
###complete_ALLPROJS
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

# }}}

# }}}
# ============================
# view() {{{

sub view() {
    my $self = shift;

    my $id = shift;
    my @files_to_view;

    foreach ($id) {
        /^vm$/ && do {
            push( @files_to_view, $0 );
            next;
        };
    }

    my $cmd = $self->viewcmd .  " @files_to_view & ";

    $self->sysrun( $cmd, driver => 'system' );

}

# }}}
# make() {{{

sub make() {
    my $self=shift;

    my $args=shift // '';

    my $cmd= "make " . $args;
    system($cmd);
}

# }}}

sub _sys(){
    my $self=shift;

    my $cmd=shift;

    system("$cmd");
}

# }}}
# ============================
# sysrun() {{{

sub sysrun() {
    my $self=shift;

    my $cmd=shift;

    system("$cmd");
}

# }}}
# ============================

# }}}
#------------------------------

1;
