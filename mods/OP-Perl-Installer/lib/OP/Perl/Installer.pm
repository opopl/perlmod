#!/usr/bin/env perl

package OP::Perl::Installer;

# use ... {{{

use strict;
use warnings;

use lib ("/home/op/wrk/perlmod/mods/OP-Perl-Installer/lib");
use lib ("/home/op/wrk/perlmod/mods/OP-Script/lib");

our $VERSION = '0.01';

use OP::Script;

use File::Basename;
use File::Path qw( remove_tree );
use FindBin;
use Getopt::Long;
use Pod::Usage;
use Module::Build;
use File::Spec::Functions qw(catfile catdir );

use lib("$FindBin::Bin/OP-Base/lib");

use OP::Base qw/:vars :funcs/;
use ExtUtils::ModuleMaker;
use Term::ShellUI;
use Data::Dumper;

use parent qw( Class::Accessor::Complex OP::Script  );

__PACKAGE__
    ->mk_new
###_ACCESSORS_SCALAR
	->mk_scalar_accessors(qw(
		moddir
	))
	->mk_integer_accessors(qw())
###_ACCESSORS_ARRAY
	->mk_array_accessors(qw(
		mod_def_names
		modules
		selected_modules
	))
###_ACCESSORS_HASH
	->mk_hash_accessors(qw());

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
    my @parts = split( "::", $module );
    $parts[-1] =~ s/$/\.pm/g;
    my $path = join( "/", @parts );

    return $path;
}

# }}}
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

sub add_modules() {
    my $self = shift;

    my ( @modules, %mods, @files );

    my $s_modules_add = $opt{add} // shift;

    @modules = split( ',', $s_modules_add );

    foreach my $module (@modules) {
        my $def_module = $self->module_to_def($module);
        push( @files, $def_module . "/lib/" . $self->module_to_path($module) );
        mkdir "$shd/mods/";
        mkdir "$shd/mods/" . $self->module_to_def($module);
        mkdir "$shd/mods/" . $self->module_to_def($module) . "/lib/";
        chdir "$shd/mods";
        $mods{$module} = ExtUtils::ModuleMaker->new(
            NAME         => "$module",
            LICENSE      => "perl",
            BUILD_SYSTEM => "Module::Build",
            COMPACT      => 1
        );
        $mods{$module}->complete_build();

        # Write the install.sh script
        open( F, ">", catfile( $def_module, "install.sh" ) );

        print F "#!/bin/bash\n";
        print F "" . "\n";
        print F "perl Build.PL" . "\n";
        print F "./Build" . "\n";
        print F "./Build test" . "\n";
        print F "./Build install" . "\n";

        close(F);
    }
    foreach (@files) { s/^/$shd\/mods\//g; }
    print "@files\n";
    system("gvim -n -p --remote-tab-silent @files");

    #exit 0;
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
        my $mdir = "$shd/mods/" . $self->module_to_def($module);
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
        @emodules = $self->modules ;
    }
    elsif ( $s_modules eq "_sel" ) {
        @emodules = $self->selected_modules ;
    }

    foreach my $module (@emodules) {
        $mfile = $self->module_to_def($module) . "/lib/"
          . $self->module_to_path($module);
        push( @files, $mfile );
    }
    foreach (@files) { s/^/$shd\/mods\//g; }

    system("gvim -n -p --remote-tab-silent @files");
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
	my $self=shift;

	my @mods=split(',',shift);
	$self->selected_modules(@mods);

}

# }}}
# install_modules() {{{

=head3 install_modules()

=cut

sub install_modules() {
    my $self = shift;

    opendir( D, $self->moddir );

    while ( my $file = readdir(D) ) {
		my $fpath=catfile($self->moddir,$file);

        next if $file =~ m/^\./;
        next if $file =~ m/^pod$/;
        next unless -d $fpath;

        $self->mod_def_names_push( $file );
        $self->modules_push( $self->def_to_module($file) );
    }

    $self->selected_modules(
        qw(
          OP::Script
          OP::GOPS::MKDEP
          OP::Perl::Installer
          )
    );

    closedir(D);
}

#}}}
# list_modules(){{{

=head3 list_modules()

=cut

sub list_modules() {
    my $self = shift;

    foreach my $mod ( $self->mod_def_names ) {
        my $module = $self->def_to_module($mod);
        print "$module\n";
    }
}

# }}}
# run_build_install(){{{

=head3 run_build_install()

=cut

sub run_build_install() {
    my $self = shift;

    my ( @exclude, @only );

    @exclude = qw( OP::Module::Build );
    @only = $self->selected_modules; 

    foreach my $mod ( $self->mod_def_names ) {

		# $dirmod = e.g. ~/wrk/perlmod/mods/OP-Base
        my $dirmod = catdir($shd, "mods",  $mod );

		# e.g $module=OP::Base
        my $module = $self->def_to_module($mod);

        next if ( grep { /^$module$/ } @exclude );

        if (@only) {
            next unless grep { /^$module$/ } @only;
        }

		if (-e $dirmod){
        	chdir $dirmod;
		}else{
			next;
		}

		if (-e "./install.sh"){
			system('./install.sh');
		}elsif(-e "Makefile.PL"){
			my @icmds;

			push(@icmds,'perl Makefile.PL');
			push(@icmds,'make');
			push(@icmds,'make test');
			push(@icmds,'make install');

			system(join(' && ',@icmds));
		}elsif(-e "Build.PL"){
			my @icmds;

			push(@icmds,'perl ./Build.PL');
			push(@icmds,'perl ./Build');
			push(@icmds,'perl ./Build test');
			push(@icmds,'perl ./Build install');

			system(join(' && ',@icmds));
		}else{
	        my $build = Module::Build->new(
	            module_name => "$module",
	            license     => 'perl'
	        );
	
	        $self->out("Building module: $module\n");
	
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
    } # end loop over $mod_def_names
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

	$self->moddir("$shd/mods/");

	$self->_term_get_commands();

}

sub _term_get_commands() {
	my $self=shift;

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
###scmd_rbi
        "rbi" => {
            desc    => "Run-build-install",
            maxargs => 0,
            proc    => sub { $self->run_build_install(); },
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

    $self->install_modules();

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

