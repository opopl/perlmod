
package OP::TEX::HTLATEX;

use warnings;
use strict;

use Exporter ();

###use
use FindBin qw($Bin $Script);
use IPC::Cmd;
use OP::Script::Simple qw(_say pre_init 
        $IFNAME $OFILE $IFILE $cmdline
        %DIRS
    );
use Env qw($hm @PATH);
use File::Slurp qw( read_file);
use File::Spec::Functions qw(catfile);
use Data::Dumper;


my @ex_vars_scalar=qw();
my @ex_vars_hash=qw();
my @ex_vars_array=qw();

our %EXPORT_TAGS = (
    'funcs' => [qw( 
         main
    )],
    'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

###our
our @ISA     = qw(Exporter);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

###our
our $opts_htlatex;
our @ARGS;
our $TEXOPTS;

sub run;
sub main;
sub htlatex;
sub get_opt;
###subs

main;

sub main {
    pre_init;
    get_opt;
    run;
}

sub bibtex {
    my $ifname=shift;

    my $cmd;

    $cmd='bibtex ' . $IFNAME;

    system("$cmd");
}

sub run {

    unshift(@PATH,"/usr/share/tex4ht");

    htlatex $IFNAME;
    bibtex $IFNAME;

    my $idx="$IFNAME.idx";
    my @cmds;

    if (-e $idx){
       push(@cmds,"tex " 
           . "'" 
           . "\\def\\filename{{$IFNAME}{idx}{4dx}{ind}}" 
           . "\\input idxmake.4ht" 
           . "'" ); 
       push(@cmds,"MAKEINDEX -o $IFNAME.ind " . " $IFNAME.4dx" );
    }
    system(join(";",@cmds));

    htlatex $IFNAME;

    if (-e $OFILE){
      _say "Output file created: " . $OFILE;
    }

}

sub htlatex {
    my $ifname = shift // '';

    my $cmd;
    my @cmds;

    $DIRS{htfonts}='/usr/share/texmf/tex4ht/ht-fonts';

    my $ptexcode =<<'EOF';
\makeatletter%
%
\def\HCode{\futurelet\HCode\HChar}%
\def\HChar{%
   \ifx"\HCode\def\HCode"##1"{\Link##1}%
       \expandafter\HCode%
   \else%
       \expandafter\Link%
   \fi%
}%
%
\def\Link#1.a.b.c.{%
  \g@addto@macro\@documentclasshook{%
		\RequirePackage[#1,html]{tex4ht}%
	}%
  \let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}%
%
\makeatother\HCode _TWO_.a.b.c.\input _ONE_
EOF
    
    $ptexcode =~ s/_ONE_/$ARGS[1]/g;
    $ptexcode =~ s/_TWO_/$ARGS[2]/g;
    
    my $latex='perltex --nosafe ';
    $cmd=$latex . ' ' . $TEXOPTS . ' ' . "'" . $ptexcode . "'" ;

    _say("TEX command: " . $cmd );

    foreach my $i ((1..3)) {
        push(@cmds,$cmd);
    }
     
    push(@cmds,'tex4ht -f/' . $ARGS[1] . ' -i/' . catfile($DIRS{htfonts},$ARGS[3]));
    push(@cmds,'t4ht -f/' . $ARGS[1] . ' ' . $ARGS[4] .  ' ## -d~/WWW/temp/ -m644');

    foreach my $cmd (@cmds) {
        system("$cmd");
    }

}


sub get_opt {

    $ARGS[$_]='' for((1..5));
    $ARGS[0]=$Script;

    unless (@ARGV) {
        _say "Usage: $Script OPTIONS FILENAME";
        exit 1;
    }
    else {
        $cmdline = join( ' ', @ARGV );

        my $i=0;
        for(@ARGV){
          $ARGS[$i]=$ARGV[$i];
          $i++;
        }
        unshift(@ARGS,$Script);

        $IFNAME=$ARGS[1];
    }

    $IFNAME =~ s/\.tex$//g;
    $IFILE=$IFNAME . '.tex';
    $OFILE=$IFNAME . '.html';

    if(-e $IFILE){
      _say "Input filename: $IFNAME";
    }else{
      $IFNAME='';
    }

    _say "Input htlatex arguments: $cmdline";

    $TEXOPTS=$ARGS[5] // '-file-line-error';

}

1;

##!/bin/bash

#if command -v xhtex > /dev/null 2>&1 ; then
  #true
#else
  #export PATH=/usr/share/tex4ht:$PATH
#fi

        #perltex --nosafe $5 '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '$2'.a.b.c.\input ' $1
        #perltex --nosafe $5 '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '$2'.a.b.c.\input ' $1
        #perltex --nosafe $5 '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode '$2'.a.b.c.\input ' $1
        #tex4ht -f/$1  -i/usr/share/texmf/tex4ht/ht-fonts/$3
        #t4ht -f/$1 $4 ## -d~/WWW/temp/ -m644 



