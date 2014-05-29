#!/usr/bin/env perl

# pminst -- find modules whose names match this pattern
# tchrist@perl.com

package OP::PERL::PMINST;

use strict;
use warnings;

use Switch;
use Env qw( $hm $PERLMODDIR );

use Data::Dumper;
use Text::Table;
use File::Find qw( find );
use File::Path qw( remove_tree);
use FindBin qw( $Bin $Script );
use Getopt::Long qw(GetOptions);

use OP::PackName;
use OP::Writer::Pod;

use Term::ANSIColor;

no lib '.';

###our
our $PATTERN;
our $INCDIR;
our %MODPATHS;
our %OPTS;
our %RE;
our @EXCLUDEDIRS;
our @SEARCHDIRS;
our $PKN;

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
my @scalar_accessors = qw(
  textcolor
  PATTERN
);

###__ACCESSORS_HASH
my @hash_accessors = qw(
  accessors
  opts
  OPTDESC
  MODPATHS
);

###__ACCESSORS_ARRAY
my @array_accessors = qw(
  MODULES
  SEARCHDIRS
  OPTSTR
);

__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_array_accessors(@array_accessors)->mk_hash_accessors(@hash_accessors);

sub main {
    my $self = shift;

    my $o = shift // {};

    $self->opts($o);

    $self->init;

    $self->getopt if not $self->opts_count;

    $self->process_opts;

    $self->find_module_matches;

    $self->printout;

}

sub printout {
    my $self = shift;

    if ($OPTS{print}) {

        for( $OPTS{print} ) {
            /^names_paths$/ && do {

                my $tb=Text::Table->new('','');

	            foreach my $module (sort($self->MODPATHS_keys)) {
	                my @paths=@{$self->MODPATHS($module)};
	                foreach my $path (@paths) {
	                    chomp($path);
	                    $tb->load([ $module,$path ] );
	                }
	            }

                print $tb;
				next;
            };
            /^names$/ && do {
                foreach my $module (sort($self->MODPATHS_keys)) {
                    print $module . "\n";
                }
				next;
            };
            /^paths$/ && do {
                foreach my $module (sort($self->MODPATHS_keys)) {
	                my @paths=@{$self->MODPATHS($module)};
	                foreach my $path (@paths) {
	                    chomp($path);
                        print $path . "\n";
	                }
	            }
				next;
            };
        }



    }
}

sub new() {
    my ( $class, %ipars ) = @_;
    my $self = bless( {}, ref($class) || $class );

    return $self;

}

sub getopt {
    my $self=shift;
    
    Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

    my(%opt,@optstr,%optdesc);
    
    @optstr=( 
        "p|print=s",
        "s|searchdirs=s",
        "r|remove"
    );
    
    %optdesc=(
        "remove"        => "Remove modules which names match the provided pattern",
        "print"         => "Specify print option",
        "searchdirs"    => "Specify a colon-separated list of directories to be searched over "
            . " (instead of those present in C<\@INC> )",
    );

    $self->OPTSTR(@optstr);
    $self->OPTDESC(%optdesc);

    my %optlong=map { 
        my $s=$_; 
        $s =~ s/=\w+$//g; 
        my @o=split('\|',$s); 
        ( $o[0] => $o[-1] ); 
    } @optstr; 

    unless( @ARGV ){ 
        $self->dhelp;
        exit 0;
    }elsif(@ARGV == 1){
    }else{
        GetOptions(\%opt,@optstr);
    }

    if ($OPTS{remove}){
        $OPTS{print}='';
    }

    while(my($short,$long)=each %optlong){
        $OPTS{$long}=$opt{$long} if defined $opt{$long};
        $OPTS{$long}=$opt{$short} if defined $opt{$short};
    }

    $PATTERN = shift(@ARGV) // '';

    die "Specify perl module pattern!"
        unless $PATTERN;

    $self->PATTERN($PATTERN);

    @SEARCHDIRS=split(':',$OPTS{searchdirs}) if defined $OPTS{searchdirs};

}

sub dhelp {
    my $self=shift;

    my $p=OP::Writer::Pod->new;

    $p->head1('USAGE');
    $p->_pod_line("$Script <options> <perl module pattern>");

    $p->head1('MODULE');
    $p->_pod_line("L<OP::PERL::PMINST>");

    $p->head1('OPTIONS');

    $p->over(4);

    for my $opt ( map { s/=\w+$//g; $_ } $self->OPTSTR ) {
        my @o=split('\|',$opt);
        my $optlong=$o[-1];

        $p->item( join(', ' , map { '--' . $_ } @o ));

        if ($self->OPTDESC_exists("$optlong")){
            $p->_pod_line($self->OPTDESC("$optlong"));
        }

    }
    $p->back;

    $p->head1('EXAMPLES');
    $p->_pod_line(" $Script --print paths");
    $p->_pod_line(" $Script --print names");
    $p->_pod_line(" $Script --print paths_names");

    $p->head1('SCRIPT LOCATION');
    $p->_pod_line("$Bin");
    $p->cut;

    #$p->_print_help;
    $p->_print_man;

}

sub init {
    my $self = shift;

    @EXCLUDEDIRS  = ();
    %MODPATHS     = ();
    $PATTERN     = '';
    %RE          = ();
    $INCDIR      = '';
    $OPTS{match} = '';

    for(@INC){
        next if /^$PERLMODDIR\/mods/;
        next if /^lib/;
        push(@SEARCHDIRS,$_);
    }

    $OPTS{print}='names_paths';
    $OPTS{print}='' if $self->opts_count;

    @SEARCHDIRS = $self->SEARCHDIRS if $self->SEARCHDIRS_count;
    $OPTS{searchmode}='simple';

}
# end: sub init 

sub process_opts {
    my $self = shift;

    return if not $self->opts_count;

    foreach my $k ( $self->opts_keys ) {
        my $v = $self->opts("$k");

        switch($k){
            case("mode") {
                for ($v) {
                    ## list names
                    /^name$/ && do {
                        %OPTS = ();
                        next;
                    };
                    ## list full paths
                    /^fullpath$/ && do {
                        $OPTS{print} = 'names_paths';
                        next;
                    };
                    /^remove$/ && do {
                        $OPTS{remove} = 1;
                        next;
                    };
                }
###PATTERN
            }
            case("PATTERN"){
                $PATTERN = $v;
                $self->PATTERN($PATTERN);
            }
            case("remove"){
                $PATTERN = "^" .  $v . '$';
                $OPTS{remove}=1;
            }
            case("excludedirs"){
                unless(ref $v){
                    @EXCLUDEDIRS=split("\n",$v);

                }elsif(ref $v eq "ARRAY"){
                    @EXCLUDEDIRS=@$v;

                }
            }
            case("searchdirs"){
                unless(ref $v){
                    @SEARCHDIRS=split(':',$v);
                }elsif(ref $v eq "ARRAY"){
                    @SEARCHDIRS=@$v;
                }
            }
            case("searchmode"){
                $OPTS{searchmode}=$v;

                $PKN=OP::PackName->new;
            }
        }
    }

}
# end: sub process_opts

sub find_module_matches {
    my $self = shift;

    $PATTERN =~ s/::/\//g;

    for ($PATTERN) {
        /\$\s*$/ && do {
            $self->opts( "endofline" => 1 );
            $OPTS{endofline} = 1;
            $OPTS{match}     = 'endofline';
            $PATTERN=~s/\$\s*$//g;
            next;
        };
    }

    $RE{PATTERN} = qr/$PATTERN/;

    for $INCDIR (@SEARCHDIRS) {
        next unless -d $INCDIR;

        if ( grep { /^\s*\Q$INCDIR\E/ } @EXCLUDEDIRS ){
            next;
        }

        find( { 
                wanted => \&wanted, 
                follow => 1, 
              },
              $INCDIR );
    }

    $self->MODPATHS(%MODPATHS);

    $self->MODULES(sort($self->MODPATHS_keys));


}

sub wanted {

    my($fullpath,$module,$relpath,$modslash);

    # skip files that do not end with .pm
    return unless /\.pm$/;

    $fullpath = $File::Find::name;

    $fullpath =~ s/\s*$//g;

    # File/Slurp.pm
    (  $relpath = $fullpath ) =~ s{^\Q$INCDIR}{};
    $relpath =~ s{^[\/]*}{}g;

    # File/Slurp
    (  $modslash=$relpath ) =~ s/\.pm$//g;

    # File::Slurp
    ( $module = $modslash ) =~ s{\Q/}{::}g;

    if ($OPTS{searchmode} eq 'simple'){
        unless ( $OPTS{match} ) {
            return unless $modslash =~ /$RE{PATTERN}/;
        }
        elsif ( $OPTS{endofline} ) {
            return unless $modslash =~ /$RE{PATTERN}$/;
        }
    }elsif ($OPTS{searchmode} eq 'allpm'){
        # check each found .pm file for the package ... ; string
    }

	# do not add already added path
	# 
	#@{$MODPATHS{$module}}=();

	return if $module =~ /^i(686|386)/;

	if ( not grep {/^$fullpath$/ } @{$MODPATHS{$module}}){
    	push(@{$MODPATHS{$module}},$fullpath);
	}

    if ( $OPTS{remove} ) {
        remove_tree($fullpath);
    }

}

1;
