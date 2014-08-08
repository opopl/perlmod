
package Mail::Runner::Alpine;

use strict;
use warnings;

use Env qw($hm);

use File::Path qw( make_path remove_tree );
use FindBin qw( $Bin );
use File::Spec::Functions qw(catfile);
use File::Slurp qw(write_file);
use File::Temp qw(tmpnam);
 
use Data::Dumper; 
use FindBin qw( $Script $Bin ); 

sub new
{
    my ($class,%opts) = @_;

    my $self = bless (\%opts, ref ($class) || $class);
	
	$self->prepare_rc;

    return $self;
}

sub prepare_rc {
	my $self=shift;

	$self->{rcfile}=tmpnam();

	write_file($self->{rcfile},$self->{rctext} . "\n");

}

sub run_client {
	my $self=shift;

	my $args=[
		'-p', $self->{rcfile},
	];
	
	system("alpine",@$args);
}


1;
