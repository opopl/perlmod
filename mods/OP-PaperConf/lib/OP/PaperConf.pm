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

###export_vars_scalar
    my @ex_vars_scalar=qw(
              $bkey
              $config
              $eqs_h
              $eqs_h_order
              $figs_h
              $figs_h_order
              $pfiles
              $refs_h
              $refs_h_order
              $texroot
         );
###export_vars_hash
    my @ex_vars_hash=qw(
              %greek_letters
              %subsyms
              %RE
              %FILES
              %seclabels
         );
###export_vars_array
    my @ex_vars_array=qw(
              @secorder
         );

    %EXPORT_TAGS = (
###export_funcs
        'funcs' => [qw( 
            readdat
            read_secorder
            read_seclabels
            Fcat
            tex_nice_base
         )],
        'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
    );

    our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

    our @EXPORT  = qw( );
    our $VERSION = '0.01';

}

###our
our ( $refs_h, $eqs_h, $figs_h, $bkey, $config, $texroot );
our ( $refs_h_order, $eqs_h_order, $figs_h_order);
our (%greek_letters,%subsyms,%RE);
our $pfiles;
our %seclabels;
our @secorder;
our %FILES;

sub readdat;
sub init_vars;
sub Fcat;

sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );
    return $self;
}

sub tex_nice_base () {

###loop_secorder
  foreach my $sec (@secorder) {
        my $file="p.$bkey.sec.$sec.i.tex";
  }

###loop_pfiles
  foreach my $file (@$pfiles) {
	    edit_file_lines {

            foreach my $lett (keys %greek_letters) {
			        my $sym=$greek_letters{$lett};
			        s/$lett/\\$sym/g;
			}

            foreach my $w (keys %subsyms) {
			        my $sym=$subsyms{$w};
			        s/$w/$sym/g;
			}
            s/(?<tagid>%%page)\s+(?<pagenum>.*)$/$+{tagid} page_$+{pagenum}/g;
            s/(?<tagid>%%equation)\s+(?<eqnum>\d+)/$+{tagid} eq_$+{eqnum}/g;
            s/(?<tagid>%%figure)\s+(?<fignum>\d+)/$+{tagid} fig_$+{fignum}/g;
            s/(?<tagid>%%section)\s+(?<secname>.*)/$+{tagid} sec_$+{secname}/g;

        } $file;
  }

}

sub readdat() {

    foreach my $id (qw( refs eqs figs )) {
        my $fdat = catfile( $texroot, "p." . $bkey . ".$id.i.dat" );
        my($H,$HORDER);

        $HORDER=[];

        # dat-file contents will have priority over manually typed contents for
        #   *_h hashes ( $refs_h, $eqs_h etc. )
        if ( -e $fdat ) {
            my @lines = read_file $fdat;

            foreach (@lines) {
                chomp;
                next if /^\s*#/ || /^\s*$/;

                my @F   = split;
                my $num = shift @F;

                push(@$HORDER,$num);

                unless ( defined $H->{$num} ) {
                    $H->{$num} = join( " ", @F );
                }
                else {
                    $H->{$num} .= " " . join( " ", @F );
                }
            }

            my $evs='';

            $evs.= '$' . $id . '_h=$H;' . "\n";
            $evs.= '$' . $id . '_h_order=$HORDER;' . "\n";

            eval ("$evs");
            die $@ if $@;

        }
        else {
            my $evs='';
            
            $evs.='$' . $id . '_h  = { 1 => "" };' . "\n" ; 
            $evs.='$' . $id . '_h_order  = ();' . "\n" ; 

            eval ("$evs");
            die $@ if $@;

        }
    }

}

sub Fcat () {
    my @names=@_;

    return catfile($texroot,@names);
}

sub read_seclabels () {

    my $i=1;

    for(@secorder){
        $seclabels{$i}=$_;
        $i++;
    }
}

sub read_secorder () {

    $FILES{secorder}=&Fcat( 'p.' . $bkey . '.secorder.i.dat' );
    my @lines;

    if (-e $FILES{secorder}){
        @lines=read_file $FILES{secorder};
        @secorder=map { chomp; /^\s*#/ ? () : $_ } @lines;
    }


}

sub init_RE() {

    %RE=(
        papereq  => qr/(\\begin\{paper(eq|align)\})/,
        labeleq  => qr/\\labeleq\{([\w\d]+)\}/,
        alignbegin  => qr/\\(?<begin>begin)\{align\}/,
        alignend    => qr/\\(?<end>end)\{align\}/,
    );

}

sub init_pfiles(){

     # Base paper file
	push(@$pfiles,"p.$bkey.tex");
	push(@$pfiles,glob("p.$bkey.sec.*.i.tex"));
	push(@$pfiles,glob("p.$bkey.fig.*.tex"));

	foreach my $piece (@{$config->{include_tex_parts}}) {
		push(@$pfiles,"p.$bkey.$piece.tex");
	}

}

sub init_vars() {

    return 0 unless defined $bkey;

    &init_RE();
    &init_pfiles();

    $texroot = $ENV{'PSH_TEXROOT'} 
        // catfile( "$ENV{hm}", qw(wrk p) )
        // catfile( "$ENV{HOME}", qw(wrk p) );

    # fill in @secorder
    &read_secorder();

    # fill in %seclabels
    &read_seclabels();

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