
package OP::hperl;

use strict;
use warnings;

=head1 NAME

OP::hperl - builder for POD + SOURCE documentation

=head1 INHERITANCE

	isa Class::Accessor::Complex
	isa OP::Script 

=head1 ACCESSORS

=over 4

=item Scalar:

	htexdir topic

=back

=cut

use Env qw($hm $PDFOUT_PERLDOC);

use FindBin qw($Bin $Script);

use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use File::Slurp qw(write_file);

use Getopt::Long;
use Pod::LaTeX;

use OP::perldoc2tex;
use OP::TEX::Text;

use Cwd;

use parent qw( 
	OP::Script
	Class::Accessor::Complex 
);

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
	htexdir
	topic
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
	files
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

sub _begin {
	my $self=shift;

	$self->{package_name}=__PACKAGE__ unless defined $self->{package_name}; 

}

=head3 buildpdf
 
=head4 Purpose

Invoke C<makefile _mkprojects> 
 
=head4 Usage
 
=head4 Input
 
=head4 Returns
 
=cut
 
sub buildpdf {
	my $self=shift;

	my $p2tex=OP::perldoc2tex->new;
	my $origtopic=$self->topic;

	( my $topic = $origtopic ) =~ s/::/-/g;

	print $origtopic . "\n";

	@ARGV=( qw( --what ) , $origtopic );
	$p2tex->main;

	my $olddir=Cwd::cwd();

	chdir $self->htexdir || $self->_die("Failed to cd: " . $self->htexdir);

	write_file('MKPROJS.i.dat',$topic . "\n");

	my $env=[
		"PDFOUT=$PDFOUT_PERLDOC",
		"MAKEINDEXSTYLE=" . $self->files("makeindexstyle")->(),
	];
	my $cmdprefix=join(" ",@$env);
	my $idx=$origtopic . '.idx';
	my $sub_idx= "perl -p -i.bak -e " 
			. "'" 
			. 's/^(\\\\indexentry)\{' . $origtopic . '!/$1\{/g' 
			. "'"
			. " "
			. $idx;
	my $make_latex= "make _latex_single; $sub_idx; make _makeindex";

	my $cmds=[
		'make _clean',
		$make_latex,
		$make_latex,
		$make_latex,
		$make_latex,
		"make _mvpdf",
	];
	for(@$cmds){
		print $_ . "\n";;
	}

	for(map { $cmdprefix . " " .  $_ } @$cmds){
		system("$_");
	}

	unless ($self->_opt_eq("skip","vdoc")) {
		system("make _vdoc");
	}


	chdir $olddir;

}

sub main {
	my $self=shift;
		
	$self->init_vars;

    $self->get_opt;

    $self->process_opt;

    $self->buildpdf;

}

sub set_these_cmdopts {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts();

    my $opts = [];
    my $desc = {};

    push(
        @$opts,
        {
            name => "topic|t",
            type => "s",
            desc => "perldoc topic to display",
        },
	    {
            name => "skip|s",
            type => "s",
            desc => "skip ...",
        },

    );

    $self->add_cmd_opts($opts);

}

sub process_opt {
	my $self=shift;

	$self->opts_to_scalar_vars(qw(topic));

}
	
sub init_vars {
	my $self=shift;

	$self->htexdir(catfile(qw( /doc perl tex )));

	$self->files(
		makeindexstyle => sub { catfile($hm,qw(wrk p opmist.ist )) },
	);
}
	

1;
