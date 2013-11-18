
package OP::Git;

use warnings;
use strict;

###use
use Env qw( 
    $hm 
    $GIT_ORIGIN 
    $PERLMODDIR 
    $HOSTNAME 
    );

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	use lib("$PERLMODDIR/mods/OP-Base/lib");
	use OP::Base qw( _import run_cmd );
	
	_import( { 
            'modules' => [qw( OP::Script::Simple IPC::Cmd )],
            'import' => { 
                'OP::Script::Simple' => [ qw( _say _say_head ) ],
            }
    });

}

#use lib("$PERLMODDIR/mods/OP-Script-Simple/lib");
#use OP::Script::Simple qw( _say _say_head );

#use lib("$PERLMODDIR/mods/IPC-Cmd/lib");
#use IPC::Cmd qw(run);

use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use Data::Dumper;

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
    $commands
    $REPO
);
###export_vars_hash
my @ex_vars_hash=qw(
    %REPOS
    @ListRepos
    @FilesToCommit
    @FilesUntracked
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
    check_repos
    git_status
    git_commit
    git_push
    git_pull
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

###subs
sub git_push;
sub git_pull;
sub git_commit;
sub git_status;
sub check_repos;
sub init_vars;

###our
our($commands);
our(%REPOS);
our(@ListRepos);
our $REPO;

our @FilesToCommit;
our @FilesUntracked;

sub new
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}

sub init_vars {

  $commands=[ qw(
		add
		st
		br
		ci
		co
		log
		lg
		lf
        rebase
		push
		pull
		pb
  )];

  foreach my $repo (qw( gops vrt scripts config)) {
     $REPOS{$repo}->{path}= catfile($hm,$repo);
  }

  foreach my $repo (qw( p texdocs texinputs perlmod)) {
     $REPOS{$repo}->{path}= catfile($hm,qw(wrk),$repo);
  }

  @ListRepos=keys %REPOS;

}

sub git_status {

    my $cmd="git status";

    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
        IPC::Cmd::run( command => $cmd, verbose => 0 );

    run_cmd( command => $cmd, verbose => 0 );

    print Dumper($full_buf);
    exit 0;
}

sub git_commit {
}

sub git_push {
}

sub git_pull {
}

sub check_repos {
    _say "Git origin is $GIT_ORIGIN";
    _say "Current hostname is $HOSTNAME";

    foreach $REPO (@ListRepos) {
        _say_head "Checking repository: $REPO";

        my $h=$REPOS{$REPO};
        my $wpath=$h->{path};

        if (-d $wpath){
            _say "  Working tree directory exists";
            _say "  Full path is: ";
            _say "    $wpath ";
            chdir $wpath;
            _say "  Invoking git status...";
            git_status;
        }
    }
}

BEGIN {
   init_vars;
}

1;

