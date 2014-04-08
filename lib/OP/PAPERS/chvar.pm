package OP::PAPERS::chvar;

use strict;
use warnings;

###use
use File::Basename;
use File::Copy;
use Getopt::Long;

use FindBin qw($Bin $Script);

###our
our @ISA     = qw(Exporter);
our @EXPORT  = qw( );
our @EXPORT_OK = qw(main);
our $VERSION = '0.01';

our(%opt,%ifiles,@optstr);
our($key,$val);
our(@ifiles,$infile);

###subs
sub dhelp;
sub get_opt;
sub hx;
sub init_vars;
sub main;
sub override;
sub svals;

sub hx { dhelp(@_); exit; }

sub dhelp {
print << "HELP";
=========================================================
PURPOSE: 
    Changing variable's values in vars.i.dat file 
USAGE: 
    $Script VARNAME VALUE
        CHANGE VARNAME's value to VALUE.
        Names/values are stored in *.i.dat files
SCRIPT LOCATION:
    $0
=========================================================

HELP
}

sub init_vars{
    @ifiles=( "vars" );
    @optstr=( "infile=s","var=s","val=s" );
}

sub get_opt {

    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    if ( !@ARGV ){ 
        hx();
    }else{
        GetOptions(\%opt,@optstr) or hx(); 
        if (defined($opt{h})){ 
            hx($opt{h}); 
        };
    }

}

sub svals {

    $key=$opt{var};
    $val=$opt{val};
    $infile="vars.i.dat";

    if (defined($opt{infile})){ $infile=$opt{infile}; } 

    my $f="$infile";
    
    open(O,"<$f");
    copy($f,"$f.bak");
    open(N,">$f.new");

    my $match=0;
    my $line;

    while(<O>){
        chomp;
        if ( m/^\s*($key)\b/ ){
            $match++;
            s/^\s*($key)\b.*$/$1 $val/g;
        }
        print N "$_\n";
    }
    if ( $match == 0 ){ 
        print N "$key $val\n"; 
    }

    move("$f.new","$f");

    close(O);
    close(N);
}

sub override {

    if (@_){
        $key=shift;
        $val=shift;
        $infile=shift if @_;

        @ARGV=(qw(--key),$key,qw(--val),$val);
        push(@ARGV,qw(--infile),$infile) if defined $infile;
    }

}

sub main {
    
    override(@_);
    init_vars;
    get_opt;
    svals;

}

1;
