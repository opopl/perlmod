
package Text::Generate::Pod;

use strict;
use warnings;

=head1 NAME

Text::Generate::Pod - Perl package for writing Pod documents

=head1 SYNOPSIS

	use Text::Generate::Pod;
	
	my $p=Text::Generate::Pod->new;

	$p->head1('NAME');

	$p->_add_line( ... );
	$p->_add_line( ... );

	$p->head1('SYNOPSIS');

	$p->head1('METHODS');

	$p->head2('method1');

	$p->over({ 
		items => [qw( item1 item2 )],
		start => '*',
		indent => 4,
	});

	$p->cut;

=cut

use IO::String;
use Pod::Usage qw(pod2usage);

use File::Temp qw{tmpnam};
use File::Slurp qw( write_file );
use Try::Tiny;

use parent qw( Text::Generate::Base );

sub init {
    my $self = shift;

    $self->Text::Generate::Base::init;

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
	my $start='';
	
	unless(ref $ref){
        $indent=$ref;
        $self->_pod_line('=over ' . $indent ); 
        return;
        
	}elsif(ref $ref eq "ARRAY"){
	    
	}elsif(ref $ref eq "HASH"){
        $items=$ref->{items};
        $start=$ref->{start} if defined $ref->{start};
        $indent=$ref->{indent} if defined $ref->{indent};
	}

    $self->_pod_line('=over ' . $indent);

    foreach my $item (@$items) {
        $self->item($item, $start);
    }

    $self->back;

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
    my $start=shift . ' ' // '';

    $self->_pod_line('=item ' . $start . $item);

}

sub _print_man {
    my $self=shift;

    $self->_print_pod(2);
}

sub _print_help {
    my $self=shift;

    $self->_print_pod(1);
}


sub _print_pod {
    my $self=shift;

    my $verbose=shift;

    my $POD=tmpnam();

    try { 
        write_file($POD,$self->text);
    } catch {
        warn "Failed to write temporary file " . $POD;
        $POD=IO::String->new($self->text);
    } finally {
        pod2usage( -input => $POD, -verbose => $verbose );
    }


}

1;

__END__

=head1 SEE ALSO 

=over 4

=item * L<Text::Generate::Base>

=item * L<Text::Generate::TeX>

=back

=head1 LICENSE

Perl Artistic License.

=head1 AUTHOR

Oleksandr Poplavskyy.

=cut

