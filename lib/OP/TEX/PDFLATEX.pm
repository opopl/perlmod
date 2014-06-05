
package OP::TEX::PDFLATEX;

use warnings;
use strict;

###use
use Exporter ();

use FindBin qw($Bin $Script);
use IPC::Cmd qw(run_forked);
use OP::Script::Simple qw( 
	pre_init
	_say 
	_die
	_warn 
    %FILES
	$IFILE
	$IFNAME
	$OFILE
);


###our
our @EXPORT_OK = qw( main );
our @EXPORT  = qw( );
our $VERSION = '0.01';
our @ISA = qw(Exporter);

our $sopts;

our $PKEY;
our $makeindexstyle;

our (%opt,@optstr);
our ($cmdline);
our $OPTS_PDFLATEX;

our (@WARNINGS,@ERRORS);

###subs
sub _pdflatex;
sub main;
sub listof_change;
sub get_opt;
sub run;
sub makeindex;
sub ind_insert_bookmarks;
sub c_idx;

sub main {
    pre_init;
    get_opt;
    run;
}

sub run {

    _pdflatex $IFNAME;

    if (-e $OFILE){
      _say "Output file created: " . $OFILE;
    }

}

sub _pdflatex {
    my $ifname = shift // '';
	
	my $cmd;

    my $exe=$FILES{pdflatex} // 'pdflatex';
    $cmd = "$exe $OPTS_PDFLATEX $ifname";

	my $res;
	
	if(not IPC::Cmd::can_run($exe)){
        _die "Cannot run: $exe ";
    }

    my ($line,$msg,$file,$lnum,$type);

    my $opts={
        stdout_handler => sub {
            local $_=shift;

            if (/^(?<file>.*):(?<lnum>\d+): LaTeX Error:(?<msg>.*)/) {
                $line=$_;
                $lnum=$+{lnum};
                $file=$+{file};
                $type='latexerror';
                $msg=$+{msg};
                return;
            }

            $line .= $_ if $line;
            $msg .= $_ if $msg;

            if (/^\s*$/ && $line){

	            push(@ERRORS,
	            { 
					lnum    => $lnum, 
					file    => $file, 
					type    => $type,
					msg     => $msg,
					line    => $_,
	            });

                $line='';
                $msg='';
            }

        }
    };
	
    $res= IPC::Cmd::run_forked( $cmd, $opts );

    if ($res->{exit_code}) {
        _warn "FAILURE with exit code: " . $res->{exit_code};
        _warn 'Errors: ';
        for(@ERRORS){
            print $_->{line};
        }

    }else{
        _say "SUCCESS";

    }


}

sub get_opt {

    $OPTS_PDFLATEX='-file-line-error';

    unless (@ARGV) {
        _say "Usage: $Script OPTIONS FILENAME";
        exit 1;
    }
    else {
        $cmdline = join( ' ', @ARGV );
        $IFNAME = pop @ARGV;
        $OPTS_PDFLATEX=join(' ',@ARGV) if @ARGV;
    }

    $IFNAME =~ s/\.tex$//g;
    $IFILE=$IFNAME . '.tex';
    $OFILE=$IFNAME . '.pdf';

    if(-e $IFILE){
      _say "Input filename: $IFNAME";

    }else{
      $OPTS_PDFLATEX.=" $IFNAME";
      $IFNAME='';

    }

    _say "Input pdflatex options: $OPTS_PDFLATEX";

    $sopts="";

	if ($IFNAME =~ /^p.(?<pkey>\w+).pdf$/){
        $PKEY=$+{pkey};
		$sopts.=" --pkey $PKEY";
    }

}

sub listof_change {

    my $pl = "listof_change.pl";

    unless(IPC::Cmd::can_run("$pl")){
        return;
    }

    # e.g. lof
    my $ext = shift;

    # e.g. figure
    my $type = shift;

    # e.g. p.HT92.pdf
    my $infile = shift . ".$ext";

    if ( -e $infile ) {
        _say "Invoking $pl for extension: $ext on file: $infile";
        my $cmd = "$pl $sopts --infile $infile --rw --type $type";
        system("$cmd");
    }
    else {
        _warn "Input file does not exist: $infile";
    }
}

1;
