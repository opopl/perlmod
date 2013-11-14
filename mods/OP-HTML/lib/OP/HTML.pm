
package OP::HTML;

use strict;
use warnings;

use feature qw(switch);

use parent qw( OP::Writer );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    openedtags
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);


sub _init {
    my $self = shift;

    $self->OP::Writer::_init;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

}

=head3 _tag_open

_tag_open('tag',{ name => 'a' });

=cut

sub _tag_open {
    my $self=shift;

    my $tag=shift // '';
    my $attr=shift // '';

    my $attr_str='';

    if (ref $attr eq "HASH") {
        while(my($k,$v)=each %{$attr}){
            $attr_str.=' ' . $k . '=' . '"' . $v . '"';
        }
    }

    my $text="<$tag" . "$attr_str" . '>';
    $self->_add_line($text);

    $self->plus('indent');

}

sub _tag_single {
    my $self=shift;

    my $tag=shift // '';
    my $attr=shift // '';

    my $attr_str='';

    if (ref $attr eq "HASH") {
        while(my($k,$v)=each %{$attr}){
            $attr_str.=' ' . $k . '=' . '"' . $v . '"';
        }
    }

    my $text="<$tag" . "$attr_str" . ' />';
    $self->_add_line($text);

}

sub _tag_close {
    my $self=shift;

    my $tag=shift // '';
    my $title=shift // '';

    my $attr=shift // '';

    $self->minus('indent');

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
    $self->openedtags(@$tags);

}

sub close_tags {
    my $self=shift;

    my $tags=shift;

    my $i=$self->openedtags_count-1;

    foreach my $tag (@$tags) {
        $self->_tag_close($tag);
        $self->openedtags_pop;
        $i--;
    }

}

sub head {
    my $self=shift;

    my $ref=shift // '';

    $self->_tag_open(qw(head));

    unless (ref $ref) {
    }elsif(ref $ref eq "HASH"){
        while(my($k,$v)=each %{$ref}){
            given($k){
                when('title') { 
                    $self->title($v);
                }
                default { }
            }
        }
    }

    $self->_tag_close(qw(head));

}

sub title {
    my $self=shift;

    my $title=shift;

    $self->_tag('title',$title);
}

=head3 frameset()

$H->frameset({ 
    cols => '25%,75%',
        frames => [ 
            { src => 'SRC1', name => 'NAME1 '},
            { src => 'SRC2', name => 'NAME2 '},
        ],
});

=cut

sub frameset {
    my $self=shift;

    my $ref=shift;
    my $attr;

    foreach my $id (qw( cols )) {
        $attr->{$id}=$ref->{$id};
    }

    $self->_tag_open('frameset', $attr );

    foreach my $frame (@{$ref->{frames}}) {
        $self->frame($frame);
    }

    $self->close_tags([qw(frameset)]);

}

sub frame {
    my $self=shift;

    my $frame=shift;

    $self->_tag_single('frame',$frame);
}

sub _start {
    my $self=shift;

    $self->_clear;

    $self->open_tags([qw(html)]);

}

sub _end {
    my $self=shift;

    $self->close_tags([qw(html)]);

}

sub li {
    my $self=shift;

    my $title=shift // '';

    $self->_tag('li',$title);
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
