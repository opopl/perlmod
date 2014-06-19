
package OP::Projs::Postprocess::acw;

use warnings;
use strict;

use Env qw($PDFOUT);
use File::Spec::Functions qw(catfile);
use File::Copy qw(move);
use parent qw( OP::Projs::Postprocess );

sub postprocess {
	my $self=shift;
    
    my $pdffile=catfile($PDFOUT,$self->PROJ . '.pdf');
    if(-e $pdffile){
        move(
            $pdffile,
            catfile($PDFOUT,$self->PROJ . '_ACW' . $self->DATA("ACWNUMBER") . '.pdf' )
        );
    }else{
        die "PDF file was not generated!";
    }

}

1;
