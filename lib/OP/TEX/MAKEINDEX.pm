
package OP::TEX::MAKEINDEX;

use warnings;
use strict;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

our @EXPORT_OK = qw( makeindex );
our @EXPORT  = qw( );
our $VERSION = '0.01';

use FindBin qw($Bin $Script);

use OP::Script::Simple qw(
	_warn 
	_say
	_die
	pre_init
	$EXITCODE
	$IFNAME
	$IFILE
	$OFILE
	%opt
	$cmdline
	override_argv
	restore_argv
);
use OP::Base qw(run_cmd);

use OP::PAPERS::idx_ins_hpage;
use OP::PAPERS::ind_insert_bookmarks qw( ind_insert_bookmarks );

use IPC::Cmd;

###our
our $OPTS_makeindex;

###subs
sub _ind_insert_bookmarks;
sub exe_makeindex;
sub c_idx;
sub get_opt;
sub makeindex;
sub run;

sub makeindex {

    pre_init;
    get_opt;
    run;

    exit $EXITCODE;

}

sub run {

    #c_idx $IFNAME;
    #makeindex $IFNAME;
	#
    exe_makeindex $IFNAME;

    _ind_insert_bookmarks $IFNAME;

}

sub get_opt {

    # default values
    %opt=();

    $OPTS_makeindex='';

	override_argv(@_);

    unless (@ARGV) {
        _say "Usage: $Script OPTIONS FILENAME";
        exit 1;
    }
    else {
        $cmdline = join(' ', @ARGV );
        $IFNAME = pop @ARGV;
        $OPTS_makeindex=join(" ",@ARGV);
    }

    $IFNAME =~ s/\.idx$//g;
    $IFILE=$IFNAME . '.idx';
    $OFILE=$IFNAME . '.ind';

	if (defined $ENV{MAKEINDEXSTYLE}) {
        $OPTS_makeindex.=" -s $ENV{MAKEINDEXSTYLE}";
	}

    if(-e $IFILE){
      _say "Input filename: $IFNAME";
    }else{
	  _die "Input file was not found: $IFILE";
      $OPTS_makeindex.=" $IFNAME";
      $IFNAME='';
    }

    if ($OPTS_makeindex){
        _say "Input options for makeindex: $OPTS_makeindex";
    }

	restore_argv;

}

=head3 _ind_insert_bookmarks
 
=head4 Usage
 
	_ind_insert_bookmarks($ifname);
 
=head4 Purpose

Invoke method L<OP::PAPERS::ind_insert_bookmarks/ind_insert_bookmarks> on
input .ind file C<$indfile=$ifname.ind>.
 
=head4 Input
 
=over 4
 
=item * C<$ifname> (SCALAR) input .ind filename (extension stripped).
 
=back
 
=head4 Returns

Nothing.
 
=cut
 
sub _ind_insert_bookmarks {
    my $ifname = shift;

    my $indfile="$ifname.ind";

    unless (-e $indfile){
	  	_warn "Cannot find input .ind file: $indfile";
      	return;
    }

	ind_insert_bookmarks( $indfile );

}

sub exe_makeindex {
    my $ifname = shift // '';

    unless($ifname){
        my $cmd = "makeindex $OPTS_makeindex";
        system("$cmd");
        return;
    }

    my $idx="$ifname.idx";
    
    unless(-e $idx){
	  _die "No idx file found: $idx";
    }

    my $cmd = "makeindex $OPTS_makeindex $idx";
    my $res=run_cmd(command => "$cmd");

    $EXITCODE=1;

    if ((-e $OFILE) && ($res->{ok})){
        _say "SUCCESS, output file created: " . $OFILE;
    	$EXITCODE=0;
    }elsif(-e $OFILE && (not $res->{ok})){
        _warn "FAILURE, but output file exists: " . $OFILE;
    	$EXITCODE=1;
    }elsif(! -e $OFILE){
        _warn "output file was not created: " . $OFILE;
    	$EXITCODE=2;
    }

}

sub c_idx {
    my $ifname = shift;

    my $idx = "$ifname.idx";

    unless (-e $idx){
      return;
    }

	my @old=@ARGV;
	@ARGV=( qw( --infile ), $idx, qw( --rw ));
	OP::PAPERS::idx_ins_hpage->new->main;

	@ARGV=@old;

}

1;
