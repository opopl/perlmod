
package OP::Git;

use warnings;
use strict;

=head1 NAME

OP::Git - Perl interface to Git

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

###use
use Env qw( 
    $hm 
    $GIT_ORIGIN 
    $PERLMODDIR 
    $HOSTNAME 
    );

use Exporter ();

BEGIN {
	use lib("$PERLMODDIR/mods/OP-Base/lib");
	use OP::Base qw( _import run_cmd );
	
	my $imp=_import( { 
            'modules' => [qw( OP::Script::Simple IPC::Cmd )],
            'import' => { 
                'OP::Script::Simple' => [ qw( _say _say_head ) ],
                'IPC::Cmd' => [ qw( run ) ],
            }
    });

    eval($imp);
    die $@ if $@;

}

use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use Data::Dumper;
 
=head1 DEPENDENCIES
 
=over 4
 
=item L<Data::Dumper>

=item L<OP::Base>

=item L<OP::Script::Simple>

=item L<IPC::Cmd>
 
=item L<File::Spec::Functions>
 
=item L<strict>
 
=item L<vars>
 
=item L<warnings>
 
=back
 
=cut
 

our $VERSION = '0.01';
our @ISA     = qw(Exporter);

our @EXPORT      = qw();

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

our %EXPORT_TAGS = (
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

=head1 METHODS

=cut

=head3 new

=cut

sub new
{
    my ($class, %parameters) = @_;
    my $self = bless ({}, ref ($class) || $class);
    return $self;
}

=head3 init_vars

=cut

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

  @ListRepos=sort keys %REPOS;

}

=head3 git_status()

=cut

sub git_status {

    my $cmd="git status";

    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) =
        IPC::Cmd::run( command => $cmd, verbose => 0 );

    run_cmd( command => $cmd, verbose => 0 );

    print Dumper($full_buf);
    exit 0;

}

=head3 git_commit()

=cut

sub git_commit {
}

=head3 git_push()

=cut

sub git_push {
}

=head3 git_pull()

=cut

sub git_pull {
}

=head3 check_repos()

=cut

sub check_repos {

    _say("Git origin is $GIT_ORIGIN");
    _say("Current hostname is $HOSTNAME");

    foreach $REPO (@ListRepos) {
        _say_head("Checking repository: $REPO");

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

###_BEGIN
BEGIN {
   init_vars;
}

1;

