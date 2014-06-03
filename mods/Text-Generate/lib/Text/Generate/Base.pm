
package Text::Generate::Base;

use strict;
use warnings;

=head1 NAME

Text::Generate::Base - base package for all package in L<Text::Generate> distribution

=cut

use parent qw( 
	Class::Accessor::Complex
);

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    text
    ofile
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
    ->mk_hash_accessors(@hash_accessors)
	->mk_new;

sub _die {
    my $self=shift;

    my $msg=shift;

	die "$msg";

}

sub _warn {
    my $self=shift;

    my $msg=shift;

	warn "$msg";

}

sub _writefile {
    my $self=shift;

    $self->_print(
		{
			file => $self->ofile, 
			fmode => 'w' 
		});

}

sub _appendfile {
    my $self=shift;

    $self->_print({file => $self->ofile, fmode => 'a' });

}

sub _print_stdout {
    my $self = shift;

    print $self->text . "\n";

}

=head3 _print

X<_print,Text::Generator::Base>

=head4 Usage

	_print($opts);

=head4 Purpose

=head4 Input

=over 4

=item * C<$opts> (HASH) 

Input options for printing

=back

=head4 Returns

=over 4

=item * 1, if success;

=item * 0, if failure.

=back

=head4 See also

L<_writefile>

=cut

sub _print {
    my $self = shift;

    my $opts = shift // '';

    unless ($opts) {
        print $self->text;
        return 1;
    }

    $opts->{fmode} = $self->default_options("print_file_mode")
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
        else {
            print $self->text;
        }
    }
}

sub init {
    my $self = shift;

    $self->default_options( 
		print_file_mode => 'w' 
	);

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

=head3 _c

X<_c,Text::Generator::Base>

=head4 Usage

	_c($text);

=head4 Purpose

=head4 Input

=over 4

=item * C<$ref> 

(SCALAR) Input text to be added as a comment using the value of C<commentchar>
accessor as a comment char, e.g. C<%> for C<LaTeX> etc.

=back

=cut

sub _c {
    my $self = shift;

    my $text = shift // '';

    $self->_add_line($self->commentchar . "$text");

}

=head3 _clear

X<_clear,Text::Generator::Base>

=head4 Usage

	_clear();

=head4 Purpose

Clear the contents of C<textlines> and C<text> scalar accessors.

=cut

sub _clear {
    my $self = shift;

    $self->text('');
    $self->indent(0);
    $self->textlines_clear;

}

sub _empty_lines {
    my $self = shift;

    my $num = shift // 1;

    for ( 1 .. $num ) {
        $self->_add_line(" ");
    }
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

    my $value=shift // 1;

    for($id){
        /^indent$/ && do {
            $self->indent($self->indent-$value);
            next;
        };
    }
}

1;
__END__

=head1 LICENSE

Perl Artistic License.

=head1 AUTHOR

Oleksandr Poplavskyy.

=cut

