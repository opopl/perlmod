#!/usr/bin/env perl 

use strict;
use warnings;

use Pod::Parser::VimHelp;
use Data::Dumper qw( Dumper );
use FindBin qw($Script);
use Getopt::Long;

our(%OPT,@OPTSTR,%OPTDESC);
our($CMDLINE);

# paths to the pod files to be converted
our @PATHS;

# Pod::Parser::VimHelp instance
our $P;

###subs
sub dhelp;
sub main;
sub get_opt;

main;

sub main {
    get_opt;
}

sub dhelp {

    print << "USAGE";

NAME

    $Script - perl script for converting POD documents to VimHelp files

SYNOPSIS

    $Script --infile FILE <options>
    $Script --module MODULE <options>

OPTIONS

    --hookroot 

USAGE

}
      
sub get_opt {
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));
    
    @OPTSTR=qw( 
            module|m=s
            infile|i=s
            hookroot|r=s
            help 
        );
    
    %OPTDESC=(
        "help"      => "Display help message",
        "infile"    => "Input POD file",
        "module"    => "Module name",
        "hookroot"    => "Specify the root hook name",
    );
    
    unless( @ARGV ){ 
        dhelp;
        exit 0;
    }else{
        $CMDLINE=join(' ',@ARGV);
        GetOptions(\%OPT,@OPTSTR);
    }   

    my $hookroot;
    my @paths;

    $hookroot='';
    if ($OPT{hookroot}){
        $hookroot=$OPT{hookroot};
    }

    if ($OPT{module}) {
        my $moddef=$OPT{module} =~ s/::/-/gr;
        $hookroot=$moddef;

        my $cmd='pmi -p paths ^' . $OPT{module} . '$';

        @PATHS=map { chomp; $_; } `$cmd`;

    }elsif($OPT{infile}){

        @PATHS=( $OPT{infile} );
    }
    

    $P=Pod::Parser::VimHelp->new(
        hookroot    => $hookroot,
        hookcounter => 0,
        hooklinewidth => 70,
    );

    foreach my $path (@PATHS) {
        $P->parse_from_file($path);
    }

}

