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
        'funcs' => [qw( 
            readdat
            read_secorder
            Fcat
         )],
        'vars'  => [
            qw(
              $bkey
              $config
              $eqs_h
              $figs_h
              $refs_h
              $texroot
              %greek_letters
              %subsyms
              %RE
              )
        ]
    );

    our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

    our @EXPORT  = qw( );
    our $VERSION = '0.01';

}

###our
our ( $refs_h, $eqs_h, $figs_h, $bkey, $config, $texroot );
our (%greek_letters,%subsyms,%RE);

sub readdat;
sub init_vars;
sub Fcat;

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

sub Fcat () {
    my @names=@_;

    return catfile($texroot,@names);
}

sub read_secorder () {

    my $file=&Fcat( 'p.' . $bkey . '.secorder.i.dat' );
    my @lines=read_file $file;

    @lines=map { chomp; /^\s*#/ ? () : $_ } @lines;

    wantarray ? @lines : \@lines;
}

sub init_RE() {

    %RE=(
        papereq  => qr/(\\begin\{paper(eq|align)\})/,
        labeleq  => qr/\\labeleq\{([\w\d]+)\}/,
        alignbegin    => qr/\\(?<begin>begin)\{align\}/,
        alignend    => qr/\\(?<end>end)\{align\}/,
    );

}

sub init_vars() {

    &init_RE();

    $texroot = $ENV{'PSH_TEXROOT'} 
        // catfile( "$ENV{hm}", qw(wrk p) )
        // catfile( "$ENV{HOME}", qw(wrk p) );

###def_greek_letters
    %greek_letters=(
        "α" => "alpha" ,
        "β" => "beta" ,
        "γ" => "gamma" ,
        "δ" => "delta" ,
        "ε" => "epsilon",
        "ζ" => "zeta",
        "η" => "eta",
        "θ" => "theta",
        "ι" => "iota",
        "κ" => "kappa",
        "ν" => "nu",
        "π" => "pi",
        "ρ" => "rho",
        "σ" => "sigma",
        "τ" => "tau",
        "χ" => "hi",
        "ω" => "omega",
        "λ" => "lambda",
        "ξ" => "xi",
        "φ" => "varphi",
        "ψ" => "psi",
        "μ" => "mu",
        "Α" => "Alpha" ,
        "Β" => "Beta" ,
        "Γ" => "Gamma" ,
        "Δ" => "Delta" ,
        "Ε" => "Epsilon",
        "Ζ" => "Zeta",
        "Η" => "Eta",
        "Θ" => "Theta",
        "Ι" => "Iota",
        "Κ" => "Kappa",
        "Ν" => "Nu",
        "Π" => "Pi",
        "Ρ" => "Rho",
        "Σ" => "Sigma",
        "Τ" => "Tau",
        "Χ" => "Hi",
        "Ω" => "Omega",
        "Λ" => "Lambda",
        "Ξ" => "Xi",
        "Φ" => "Varphi",
        "Ψ" => "Psi",
        "Μ" => "Mu",
    );

###def_subsyms
    %subsyms=(
            "×" => "\\times ",
            "≡" => "\\equiv ",
            "±" => "\\pm ",
	        "–" => "-",
            "−" => "-",
    );

}

&init_vars();

1;
