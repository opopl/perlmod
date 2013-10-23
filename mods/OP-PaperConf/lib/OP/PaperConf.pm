package OP::PaperConf;

use strict;
use warnings;

use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);
use File::Spec::Functions qw(catfile rel2abs curdir );
use Term::ANSIColor;
use Data::Dumper;

use OP::TEX::PNC qw( :vars :funcs );
use OP::Base qw(
  %DIRS
  readhash
  _hash_add
);

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

#Give a hoot don't pollute, do not export more than needed by default
@EXPORT = qw();

###export_vars_scalar
my @ex_vars_scalar = qw(
  $bkey
  $config
  $eqs_h
  $eqs_h_order
  $figs_h
  $figs_h_order
  $tabs_h
  $tabs_h_order
  $pfiles
  $refs_h
  $refs_h_order
  $texroot
  $viewfiles
);
###export_vars_hash
my @ex_vars_hash = qw(
  %greek_letters
  %SUBSYMS
  %RE
  %FILES
  %COLORS
  %seclabels
);
###export_vars_array
my @ex_vars_array = qw(
  @SECORDER
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [
        qw(
          init_vars
          readdat
          main
          process_perltex
          read_SECORDER
          read_seclabels
          update_config
          Fcat
          psay
          pwarn
          tex_nice_base
          )
    ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );
our $VERSION = '0.01';

###our
our ( $refs_h, $eqs_h, $figs_h, $tabs_h, $bkey, $config, $texroot );
our ( $refs_h_order, $eqs_h_order, $figs_h_order, $tabs_h_order );
our ( %greek_letters, %SUBSYMS, %RE );

our $pfiles;
our $viewfiles;
our %seclabels;
our @SECORDER;
our %VERB;
our %FILES;
our %COLORS;

sub readdat;
sub process_perltex;
sub init_vars;
sub Fcat;
sub main;

sub new {

    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );

    return $self;
}

sub pwarn {
    my $text = shift;

    my $evs = "print color '" . $COLORS{'warn'} . "';";
    eval("$evs");
    die $@ if $@;

    print __PACKAGE__ . "> $text\n";
    print color 'reset';

}

sub psay {
    my $text = shift;

    my $evs = "print color '" . $COLORS{'say'} . "';";
    eval("$evs");
    die $@ if $@;

    print __PACKAGE__ . "> $text\n";
    print color 'reset';

}

=head3 tex_nice_base

=cut

sub tex_nice_base {

    &psay("Running tex_nice_base() for key $bkey");
    &psay("Current directory is " . rel2abs(curdir()) );

###loop_secorder
    foreach my $sec (@SECORDER) {
        my $file = "p.$bkey.sec.$sec.i.tex";
    }

###loop_pfiles
    foreach my $file (@$pfiles) {
        next unless -e $file;

        my $isec='';

        if($file  =~ /\.sec\.(\w+)\.i\.tex$/g){
          $isec=$1;
        }

        if ($isec){
          &psay("Processing section: $isec");
        }else{
          &psay("Processing file: $file");
        }

        my @lines = read_file $file;

        foreach (@lines) {
            chomp;

            s///g;
            s///g;
            s///g;

            foreach my $lett ( keys %greek_letters ) {
                my $sym = $greek_letters{$lett};
                s/$lett/\\$sym/g;
            }

            my $i = 1;
            foreach my $sec (@SECORDER) {
                s/refsec\{$i\}/refsec{$sec}/g;
                $i++;
            }

            if ($isec){
	            my $verbslist=$VERB{$isec} // '';

              my @verbs=split(' ',$verbslist);

	            foreach my $v (@verbs) {
	              s/\\$v\b/\\verb|\\$v|/g;
	            }
            }

##TODO process_perltex
            #$_=process_perltex($_);

            foreach my $w ( keys %SUBSYMS ) {
                my $sym = $SUBSYMS{$w};
                s/$w/$sym/g;
            }

            /(?<before>.*)\\cite\{(?<cites>[\w\s,]+)\}(?<after>.*)/ && do {
                my @keys = split( ',', $+{cites} );
                my $newstr = '';
                foreach my $k (@keys) {
                    $k = '\cite{' . $k . '}';
                }
                $newstr .= join( ',', @keys );
                $_ = $+{before} . $newstr . $+{after};
            };

            s/[,]{2,}//g;

            unless ( grep { /^$bkey$/ } qw( GoossensLATEXWEB ) ) {
                s/"(?<words>[\w\s,\-]+)"/``$+{words}''/g;
            }

            s/^(?<tagid>%%page)\s+(?<pagenum>.+)$/$+{tagid} page_$+{pagenum}/g;
s/^(?<tagid>%%page)\s+(?<pagetrash>[page_]*(?<pnum>\d+))\s*$/$+{tagid} page_$+{pnum}/g;
            s/page_page/page/g;

            s/^(?<tagid>%%equation)\s+(?<eqnum>.+)/$+{tagid} eq_$+{eqnum}/g;
            s/eq_eq_eq/eq/g;
            s/eq_eq/eq/g;

            s/^(?<tagid>%%figure)\s+(?<fignum>.+)/$+{tagid} fig_$+{fignum}/g;
            s/fig_fig/fig/g;

            s/^(?<tagid>%%section)\s+(?<secname>.*)/$+{tagid} sec_$+{secname}/g;
s/^(?<tagid>%%section)\s+(?<sectrash>[sec_]*(?<sname>\w+))$/$+{tagid} sec_$+{sname}/g;

        }
        write_file( $file, join( "\n", @lines ) . "\n" );
    }

}

sub readdat() {

    foreach my $id (qw( refs eqs figs tabs )) {
        my $fdat = catfile( $texroot, "p." . $bkey . ".$id.i.dat" );
        my ( $H, $HORDER );

        $HORDER = [];

        # dat-file contents will have priority over manually typed contents for
        #   *_h hashes ( $refs_h, $eqs_h etc. )
        if ( -e $fdat ) {
            my @lines = read_file $fdat;

            foreach (@lines) {
                chomp;
                next if /^\s*#/ || /^\s*$/;

                my @F   = split;
                my $num = shift @F;

                push( @$HORDER, $num );

                unless ( defined $H->{$num} ) {
                    $H->{$num} = join( " ", @F );
                }
                else {
                    $H->{$num} .= " " . join( " ", @F );
                }
            }

            my $evs = '';

            $evs .= '$' . $id . '_h=$H;' . "\n";
            $evs .= '$' . $id . '_h_order=$HORDER;' . "\n";

            eval("$evs");
            die $@ if $@;

        }
        else {
            my $evs = '';

            $evs .= '$' . $id . '_h  = { 1 => "" };' . "\n";
            $evs .= '$' . $id . '_h_order  = ();' . "\n";

            eval("$evs");
            die $@ if $@;

        }
    }

}

sub Fcat () {
    my @names = @_;

    return catfile( $texroot, @names );
}

sub read_seclabels () {

    my $i = 1;

    for (@SECORDER) {
        $seclabels{$i} = $_;
        $i++;
    }
}

sub read_SUBSYMS {

###def_SUBSYMS
    %SUBSYMS = (
        "×"  => "\\times ",
        "≡" => "\\equiv ",
        "±"  => "\\pm ",
        "–" => "-",
        "−" => "-",
        "ô"  => "o",
    );

    my $datfile =

    my @subsymfiles=();

    push(@subsymfiles,  catfile( $DIRS{PERLMOD}, qw( mods OP-PaperConf PaperConf_subsyms ) )
      . '.i.dat');

    push(@subsymfiles,catfile($texroot,'p.' . $bkey . '.subsyms.i.dat'));

    foreach my $datfile (@subsymfiles) {
	    next unless ( -e $datfile );
	
	    my $ss={};
	
	    $ss = readhash( $datfile, { sep => '__' } );
	
	    if ( keys(%$ss) ) {
	        $ss= _hash_add( \%SUBSYMS, $ss );
	        %SUBSYMS = %$ss;
	    }
	
    }

}

sub read_VERB () {
    my @lines;

    %VERB=();

    if ( -e $FILES{verb} ) {

        &psay("reading verb.i.dat file for key $bkey");

        %VERB = readhash($FILES{verb},{ sep  => " "});

    }
    else {
        &pwarn( "verb.i.dat file not found: " . $FILES{secorder} );
    }
}

sub read_SECORDER () {

    my @lines;

    if ( -e $FILES{secorder} ) {

        &psay("reading secorder.i.dat file for key $bkey");

        @lines = read_file $FILES{secorder};
        @SECORDER = map { chomp; /^\s*#/ ? () : $_ } @lines;

    }
    else {
        &pwarn( "secorder.i.dat file not found: " . $FILES{secorder} );
    }

}

sub init_RE() {

    %RE = (
        papereq    => qr/(\\begin\{paper(eq|align)\})/,
        labeleq    => qr/\\labeleq\{([\w\d]+)\}/,
        alignbegin => qr/\\(?<begin>begin)\{align\}/,
        alignend   => qr/\\(?<end>end)\{align\}/,
    );

}

sub init_pfiles() {

###init_pfiles
    # Base paper file
    push( @$pfiles, "p.$bkey.tex" );
    push( @$pfiles, glob("p.$bkey.sec.*.i.tex") );
    push( @$pfiles, glob("p.$bkey.fig.*.tex") );

    foreach my $piece ( @{ $config->{include_tex_parts} } ) {
        push( @$pfiles, "p.$bkey.$piece.tex" );
    }

    foreach my $piece (qw( abs not )) {
        push( @$pfiles, "p.$bkey.$piece.tex" );
    }

    #foreach my $piece (qw( djvu txt )) {
        #push( @$pfiles, "p.$bkey.$piece.tex" );
    #}

}

sub init_FILES() {

    $FILES{secorder} = &Fcat( 'p.' . $bkey . '.secorder.i.dat' );
    $FILES{verb} = &Fcat( 'p.' . $bkey . '.verb.i.dat' );

}

sub update_config {
    my $c = shift;

    my %opts = @_;

    my $mode = $opts{mode} // '';

    while ( my ( $k, $v ) = each %{$c} ) {
        unless ( ref $v ) {

            # replace values only if the new value
            #  is non-zero
            $config->{$k} = $v if $v;
        }
        elsif ( ref $v eq "ARRAY" ) {
            for ($mode) {
                /^append$/ && do {
                    push( @{ $config->{$k} }, @$v );
                    next;
                };
                /^prepend$/ && do {
                    unshift( @{ $config->{$k} }, @$v );
                    next;
                };
                /^reset$/ && do {
                    $config->{$k} = $v;
                    next;
                };
            }
        }
        elsif ( ref $v eq "HASH" ) {
        }
    }
}

sub init_vars() {

    %COLORS = (
        "say"  => 'blue',
        "warn" => 'bold red',
    );

    @PNC = qw(
      ienv
      pbib
    );

    $texroot = $ENV{'PSH_TEXROOT'} // catfile( "$ENV{hm}", qw(wrk p) )
      // catfile( "$ENV{HOME}", qw(wrk p) );

    return 0 unless defined $bkey;

    &init_FILES();
    &init_RE();
    &init_pfiles();

    # fill in @SECORDER
    &read_SECORDER();

    &read_VERB();

    # fill in %seclabels
    &read_seclabels();

    # fill in %SUBSYMS
    &read_SUBSYMS();

###def_config
    $config = {
        include_tex_parts   => [qw( not figs eqs  )],
        include_lists_start => [qw( toc )],
        include_abstract    => 1,
        edit_figs           => 0,
        titpage_width       => 6,
        tex_textwidth       => "6in",
        docstyle            => "report"
    };

###def_viewfiles
    $viewfiles = {
        secs      => [qw( intro )],
        texpieces => [qw( eqs nc figs refs )]
    };

###def_greek_letters
    %greek_letters = (
        "α" => "alpha",
        "β" => "beta",
        "γ" => "gamma",
        "δ" => "delta",
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
        "Α" => "Alpha",
        "Β" => "Beta",
        "Γ" => "Gamma",
        "Δ" => "Delta",
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

}

BEGIN {
    &init_vars();
}

1;
