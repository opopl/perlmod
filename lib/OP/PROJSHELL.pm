package OP::PROJSHELL;

use strict;
use warnings;

=head1 NAME

OP::PROJSHELL

=head1 SYNOPSIS

=head1 METHODS

=cut

use Switch;

use Env qw(
	$hm 
	$HTMLOUT 
	$PROJSDIR
	$PDFOUT
);

use base qw( 
	Class::Accessor::Complex 
	OP::Script 
	OP::Makefile
	OP::PROJSHELL::Term
	OP::PROJSHELL::CGI
);

use File::Spec::Functions qw(catfile rel2abs curdir);
use File::Temp qw(mktemp);

use HTTP::Request;
use LWP::UserAgent;
use IPC::Cmd;

use OP::Base qw(uniq readarr uniq);
use OP::Git;
use OP::HTML;
use OP::BIBTEX;

use File::Find qw( find finddepth);

use Try::Tiny;

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
	runbufs
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
	shellterm_sys_commands
	sections
	PROJS
	MKNOTPROJS
	MKPROJS
	HTMLPROJS
	PDFPROJS
	PDFPERLDOC
	MKTARGETS
	HTMLFILES
	HPERLTARGETS
	submits
	cmdout
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);
##our

# }}}
#------------------------------
# Methods {{{

# ============================


# }}}

# }}}
# ============================
# Core: _begin() get_opt() init_vars() main() new() set_these_cmdopts() {{{

# _begin() {{{

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

# }}}
#






# get_opt() {{{

=head3 get_opt

=cut

sub get_opt {
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

sub warn {
	my $self=shift;

	warn $_ . "\n" for(@_);

}

sub say {
	my $self=shift;

	print $_ . "\n" for(@_);

}

# init_vars() {{{

=head3 init_vars

=cut

sub init_vars {
    my $self = shift;

    $self->_begin();

    $self->set_accessor_descriptions();

    $self->HTMLOUT(catfile($HTMLOUT,qw(projs)) || catfile( $hm,qw(html projs)));

    $self->PROJSDIR( $PROJSDIR || catfile($hm, qw( wrk texdocs )) );

	$self->dirs(PDFOUT => $PDFOUT || catfile($hm,qw(pdf out)));

	$self->dirs(PDFOUT_PERLDOC => catfile($self->dirs('PDFOUT'),qw(perldoc)));

    chdir($self->PROJSDIR) || die $!;

    foreach my $id (qw( PROJS MKPROJS )) {
        $self->files(
            $id  => catfile($self->PROJSDIR,$id . ".i.dat" ) ); 
    }

	if ($^O eq 'MSWin32') {
	    $self->files( 
	        'maketex_mk'  => catfile($ENV{REPOSGIT},qw(scripts mk maketex.targets.mk ),
	    )); 
	}else{
	    $self->files( 
	        'maketex_mk'  => catfile($hm,qw(scripts mk maketex.targets.mk ),
	    )); 
	}

    $self->_reset_HPERLTARGETS();

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

	# retrieve the list of PDF-generated projects
    $self->_reset_PDFPROJS();

	# retrieve the list of PDF-generated perldoc files
    $self->_reset_PDFPERLDOC();

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

sub main {
    my $self = shift;

    $self->get_opt;

    $self->init_vars;

    $self->_term_init;
    $self->_term_run;
}

# }}}

sub new
{
    my ($class, %ipars) = @_;
    my $self = bless (\%ipars, ref ($class) || $class);

	$self->_begin if $self->can('_begin');
	$self->init if $self->can('init');

    return $self;
}


sub runsyscmd {
    my $self=shift;

    my $cmd=shift;
    my @args=@_;

    system("$cmd @args");
}

# set_these_cmdopts() {{{

=head3 set_these_cmdopts

=cut

sub set_these_cmdopts {
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

=head3 _complete_cmd

=cut

sub _complete_cmd {
    my $self = shift;

    my $ref_cmds = shift || '';

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

sub view {
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

    my $proj=shift || $self->PROJ;

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

    my $proj=shift || $self->PROJ;

    my $htmlfile=catfile($self->HTMLOUT, $proj, "$proj.html");
    system("firefox ". $htmlfile . " &" ) if -e $htmlfile;

}

# }}}
# make() {{{

sub make {
    my $self=shift;

    my $args=shift || '';

    my %runopts=@_;

    chdir($self->PROJSDIR) || die $!;

	switch($args){
		case(qw/_html _makehtml_tex4ht/) { 
			$self->_reset_HTMLPROJS;
		}
	}

    if ($self->belongsto_PROJS($args)){
        $self->_proj_reset($args);
    }

	if ($self->usecgi) {
		foreach my $id (qw(TEXINPUTS TEXMFLOCAL)) {
			my $msg;
			if (defined $ENV{$id}) {
				my $val=$ENV{$id};
				$msg="$id : " . $val ;
			}else{
				$msg="$id : " . 'undefined' ;
			}

			$self->cgi->br("msg");
		}
		$self->cgi->hr;
	}

    my $cmd=join(";", "cd " . $self->PROJSDIR, "make " . $args);

	$self->_sys($cmd,%runopts);


}

# }}}
# _proj_reset() {{{

sub _proj_reset {
    my $self=shift;

    my $proj=shift || '';

    return 0 unless $proj;

    $self->PROJ($proj);

	$self->_reset_HTMLFILES;

	$self->PDFFILENAME($self->PROJ . '.pdf');
	$self->PDFFILE(
		catfile($self->dirs('PDFOUT'),$self->PDFFILENAME)
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



# _read_PROJS {{{
#
#

=head3 _read_PROJS

=cut 

sub _read_PROJS {
    my $self=shift;

    my @lines;
    
    foreach my $id (qw( PROJS MKPROJS )) {
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

sub _reset_HPERLTARGETS {
	my $self=shift;

	my $id='hperltargets_dat';
    $self->files( 
          $id => catfile(qw(/doc perl tex hperl_targets.i.dat )),
    ); 

	if (not -e $self->files($id)) {
		return 0;
	}

	$self->HPERLTARGETS(readarr($self->files('hperltargets_dat')));

}

sub _reset_HTMLPROJS {
	my $self=shift;

	$self->HTMLPROJS_clear;

    unless (-e $self->HTMLOUT) {
        return 0;
    }

	File::Find::find(
		sub { 
			$self->HTMLPROJS_push($_) if (-d && ! /^\.$/)
		},
		$self->HTMLOUT);

	$self->HTMLPROJS_sort;

}

sub _reset_PDFPROJS {
	my $self=shift;

	$self->PDFPROJS_clear;

	unless(-d $self->dirs('PDFOUT')){
		$self->warn('No PDFOUT directory');
		return;
	}

	File::Find::find(
		sub{ 
			if (-f && /\.pdf$/){
				s/\.pdf$//g;
				my $proj=$_;

				if(grep { /^$proj$/ } @{$self->PROJS} ){
					$self->PDFPROJS_push($_);
				}
			}
		},
		$self->dirs('PDFOUT'));

	$self->PDFPROJS_sort;

}

sub _reset_PDFPERLDOC {
	my $self=shift;

	$self->PDFPERLDOC_clear;

	if (not -d $self->dirs('PDFOUT_PERLDOC')){
		return 0;
	}

	File::Find::find(
		sub{ 
			if (-f && /\.pdf$/ ){
				s/\.pdf$//g;

				my $proj=$_;

				if( grep { /^$proj$/ } @{$self->HPERLTARGETS} ){
					$self->PDFPERLDOC_push($proj);
				}

			}
		},
		$self->dirs('PDFOUT_PERLDOC'));

	$self->PDFPERLDOC_sort;

}

# }}}
#
sub _sys {
    my $self=shift;

	if ($^O eq 'MSWin32') {
		$self->_sys_win(@_);
	}else{
		$self->_sys_unix(@_);
	}
}

sub _sys_win {
    my $self=shift;

    my $cmd=shift;

    my %runopts=@_;

	$self->say('Running command: ',"\t" . $cmd);

	my $tmp=mktemp("XXXXXX");

	system("cmd /c $cmd > $tmp 2>&1");
	my $c = $self->{runcmd_perl_exitcode} = $? >> 8;

	$self->say('perl system() exit code: ' . $c );

	$self->cmdout_clear;

	open(F,"<$tmp") || die $!;
	while(<F>){
		chomp;
		my $line=$_;

		$self->cmdout_push($line);
	}
	close(F);

	if ($c) {
		$self->warn('command output:',$self->cmdout );
	}
}

sub _sys_unix {
    my $self=shift;

    my $cmd=shift;

    my %runopts=@_;

	$runopts{runmode}='ipc_cmd_forked' 
		unless defined  $runopts{runmode};

	unless($self->usecgi) {

		for($runopts{runmode}){	
			/^ipc_cmd_forked$/ && do { 
		        my $res= IPC::Cmd::run_forked( $cmd );
		        
		        if ($res->{exit_code}) {
		            $self->warn("FAILURE with exit code: " . $res->{exit_code});
		        
		        }else{
		            $self->say("SUCCESS");
		        
		        }
				next;
			};

			/^system$/ && do { 
				system("$cmd");
				next;
			};

			system("$cmd");
		}

	}else{
		my %res;
		
		@res{qw( ok error_message full_buf stdout_buf stderr_buf )}=
			IPC::Cmd::run( command => $cmd, verbose => 0 );

		my $q=$self->cgi;
		
		foreach my $id (qw( stdout_buf full_buf stderr_buf )) {
			$res{$id}= [ 
					map { "<br/>$_" } 
					split("\n",join("",@{$res{$id}})) 
				];
		}

		$self->runbufs(%res);

		my @out= @{$res{full_buf}};

		print $_ . "\n" for(@out);

	}

}


# cmd_list() {{{

sub cmd_list {
    my $self=shift;

    my $opt=shift || ''; 

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
        /^(htmlfiles)$/ && do {
            $self->HTMLFILES_print();
            next;
        };
    }
}

# }}}
# }}}
# ============================

sub set_accessor_descriptions {
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

sub sysrun {
    my $self=shift;

    my $cmd=shift;

    system("$cmd");
}


=head3 info
   
=cut
   
sub info {
	my $self=shift;

    print $self->PROJ . "\n";
    print $self->PROJSDIR . "\n";
   
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
  
