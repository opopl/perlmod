
package OP::Writer;
use strict;

use parent qw( OP::Script Class::Accessor::Complex );
use OP::Base qw( %opts %fh );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    textcolor
    text
    commentchar
    delimchar
    delimchars_num
    indent
    indentstr
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
    default_options
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    textlines
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

sub _print {
    my $self = shift;

    my $opts;

    $opts = shift // '';

    unless ($opts) {
        print $self->text;
        return 1;
    }

    $opts->{fmode} = $self->_defaults("print_file_mode")
      unless defined $opts->{fmode};

    if ( ref $opts eq "HASH" ) {
        if ( defined $opts->{file} ) {

            my $file = $opts->{file};

            foreach ( $opts->{fmode} ) {
                /^w$/ && do { open( F, ">$file" ) || die $!; next; };
                /^a$/ && do {
                    open( F, ">>$file" ) || die $!;
                    next;
                };
            }

            print F $self->text;

            close F;

        }
        elsif ( defined $opts{fh} ) {

            my $fh = $opts{fh};

            print $fh { $self->text };

        }
        else {
            print $self->text;
        }
    }
}

sub _defaults {
    my $self = shift;

    my $opt = shift // '';

    return undef unless $opt;

    return $self->default_options( $opt );

}

sub _init {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    my $dopts = { print_file_mode => "w" };

    $self->default_options( $dopts );

    $self->text('');
    $self->textlines();
    $self->indent(0);

    $self->commentchar('#');
    $self->delimchar('-');
    $self->delimchars_num(50);

}

sub _c_delim {
    my $self = shift;

    my $text = $self->delimchar x $self->delimchars_num;

    $self->_c("$text");
}

sub _c {
    my $self = shift;

    my $ref = shift // '';

    my $text = $ref;

    $self->_add_line($self->commentchar . "$text");

}

sub _clear {
    my $self = shift;

    $self->text('');
    $self->textlines_clear;

}

sub _empty_lines {
    my $self = shift;

    my $num = shift // 1;

    for ( 1 .. $num ) {
        $self->_add_line(" ");
    }
}

sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );

    $self->_init;

    return $self;
}

sub _flush {
    my $self = shift;

    $self->_clear;
}

sub _add_line {
    my $self = shift;

    my $ref = shift // '';
    my ( $addtext, $oldtext, $text );

    return 1 unless $ref;

    $oldtext = $self->text // '';

    # In case a string is supplied, this
    #	string is passed as the value of the
    #	internal "text" variable
    unless ( ref $ref ) {
        $addtext = $ref;
    }
    elsif ( ref $ref eq "HASH" ) {
    }
    elsif ( ref $ref eq "ARRAY" ) {
        my $c = shift @$ref;
        my $x = shift @$ref;
        $addtext = "\\" . $c . '{' . $x . '}';
    }
    $addtext=' ' x $self->indent . $addtext;

    $text = $oldtext . $addtext . "\n";
    $self->text( $text );

    $self->textlines_push(split("\n",$addtext));

}

sub plus {
    my $self=shift;

    my $id=shift;
    my $val=shift // 1;

    for($id){
        /^indent$/ && do {
            $self->indent($self->indent+$val);
            next;
        };
    }
}

sub minus {
    my $self=shift;

    my $id=shift;
    my $val=shift // 1;

    for($id){
        /^indent$/ && do {
            $self->indent($self->indent-$val);
            next;
        };
    }
}

1;

