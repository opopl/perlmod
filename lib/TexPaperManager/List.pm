
package TexPaperManager::List;

use strict;
use warnings;

use  Text::TabularDisplay;
use File::Basename qw(basename);

# list_accessors () {{{

sub list_accessors () {
    my $self = shift;

    open( LESS, "| less" ) || die $!;

    print LESS "-" x 50 . "\n";
    print LESS "List of defined accessors in psh.pl" . "\n";

    foreach my $id (qw(scalar hash array)) {
        my @columns;
        my $value;

        if ( $id =~ /^scalar$/ ) {
            @columns = qw( Name Value Description );
        }
        else {
            @columns = qw( Name Description );
        }

        print LESS "-" x 50 . "\n";
        print LESS "$id accessors: \n\n";

        my $table = Text::TabularDisplay->new(@columns);

        for my $acc ( @{ $self->accessors($id) } ) {
            my $accvar = $id . "_$acc";

            my @row;
            push( @row, $acc );

            if ( $id =~ /^scalar$/ ) {
                eval '$value=$self->' . $acc;
                die $@ if $@;
                my $width = 30;
                if ( length($value) > $width ) {
                    $value = substr( $value, 0, $width ) . ' ...';
                }
                push( @row, $value );
            }

            if ( $self->accdesc_exists("$accvar") ) {
                push( @row, $self->accdesc("$accvar") );
            }
            else {
                push( @row, " " );
            }

            $table->add(@row);

        }

        print LESS $table->render;
    }

    close(LESS);

}

# }}}
# list_compiled() {{{

sub list_compiled() {
    my $self = shift;

    my $ref = shift;

    foreach ($ref) {
        /^pdf_papers$/ && do {
            print "$_\n" for ( $self->compiled_tex_papers );
            next;
        };
        /^pdf_parts$/ && do {
            print "$_\n" for ( $self->compiled_parts );
            next;
        };

    }
}

# }}}
# list_fig_tex () {{{

=head3 list_fig_tex () 

=cut

sub list_fig_tex() {
    my $self = shift;

    my @files = glob("p.*.fig.*.tex");

    foreach my $f (@files) {
        print "$f\n";
    }

}

# }}}
# list_partpaps() {{{

sub list_partpaps() {
    my $self = shift;

    my $part = shift || $self->part;
    $self->part($part);

    $self->_part_read_paps($part);
    print "$_" . "\n" for ( @{ $self->part_paps($part) } );
}

# }}}
# list_vars() {{{

sub list_vars() {
    my $self = shift;

    #foreach my $id (qw( hash array scalar )) {
    #foreach my $x ($self->) {
    ## body...
    #}
    #}

}

# }}}
# list_scripts() {{{

sub list_scripts() {
    my $self = shift;

    my $mode = shift || '';

    $self->scripts(qw());

    opendir( D, $self->texroot ) || die $!;
    while ( my $file = readdir(D) ) {
        $file = basename($file);
        $file =~ s/^\.\///g;
        next if -d $file;
        if ( $file =~ /^(\w+)$/ ) {
            $self->scripts_push($1);
        }
    }
    closedir(D);

    $self->scripts_sort();
    $self->scripts_uniq();

    unless ($mode) {
        $self->scripts_print();
        return 1;
    }

    foreach ($mode) {
        /^less$/ && do {
            open( LESS, "| less" ) || die $!;
            $self->scripts_print( \*LESS );
            close(LESS);
            next;
          }
    }

}

# }}}


1;
 

