
package OP::hperl;

use OP::perldoc2tex;

use Env qw($hm);

use FindBin qw($Bin $Script);
use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use Getopt::Long;
use Pod::LaTeX;
use OP::TEX::Text;

use parent qw( 
	OP::Script
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	htexdir
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

#perldoc2tex.pl --what "$what" --texfile $topic.tex
   #     cd $htexdir
		#make $topic PDFOUT="$PDFOUT_PERLDOC"
		#make _vdoc _clean
		#cd $olddir
#fi
sub main {
	my $self=shift;
		
	$self->init_vars;

    $self->get_opt;

    $self->process_opt;

	chdir $self->htexdir;
}

sub process_opt {
	my $self=shift;
}
	
sub init_vars {
	my $self=shift;

	$self->htexdir(catfile(qw( doc perl tex )));
}
	

1;
