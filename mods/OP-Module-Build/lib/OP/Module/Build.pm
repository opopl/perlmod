
package OP::Module::Build;

use strict;
use warnings;

our $VERSION     = '0.01';

use parent qw( Module::Build );

use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);

my $reqs={};

my $depsdat=catfile($Bin,qw(deps.i.dat));

if (-e $depsdat){
    open(F,"<$depsdat") || die $!;
    while(<F>){
        chomp;
        next if /^\s*#/ || /^\s*$/;

        my $line=$_;
        my @F=split(' ',$line);
        my $module=shift @F;

        $reqs->{$module}=0;
    }
    close(F);
}

my $mb=Module::Build->new
    ( module_name     => 'OP::PAPERS::PSH',
      license         => 'perl',
      requires        => $reqs,
    );
    
$mb->create_build_script;

1;

