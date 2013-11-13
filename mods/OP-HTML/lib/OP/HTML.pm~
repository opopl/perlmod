
package OP::HTML;

use strict;
use warnings;

use parent qw( OP::Writer );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
our @array_accessors=qw();

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);


sub _init {
    my $self = shift;

    $self->OP::Writer::_init;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

}

sub _tag_open {
    my $self=shift;

    my $tag=shift // '';
    my $title=shift // '';

    my $attr=shift // '';

    my $text="<$tag>";
    $self->_add_line($text);

}

sub _tag_close {
    my $self=shift;

    my $tag=shift // '';
    my $title=shift // '';

    my $attr=shift // '';

    my $text="</$tag>";
    $self->_add_line($text);

}


sub _tag {
    my $self=shift;

    my $tag=shift // '';
    my $title=shift // '';

    my $attr=shift // '';

    my $text="<$tag>" . $title . "</$tag>";
    $self->_add_line($text);

}

sub open_tags {
    my $self=shift;

    my $tags=shift;

    foreach my $tag (@$tags) {
        $self->_tag_open($tag);
    }

}

sub close_tags {
    my $self=shift;

    my $tags=shift;

    foreach my $tag (@$tags) {
        $self->_tag_close($tag);
    }

}

sub h1 {
    my $self=shift;

    my $title=shift // '';

    $self->_tag('h1',$title);
}

sub h2 {
    my $self=shift;

    my $title=shift // '';

    $self->_tag('h2',$title);
}

sub h3 {
    my $self=shift;

    my $title=shift // '';

    $self->_tag('h3',$title);
}

sub h4 {
    my $self=shift;

    my $title=shift // '';

    $self->_tag('h4',$title);
}



1;
