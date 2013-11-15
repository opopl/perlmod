#!/usr/bin/env perl

use strict;
use warnings;

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
use File::Slurp qw( read_file );
use File::Find;

###our
our($mkdir,$incdir);
our @modules;

###subs
sub wanted;
sub module_local_paths;
sub module_install_paths;
sub main;

main;

sub wanted {

    foreach my $dir (@PERLLIB) {
        # body...
    }
}

sub module_install_paths {
    my $module=shift;

    ( my $modslash=$module )  =~ s/::/\//g;

    my @paths=();
    
    push(@paths, catfile($PERL_INSTALL_PREFIX, "$modslash.pm" ));    

    wantarray ? @paths : \@paths ;

}

sub module_local_paths {
    my $module=shift;

    ( my $modslash=$module )  =~ s/::/\//g;
    ( my $moddef=$module  ) =~ s/::/-/g;

    my @paths=();

    push(@paths, catfile($PERLMODDIR, qw(mods),$moddef,qw(lib),"$modslash.pm" ));    

    wantarray ? @paths : \@paths ;
}

sub main {

	$mkdir=catfile($PERLMODDIR,qw(mk iall));
	$incdir=catfile($PERLMODDIR,qw(inc iall));
	
	make_path($mkdir);
	make_path($incdir);
	
	@modules=map { chomp; /^\s*#/ ? () : $_; }
	    read_file(catfile($PERLMODDIR,qw( inc modules_to_install.i.dat)));
	
	my $mk=catfile($mkdir,qw(install_modules.mk));
	
	open(F,">$mk") || die $!;
	
	foreach my $module (@modules) {
	    ( my $module_esc = $module ) =~ s/::/-/g;
	    ( my $moddef = $module ) =~ s/::/-/g;
        my $moddir =catfile($PERLMODDIR,qw(mods),$moddef);
	
	    my @ipaths=module_install_paths($module);
	    my @lpaths=module_local_paths($module);

	    print F ' ' . "\n";
	    print F join(' ',@ipaths) . ': ' . join(' ',@lpaths) . "\n";
	    print F "\t\@cd $moddir; ./imod.mk install" . "\n";
	
	    print F ' ' . "\n";
	    print F $module_esc . ': ' . join(' ',@ipaths) . "\n";
	
	}
	    
	close(F);
	
}
