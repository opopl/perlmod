
package OP::Writer::Pod;

use strict;
use warnings;

use feature qw(switch);

use Env qw( $hm $PERLMODDIR );

use IO::String;
use Pod::Usage qw(pod2usage);



use lib("$PERLMODDIR/mods/OP-Writer/lib");
use parent qw( OP::Writer );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

sub _init {
    my $self = shift;

    $self->OP::Writer::_init;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->_pod_line('=pod');

}

sub cut {
    my $self=shift;

    $self->_pod_line('=cut');

}

sub _pod_line {
    my $self=shift;

    my $text=shift;

    $self->_add_line($text);
    $self->_add_line(' ');

}

sub back {
    my $self=shift;

    $self->_pod_line('=back');
}

sub over {
    my $self=shift;

    my $ref=shift;

    my $items;
    my $indent=4;
	
	unless(ref $ref){
        $indent=$ref;
        $self->_pod_line('=over ' . $indent ); 
        return;
        
	}elsif(ref $ref eq "ARRAY"){
	    
	}elsif(ref $ref eq "HASH"){
        $items=$ref->{items};
	}

    $self->_pod_line('=over ' . $indent);

    foreach my $item (@$items) {
        $self->item($item);
    }

    $self->_pod_line('=back');

}


sub head1 {
    my $self=shift;

    my $text=shift;

    $self->_pod_line('=head1 ' . $text);

}

sub head2 {
    my $self=shift;

    my $text=shift;

    $self->_pod_line('=head2 ' . $text);

}

sub head3 {
    my $self=shift;

    my $text=shift;

    $self->_pod_line('=head3 ' . $text);

}

sub head4 {
    my $self=shift;

    my $text=shift;

    $self->_pod_line('=head4 ' . $text);

}


sub item {
    my $self=shift;

    my $item=shift;

    $self->_pod_line('=item ' . $item);

}

sub _print_man {
    my $self=shift;

    my $POD=IO::String->new($self->text);

    pod2usage( -input => $POD, -verbose => 2 );

}

sub _print_help {
    my $self=shift;

    my $POD=IO::String->new($self->text);

    pod2usage( -input => $POD, -verbose => 1 );

}

1;
