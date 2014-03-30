
package OP::TEX::MAKEINDEX;

use warnings;
use strict;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

our @EXPORT_OK = qw( main );
our @EXPORT  = qw( );
our $VERSION = '0.01';

use FindBin qw($Bin $Script);

use OP::Script::Simple qw(
	_warn 
	_say
	pre_init
	$EXITCODE
	$IFNAME
	$IFILE
	$OFILE
	%opt
	$cmdline
);
use OP::Base qw(run_cmd);
use OP::PAPERS::idx_ins_hpage;

use IPC::Cmd;

###our
our $opts_makeindex;

sub main;
###subs
sub c_idx;
sub get_opt;
sub ind_insert_bookmarks;
sub makeindex;
sub run;

sub main {
    pre_init;
    get_opt;
    run;

    exit $EXITCODE;
}

sub run {

    #c_idx $IFNAME;
    #makeindex $IFNAME;
    #ind_insert_bookmarks $IFNAME;
	#
    makeindex $IFNAME;

}

sub get_opt {

    # default values
    %opt=();

    $opts_makeindex='';

    unless (@ARGV) {
        _say "Usage: $Script OPTIONS FILENAME";
        exit 1;
    }
    else {
        $cmdline = join(' ', @ARGV );
        $IFNAME = pop @ARGV;
        $opts_makeindex=join(" ",@ARGV);
    }

    $IFNAME =~ s/\.idx$//g;
    $IFILE=$IFNAME . '.idx';
    $OFILE=$IFNAME . '.ind';

    if(-e $IFILE){
      _say "Input filename: $IFNAME";
    }else{
      $opts_makeindex.=" $IFNAME";
      $IFNAME='';
    }

    if ($opts_makeindex){
        _say "Input options: $opts_makeindex";
    }

}

sub ind_insert_bookmarks {
    my $ifname = shift;

    my $ind="$ifname.ind";

    unless (-e $ind){
      return;
    }

    my $cmd = "ind_insert_bookmarks.pl $ind";

    system("$cmd");
}

sub makeindex {
    my $ifname = shift // '';

    unless($ifname){
        my $cmd = "makeindex $opts_makeindex";
        system("$cmd");
        return;
    }

    my $idx="$ifname.idx";
    
    unless(-e $idx){
      return;
    }

    my $cmd = "makeindex $opts_makeindex $idx";
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
