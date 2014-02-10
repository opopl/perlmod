package OP::ConvBib;

use strict;
use warnings;

use FindBin qw($Bin $Script);
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use Data::Dumper;
use OP::Base qw(uniq);

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT = qw();

###export_vars_scalar
my @ex_vars_scalar = qw(
  $BIBINFO
  $PROJ
  $NKINFO
);
###export_vars_hash
my @ex_vars_hash = qw(
  %ONKEYS
  %DONKEYS
  %NC
  %FILES
);
###export_vars_array
my @ex_vars_array = qw(
  @NOT_OK_OLD
  @NKEYS
  @OLDKEYS
  @PFILES
  @NKOK
  @OOK
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [
        qw(
          expandnc
          init
          print_INFO
          process_PFILES
          process_pdata
          process_BIB
          read_NC
          write_NEWBIB
          )
    ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

our @EXPORT  = qw( );
our $VERSION = '0.01';

###our
our @NOT_OK_OLD;
our @NKEYS;
our @OLDKEYS;
our @PFILES;
our @NKOK;
our @OOK;
###our_hash
our %ONKEYS;
our %FILES;
our %DONKEYS;
our %NC;
###our_scalar
our $PROJ;
our $BIBINFO;
our $NKINFO;

sub expandnc;
sub init;
sub process_PFILES;
sub process_BIB;
sub process_pdata;
sub read_NC;
sub print_INFO;
sub write_NEWBIB;

sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );
    return $self;
}

sub print_INFO {

    open( I, ">$Bin/dm.bib.pl" ) || die "$!";

    #print I Dumper( \%ONKEYS );
    print I Dumper($NKINFO);
    print I Dumper( \%ONKEYS );
    close(I);

    #print Dumper( \%NC );
    #print Dumper( $BIBINFO->{eva} );
    #print Dumper( $BIBINFO->{toke} );
}

sub process_PFILES {

    
    foreach my $pfile (@PFILES) {
        next if ( $pfile =~ /\.bib\.tex$/ );
        print "Replacing cite occurences in file: $pfile \n";

        my @lines = read_file $pfile;

        foreach (@lines) {
            chomp;

            m/^(?<before>.*\\(|online)cite\{)(?<citestr>[^{}]*)(?<after>\}.*)$/g
              && do {
                my @mokeys = split( ',', $+{citestr} );
                my $citestr = $+{citestr};

                for my $okey (@mokeys) {
                    next if ( grep { /^$okey$/ } @NOT_OK_OLD );

                    my $nkeys;
                    if ( grep { /^$okey$/ } keys %DONKEYS ) {
                        $nkeys = join( ',', @{ $DONKEYS{$okey} } );

                        if ($nkeys) {
                            $citestr =~ s/$okey/$nkeys/g;
                        }
                    }
                }
                $_ = $+{before} . $citestr . $+{after};
              };
        }
        write_file( $pfile, join( "\n", @lines ) . "\n" );
    }

}

sub write_NEWBIB {
    print "Writing new BibTeX file: " . $FILES{NEWBIB} . "\n";

    open( F, ">$FILES{NEWBIB}" ) || die $!;

    foreach my $okey (@OLDKEYS) {
        next if ( grep { /^$okey$/ } @NOT_OK_OLD );

        my $refs = $BIBINFO->{$okey};

        print "Printing old key: $okey\n";

        foreach my $k ( keys %$refs ) {
            next if ( $k eq "pdata" );

            my $nkey    = $k;
            my $ref     = $refs->{$k};
            my @authors = @{ $ref->{authors} };
            my @L;

            push( @L, "\n" x 3 );
            push( @L, '@article{' . $nkey . ',' );
            push( @L, ' author={' . join( ' and ', @authors ) . '},' );
            for my $id (qw( journal volume pages year )) {
                my $val = $ref->{$id} // '';
                push( @L, ' ' . $id . '={' . $val . '},' );
            }
            push( @L, '}' );

            print F join( "\n", @L ) . "\n";
        }
    }

    close(F);

}

sub read_NC {

    print "Processing file with new commands...\n";

    my @lines = read_file $FILES{NC};

    foreach (@lines) {
        chomp;
        my $line = $_;

        m/^\s*\\nc\{\\(?<name>.*)\}(|\[(?<nargs>\d+)\])\{(?<def>.*)\}/
          && do {
            my $nargs = 0;
            $nargs = $+{nargs} if $+{nargs};

            $NC{ $+{name} } = {
                def   => $+{def},
                nargs => $nargs,
            };
          };
    }
}

sub expandchars {
    my $text = shift;

    for ($text) {
        s/\\('|\^|){(?<char>\w+)}/$+{char}/g;
        s/\\"(?<char>\w+)/$+{char}/g;
    }

    $text;
}

sub expandnc {
    my $text = shift;

    for ($text) {
        /\\(?<cmd>\w+)\b/ && do {
            my $cmd = $+{cmd};

            if ( grep { /^$cmd$/ } keys %NC ) {
                my $ncmd = $NC{$cmd}->{def};
                $text =~ s/\\$cmd/$ncmd/g;
            }
            next;
        };
    }

    $text;
}

sub process_pdata {
    my $pdata = shift;

    my @paplines = split( ';', $pdata );

    my $refs = [];
    my @entries;
    my @order = ( 'a' .. 'z' );
    my @AUTHORS;

    my $i = 0;

    foreach my $papline (@paplines) {
        my $lett = shift @order;
        my $ref  = {};

        @entries = split( /,/, $papline );

        my ( $journal, $volume, $pages, $year, @authors );

        # Pages (Year)
        my $py = pop @entries;

        open( F, ">>$Bin/ass" );
        print F "$py\n";
        for ($py) {
            /^[\\\s]*(?<pages>\w+(|[()R]*))[\\\s]*\(\s*(?<year>\d+)\s*\)[^()]*$/
              && do {
                $year  = $+{year};
                $pages = $+{pages};
                print F "--------match---------\n";
                next;
              };
        }
        close(F);

        #my @pylines = split( /[()]+/, $py );

        # Journal Volume
        my $jv = pop @entries // '';

        if ($jv) {
            my @jvlines = split( ' ', $jv );

            $volume = pop @jvlines;
            $journal = join( ' ', @jvlines );
        }

        # Authors
        #   remove wh from both ends
        @entries = map { s/^\s*//g; s/\s*$//g; s/^and\s*//g; $_ } @entries;
        for my $e (@entries) {
            my @F = split( 'and', $e );
            push( @authors, @F );
        }
        for (@authors) {
            s/^(\s*|[\\\s]*\s+)//g;
            s/(\s*|[\\\s]*\s+)$//g;
            $_ = expandnc($_);
            $_ = expandchars($_);

            s/[{}]*$//g;
            s/^[{}]*//g;
        }

        @authors = @AUTHORS unless (@authors);

        push( @AUTHORS, @authors ) unless $i;

        @{ $ref->{authors} } = @authors;

        # First author will determine the new pkey
        #   Full name as it is written
        my $fa = shift @authors // '';

        #   Surname
        my $surname;
        if ($fa) {
            my @srn = split( ' ', $fa );
            $surname = pop @srn;

            $ref->{fa}->{fullname} = $fa;
            $ref->{fa}->{surname}  = $surname;
        }

        # short year
        $ref->{newkey} = '';
        if ( defined $year ) {
            my $sy = substr( $year, 2 ) if ( length($year) == 4 );
            if ( ( defined $sy ) && ( defined $surname ) ) {
                $ref->{newkey} = $surname . $sy . $lett;
            }
        }

        foreach my $id (qw(journal volume pages year )) {
            my $evs = '$ref->{' . $id . '}=$' . $id . ';';
            eval "$evs";
            die $@ if $@;
        }

        while ( my ( $k, $v ) = each %{$ref} ) {
            next unless defined $v;

            unless ( ref $v ) {
                $v =~ s/^\s*//g;
                $v =~ s/\s*$//g;

                $v =~ s/\{\s*\\bf\s*$//g;
                $v =~ s/\\textbf\{\s*//g;
                $v =~ s/\}s*//g;

                $v =~ s/^(\s*|[\\\s]*\s+)//g;
                $v =~ s/(\s*|[\\\s]*\s+)$//g;

                $v =~ s/\\*\s*$//g;

                $v =~ s/[{}]*$//g;
                $v =~ s/^[{}]*//g;

                $ref->{$k} = $v;

            }
            elsif ( ref $v eq "ARRAY" ) {
            }
            elsif ( ref $v eq "HASH" ) {
            }
        }

        #$ref->{journal} =~ s/\s+/~/g if defined $ref->{journal};
        push( @$refs, $ref );
        push( @NKEYS, $ref->{newkey} ) if $ref->{newkey};

        $i++;
    }    # end loop over paplines

    my @nkeys;
    for (@$refs) { push( @nkeys, $_->{newkey} ); }

    my @authy = map { m/^([a-zA-Z]+[0-9]+)/ ? $1 : () } @nkeys;
    @authy = &uniq(@authy);

    if ( ( scalar @authy > 1 ) || ( scalar @nkeys == 1 ) ) {
        for my $ref (@$refs) {
            $ref->{newkey} =~ s/[a-z]$//g;
        }
    }

    $refs;

}

sub process_BIB {

    unless ( -e $FILES{BIB} ) { die "Input bib.tex file was not found"; }

    print "Processing input bib.tex file...\n";

    my @lines = read_file $FILES{BIB};

###loop_bib
    open( PIPE, "|less" );
    foreach (@lines) {
        chomp;
        my $line = $_;

        my $ref;
        my $expanded;

        my $start = '';
        my $end   = '';

###match_journ
m/^(?<start>.*)\\(?<jtype>journ|journELS){(?<journal>[\w\s\\]*)}{(?<volume>[\s\w]*)}{(?<pages>[\s\w()]*)}{(?<year>[\w\s]*)}(?<end>.*)$/g
          && do {
            foreach my $k (qw(journal volume pages year)) {
                my $v = '';

                if ( defined $+{$k} ) {
                    $v = $+{$k};

                    $v =~ s/^\s*//g;
                    $v =~ s/\s*$//g;

                    $ref->{$k} = $v;
                }
            }

            for ( $+{jtype} ) {
                /^journ$/ && do {
                    $expanded =
                        $ref->{journal}
                      . '\ \textbf{'
                      . $ref->{volume} . '},\ ' . ' '
                      . $ref->{pages} . '\ ('
                      . $ref->{year} . ')';
                    next;
                };
                /^journELS$/ && do {

                    #\nc{\journELS}[4]{#1\ {#2}\ (#4) #3}
                    next;
                };

            }
            $start = $+{start};
            $end   = $+{end};
          };

        if ( $start || $end || $expanded ) {
            $_ = $start . $expanded . $end;

        }

        print PIPE "$_\n";

###match_bibitem
        /^\s*\\bibitem\{(?<pkey>[\w\.]*)\}(?<pdata>.*)$/g && do {
            my $oldkey = $+{pkey};
            my $pdata  = $+{pdata};

            $BIBINFO->{$oldkey} = { pdata => $pdata };

            my $refs = process_pdata("$pdata");

            for my $papref (@$refs) {
                my $nkey = $papref->{newkey};

                while ( my ( $k, $v ) = each %{$papref} ) {
                    $BIBINFO->{$oldkey}->{$nkey}->{$k} = $v;
                }
                if ($nkey) {
                    push( @{ $ONKEYS{$oldkey} }, $nkey );
                    push( @OLDKEYS,              $oldkey );
                    $NKINFO->{$nkey} = $papref;
                }
                $papref->{oldkey} = $oldkey;
            }

            next;
        };
    }

    @OLDKEYS = &uniq(@OLDKEYS);

    close(PIPE);

}

sub init {

    print "Initializing variables...\n";

    $FILES{BIB}    = catfile( $Bin, $PROJ . '.bib.tex' );
    $FILES{NC}     = catfile( $Bin, $PROJ . '.nc.tex' );
    $FILES{NEWBIB} = catfile( $Bin, $PROJ . '.refs.bib' );

    @PFILES = glob("$PROJ*.tex");

}

1;

