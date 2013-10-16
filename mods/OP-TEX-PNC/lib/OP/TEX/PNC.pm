package OP::TEX::PNC;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT = qw();

###export_vars_scalar
my @ex_vars_scalar = qw(
);
###export_vars_hash
my @ex_vars_hash = qw(
);
###export_vars_array
my @ex_vars_array = qw(
  @PNC
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [
        qw(
          _pnc_ienv
          _pnc_pbib
          process_perltex
          )
    ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT    = qw( );
our $VERSION   = '0.01';

sub _pnc_pbib;
sub _pnc_ienv;

our @PNC;

sub process_perltex {
    local $_ = shift;

    foreach my $pnc (@PNC) {

        my %re;

        # three arguments
        $re{3} = qr/
				(?<before>[^%]*)
				(?<pnc>\\$pnc\{(?<a1>[^{}]+)\}\{(?<a2>[^{}]+)\}\{(?<a3>[^{}]+)\})
				(?<after>.*)
				/x;
        
        # two arguments
        $re{2} = qr/
				(?<before>[^%]*)
				(?<pnc>\\$pnc\{(?<a1>[^{}]+)\}\{(?<a2>[^{}]+)\})
				(?<after>.*)
				/x;

        # one argument
        $re{1} = qr/
				(?<before>[^%]*)
				(?<pnc>\\$pnc\{(?<a1>[^{}]+)\})
				(?<after>.*)
				/x;

        for my $i((3..1)){
	        if (/^$re{$i}$/) {
	            my $expr;
	
	            my $evs = '$expr=_pnc_' . $pnc . '($+{a1},$+{a2})';
	            eval "$evs";
	            die $@ if $@;
	
	            $_ = $+{before} . "\n%" . $+{pnc} . "\n" . $expr . $+{after};
	        }
        }
    }

    return $_;
}

sub _pnc_pbib {
    my ( $num, $pkey ) = @_;

    my ($s);

    $pkey =~ s/\s*//g;
    chomp($pkey);

    if ( ( defined $num ) && ( length($pkey) ) ) {
        my $bibt = "bibt.$pkey.tex";
        if ( !-e $bibt ) { `bib_print_entry $pkey > $bibt`; }
        if ( -e $bibt ) {
            $s = "\\paragraph*{$num. $pkey}\n";
            $s .= "\\input{$bibt}\n";
        }
        my $pdffile = "$ENV{HOME}/doc/papers/ChemPhys/$pkey.pdf";
        if ( -e $pdffile ) {

            #$s.="\\href{file://$pdffile}{File}\n";
        }
    }
    else {
        $s = "";
    }
    return $s;

}

sub _pnc_ienv {
    my $env = shift;
    my @ranges = split( ',', shift );

    my $pkey = '\pn';

    #my $env=$ARGV[0];
    #my @ranges=split(',', $ARGV[1]);

    my ( @pages, @pt );
    my ( $start, $fin );
    my $stex = "";

    foreach (@ranges) {
        chomp;
        if (/^\s*(\w+)\s*$/) {
            push( @pages, $1 );
        }
        elsif (/^\s*(\d+)\-(\d+)\s*$/) {
            $start = $1;
            $fin   = $2;
            @pt    = ( $start .. $fin );
            push( @pages, @pt );
        }
    }

    foreach my $p (@pages) {
        $stex = $stex . "\\input\{p.$pkey.$env.$p.tex\}\n";
    }
    return $stex;

}

1;

# The preceding line will help the module return a true value

