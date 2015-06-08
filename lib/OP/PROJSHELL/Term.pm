
package OP::PROJSHELL::Term;

use strict;
use warnings;

use Env qw($hm);
use Term::ShellUI;
use File::Spec::Functions qw(catfile rel2abs curdir);

# Shell Terminal stuff {{{

# _term_get_commands {{{

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
##cmd_clean_html
		"clean_html" => {
            desc => "Clean the html out directory",
            proc => sub { $self->clean_html(@_); },
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
            proc => sub { $self->_sys('clear', runmode => 'system' ) },
        },
        "cls" => {
            desc => "Invoke cls ",
            proc => sub { $self->_sys('cls', runmode => 'system' ) },
        },
        # }}}
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
            args => sub { shift; $self->_complete_cmd( [qw(HTMLPROJS)], @_ ); },
            proc => sub { 
				if ($self->_opt_true('cgi')) {
					$self->_cgi_htmlview;
				}else{
					$self->view_html(@_); 
				}
			}
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
            proc => sub { 
				if ($self->usecgi) {
					$self->_cgi_pdfview;
				}else{
					$self->make('_vdoc', runmode => 'system'); 
				}
			}
        },
##cmd_gen
        "cgi" => {
            desc => "generate ...",
			cmds => {
				www => {
					desc => 'generate root page in www/ subdirectory',
            		proc => sub { $self->_cgi_www; }
				},
			}
        },
##cmd_info
        "info" => {
            desc => "Display info",
            proc => sub { $self->info; }
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
##cmd_list_htmlprojs
                htmlprojs  => {
		            desc => "List all projects (written in PROJS.i.dat)",
                    maxargs  => 0,
		            proc => sub { $self->cmd_list('htmlprojs'); }
                },
##cmd_list_htmlfiles
                htmlfiles  => {
		            desc => "List htmlfiles for the chosen HTML project",
                    maxargs  => 1,
            		args => sub { 
						shift; $self->_complete_cmd( [qw( HTMLPROJS )], @_ ); 
					},
		            proc => sub { 
						my $proj=shift;

						$self->_proj_reset($proj);
						$self->_reset_HTMLFILES;

						$self->cmd_list('htmlfiles'); 
					}
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
        # }}}
        #########################
    };

    #########################
    # System commands {{{
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

    # }}}
    #########################

    $self->term_commands($commands);
    $self->shellterm( commands => $commands );

}

# }}}
# _term_list_commands() {{{

=head3 _term_list_commands

=cut

sub _term_list_commands {
    my $self = shift;
}

# }}}
# _term_init() {{{

=head3 _term_init

Initialize a shell terminal L<Term::ShellUI> instance.

=cut

sub _term_init {
    my $self = shift;

    $self->_term_get_commands();

	my $hist=catfile($hm,"ProjShell.history" );

	if (-e $hist) {
		chmod 755,$hist;
	}

    $self->shellterm( history_file => $hist );
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

=head3 _term_run

=cut

sub _term_run {
    my $self = shift;

    my $cmds = shift || [qw()];

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

=head3 _term_exit 

=cut

sub _term_exit {
    my $self = shift;

    $self->LOGFILE->close;
}

# }}}
# }}}
# termcmd_reset() {{{

sub termcmd_reset {

    my $self = shift;
    my $cmd  = shift;

    $self->termcmd($cmd);
    $self->termcmdreset(1);
    $self->LOGFILE_PRINTED_TERMCMD(0);
}

1;
 

