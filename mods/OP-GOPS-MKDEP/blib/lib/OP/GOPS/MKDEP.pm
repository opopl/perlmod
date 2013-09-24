package OP::GOPS::MKDEP;

# intro {{{

=head1 INHERITANCE

L<Class::Accessor::Complex>, L<OP::Script>

=head1 USES

	use Getopt::Long;
	use Pod::Usage;
	use Cwd;
	use File::Basename;
	use OP::Base qw/:vars :funcs/;
	use File::Grep qw( fgrep fmap fdo );

use OP::Base qw/:vars :funcs/;

=head1 ACCESSORS

=head2 Scalar Accessors

	nuexist - does the nu.mk file exist? 0 for no, 1 for yes

=head2 Array Accessors

	nused  -  array for not-used fortran files which are taken from file nu.mk
	nudirs -
	aumods -  all modules which were found through the 'use' statement
	exmods -  those mods which are not in fortranfiles

=head2 Hash Accessors

	rec_lev - recursion level of calling a subroutine

=cut

use strict;
use warnings;

our $VERSION = '0.01';

###_USE
use FindBin qw($Bin $Script);
use Getopt::Long;
use Pod::Usage;
use Cwd;
use File::Basename qw(basename dirname);
use OP::Base qw/:vars :funcs/;
use File::Grep qw( fgrep fmap fdo );
use File::Spec::Functions qw(catfile rel2abs curdir catdir );

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors = qw(
  PROGNAME
  date
  fext
  fname
  module_name
  nuexist
  resline_lev
  val
  var
);

###__ACCESSORS_HASH
our @hash_accessors = qw(
  accessors
  deps
  dirs
  excluded
  files
  libs
  rec_lev
  regex
  usedin
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
  aumods
  exmods
  fortranfiles
  libdirs
  mkfiles
  modules
  nudirs
  nused
  source_search_dirs
  used_source_search_dirs
);

our $DEPS;

###_ACCESSORS
__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_hash_accessors(@hash_accessors)->mk_array_accessors(@array_accessors);

sub init_vars() {
    my $self = shift;

###set_regex
    $self->regex(
        fortran => {
            "include_file"      => qr/^\s*include\s+["\']([^"\']+)["\']/i,
            "use_module"        => qr/^\s*use\s+([^\s,!]+)\s*,?/i,
            "declare_module"    => qr/\s*module\s+([^\s!]+)/i,
            "not_used_patterns" => qr/.*\.(inc|i|o|old|save|ref)\..*/,
            "prefix_slash"      => qr/^(.*)\//
        }
    );

    # makefile-related
    $self->mkfiles(qw( inc.mk t.mk def.mk ));

    $self->source_search_dirs(qw( . ));

    # current project full path, e.g., /home/op226/gops/G
    $self->dirs( "ppath" => rel2abs( curdir() ) );

    # current program name, e.g., G
    $self->PROGNAME( basename( $self->dirs("ppath") ) );

    $self->_set_ussd();

    ## scripts/all/
    $self->dirs( scripts => { all => $Bin } );

    # $HOME/gops/
    $self->dirs( root => catdir( $self->dirs("scripts")->{all}, "..", ".." ) );
    $self->dirs( inc => catdir( $self->dirs("root"), "inc" ) );

    $self->files(
        "notused" => $self->dirs('inc') . "/nu_" . $self->PROGNAME . ".mk" );

    if ( $self->_opt_true("dpfile") ) {
        $self->files( 'deps' =>
              catfile( $self->dirs("ppath"), $self->_opt_get("dpfile") ) );
    }
    else {
        $self->files( "deps" => "deps.mk" );
    }

    open( DP, ">", $self->files("deps") ) or die $!;

    print DP "# Project dir: " . $self->dirs("ppath") . "\n";
    print DP "# Program name: " . $self->PROGNAME . "\n";

}

#}}}
# Methods 											{{{

# new()												{{{

=head3 new()

=cut

sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

# 													}}}
# remove_extension()								{{{

=head3 remove_extension()

=cut

sub remove_extension() {
    my $self = shift;

    my $file = shift;

    $file =~ s/\.\w*$//g;

    return $file;
}

# }}}
# _set_ussd() {{{

=head3 _set_ussd()

=cut

sub _set_ussd() {
    my $self = shift;

    foreach my $f ( $self->mkfiles ) {
        next unless -e $f;
        open( F, "<$f" ) || die $!;
        while (<F>) {
            /^\s*USED_SOURCE_SEARCH_DIRS\s*:?=(.*)/;
            if ( defined($1) ) {
                my $val = $1;
                $val =~ s/\s*//g;
                $self->push_used_source_search_dirs( split( ':', $val ) );
            }
        }
        close(F);
    }
}

# }}}
# set_these_cmdopts()							{{{

sub set_these_cmdopts() {
    my $self = shift;

    my $opts;

    push( @$opts, { name => "h,help",   desc => "Print the help message" } );
    push( @$opts, { name => "man",      desc => "Print the man page" } );
    push( @$opts, { name => "examples", desc => "Show examples of usage" } );
    push( @$opts, { name => "vm",       desc => "View myself" } );

    push( @$opts,
        {
            name => "dpfile",
            desc => "Provide the filename of the dependency file",
            type => "s"
        }
    );

    push( @$opts, { name => "nolibs", desc => "" } );
    push( @$opts, { name => "print_non_root", desc => "" } );
    
    push( @$opts,
        {
            name => "flist",
            desc => "Use the flist fortran files"
        }
      );

    $self->add_cmd_opts($opts);
}

#}}}
# wanted() _get_unused() 								{{{

=head3 _get_unused()

=cut

sub _get_unused() {
    my $self = shift;

    my @nused;
    $self->nuexist(1);

    open( NUF, $self->files("notused") ) or $self->nuexist(0);

    if ( $self->nuexist eq 1 ) {
        while (<NUF>) {
            chomp;
            if ( !/^(#|d:)/ ) {
                push( @nused, $_ );
            }
            elsif (/^d:\s*(.*)/g) {
                $self->nudirs_push($1);
                print DP "# Not used dir: $1\n";
            }
        }
        foreach (@nused) { s/^\s+//; s/\s+$//; }
        close(NUF);
    }

}

#}}}
# PrintWords() {{{

=head3 PrintWords()

=cut

sub PrintWords {
    my $self = shift;

# &PrintWords(current output column, extra tab?, word list); --- print words nicely
    my ($columns)  = 78 - shift(@_);
    my ($extratab) = shift(@_);
    my ($wordlength);
    #
    print DP $_[0];

    $columns -= length( shift(@_) );
    foreach my $word (@_) {
        $wordlength = length($word);
        if ( $wordlength + 1 < $columns ) {
            print DP " $word";
            $columns -= $wordlength + 1;
        }
        else {
            #
            # Continue onto a new line
            #
            if ($extratab) {
                print DP " \\\n\t\t$word";
                $columns = 62 - $wordlength;
            }
            else {
                print DP " \\\n\t$word";
                $columns = 70 - $wordlength;
            }
        }
    }
}

# }}}
# resolve_line(){{{

=head3 resolve_line()

=cut

sub resolve_line() {
    my $self = shift;

    my ( $line, $switch ) = @_;

	if ($self->resline_lev){
		$self->resline_lev($self->resline_lev+1);
	}else{
		$self->resline_lev(1);
	}

    my $regex = $self->regex('fortran')->{$switch};

    if ( $line =~ m/$regex/ig ) {
###switch_include_file
        if ( $switch eq "include_file" ) {
            unless ( $self->excluded_exists($1) ) {

                # push(@incs, $1);
                my $include_file = $1;
                open( IFILE, "<", $include_file ) || die $!;
				$self->say("Current include file is: $include_file");

                while (<IFILE>) {
                    chomp;
                    $self->resolve_line( $_, "use_module" );
                    $self->resolve_line( $_, "include_file" );
                }
                close IFILE;
            }
        }
###switch_use_module
        elsif ( $switch eq "use_module" ) {
            if ( defined($1) ) {
                my $mod = &toLower($1);

                $self->modules_push($mod);
                $self->aumods_push($mod);

                unless ( $self->usedin_exists($mod) ) {
                    $self->usedin( $mod => $self->fname );
                }
                else {
                    $self->usedin(
                        $mod => $self->fname . ' ' . $self->usedin($mod) );
                }
                if ( !grep { /$mod\.(f|f90)$/ } $self->fortranfiles ) {
                    $self->exmods_push($mod);
                }
            }
        }
    }

	$self->resline_lev($self->resline_lev-1);
}

# }}}
# make_deps() {{{

=head3 make_deps()

=cut

sub make_deps() {
    my $self = shift;

    my $subname = ( caller(0) )[3];
    my (@dependencies);
    my (%filename);
    my ($mo);
    my (@incs);
    my ($mod);
    my ($objfile);

    $self->aumods(qw());

    $self->date(localtime);

	my $endl="\n";
	my $delim='-' x 50;

    print DP "#	" . $delim                                      . $endl ;
    print DP "#	File: "                                         . $endl ;
    print DP "#" .	$self->files("deps")                        . $endl ;
    print DP "#	Program:"                                       . $endl ;
    print DP "#		" . $self->PROGNAME                         . $endl ;
    print DP "#	Purpose:"                                       . $endl ;
    print DP "#		Contains Fortran object files dependencies" . $endl ;
    print DP "#	Created: "                                      . $endl ;
    print DP "#		" . $self->date                             . $endl ;
    print DP "#	Creating script:"                               . $endl ;
    print DP "#		$Script"                                    . $endl ;
    print DP "#	" . $delim                                      . $endl ;

    unless ( $self->rec_lev_exists($subname) ) {
        $self->rec_lev( $subname => 0 );
    }
    else {
        my $x = $self->rec_lev($subname);
        $x++;
        $self->rec_lev( $subname => $x );
    }

    # Associate each module with the name of the file that contains it {{{

    foreach my $file ( $self->fortranfiles ) {
        open( FILE, $file ) || warn "Cannot open $file: $!\n";

        # get extension from the $file
        if ( $file =~ /.*\.(f|F|f90)$/ ) {
            $self->fext($1);
        }

        # get the object name for the module
        while (<FILE>) {

            my $regex = $self->regex('fortran')->{declare_module};
            my $fext  = $self->fext;

            if (/^$regex/) {
                $mod = lc $1 if ( defined($1) );
                $filename{src}{$mod} = $file;
                ( $filename{obj}{$mod} = $file ) =~ s/\.$fext$/.o/;
            }
        }
    }

    # }}}
    # Print the dependencies of each file that has one or more include's or
    # references one or more modules

    foreach my $file ( $self->fortranfiles ) {

        open( FILE, "<$file" ) || die $!;
        $self->fname( $self->remove_extension($file) );

        while (<FILE>) {
            chomp;
            my $line = $_;
            next if ( /^\s*!/ || /^\s*$/ );
            $self->resolve_line( $line, "use_module" );
            $self->resolve_line( $line, "include_file" );
        }

        close(FILE);

        if ( (@incs) || ( $self->modules ) ) {
            ( $objfile = $file ) =~ s/\.[^\.]+$/.o/g;
            my $regex = $self->regex('fortran')->{prefix_slash};
            if ( 
				( $objfile !~ /$regex/ || $self->_opt_true("print_non_root") )
                && 
				( $objfile !~ /$self->regex('fortran')->{not_used_patterns}/ )
              )
            {
                #{{{
                print DP "$objfile: ";
                undef @dependencies;

                foreach my $module ( $self->modules ) {
                    if ( defined $filename{src}{$module} ) {
                        $mo = $filename{obj}{$module};

                        foreach my $libdir ( $self->libdirs ) {
                            my $libname = $self->libs($libdir);
                            $mo =~ s/^$libdir\/.*/$libname/;
                        }
                        unless ( $self->excluded_exists($mo) ) {

                            # check for not-used
                            ( my $moname = $mo ) =~ s/\.o$//g;
                            unless ( grep { /^$filename{src}{$module}$/ }
                                $self->nused )
                            {
                                push( @dependencies, $mo );
                            }
                            else {
								push(@{ $DEPS->{$file}->{nexist} },$mo);
                            }
                        }
                    }
                    else {
                        push( @{ $DEPS->{$file}->{nexist} }, $module );
                    }
                }
                if (@dependencies) {
                    @dependencies = &uniq( sort(@dependencies) );
                    $self->PrintWords( length($objfile) + 2,
                        0, @dependencies, &uniq( sort(@incs) ) );
                }
                print DP "\n";

                #}}}
            }
            undef @incs;
            $self->modules_clear;
        }
    }
    foreach my $mode (qw( nexist nused)) {
        print DP "# $mode dependencies:\n";
        foreach my $file ( $self->fortranfiles ) {
            if ( defined $DEPS->{$file}->{$mode}  ) {
            	if ( @{ $DEPS->{$file}->{$mode} } ) {
                	print DP "# 	$file =>  ";
                	foreach ( @{ $DEPS->{$file}->{$mode} } ) { print DP "$_ "; }
                	print DP "\n";
            	}
			}
        }
    }

    unless ( $self->used_source_search_dirs ) {
        &eoo("Source search dirs were not given!\n");
    }
    if ( $self->exmods ) {
        $self->fortranfiles(qw());
        $self->exmods( sort( &uniq( sort( $self->exmods ) ) ) );
        foreach ( $self->exmods ) {
            print( "Ex Module: $_" . $self->rec_lev($subname) . "\n" );
            $self->module_name($_);

            #if ( $self->used_source_search_dirs ) {
                #File::Find::find(
                    #{ wanted => \&_used_source_wanted },
                    #$self->used_source_search_dirs
                #);
            #}
        }
        if ( $self->fortranfiles ) {
            my $flist = join( ' ', $self->fortranfiles );
            print "$flist\n";

            #&make_deps();
        }
    }
}

# }}}
# _set_libs()										{{{

sub _set_libs() {
    my $self = shift;

    unless ( $self->_opt_true("nolibs") ) {
        $self->libs(
            "CONNECT"     => "libnc.a",
            "NEB"         => "libnn.a",
            "AMH"         => "libamh.a",
            "libbowman.a" => "libbowman.a"
        );
        $self->libdirs( $self->libs_keys );
    }
}

# 													}}}
# _get_fortranfiles()								{{{

=head3 _get_fortranfiles()

=cut

sub _get_fortranfiles() {
    my $self = shift;

    if ( $self->_opt_true("flist") ) {
        $self->fortranfiles( map { chomp; $_; }
              `$shd/get_flist.pl --out --file` );
    }
}

# }}}
# _begin() {{{

=head3 _begin()

=cut

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

# }}}

# }}}

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();
}

# main() {{{

=head3 main()

=cut

sub main() {
    my $self = shift;

    $self->init_vars();

    $self->get_opt();

    $self->_set_libs();
    $self->_get_unused();
    $self->_get_fortranfiles();

    $self->make_deps();

    close DP;
}

#}}}

1;
__END__

=head1 CHANGELOG

Original makemake utility - Written by Michael Wester <wester@math.unm.edu> December 27, 1995
Cotopaxi (Consulting), Albuquerque, New Mexico

14:19:31 (Sat, 26-Mar-2011):

mkdep - put under git control by op

=cut
