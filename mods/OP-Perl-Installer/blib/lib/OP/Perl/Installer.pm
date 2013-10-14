#!/usr/bin/env perl

package OP::Perl::Installer;

# use ... {{{

use strict;
use warnings;

our $VERSION = '0.01';

use OP::Script;
use OP::Base qw/:vars :funcs/;
use OP::Git;
use OP::PERL::PMINST;

use File::Basename qw(basename dirname );
use File::Path qw( remove_tree make_path );
use FindBin;
use Getopt::Long;
use Pod::Usage;
use Module::Build;
use File::Spec::Functions qw(catfile catdir );

use ExtUtils::ModuleMaker;
use Term::ShellUI;
use Data::Dumper;

use parent qw( Class::Accessor::Complex OP::Script  );

__PACKAGE__->mk_new
###_ACCESSORS_SCALAR
  ->mk_scalar_accessors(
    qw(
      PERLMODDIR
      viewcmd
      textcolor
      warncolor
      usecolor
      rbi_force
      rbi_discard_loaddat
      )
  )->mk_integer_accessors(qw())
###_ACCESSORS_ARRAY
  ->mk_array_accessors(
    qw(
      mod_def_names
      modules
      modules_to_install
      modules_to_exclude
      )
  )
###_ACCESSORS_HASH
  ->mk_hash_accessors(
    qw(
      moddeps
      dirs
      files
      )
  );

# }}}
# Methods {{{

=head1 Methods

=cut

=head2 Initializations

=cut

#sub new() {
#my ( $class, %parameters ) = @_;
#my $self = bless( {}, ref($class) || $class );

#$self->init();

#return $self;
#}

=head3 init()

=cut

sub init() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};
}

# module_to_path() {{{

=head3 module_to_path()

=cut

sub module_to_path() {
    my $self = shift;

    # input: My::Module::Base
    # output My/Module/Base.pm
    my $module = shift;

    $module =~ s/$/\.pm/g;
    ( my $path = $module ) =~ s/::/\//g;

    return $path;
}

# }}}

sub _sys() {
    my $self = shift;

    my $cmd = shift;

    system("$cmd");
}

sub module_installed_path {
    my $self = shift;
}

sub module_full_local_path {
    my $self = shift;

    my $module = shift;

    return shift $self->module_full_local_paths($module);

}

sub module_full_local_paths() {
    my $self = shift;

    my $module = shift;

    my @dirs   = qw( . lib );
    my @lpaths = ();

    foreach my $dir (@dirs) {
        my $mfile = catfile( $self->module_to_def($module),
            $dir, $self->module_to_path($module) );

        for ($module) {
            /^LaTeX::BibTeX$/ && do {
                $mfile = catfile( $self->module_to_def($module),
                    basename( $self->module_to_path($module) ) );
                next;
            };
        }
        my $fullpath = catfile( $self->dirs("mods"), $mfile );
        push( @lpaths, $mfile ) if -e $fullpath;
    }

    @lpaths = &uniq(@lpaths);

    wantarray ? @lpaths : \@lpaths;

}

# module_to_def() {{{

=head3 module_to_def()

=cut

sub module_to_def() {
    my $self = shift;

    # input: My::Module::Base
    # output My-Module-Base
    my $module = shift;
    my $res = join( "-", split( "::", $module ) );

    return $res;
}

#}}}
# def_to_module() {{{

=head3 def_to_module()

=cut

sub def_to_module() {
    my $self = shift;

    # input My-Module-Base
    # output: My::Module::Base

    my $def = shift;
    my $module = join( "::", split( "-", $def ) );

    return $module;
}

#}}}
# add_modules() {{{

=head3 add_modules()

=cut

sub module_libdir {
    my $self = shift;

    my $module = shift;

    return catfile( $self->dirs("mods"), $self->module_to_def($module), "lib" );

}

sub module_local_dir {
    my $self = shift;

    my $module = shift;

    return catfile( $self->dirs("mods"), $self->module_to_def($module) );

}

sub add_modules() {
    my $self = shift;

    my ( @modules, %mods, @files );

    my $s_modules_add = $opt{add} // shift;

    @modules = split( ',', $s_modules_add );

    foreach my $module (@modules) {
        my $def_module = $self->module_to_def($module);

        push( @files,
            catfile( $def_module, "lib", $self->module_to_path($module) ) );

        make_path(
            catfile(
                $self->dirs("mods"), $self->module_to_def($module), "lib"
            )
        );

        chdir $self->dirs("mods");

        $mods{$module} = ExtUtils::ModuleMaker->new(
            NAME         => "$module",
            LICENSE      => "perl",
            BUILD_SYSTEM => "Module::Build",
            COMPACT      => 1
        );

        $mods{$module}->complete_build();

        # Write the install.sh script
        my $installsh = catfile( $def_module, "install.sh" );

        open( F, ">", $installsh );

        print F "#!/bin/bash\n";
        print F "" . "\n";
        print F "perl Build.PL" . " &&";
        print F "./Build " . " &&";
        print F "./Build test " . " &&";
        print F "./Build install";

        close(F);

        system("chmod +rx $installsh");

    }
    my $pmdir = $self->PERLMODDIR;
    foreach (@files) { s/^/$pmdir\/mods\//g; }
    print "@files\n";

    system( $self->viewcmd . "@files" );

}

# }}}
# remove_modules() {{{

=head3 remove_modules()

=cut

sub remove_modules() {
    my $self = shift;
    my ( @modules, %mods, @files );
    @modules = split( ',', $opt{rm} );

    foreach my $module (@modules) {
        my $mdir = "$self->PERLMODDIR/mods/" . $self->module_to_def($module);
        remove_tree($mdir) if ( ( -e $mdir ) && ( -d $mdir ) );
    }
    exit 0;
}

# }}}
# edit_modules() {{{

=head3 edit_modules()

=cut

sub edit_modules() {
    my $self = shift;

    my ( @emodules, @files );
    my $mfile;

    my $s_modules = $opt{edit} // shift;

    @emodules = split( ',', $s_modules ) if defined $s_modules;

    if ( $s_modules eq "_all" ) {
        @emodules = $self->modules;
    }
    elsif ( $s_modules eq "_sel" ) {
        @emodules = $self->modules_to_install;
    }

    foreach my $module (@emodules) {
        my @mfiles = $self->module_full_local_paths($module);
        push( @files, @mfiles );
    }

    my $pmdir = $self->PERLMODDIR;
    foreach (@files) { s/^/$pmdir\/mods\//g; }

    if (@files) {
        system( $self->viewcmd . "  @files" );
    }
}

# }}}
# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts() {
    my $self = shift;

    @cmdopts = (
        { name => "h,help",   desc => "Print the help message" },
        { name => "man",      desc => "Print the man page" },
        { name => "examples", desc => "Show examples of usage" },
        { name => "vm",       desc => "View myself" },
        { name => "r",        desc => "Run the script" },
        { name => "l,list",   desc => "List the modules to be installed" },
        { name => "e,edit",   desc => "Edit the chosen modules", type => "s" },
        {
            name => "a,add",
            desc => "Create modules	 with the given names",
            type => "s"
        },
        {
            name => "rm",
            desc => "Remove module with the given names",
            type => "s"
        },
        { name => "sh",     desc => "Run an interactive shell " },
        { name => "shcmds", type => "s", desc => "Run shell commands " }

        #,{ cmd	=>	"<++>", 		desc	=>	"<++>", type	=>	"s"	}
    );
}

#}}}
# choose_modules() {{{

=head3 choose_modules()

=cut

sub choose_modules() {
    my $self = shift;

    my @mods = split( ',', shift );
    $self->modules_to_install(@mods);

}

# }}}
# load_modules() {{{

=head3 load_modules()

=cut

sub load_modules() {
    my $self = shift;

    opendir( D, $self->dirs("mods") );

    while ( my $file = readdir(D) ) {
        my $fpath = catfile( $self->dirs("mods"), $file );

        next if $file =~ m/^\./;
        next if $file =~ m/^pod$/;
        next unless -d $fpath;

        $self->mod_def_names_push($file);
        $self->modules_push( $self->def_to_module($file) );
    }

    $self->modules_sort();

    $self->modules_to_install(
        qw(
          OP::Script
          OP::Base
          OP::GOPS::MKDEP
          OP::Perl::Installer
          )
    );

    $self->modules_to_exclude(qw(OP::Module::Build));

    $self->load_dat();

    closedir(D);
}

sub load_dat() {
    my $self = shift;

    my $datfile = $DATFILES{modules_to_install};
    if ( -e $datfile ) {
        $self->modules_to_install_clear;
        $self->modules_to_install( readarr($datfile) );
    }
}

#}}}
# list_modules(){{{

=head3 list_modules()

=cut

sub list_modules() {
    my $self = shift;

    $self->modules_print();

}

# }}}
# run_build_install(){{{

=head3 run_build_install()

=cut

###rbi_
sub run_build_install() {
    my $self = shift;

    my @imodules;

	my $errorlines;

    @imodules = @_ if @_;

    unless (@imodules) {
        $self->load_dat();
        @imodules = $self->modules_to_install;
    }

    my ( @exclude, @only, @okmods, @failmods, @processed );

    @only    = $self->modules_to_install;
    @exclude = $self->modules_to_exclude;

    foreach my $module (@imodules) {
###rbi_loop_imodules
        next if grep { /^$module$/ } @processed;

        push( @processed, $module );

        # Local path to the module
        my $lpath = catfile( $self->dirs("mods"),
            $self->module_full_local_path($module) );

        unless ( -e $lpath ) {
            $self->warn("Local path points to non-existing file: $lpath");
        }

        # Locations of the installed module
        my $pminst = OP::PERL::PMINST->new;
        ( my $mdef = $module ) =~ s/::/-/g;
        $pminst->main(
            {
                PATTERN     => '^' . "$module" . '$',
                mode        => 'fullpath',
                excludedirs => catfile( $self->dirs("mods"), $mdef, qw(lib) ),
            }
        );

        my @ipaths = $pminst->MPATHS;

        use File::stat;

        my $stat;

        # Size time of the local module file
        $stat = stat($lpath);
        my $lsize = $stat->size;

        # Size of the installed module file
        my $different = 0;
        my $ipath;

##TODO todo_install
        $self->warn("Failed to get installed location for $module")
          unless @ipaths;

        # if @ipath=(), this means that the module was not installed,
        #   hence we will need to install it

        # two or more different installation locations; need to install
###rbi_loop_ipaths
        if ( @ipaths > 1 ) {
            $pminst->main( { remove => "$module" } );
            $different = 1;
        }
        elsif ( @ipaths == 1 ) {
            $ipath = shift @ipaths;

            if ($ipath) {
                $stat = stat($ipath);
                my $isize = stat($ipath)->size // '';

                $different = ( $lsize == $isize ) ? 0 : 1;
            }
            else {
                $different = 1;
            }

        }
        else {
            # module was not installed at all; need to install
            $different = 1;
        }

        # do not install the module if the local and installed versions
        #   are the same
###rbi_next_unless_different
        unless ( $self->rbi_force ) {
            next unless $different;
        }

        my $mod = $self->module_to_def($module);

        # $dirmod = e.g. ~/wrk/perlmod/mods/OP-Base
        my $dirmod = catdir( $self->PERLMODDIR, "mods", $mod );

        next if ( grep { /^$module$/ } @exclude );

        unless ( $self->rbi_discard_loaddat ) {
            if (@only) {
                next unless grep { /^$module$/ } @only;
            }
        }

        if ( -e $dirmod ) {
            chdir $dirmod;
        }
        else {
            next;
        }

###rbi_load_modules_order
        my (@icmds);
        my $icmd = '';

        if ( -e "./install.sh" ) {
            $icmd = './install.sh';
        }
        elsif ( -e "Makefile.PL" ) {
###rbi_Makefile_PL

            push( @icmds, 'perl Makefile.PL' );
            push( @icmds, 'make' );
            push( @icmds, 'make test' );
            push( @icmds, 'make install' );

        }
###rbi_Build_PL
        elsif ( -e "Build.PL" ) {

            push( @icmds, 'perl ./Build.PL' );
            push( @icmds, 'perl ./Build' );
            push( @icmds, 'perl ./Build test' );
            push( @icmds, 'perl ./Build install' );

        }
        $icmd = join( ' && ', @icmds ) if @icmds;

        if ($icmd) {
            my $imsg = 'Installing module: ' . $module;
            $self->out($imsg);
            my ( $ok, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
              IPC::Cmd::run( command => $icmd, verbose => 0 );

            my $indent     = 0;
            my $linelength = 50;
            my %oo         = ();

            if ($ok) {
###rbi_push_okmods
                push( @okmods, $module );

                $indent = $linelength - length('OK') - length($imsg);
                $oo{indent} = $indent if $indent > 0;
                $oo{color} = 'yellow';

                $self->saytext( 'OK', %oo );
            }
            else {
###rbi_push_failmods
                push( @failmods, $module );

                $indent = $linelength - length('FAIL') - length($imsg);
                $oo{indent} = $indent if $indent > 0;

                $self->warntext( 'FAIL', %oo );

                %oo = ( color => 'bold red', indent => 5 );
                my @olines = split( "\n", join( "", @$full_buf ) );
                for (@olines) {
                    $self->outtext( $_ . "\n", %oo );
###rbi_push_errorlines
                    push(@{$errorlines->{$module}},$_);
                }
            }
        }
        else {
            my $build = Module::Build->new(
                module_name => "$module",
                license     => 'perl'
            );

            $self->OP::Script::out( "Building module: $module\n",
                color => 'blue' );

            #		select $fh{log};
            $build->dispatch('build');

            #		select STDOUT;
            $self->out("Testing module: $module\n");

            ##		select $fh{log};
            $build->dispatch( 'test', quiet => 1 );

            ##		select STDOUT;
            $self->out("Installing module: $module\n");

            ##		select $fh{log};
            $build->dispatch( 'install', install_base => "$ENV{HOME}" );
        }
    }    # end loop over $mod_def_names
    my ( $SUCCESS, $FAIL, $OK, @RESULT );
    $SUCCESS = 0;
    $FAIL    = 0;
    $OK      = 1;

    foreach my $module (@okmods) {
        $self->saytext( "OK: $module", color => 'bold yellow' );
        $SUCCESS++;
    }
    foreach my $module (@failmods) {
        $self->saytext( "FAIL: $module", color => 'bold red' );
        $FAIL++;
    }

    $OK = 0 if $FAIL;
    @RESULT = ( $OK, $SUCCESS, $FAIL, \@failmods, $errorlines );

###rbi_@RESULT

    return @RESULT;
}

# }}}
# sub run_shell() {{{

=head3 run_shell()

=cut

sub run_shell() {
    my $self = shift;

    my ( $cmd_string, @cmds );

    $cmd_string = shift // '';
    @cmds = split( ";", $cmd_string );

    my $term = new Term::ShellUI(
        commands     => $self->{'shell_commands'},
        history_file => 'ish.history'
    );

    $term->exit_requested(0);

    #print 'Using '.$term->{term}->ReadLine."\n";

    $term->prompt("i>");

    if (@cmds) {
        foreach my $cmd (@cmds) {
            $term->run("$cmd");
        }
    }
    else {
        $term->run();
    }
}

# }}}

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
            /^ALLPROJS$/ && do {
                push( @comps, $self->PROJS );
                next;
            };
            /^MKTARGETS$/ && do {
                push( @comps, $self->MKTARGETS );
                next;
            };
###complete_sys
            /^sys$/ && do {
                push( @comps, qw( clear ls  ) );
                next;
            };
###complete_git
            /^git$/ && do {
                push( @comps, @$OP::Git::commands );
                next;
            };
        }
    }
    @comps = sort( uniq(@comps) );

    $ref = \@comps if @comps;

    return $ref;
}

# _complete_modules() {{{

=head3 _complete_modules()

=cut

sub _complete_modules() {
    my $self = shift;

    my $cmpl = shift // '';
    my $ref;

    if ($cmpl) {
        foreach my $module ( @{ $self->{'modules'} } ) {
            if ( $module =~ m/^\s*$cmpl->{str}/i ) {

                #print ref $cmpl->{str},"\n";
                push( @{$ref}, "$module" );
            }
        }
    }
    else {
        $ref = $self->{'modules'};
    }

    push( @{$ref}, qw(_all _sel) );
    return $ref;
}

# }}}
# init_vars(){{{

=head3 init_vars()

=cut

sub init_vars() {
    my $self = shift;

    $self->PERLMODDIR( $ENV{PERLMODDIR}
          // catfile( $ENV{HOME}, qw(wrk perlmod ) ) );

    $self->dirs( "mods" => catfile( $self->PERLMODDIR, qw(mods) ) );
    $self->viewcmd("gvim -n -p --remote-tab-silent ");

    $self->_term_get_commands();

    $self->moddeps( "Directory::Iterator" => "Directory::Iterator::PP" );
    $self->textcolor('blue');
    $self->warncolor('red');
    $self->usecolor(1);

    $self->rbi_force(0);
    $self->rbi_discard_loaddat(0);

}

sub _term_get_commands() {
    my $self = shift;

    $self->{'shell_commands'} = {
###cmd_help
        "help" => {
            desc   => "Print helpful information",
            args   => sub { shift->help_args( undef, @_ ); },
            method => sub { shift->help_call( undef, @_ ); }
        },
        "h" => { alias => "help", exclude_from_completion => 1 },
        "q" => { alias => 'quit', exclude_from_completion => 1 },
###cmd_cd
        "cd" => {
            desc    => "Change to directory DIR",
            maxargs => 1,
            args    => sub { shift->complete_onlydirs(@_); },
            proc    => sub { chdir( $_[0] || $ENV{HOME} || $ENV{LOGDIR} ); },
        },
###cmd_chdir
        "chdir" => { alias => 'cd' },
        "lm"    => { alias => 'list modules' },
###cmd_pwd
        "pwd" => {
            desc    => "Print the current working directory",
            maxargs => 0,
            proc    => sub { system('pwd'); },
        },
###cmd_choose
        "choose" => {
            desc    => "Choose a module",
            maxargs => 1,
            minargs => 1,
            proc    => sub { $self->choose_modules(shift); },
            args    => sub {
                my $s = shift;
                $s->suppress_completion_append_character();
                $self->_complete_modules(@_);
              }
        },
###cmd_nocolor
        "nocolor" => {
            desc    => "Disable color print",
            maxargs => 0,
            proc    => sub { $self->usecolor(0); },
        },
###scmd_rbi
        "rbi" => {
            desc => "Run-build-install",
            args => sub {
                my $s = shift;
                $s->suppress_completion_append_character();
                $self->_complete_modules(@_);
            },
            proc => sub { $self->run_build_install(@_); },
        },
###scmd_eam
        "eam" => {
            desc    => "Edit all Perl modules",
            maxargs => 0,
            proc    => sub { $self->edit_modules("_all"); },
        },
###scmd_esm
        "esm" => {
            desc    => "Edit selected Perl modules",
            maxargs => 0,
            proc    => sub { $self->edit_modules("_sel"); },
        },
###cmd_quit
        "quit" => {
            desc    => "Quit this program",
            maxargs => 0,
            method  => sub { shift->exit_requested(1); },
        },
###cmd_lm
        "lm" => {
            desc    => "List available modules",
            proc    => sub { $self->list_modules(); },
            maxargs => 0
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
###cmd_vm
        "vm" => {
            desc    => "Edit OP::Perl::Installer",
            proc    => sub { $self->edit_modules('OP::Perl::Installer'); },
            maxargs => 0
        },
###cmd_list
        "list" => {
            desc => "List different things",
            cmds => {
                modules => {
                    desc    => "List available modules",
                    proc    => sub { $self->list_modules(); },
                    maxargs => 0
                }
            }
        },
###cmd_add
        "add" => {
            desc    => "Add module",
            maxargs => 1,
            minargs => 1,
            proc    => sub { $self->add_modules(shift); },
            args    => sub {
                my $s = shift;

                #$s->{debug_complete}=5;
                $s->suppress_completion_append_character();
                $self->_complete_modules(@_);
              }
        },
###cmd_edit
        "edit" => {
            desc    => "Edit module",
            maxargs => 1,
            minargs => 1,
            proc    => sub { $self->edit_modules(shift); },
            args    => sub {
                my $s = shift;

                #$s->{debug_complete}=5;
                $s->suppress_completion_append_character();
                $self->_complete_modules(@_);
              }
        },

    };

}

# }}}

# main() {{{

sub main() {
    my $self = shift;

    $self->init();

    $self->get_opt();

    $self->init_vars();

    $self->load_modules();

    do { $self->run_build_install(); exit 0; } if ( $opt{run}  || $opt{r} );
    do { $self->list_modules();      exit 0; } if ( $opt{list} || $opt{l} );
    do { $self->edit_modules();      exit 0; } if ( $opt{edit} || $opt{e} );

    $self->add_modules() if ( $opt{add} || $opt{a} );
    $self->remove_modules() if ( $opt{rm} );

    # Running shell
    $self->run_shell() if ( $opt{sh} );

    if ( $opt{shcmds} ) {
        $self->run_shell( $opt{shcmds} );
        exit 0;
    }

}

# }}}
# }}}
1;

