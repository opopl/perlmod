#!/usr/bin/env perl

use strict;
use warnings;

###use

use Env qw( 
    $PERLMODDIR 
    @PERLLIB 
    $ppv 
    $pan 
    $PERLDIST 
    $PERL_INSTALL_PREFIX 
    );

use File::Path qw(make_path remove_tree);
use File::Spec::Functions qw( catfile );
use File::Slurp qw( read_file append_file write_file );
use File::Find;
use Data::Dumper;
use FindBin qw( $Bin $Script );
use FileHandle;
use IO::String;

use lib("$PERLMODDIR/mods/OP-Script-Simple/lib");
use OP::Script::Simple qw(
    get_opt 
    write_help_POD
    %opt
    %optdesc
    @optstr
);

###our
our $DEBUG;

our @installed_cpan;
our @modules_esc;
our %moduledeps;
our($mkdir,$incdir);
our @modules_to_install;
our @modules_to_install_esc;
our @all_local_modules;
our @cpan_modules;
our @modules;

### needed in wanted_ipath
our $M;
our $M_is_installed;
our @M_ipaths;
our @M_paths_exclude;
our $IMAX;

our %m_install_paths;
our %m_local_paths;

our %dat;
our %mkfiles;
our @datfiles;

###subs
sub init_dat;
sub init_m_paths;
sub module_cpan_installed;
sub write_defs;
sub remove_dat;
sub test;
sub process_opt;
sub init_after_get_opt;
sub _debug;
sub _say;
sub call;
sub call_subs;
sub dhelp;
sub end;
sub get_all_local_modules;
sub get_cpan_modules;
sub get_installed_cpan;
sub get_modules;
sub get_modules_to_install;
sub init;
sub main;
sub make_dirs;
sub module_deps;
sub module_deps_esc;
sub module_dir;
sub module_esc;
sub module_install_paths;
sub module_is_installed;
sub module_local_paths;
sub print_prereq;
sub readarr;
sub readhash;
sub uniq;
sub wanted;
sub wanted_installed;
sub wanted_ipath;
sub write_mk;

main;
      

sub wanted_installed {

    ( my $moddef=$M ) =~ s/::/-/g;
    ( my $modslash=$M ) =~ s/::/\//g;

    my @m=split('::',$M);
    my $modname=pop(@m);
    my $fname=$File::Find::name;

    if ($fname =~ /$modslash\.pm$/){
        $M_is_installed=1;
        return;
    }

}

sub wanted_ipath {

    ( my $moddef=$M ) =~ s/::/-/g;
    ( my $modslash=$M ) =~ s/::/\//g;

    my @m=split('::',$M);
    my $modname=pop(@m);
    my $fname=$File::Find::name;

    ( my $dir = $File::Find::dir ) =~ s/\/$//g;

    foreach my $path (@M_paths_exclude) {
        return if $dir =~ /$path/;
    }

    if ($fname =~ /$modslash\.pm$/){
        push(@M_ipaths,$fname);
    }elsif($fname =~ /\.pm$/){
        my @lines=read_file($fname);
        foreach (@lines){
            chomp;
            next if /^\s*#/;
            if(/^\s*package\s+$M\s*;/){
                push(@M_ipaths,$fname);
                last;
            }
        }
    }
}

sub module_is_installed {
    my $module=shift;

    my $ip=$m_install_paths{$module} // [];

    foreach my $p (@$ip) {
        return 1 if -e $p;
    }

    $M=$module;
    $M_is_installed=0;

    File::Find::find({ wanted  => \&wanted_installed }, @PERLLIB);

    $M_is_installed;

}

sub module_local_paths {
    my $module=shift;

    my $paths=$m_local_paths{$module} // [];

    if(@$paths){
        return @$paths;
    }

    $M=$module;

    ( my $modslash=$module )  =~ s/::/\//g;
    ( my $moddef=$module  ) =~ s/::/-/g;

    my $moddir=module_dir($module);
    my $blibdir=catfile($moddir,qw(blib));

    @M_ipaths=();
    @M_paths_exclude=();

    push(@M_paths_exclude,$blibdir);

    File::Find::find({ wanted  => \&wanted_ipath },$moddir);

    push(@$paths,@M_ipaths);

    foreach my $p (@$paths) {
      append_file($dat{local_paths},"$module $p" . "\n");
    }

    $m_local_paths{$module}=$paths;

    @$paths;


}

sub module_install_paths {
    my $module=shift;

    ( my $modslash=$module )  =~ s/::/\//g;

    my $paths=$m_install_paths{$module} // [];

    if(@$paths){
        return @$paths;
    }
    
    unless (module_is_installed($module)) {
        push(@$paths, catfile($PERL_INSTALL_PREFIX, "$modslash.pm" ));    
    }else{
        @M_ipaths=();
        File::Find::find({ wanted  => \&wanted_ipath }, @PERLLIB);

        push(@$paths,@M_ipaths);
        foreach my $p (@$paths) {
            append_file($dat{install_paths},"$module $p" . "\n");
        }
    }

    $m_install_paths{$module}=$paths;

    uniq(@$paths);

}

sub module_deps {
    my $module=shift;

    my $moddir=module_dir($module);
    my $dat_deps=catfile($moddir,qw(deps.i.dat));
    my $deps;

    $deps=$moduledeps{$module} // [];

    unless(@$deps){
        if (-e $dat_deps) {
            @$deps=map { module_is_installed($_) ? $_ : ()  } readarr($dat_deps);
            $moduledeps{$module}=$deps;
        }
    }

    @$deps;

}

sub module_deps_esc {
    my $module=shift;

    my @deps=map { s/::/-/g; $_ } module_deps($module);

    @deps;

}

sub module_dir {
    my $module=shift;

	( my $moddef = $module ) =~ s/::/-/g;

    my $moddir =catfile($PERLMODDIR,qw(mods),$moddef);

    $moddir;

}

sub readarr {
    my $file=shift;
    
    my @lines;

    unless (-e $file) {
        return ();
    }

    @lines=map { 
            chomp; 

            s/^\s*//g; 
            s/\s*$//g; 

            /^\s*#/ ? () : $_; 
        } read_file($file);

    @lines;
}

sub readhash {
    my $if = shift;

    my $opts = shift // {};

    my $sep = $opts->{sep} // ' ';

    unless ( -e $if ) {
      return ();
    }

    open( FILE, "<$if" ) || die $!;

    my %hash = ();
    my ( @F, $line, $var );

    while (<FILE>) {
        chomp;

        s/\s*$//g;

        next if ( /^\s*#/ || /^\s*$/ );

        $line = $_;

        $line =~ s/\s*$//g;
        $line =~ s/^\s*//g;

        @F = split( $sep, $line );

        for (@F) {
                s/^\s*//g;
                s/\s*$//g;
        }

        $var = shift @F;

        $hash{$var} = [] unless defined $hash{$var};

        if (@F) {
             push(@{$hash{$var}}, join( $sep, @F ));
        }

        s/\s+/ /g for(@{$hash{$var}});

    }

    close(FILE);

    while(my($k,$v)=each %hash){
        @{$hash{$k}}=uniq(@$v);
    }

    wantarray ? %hash : \%hash;

}


sub get_all_local_modules {

    my $dir=catfile($PERLMODDIR,qw( mods ));
    opendir(D,$dir) || die $!;
    while (my $f=readdir(D)) {
        my $fulldir=catfile($dir,$f);

        next unless -d $fulldir;
        next if ($f eq "pod");
        next if ($f =~ /^\./);

        ( my $module=$f ) =~ s/-/::/g;
        push(@all_local_modules,$module);
    }
    @all_local_modules=uniq(@all_local_modules);
    
    closedir(D);

}

sub get_cpan_modules {

	foreach my $module (@modules_to_install) {
        my @deps=module_deps($module);

        push(@modules,@deps);

        foreach my $dep (@deps) {
            unless($dep ~~ @all_local_modules){
                push(@cpan_modules,$dep);
            }
        }
    }

    @cpan_modules=uniq(@cpan_modules);
    _say "Number of CPAN modules: " . scalar @cpan_modules;

}

sub get_installed_cpan {


    if (-e $dat{installed_cpan}){
        _say "Found dat-file with the list of installed CPAN modules:";
        _say "     $dat{installed_cpan}";
	    @installed_cpan=readarr($dat{installed_cpan});
        _say "Number of installed CPAN modules: " . scalar @installed_cpan;
    }

}

sub get_modules_to_install {

    my $dat=catfile($PERLMODDIR,qw( inc modules_to_install.i.dat ));

	@modules_to_install=readarr($dat);
    @modules_to_install=uniq(@modules_to_install);

    @modules_to_install_esc=map { module_esc($_) } @modules_to_install;

}

sub make_dirs {

	$mkdir=catfile($PERLMODDIR,qw(mk iall));
	$incdir=catfile($PERLMODDIR,qw(inc iall));
	
	make_path($mkdir);
	make_path($incdir);

}

sub get_modules {
	
    push(@modules,@modules_to_install);
    @modules=(@cpan_modules,@all_local_modules);

    @modules=uniq(@modules);

    @modules_esc=map { module_esc($_) } @modules;

}

sub call {
    my $sub=shift; 

    _debug "--------- Calling: $sub ---------------";

    eval $sub;
    die $@ if $@;

}

sub call_subs {

    my @subs=map { chomp; ( /^\s*#/ || /^\s*$/ ) ? () : $_ } <main::DATA>;

    foreach my $sub (@subs) {
        call($sub);
    }

    close(main::DATA);

}

sub main {

    init;

    call_subs;
		
}

sub _say {
    my $text=shift;

    print "$text\n";
}

sub module_cpan_installed {
    my $module=shift; 

   if (($module ~~ @cpan_modules) && (module_is_installed($module))){
      _say "...INSTALLED, skipping...";

      return 1;
   }

   return 0;

}


sub write_defs {

	open(D,">",$mkfiles{defs}) || die $!;

    my $imod=0;
	foreach my $module (@modules) {
        last if ($imod == $IMAX);

        next if module_cpan_installed($module);

        _say "(defs) Processing: $module";

        ( my $modu=$module ) =~ s/::/_/g;
        ( my $moddef=$module ) =~ s/::/-/g;
	
	    my @ipaths=module_install_paths($module);
	    my @lpaths=module_local_paths($module);

        print D ' ' . "\n";
        print D $modu . '_ipaths:= ' . join(' ',@ipaths) . "\n";
        print D $modu . '_lpaths:= ' . join(' ',@lpaths) . "\n";

        $imod++;
    }

    close D;

}





sub write_mk {

	open(F,">",$mkfiles{install_modules}) || die $!;

    print F ' ' . "\n";
    print F '# ---------------- DEFINITIONS ----------------- ' . "\n";
    print F ' ' . "\n";
    print F 'PERLMODDIR:=' . $PERLMODDIR . "\n";
    print F ' ' . "\n";
    print F 'include ' . $mkfiles{defs}  . "\n";
    print F ' ' . "\n";
    print F '# ---------------- TARGETS ----------------- ' . "\n";
    print F ' ' . "\n";
	print F '.PHONY: ' . join(' ',@modules_esc) .  "\n";
    print F ' ' . "\n";
    print F 'install_modules: ' . print_prereq(@modules_to_install_esc) . "\n";

    print F 'remove_dat: ' . print_prereq(qw(
        remove_dat_installed_cpan 
        remove_dat_install_paths 
        remove_dat_local_paths 
    )) . "\n";

    print F ' ' . "\n";
    print F 'remove_dat_installed_cpan: ' . "\n";
    print F "\t\@rm -rf " . $dat{installed_cpan} . "\n";
    print F 'remove_dat_install_paths: ' . "\n";
    print F "\t\@rm -rf $dat{install_paths}" . "\n";
    print F 'remove_dat_local_paths: ' . "\n";
    print F "\t\@rm -rf $dat{local_paths}" . "\n";

    _say "Number of modules to be processed: " . scalar @modules ;

    my $imod=0;
	foreach my $module (@modules) {
        last if ($imod == $IMAX);

        _say "(mk) Processing: $module";

        next if module_cpan_installed($module);

        my $moddir = module_dir($module);

        ( my $modu=$module ) =~ s/::/_/g;
        ( my $moddef=$module ) =~ s/::/-/g;
	
	    my @ipaths=module_install_paths($module);
	    my @lpaths=module_local_paths($module);

        my @deps=module_deps_esc($module);

        my @prereq=(@deps,'$(' . $modu . '_lpaths)');
        my $targets='$(' . $modu . '_ipaths)';

        print F ' ' . "\n";
        print F module_esc("$module") . ': $(' . $modu . '_ipaths)' . "\n";

        if ($module ~~ @cpan_modules){
            @prereq=();
        }

		print F ' ' . "\n";
		print F $targets . ': ' . print_prereq(@prereq) . "\n";

        if ($module ~~ @cpan_modules){
		    print F "\t\@perl -MCPAN -e \"install('$module');\"" . "\n";
            print F "\t\@echo '$module' >> " . $dat{installed_cpan} . "\n";

        }elsif($module ~~ @all_local_modules){
        
		    print F "\t\@cd \$(PERLMODDIR)/mods/$moddef/; make -f ./imod.mk install" . "\n";
		    print F "\t\@touch " . '$@' .  "\n";

        }   
	
        $imod++;
	}
	    
	close(F);
	close(D);

}

sub print_prereq {
    my @prereq=@_;

    my $indent=" " x 5;
    my $sep=" \\\n$indent";

    my $s;

    @prereq=map { length("$_") && (! /^\s*$/ ) ? $_ : () } @prereq;

    if (@prereq) {
        $s=$sep . join($sep,@prereq);
    }else{
        $s='';
    }

    $s;

}

sub module_esc {
    my $module=shift;

	( my $module_esc = $module ) =~ s/::/-/g;

    $module_esc;

}

sub uniq {
    my ( %h, @W );

    my @words = @_;

    foreach my $w (@words) {
        push( @W, $w ) unless defined $h{$w};
        $h{$w} = 1;
    }
    @W=sort(@W);

    wantarray ? @W : \@W;

}

sub _debug {
    my $text=shift;

    append_file($DEBUG,"$text\n");

}

sub remove_dat {

    _say "Removing dat-files...";

        foreach (qw(installed_cpan install_paths local_paths )) {
            remove_tree($dat{$_});
        }
}

sub process_opt {

    $IMAX=$opt{IMAX} // -1;

###opt_remove_dat
    if ($opt{remove_dat}) {
        remove_dat;
        exit 0;
    }

###opt_list_install_paths

    if ($opt{list_install_paths}) {
        my $module=$opt{list_install_paths};
        my @ipaths=module_install_paths($module);
        print $_ . "\n" for(@ipaths);
        exit 0;
    }

###opt_list_local_paths

    if ($opt{list_local_paths}) {
        my $module=$opt{list_local_paths};
        my @lpaths=module_local_paths($module);
        print $_ . "\n" for(@lpaths);
        exit 0;
    }

###opt_gen_dat
    if ($opt{gen_dat}) {

        get_all_local_modules;
        remove_dat;

        foreach my $module (@all_local_modules) {
            my($stime,$etime,$time);

            _say "Processing module: $module";

            # first time
            _say "First time...";
            _say " Filling in the paths database...";

            $stime=time;

            module_install_paths($module);
            module_local_paths($module);

            $etime=time;
            $time=$etime - $stime;

            _say " Time spent: " . $time . ' (secs)';

            # second time
            _say "Second time...";

            $stime=time;

            my @ip= module_install_paths($module);
            my @lp= module_local_paths($module);

            print Dumper( \@ip);
            print Dumper( \@lp);

            $etime=time;
            $time=$etime - $stime;

            _say " Time spent: " . $time . ' (secs)';

        }

    }

}

sub init_m_paths {

    if (-e $dat{local_paths}){
        %m_local_paths=readhash($dat{local_paths});
    }

    if (-e $dat{install_paths}){
        %m_install_paths=readhash($dat{install_paths});
    }

}

sub init_after_get_opt {

    init_m_paths;

}

sub init_dat {

    @datfiles=qw( installed_cpan install_paths local_paths );

    $dat{install_paths}=catfile($PERLMODDIR,qw( inc iall install_paths.i.dat ));
    $dat{local_paths}=catfile($PERLMODDIR,qw( inc iall local_paths.i.dat ));

    $dat{installed_cpan}=catfile($PERLMODDIR,qw( inc iall installed_cpan.i.dat ));

    # Initialize dat-files if non existing
    foreach (@datfiles ) {
        my $f=$dat{$_};
        write_file("$f","") unless -e $f;
    }

}

sub init_mkfiles {

    $mkfiles{install_modules}=catfile($mkdir,qw(install_modules.mk));
    $mkfiles{defs}=catfile($mkdir,qw(defs.mk));

}

sub init {

    make_dirs;

    init_mkfiles;
    init_dat;
    init_m_paths;

    @PERLLIB=map { ( defined $_ && -d "$_" ) ? $_ : () } @PERLLIB;

    $DEBUG="$Bin/log";

    write_file("$DEBUG","");

###set_optstr
    @optstr=qw( help man remove_dat gen_dat 
        IMAX=s 
        list_install_paths=s
        list_local_paths=s
    );

###set_optdesc
    %optdesc=(
        help            => 'Display help message',
        man             => 'Display man page',
        remove_dat      => 'Remove dat-files',
        gen_dat         => 'Generate dat-files',
        IMAX            => 'Maximal number of modules to be processed',
        list_install_paths          => 'List install paths ',
        list_local_paths            => 'List local paths ',
    );

}

sub test {
    my $m;

    $m='OP::Script';

    my @i=module_install_paths($m);
    my @l=module_local_paths($m);

    print Dumper(\%m_local_paths);
    print Dumper(\%m_install_paths);
    exit 0;

}

sub end {

    $DEBUG->close;

}

__DATA__

get_opt
process_opt
init_after_get_opt

get_modules_to_install

get_all_local_modules

get_cpan_modules

# get @installed_cpan from $dat{installed_cpan}
get_installed_cpan

# set @modules, @modules_esc
get_modules

# test

# write the mk-files
write_defs
write_mk

