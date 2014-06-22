
package Apache2::Basevars::Html;
 
use warnings;
use strict;

sub new {
    my ( $class, %ipars ) = @_;
    my $self = bless( \%ipars, ref($class) || $class );

    $self->init;

    return $self;

}

sub init {
	my $self=shift;

	my $opts={
		HTMLLINES => [],
	};

	while(my($k,$v)=each %{$opts}){
		$self->{$k}=$v;
	}
}
 
sub _add {
	my $self=shift;

    push(@{$self->{HTMLLINES}}, @_ );

}

sub start {
	my $self=shift;

	$self->_add( $self->{Q}->start_html(@_) );
}

sub restart {
	my $self=shift;

	$self->clear;
	$self->start;
}

sub print {
	my $self=shift;

    $self->{R}->print($_ . "\n") for(@{$self->{HTMLLINES}});
}

sub clear {
	my $self=shift;

	$self->{HTMLLINES}=[];
}

sub end {
	my $self=shift;

	$self->_add( $self->{Q}->end_html );
}

1;
