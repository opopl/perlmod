package OP::PaperConf;

use strict;
use warnings;

use File::Slurp qw( edit_file edit_file_lines read_file );
use File::Spec::Functions qw(catfile rel2abs curdir );

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

    $VERSION = '0.01';
    @ISA     = qw(Exporter);

    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    %EXPORT_TAGS = (
        'funcs' => [qw( readdat )],
        'vars'  => [
            qw(
              $bkey
              $config
              $eqs_h
              $figs_h
              $refs_h
              $texroot
              )
        ]
    );

    our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

    our @EXPORT  = qw( );
    our $VERSION = '0.01';

}

our $texroot = $ENV{'PSH_TEXROOT'} 
    // catfile( "$ENV{hm}", qw(wrk p) )
    // catfile( "$ENV{HOME}", qw(wrk p) );

our ( $refs_h, $eqs_h, $figs_h, $bkey, $config );

sub readdat;

sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );
    return $self;
}

sub readdat() {

    foreach my $id (qw(refs eqs figs )) {
        my $fdat = catfile( $texroot, "p." . $bkey . ".$id.i.dat" );
        my $H;

        # dat-file contents will have priority over manually typed contents for
        #   *_h hashes ( $refs_h, $eqs_h etc. )
        if ( -e $fdat ) {
            my @lines = read_file $fdat;

            foreach (@lines) {
                chomp;
                next if /^\s*#/ || /^\s*$/;

                my @F   = split;
                my $num = shift @F;

                unless ( defined $H->{$num} ) {
                    $H->{$num} = join( " ", @F );
                }
                else {
                    $H->{$num} .= " " . join( " ", @F );
                }
            }

            eval '$' . $id . '_h=$H';
            die $@ if $@;

        }
        else {
            $refs_h = { 1 => "" };
            $eqs_h  = { 1 => "" };
        }
    }

}

1;
