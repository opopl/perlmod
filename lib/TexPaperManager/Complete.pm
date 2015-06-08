
package TexPaperManager::Complete;

use strict;
use warnings;


=head3 _complete_papers()

=cut

sub _complete_papers() {
    my $self = shift;

    my $type = shift;
    my $cmpl = shift;

    my ( @comps, @pkeys, $ref );

    if ( grep { /^$type$/ } qw( original_pdf tex bib short_tex ) ) {
        eval '@pkeys=$self->' . "$type" . "_papers";
        die $@ if $@;
    }

    if ( $cmpl->{str} ) {

        my $str = lc $cmpl->{str};
        my @arr = ();

        foreach my $pkey (@pkeys) {
            if ( lc($pkey) =~ /^\s*$str/i ) {
                push( @arr, $pkey );
            }
        }
        $ref = \@arr;
    }
    else {
        $ref = \@pkeys;
    }

    return $ref;

}

=head3 _complete_cmd()

=cut

sub _complete_cmd() {
    my $self = shift;

    my $ref_cmds = shift || '';

    return [] unless $ref_cmds;

    my @comps = ();
    my $ref;

    return 1 unless ( ref $ref_cmds eq "ARRAY" );

    while ( my $cmd = shift @$ref_cmds ) {
        foreach ($cmd) {
            /^bt$/ && do {
                push( @comps, qw( lk lak la ) );
                next;
            };

            # List of scalar accessors
            /^scalar_accessors$/ && do {
                push( @comps, @{ $self->accessors('scalar') } );
                next;
            };

            # Specific accessor
            /^scalar_accessor_(\w+)$/ && do {
				my $acc=$1;

                for ( $acc ) {
                    /^view_cmd_pdf_(generated|original)$/ && do {
                        push( @comps, qw(evince okular) );
                        next;
                    };
                    /^(pkey|tex_papers)$/ && do {
                        push( @comps, $self->tex_papers );
                        next;
                    };

                    /^part$/ && do {
                        push( @comps, $self->all_parts );
                        next;
                    };
                    /^docstyle$/ && do {
                        my @s = $self->docstyles;
                        push( @comps, @s );
                        next;
                    };
                }
                next;
            };

            /^short_tex_papers$/ && do {
                push( @comps, $self->short_tex_papers );
                next;
            };

            # List of makeindex styles
            /^mistyles$/ && do {
                push( @comps, $self->mistyles );
                next;
            };
            /^gitco$/ && do {
                push( @comps, qw(ptex nc isec) );
                next;
            };

            # List of BibTeX keys
            /^(lk|bib_papers)$/ && do {
                push( @comps, $self->bib_papers );
                next;
            };

            # List of parts
            /^lparts$/ && do {
                push( @comps, $self->all_parts );
                next;
            };

            # List of builds
            /^builds$/ && do {
                push( @comps, $self->builds );
                next;
            };

            # make (compile a PDF from LaTeX sources)
            # - both list of TeX papers and list of parts
            # need to be completed
###_complete_cmd_make
            /^make$/ && do {

                #push( @comps, $self->tex_papers );
                push( @comps, $self->MAKETARGETS );
                next;
            };

            # Make PDF part
            /^mpa$/ && do {
                push( @comps, $self->all_parts );
                next;
            };

            # makehtml (generate HTML from LaTeX sources)
            /^makehtml$/ && do {
                push( @comps, $self->all_parts );
                push( @comps, $self->tex_papers );
                next;
            };

        }
    }

    $ref = \@comps if @comps;

    return $ref;
}


1;
 

