
package OP::PaperConf;

use strict;
use warnings;

use feature qw(switch);

use File::Slurp qw(
  read_file
);

use File::Spec::Functions qw(catfile rel2abs curdir );
use Term::ANSIColor;
use Data::Dumper;
use File::Basename qw(dirname basename);

use OP::TEX::PNC qw( :vars :funcs );
use OP::Base qw(
  %DIRS
  readhash
  readarr
  _hash_add
  op_write_file
  uniq
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
  $NICE_FILE
  $TEXNICE_OPTS
);
###export_vars_hash
my @ex_vars_hash = qw(
  %greek_letters
  %SUBSYMS
  %ENABLE
  %RE
  %FILES
  %COLORS
  %seclabels
  %SECORDER_CMDS
);
###export_vars_array
my @ex_vars_array = qw(
  @SECORDER
  @NICE_ISECS_ONLY
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
          conf_psay
          conf_pwarn
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
our %SECORDER_CMDS;
our %VERB;
our %FILES;
our %COLORS;
our %ENABLE;

our $FTEX;
our $FLINE;

our @NICE_ISECS_ONLY;
our $NICE_FILE;

our $TEXNICE_OPTS;

sub _nice_join_words;
sub _nice_sub_words;
sub _nice_remove_hyphens;
###subs
sub _FTEX_apply_re;
sub new;
sub read_SUBSYMS;
sub update_config;

sub Fcat;
sub init_vars;
sub main;
sub process_perltex;
sub conf_psay;
sub psay;
sub pwarn;
sub readdat;
sub tex_nice_base;
sub catroot;
sub globroot;

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

sub conf_pwarn {
    my $text = shift;

    my $pref = 'Config::' . $bkey;

    my $evs = "print color '" . $COLORS{'conf_warn'} . "';";
    eval("$evs");
    die $@ if $@;

    print $pref . "> $text\n";
    print color 'reset';

}

sub conf_psay {
    my $text = shift;

    my $pref = 'Config::' . $bkey;

    my $evs = "print color '" . $COLORS{'conf_say'} . "';";
    eval("$evs");
    die $@ if $@;

    print $pref . "> $text\n";
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
    my $opts = shift // {};

    psay("Running tex_nice_base() for key $bkey");
    psay( "Current directory is " . rel2abs( curdir() ) );


###loop_secorder
    foreach my $sec (@SECORDER) {
        my $file = "p.$bkey.sec.$sec.i.tex";
    }

    psay( ' (@$pfiles)       '  . " Number of paper files to be processed: " . scalar(@$pfiles) );
    psay( ' (keys %SUBSYMS) '   . " Number of substitution symbols : " . scalar(keys %SUBSYMS) );

###loop_pfiles
    foreach my $file (@$pfiles) {
        next unless -e $file;

        $FTEX=read_file $file;

        _nice_join_words;
        _nice_sub_words;
        _nice_remove_hyphens;

        my $bfile = basename($file);

        my $isec = '';

        if ( $file =~ /\.sec\.(\w+)\.i\.tex$/g ) {
            $isec = $1;
        }

        if ($isec) {
            psay("Processing section: $isec");
        }
        else {
            psay("Processing file: $bfile");
        }

        my @lines = read_file $file;

        my %lineflags;
        foreach my $k (qw(in_verbatim)) {
            $lineflags{$k} = 0;
        }

        my $n_linesubs=0;
        my $nsubs=0;

        foreach (@lines) {
            chomp;

            $FLINE=$_;

            s///g;
            s///g;
            s///g;

            if (/^\s*\\begin{verbatim}/) {
                $lineflags{in_verbatim} = 1;
            }
            elsif (/^\s*\\end{verbatim}/) {
                $lineflags{in_verbatim} = 0;
            }

            next if $lineflags{in_verbatim};

            if($ENABLE{sub_greek_letters}){
	            foreach my $lett ( keys %greek_letters ) {
	                my $sym = $greek_letters{$lett};
	                $nsubs++ if(s/$lett/\\$sym/g);
	            }
            }

            my $i = 1;
            foreach my $sec (@SECORDER) {
                $nsubs++ if s/refsec\{$i\}/refsec{$sec}/g;
                $i++;
            }

            if ($isec) {

                ### verb substitutions
                my $verbslist = $VERB{$isec} // '';

                my @verbs = split( ' ', $verbslist );

                foreach my $v (@verbs) {
                    s/\\$v\b/\\verb|\\$v|/g;

                    s/\\verb|\\verb|\\$v||/\\verb|\\$v|/g;
                }
            }

            foreach my $w ( keys %SUBSYMS ) {
                my $sym = $SUBSYMS{$w};
                $nsubs++ if s/$w/$sym/g;
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

            $nsubs++ if s/[,]{2,}//g;

            unless ( grep { /^$bkey$/ } qw( GoossensLATEXWEB ) ) {
                $nsubs++ if s/"(?<words>[\w\s,\-]+)"/``$+{words}''/g;
            }

            s/^(?<tagid>%%page)\s+(?<pagenum>.+)$/$+{tagid} page_$+{pagenum}/g;
s/^(?<tagid>%%page)\s+(?<pagetrash>[page_]*(?<pnum>\d+))\s*$/$+{tagid} page_$+{pnum}/g;
            s/page_page/page/g;

            s/^(?<tagid>%%equation)\s+(?<eqnum>.+)/$+{tagid} eq_$+{eqnum}/g;
            s/eq_eq_eq/eq/g;
            s/eq_eq/eq/g;

            s/^(?<tagid>%%figure)\s+(?<fignum>.+)/$+{tagid} fig_$+{fignum}/g;
            s/fig_fig/fig/g;

            next if /^(?<tagid>%%section)\s+(sec|ipar|isec|isubsec|isubsubsec)_/g;

            s/^(?<tagid>%%section)\s+(?<secname>.*)/$+{tagid} sec_$+{secname}/g;
s/^(?<tagid>%%section)\s+(?<sectrash>[sec_]*(?<sname>\w+))$/$+{tagid} sec_$+{sname}/g;
            
            $n_linesubs++ unless ( $FLINE eq "$_");

        }

        psay("Number of line substitutions:  " . $n_linesubs );
        psay("Total number of substitutions:  " . $nsubs );
        op_write_file( $file, join( "\n", @lines ) . "\n" );
    }

    psay("Done: tex_nice_base(). ");

}

sub readdat {

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

sub Fcat  {
    my @names = @_;

    return catfile( $texroot, @names );
}

sub read_seclabels  {

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

    my @subsymfiles = ();

    push( @subsymfiles,
        catfile( $DIRS{PERLMOD}, qw( mods OP-PaperConf PaperConf_subsyms ) )
          . '.i.dat' );

    push( @subsymfiles, catfile( $texroot, 'p.' . $bkey . '.subsyms.i.dat' ) );

    foreach my $datfile (@subsymfiles) {
        next unless ( -e $datfile );

        my $ss = {};

        $ss = readhash( $datfile, { sep => '__' } );

        if ( keys(%$ss) ) {
            $ss = _hash_add( \%SUBSYMS, $ss );
            %SUBSYMS = %$ss;
        }

    }

}

sub read_VERB  {
    my @lines;

    %VERB = ();

    if ( -e $FILES{verb} ) {

        &psay("reading verb.i.dat file for key $bkey");

        %VERB = readhash( $FILES{verb}, { sep => " " } );

    }
    else {
        &pwarn( "verb.i.dat file not found: " . $FILES{secorder} );
    }
}

sub read_SECORDER  {

    my @lines;

    if ( -e $FILES{secorder} ) {

        &psay("reading secorder.i.dat file for key $bkey");

        @lines = read_file $FILES{secorder};

        my ( $sec, @cmds );

        foreach my $line (@lines) {
            chomp($line);

            given ($line) {
                when (/^(?<sec>\w+)/) {
                    my $sec = $+{sec};

                    push( @SECORDER,                 $sec );
                    push( @{ $SECORDER_CMDS{$sec} }, @cmds );
                    @cmds = ();
                }
                when (/^\s*#_/) {
                    $line =~ s/^#_//g;
                    push( @cmds, $line );
                }
                default {
                }
            }

        }

    }
    else {
        &pwarn( "secorder.i.dat file not found: " . $FILES{secorder} );
    }

}

sub init_RE {

    %RE = (
        papereq    => qr/(\\begin\{paper(eq|align)\})/,
        labeleq    => qr/\\labeleq\{([\w\d]+)\}/,
        alignbegin => qr/\\(?<begin>begin)\{align\}/,
        alignend   => qr/\\(?<end>end)\{align\}/,
    );

}

sub catroot {

    return catfile( $texroot, @_ );
}

sub globroot {
    my $pat = shift;

    return glob( catroot($pat) );
}

sub _isec_full_path {
    my $isec=shift;

    return catroot("p.$bkey.sec.$isec.i.tex");
}

sub init_options {

    foreach my $opt (qw( sub_greek_letters)) {
        $ENABLE{$opt}=1;
    }

    foreach my $id (qw( options )) {
        my $f=catroot("p.$bkey.texnice_$id.i.dat");
        next unless -e $f;

        my $lopts=readhash($f);

        while(my($k,$v)=each %{$lopts}){
            given($k){
                when('disable') { 
                    foreach my $opt (split(" ",$v)) {
                        $ENABLE{$opt}=0;
                    }
                }
                default { }
            }
        }
    }
    my @enabled=map { $ENABLE{$_} ? $_ : () } keys %ENABLE;
    my @disabled=map { $ENABLE{$_} ? () : $_ } keys %ENABLE;

    psay(" Enabled: " , join(' ',@enabled)) if @enabled;
    psay(" Disabled: " , join(' ',@enabled)) if @disabled;
    
}

sub init_pfiles {

    &psay("Initializing \$pfiles...");

###init_pfiles
    # Base paper file
    push( @$pfiles, catroot("p.$bkey.tex") );
    push( @$pfiles, globroot("p.$bkey.sec.*.i.tex") );
    push( @$pfiles, globroot("p.$bkey.fig.*.tex") );

    foreach my $piece ( @{ $config->{include_tex_parts} } ) {
        push( @$pfiles, catroot("p.$bkey.$piece.tex") );
    }

    foreach my $piece (qw( abs not )) {
        push( @$pfiles, catroot("p.$bkey.$piece.tex") );
    }

    my $reset_pfiles=0;

    # if any of the following files contains non-zero entries,
    #   @$pfiles array is reset to zero
    foreach my $id (qw( files isecs)) {
        my $f=catroot("p.$bkey.texnice_$id.i.dat");
        next unless -e $f;

        my @a=readarr($f);

        if(@a){
            unless($reset_pfiles){
                $reset_pfiles=1;
                @$pfiles=();
                psay("$f is non-zero, thus cleared \@\$pfiles.");
            }

            given($id){
                when("files") { 
                    push(@$pfiles,map { _isec_full_path($_); } @a);
                }
                when("isecs") { 
                    push(@$pfiles,map { _isec_full_path($_); } @a);
                }
                default { }
            }
        }
    }

    if ( defined $TEXNICE_OPTS ) {
        foreach my $opt ( split( ',', $TEXNICE_OPTS ) ) {
            given ($opt) {

                # only the currently loaded buffer
                when (/^CurrentFile/) {
                    if ($NICE_FILE) {
                        $pfiles = [$NICE_FILE];
                    }
                }

                # only the selected section files (*.sec.*.i.tex)
                when ('OnlySecs') {

                    # include only desired sections
                    if (@NICE_ISECS_ONLY) {
                        @$pfiles = map { "p.$bkey.sec." . $_ . ".i.tex" }
                          @NICE_ISECS_ONLY;
                    }
                }
                default {
                }
            }
        }
    }

    #foreach my $piece (qw( djvu txt )) {
    #push( @$pfiles, "p.$bkey.$piece.tex" );
    #}

    @$pfiles=sort(uniq(@$pfiles));

}

sub _FTEX_apply_re {
    my $re=shift;

    my @evs;
    
    push(@evs,'$FTEX =~ ' . $re );
    
    eval(join(";\n",@evs));
    die $@ if $@;

}

sub _nice_join_words {

    # Files which contain disjoint words
    my @djwfiles = ();

    push( @djwfiles, catroot("tex_nice.djw.i.dat") );
    push( @djwfiles, catroot("p.$bkey.djw.i.dat") );

    psay("Joining words...");

    foreach my $f (@djwfiles) {
        next unless ( -e "$f" );

        my $h = readhash($f);

        while ( my ( $k, $v ) = each %{$h} ) {
            my $re = 's/(\W+)' . $k . '\s+' . $v . '(\W+)/$1' . "$k$v" . '$2/g' ;
            _FTEX_apply_re($re);
        }
    }
}

# }}}
# _nice_sub_words()   - words to substitute {{{

=head3 _nice_sub_words()

=cut

sub _nice_sub_words {
      my $self = shift;

      # Files which contain words to be substituted
      my @swfiles = ();

      push( @swfiles, "tex_nice.sw.i.dat" );
      push( @swfiles, "p.$bkey.sw.i.dat" );

      psay("Substituting words...");

      foreach my $swf (@swfiles) {
          next unless ( -e $swf );

          my $sw_h = readhash("$swf");

          while ( my ( $k, $v ) = each %{$sw_h} ) {
              my $re = 's/(\s+)' . $k . '(\s+)/$1' . $v . '$2/g' ;
              _FTEX_apply_re($re);
          }
      }

}

#}}}
# _nice_remove_hyphens() - remove end-line hyphens {{{

=head3 _nice_remove_hyphens()

Remove end-line hyphens

=cut 

sub _nice_remove_hyphens {
      my $self = shift;

      psay("Removing end-line hyphens...");

      _FTEX_apply_re('s/(\w*)\-\s*\n(\w*)/\r$1$2/g');
      _FTEX_apply_re('s/\b(\w+)\-\s+(\w+)\b/\r$1$2/g');

}

sub init_FILES {

      $FILES{secorder} = &Fcat( 'p.' . $bkey . '.secorder.i.dat' );
      $FILES{verb}     = &Fcat( 'p.' . $bkey . '.verb.i.dat' );

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

sub init_vars {

      %COLORS = (
          "say"  => 'blue',
          "warn" => 'bold red',
          "conf_say"  => 'green',
          "conf_warn"  => 'red',
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
      &init_options();
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
