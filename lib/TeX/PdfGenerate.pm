
package TeX::PdfGenerate;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);
use FindBin qw($Bin $Script);
use File::Path qw(mkpath rmtree);
use File::Copy qw(copy);
use File::Spec::Functions qw(catfile);
use File::Temp qw(mktemp);

my $tmpdir=catfile($Bin,qw(tmp_pdflatex));
my $PDFOUT=$ENV{PDFOUT};

use CGI qw(:standard);

use Env qw(@TEXINPUTS @BIBINPUTS $PDFOUT);

sub env {
	my $self=shift;

	my $var=shift;

	( defined $ENV{$var} ) ? $ENV{$var} : '<undef>';
}

sub env_array {
	my $self=shift;

	my $var=shift;
	my $val=$self->env($var);

	my @a=split(';',$val);

	return @a;

}

sub main {
	my $self=shift;

	if (-d $tmpdir){
		$self->puts_tab(
			'Re-creating temporary directory:',
			$tmpdir);

		rmtree $tmpdir;
	}

	mkpath $tmpdir;
	
	$self->puts_box(
		"TEXINPUTS",( map { "\t" . $_ } $self->env_array('TEXINPUTS') ),
		"BIBINPUTS",( map { "\t" . $_ } $self->env_array('BIBINPUTS') ),
		"PDFOUT"   ,"\t" . $self->env('PDFOUT'),
	);
	
	chdir $tmpdir;
	$self->puts_tab("Current directory:",$tmpdir);
	
	my (@o,@o_bibtex);
	
	my $texfile = $self->proj . ".tex";
	push @o, 
		"-file-line-error", 
		'-interaction=nonstopmode',
		$texfile;

	push @o_bibtex,
		'--huge',
		'--csfile "utf8cyrillic.csf"',
		$self->proj,
	;


	$self->rcmd({ cmd => [ 'copy ..\*.tex .' ] });
	
	$self->rcmd({ cmd => [ 'pdflatex',@o ] });
	$self->rcmd({ cmd => [ 'bibtex8'  ,@o_bibtex ]      });
	$self->rcmd({ cmd => [ 'pdflatex',@o ] });
	$self->rcmd({ cmd => [ 'pdflatex',@o ] });
	
	my $outdir=$PDFOUT;
	mkpath $PDFOUT;
	
	my $pdffile=$self->proj . ".pdf";

	if (-e $pdffile) {
		$self->rcmd({ cmd => [ "copy $pdffile $outdir" ] });
	}

	exit 0;

}

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

    return $self;
}

sub init {
	my $self=shift;

	my $h={
		proj => undef
	};
		
	my @k=keys %$h;

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}
}


sub puts {
	my $self=shift;

	my @msg=@_;

	print $_ . "\n" for(@msg);
}

sub puts_tab {
	my $self=shift;

	my $head=shift;

	$self->puts( $head, map { "\t" . $_ } @_ );

}

sub puts_box {
	my $self=shift;

	my $d='-' x 50;

	$self->puts( $d, @_, $d );

}

sub rcmd {
	my $self=shift;

	my $ref=shift;

	my $cmd=join(' ',@{$ref->{cmd}});

	my $tmp=mktemp("XXXXXX");

	$self->puts_tab('Running command: ', $cmd);

	system("cmd /c $cmd > $tmp 2>&1");
	my $c= $? >> 8;

	$self->puts_tab('Exit code: ', $c);

	my $tailsize=50;

	if ($c) {
		my @e=();

		open(F,"<$tmp") || die $!;
		while(<F>){
			chomp;
			my $line=$_;
			push @e,$line;
		}
		close(F);

		unlink $tmp if -e $tmp;

		my $i=0;
		my @tail;
		while ($i < $tailsize) {
			push @tail,pop @e;
			$i++;
		}

		$self->puts_tab('Tail: ', @tail);

		exit 1;

	}

	unlink $tmp if -e $tmp;
}

1;
 
