package OP::PROJSHELL;

use strict;
use warnings;
use Switch;

#------------------------------
# intro {{{

use Env qw(
			$hm 
			$HTMLOUT 
			$PERLMODDIR 
			$PROJSDIR
			$PDFOUT
		);

use Term::ShellUI;
use File::Spec::Functions qw(catfile rel2abs curdir);
use HTTP::Request;
use LWP::UserAgent;

use OP::Writer::Tex;
use OP::Base qw(uniq readarr);
use OP::Git;
use OP::HTML;

use File::Find qw( find finddepth);
use CGI;
use Try::Tiny;

use OP::BIBTEX;

use Data::Dumper;
use File::Copy qw(copy move);
use File::Path qw(make_path remove_tree);
use File::Basename;
use IO::File;

use File::Slurp qw(
  append_file
  read_file
  write_file
);

use lib("$PERLMODDIR/mods/Class-Accessor-Complex/lib");

use parent qw( 
	OP::Script 
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
	cgi
    HOME
    HTMLOUT
    PROJSDIR
    PROJ
    PROJFILE
	PDFFILE
	PDFFILENAME
	PDFOUT
	HTMLDIR
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
    sections
    PROJS
    MKNOTPROJS
    MKPROJS
	HTMLPROJS
    MKTARGETS
	HTMLFILES
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);
##our

###subs
sub _begin;
sub _complete_cmd;
sub _proj_reset;
sub _read_MKTARGETS;
sub _read_PROJS;
sub _sys;
sub _term_exit;
sub _term_get_commands;
sub _term_init;
sub _term_list_commands;
sub _term_run;
sub cmd_list;
sub get_opt;
sub importprojs;
sub init_vars;
sub main;
sub make;
sub new;
sub runsyscmd;
sub set_accessor_descriptions;
sub set_these_cmdopts;
sub sysrun;
sub termcmd_reset;
sub view;
sub view_html;
sub view_proj_tex;
# }}}
#------------------------------
# Methods {{{

# ============================
# Shell Terminal stuff {{{

# _term_get_commands() {{{

=head3 _term_get_commands()

=cut

sub _term_get_commands() {
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
            proc => sub { $self->_sys('clear') },
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
				if ($self->_opt_true("cgi")) {
					$self->_cgi_pdfview;
				}else{
					$self->make('_vdoc'); 
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
#

sub _cgi_htmlview {
	my $self=shift;

	my $q= CGI->new;

	my $nfiles=$self->HTMLFILES_count;
	my $PROJ=$self->PROJ;
	my $HTMLDIR=$self->HTMLDIR;
	my $h=OP::HTML->new;

	if ($nfiles == 1) {
		my $file=$self->HTMLFILES_shift;
		my $wwwprojs='http://localhost/wwwprojs/index.html';
		my $projuri='http://localhost/htmlprojs/' 
				 . $self->PROJ . '/' . $file;

		print $q->header;
		print $q->start_html( 
				title => 'Frames',
 				dtd => [ 
					'-//W3C//DTD HTML 4.01 Transitional//EN', 
					'http://www.w3.org/TR/html4/loose.dtd' 
				],
#<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"  
#"http://www.w3.org/TR/html4/frameset.dtd"> 
			);

		$h->frameset({
	            rows        => '50%,50%',
	            cols        => '*',
	            frameborder => 'yes',
	            border      => '1',
	            frames      => [
	                { src => $projuri,  name => "proj_$PROJ" },
	                { src => $wwwprojs, name => 'wwwprojs' },
	            ],
			});

		print $h->text . "\n";

		print $q->end_html . "\n";

		#print $q->redirect( $projuri);

	}

}

sub _cgi_pdfview {
	my $self=shift;

	my $q=$self->cgi;

	unless ($q->param) {
	    print "<b>No query submitted yet.</b>";
    	return;
	}

	my $proj=$q->param('proj');

    print "<b>Project: $proj</b><p>";

	$self->_proj_reset($proj);
	
	unless (-e $self->PDFFILE) {
	    print "<b>PDF output file does not exist</b>";
		return;
	}

	print "Content-Type:application/x-download\n";
	print "Content-Disposition: attachment; filename=" 
			. $self->PDFFILENAME . "\n\n";

	open FILE, "<", $self->PDFFILE or die "can't open : $!";
	binmode FILE;
	local $/ = \10240;
	while (<FILE>){
	    print $_;
	}
	
    close FILE;
}

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

sub move_html {
    my $self=shift;

    chdir $self->HTMLOUT;
    foreach my $proj ($self->PROJS) {
        make_path($proj);
        my @htmlfiles=glob("$proj*.html");
        if (@htmlfiles) {
          foreach my $file (@htmlfiles) {
            File::Copy::move($file,$proj);
          }
        }
    }
}

# init_vars() {{{

=head3 init_vars()

=cut

sub init_vars() {
    my $self = shift;

    $self->_begin();

    $self->set_accessor_descriptions();

    $self->HTMLOUT(catfile($HTMLOUT,qw(projs)) // catfile( $hm,qw(html projs)));


    $self->PROJSDIR( $PROJSDIR // catfile($hm, qw( wrk texdocs )) );

	$self->PDFOUT($PDFOUT // catfile($hm,qw(pdf out)));

    chdir($self->PROJSDIR) || die $!;

    foreach my $id (qw( PROJS MKPROJS )) {
        $self->files(
            $id  => catfile($self->PROJSDIR,$id . ".i.dat" ) ); 
    }

    $self->files( 
        'maketex_mk'  => catfile($hm,qw(scripts mk maketex.targets.mk ),
        )); 

    $self->LOGFILENAME("ProjShell_log.data.tex");
    $self->LOGFILE( IO::File->new() );
    $self->LOGFILE->open( ">" . $self->LOGFILENAME );

    # read files in directory PROJSDIR:
    #   PROJS.i.dat
    #   MKPROJS.i.dat
    # and fill the corresponding arrays
    $self->_read_PROJS();

	# retrieve the list of HTML-generated projects
    $self->_reset_HTMLPROJS();

    # read in from ~/scripts/mk/maketex.mk
    #    the list of available makefile targets;
    #   this list will be stored in array $self->MKTARGETS
    $self->_read_MKTARGETS();

    $self->viewcmd("gvim -n -p --remote-tab-silent ");

}

sub _reset_HTMLFILES {
	my $self=shift;

	$self->HTMLDIR(catfile($self->HTMLOUT,$self->PROJ));

	my $PROJ=$self->PROJ;

	$self->HTMLFILES_clear;

	if (! -d $self->HTMLDIR) {
		#$self->warn('No HTMLDIR exists for project : ' . $self->PROJ );
		return;
	}

	find(sub { 
			if ( /^($PROJ|index)\.html$/ && -f ){
				$self->HTMLFILES_push($_); 
			}
		}, $self->HTMLDIR);

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

sub runsyscmd{
    my $self=shift;

    my $cmd=shift;
    my @args=@_;

    system("$cmd @args");
}

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
        },
        {
            name => "cgi",
            desc => "CGI mode",
        },
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
            /^ALLPROJS$/ && do {
                push(@comps,$self->PROJS);
                next;
            };
            /^HTMLPROJS$/ && do {
                push(@comps,$self->HTMLPROJS);
                next;
            };
            /^MKTARGETS$/ && do {
                push(@comps,$self->MKTARGETS);
                next;
            };
###complete_sys
            /^sys$/ && do {
                push(@comps,qw( clear ls  ));
                next;
            };
###complete_git
            /^git$/ && do {
                push(@comps,@$OP::Git::commands);
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

sub view_proj_tex {
    my $self=shift;

    my $proj=shift // $self->PROJ;

    my $file=catfile($self->PROJSDIR, $proj . ".tex");
    system($self->viewcmd . " ". $file );

}

sub importprojs {
  my $self=shift;

  my $dir=shift;

  chdir $dir || die $!;

  my @iprojs=readarr('PROJS.i.dat');
  foreach my $proj (@iprojs) {
    append_file ($self->files('PROJS'), $proj . "\n");

    my @files;
    push(@files,glob("$proj.*.tex"));
    push(@files,"$proj.tex");
    foreach my $file (@files) {
      File::Copy::copy($file,$self->PROJSDIR);
    }
  }

}

sub view_html {
    my $self=shift;

    my $proj=shift // $self->PROJ;

    my $htmlfile=catfile($self->HTMLOUT, $proj, "$proj.html");
    system("firefox ". $htmlfile . " &" ) if -e $htmlfile;

}

# }}}
# make() {{{

sub make() {
    my $self=shift;

    my $args=shift // '';

    chdir($self->PROJSDIR) || die $!;

	switch($args){
			case(qw/_html _makehtml_tex4ht/) { 
				$self->_reset_HTMLPROJS;
			}
	}

    if ($self->belongsto_PROJS($args)){
        print "$args\n";
        $self->_proj_reset($args);
    }

    my $cmd=join(";", "cd " . $self->PROJSDIR, "make " . $args);
    system($cmd);

}

# }}}
# _proj_reset() {{{

sub _proj_reset() {
    my $self=shift;

    my $proj=shift // '';

    return 0 unless $proj;

    $self->PROJ($proj);

	$self->_reset_HTMLFILES;

	$self->PDFFILENAME($self->PROJ . '.pdf');
	$self->PDFFILE(
		catfile($self->PDFOUT,$self->PDFFILENAME)
	);


	if ($self->_opt_true('cgi')){
		return;
	}

	my $file=$self->files('MKPROJS');

	try {
	
	   	$self->say("Project is set to: " . $proj );
	   	write_file ( $file , "$proj" );
	   	$self->_read_PROJS();
	}
	catch {
		$self->warn('Failed to write to: ' . $file);
	}

}

# }}}
#
#
#
sub _cgi_www_frame_response {
	my $self=shift;

	my $q=$self->cgi;

	my $lines=[
		$q->start_html('ProjsResponse'), 
	];

}

sub _cgi_www_frame_query {
	my $self=shift;

	my $q=$self->cgi;

	my $sname=$q->script_name;

	my $lines=[
		$q->start_html('ProjsQuery'), 
		$q->h1('Project Index Page'),
		$q->popup_menu(
			-name		=> 'proj',
			-values		=>	[ $self->PROJS ],
			-default 	=> 'programmingperl'
		),
		# -------------- View PDF
		$q->start_form(
			-method => "GET",
			-action => "$sname/pdfview",
			-target => "response",
		),
		$q->submit('button_pdfview' ,'View PDF'),
		$q->end_form,
		# -------------- View HTML 
		$q->start_form(
			-method => "GET",
			-action => "$sname/htmlview",
			-target => "response",
		),
		$q->submit('button_htmlview','View HTML'),
		$q->end_form,
		# -------------- Generate PDF 
		$q->start_form(
			-method => "GET",
			-action => "$sname/makepdf",
			-target => "response",
		),
		$q->submit('button_makepdf' , 'Generate PDF'),
		$q->end_form,
		# -------------- Generate HTML
		$q->submit('button_makehtml' ,'Generate HTML'),
		$q->start_form(
			-method => "GET",
			-action => "$sname/makehtml",
			-target => "response",
		),
		$q->end_form,
	];

	print join("\n",@$lines) . "\n";

}

sub _cgi_www {
	my $self=shift;

	$self->cgi( CGI->new );
	my $pinfo=$self->cgi->path_info;

	print $self->cgi->header;

	switch($pinfo){
		case('') { 
			$self->_cgi_www_frameset;
		}
		case(/pdfview/) { 
			$self->_cgi_pdfview;
			exit 0;
		}
		case(/htmlview/) { 
			$self->_cgi_htmlview;
			exit 0;
		}
		case(/query/) { 
			$self->_cgi_www_frame_query;
		}
		case(/response/) { 
			$self->_cgi_www_frame_response;
		}
	}

	print $self->cgi->end_html . "\n";

    exit 0;
}

sub _cgi_www_frameset {
	my $self=shift;

	my $q=$self->cgi;

	my $sname=$q->script_name;

	my $h=OP::HTML->new;

    print <<EOF;
<html><head><title>Root Projs Page</title></head>
	<frameset cols="30,70" frameborder='yes' border=1>
	<frame src="$sname/query" name="query">
	<frame src="$sname/response" name="response">
</frameset>
EOF

}

# _read_PROJS() {{{
#
=head3 _read_PROJS()

=cut 

sub _read_PROJS() {
    my $self=shift;

    my @lines;
    
    foreach my $id (qw(PROJS MKPROJS )) {
        # clear the lists 
	    eval '$self->' . $id . '_clear()';
        die $@ if $@;

        # read in the corresponding *.i.dat files
	    eval '@lines=read_file $self->files("' . $id . '")';
        die $@ if $@;
	
	    foreach (@lines) {
	        chomp;
		    next if /^\s*#/ || /^\s*$/;
	
	        my @F=split(' ',$_);
	
	        eval '$self->' . $id . '_push(@F)' if @F;
            die $@ if $@;
	    }
	    eval '$self->' . $id . '_sort()';
	    eval '$self->' . $id . '_uniq()';
	
    }

    return 1 unless $self->MKPROJS;

    $self->PROJ($self->MKPROJS_index(0));

}

sub _reset_HTMLPROJS {
	my $self=shift;

	$self->HTMLPROJS_clear;
	File::Find::find(
		sub{ 
			$self->HTMLPROJS_push($_) if (-d && ! /^\.$/)
		},
		$self->HTMLOUT);

	$self->HTMLPROJS_sort;

}

# }}}

sub _sys(){
    my $self=shift;

    my $cmd=shift;

    system("$cmd");
}

# _read_MKTARGETS() {{{

sub _read_MKTARGETS() {
    my $self=shift;

    my $tmk=shift // $self->files("maketex_mk");

    my $makefile_dir=dirname($tmk);
    my $old_dir=rel2abs(curdir());

    chdir $makefile_dir;

    unless (-e $tmk) {
        $self->warn('_read_MKTARGETS(): input makefile not found!');
        return;
    }

    my @lines=read_file $tmk;

    foreach (@lines) {
        chomp;
        next if /^\$/ || /^\s*#/;

        if (/^(?<target>[^:\s]+):\s*[^=]*$/){
            $self->MKTARGETS_push($+{target});
        }
        elsif (/^(\S[^:]+):\s*[^=]*$/){
            $self->MKTARGETS_push(split(" ",$1));
        }

        if (/^include\s+(?<file>.+)/){
          $self->_read_MKTARGETS($+{file});
        }
    }

    $self->MKTARGETS_sort();
    $self->MKTARGETS_uniq();

    chdir $old_dir;

}
# }}}
# cmd_list() {{{

sub cmd_list() {
    my $self=shift;

    my $opt=shift // ''; 

    foreach($opt){
        /^(projs|mkprojs)$/ && do {
            my $ID=uc $opt;
            my $evs='$self->' . $ID . '_print();';
            eval $evs;
            die $@ if $@;
            next;
        };
        /^(targets)$/ && do {
            $self->MKTARGETS_print();
            next;
        };
        /^(htmlprojs)$/ && do {
            $self->HTMLPROJS_print();
            next;
        };
    }
}

# }}}
# }}}
# ============================
# set_accessor_descriptions() {{{

sub set_accessor_descriptions() {
    my $self=shift;

###_ACCDESC
    my ( %accdesc, %accdesc_array, %accdesc_scalar, %accdesc_hash );
###_ACCDESC_SCALAR
    %accdesc_scalar = (
        PROJ             => 'Project name',
        PROJFILE         => 'Project file (full path)',
        PROJSDIR         => 'Projects dir',
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

=head3 info
   
=cut
   
sub info {
	my $self=shift;
    print "\n";
   
}

=head3 clean_html
   
=cut

sub clean_html {
	my $self=shift;

	my @emptydirs;

	my $count=0;

	finddepth(sub { rmdir },$self->HTMLOUT);
	$self->_reset_HTMLPROJS;

}

# }}}
#------------------------------
1;
  
   
