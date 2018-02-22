
package File::Dat::Utils;

=head1 NAME

File::Dat::Utils - methods for reading text files with dictionaries and list

=head1 USAGE

	use File::Dat::Utils qw(readarr readhash);

=head1 METHODS


=cut

use strict;
use warnings;

use base qw(Exporter);

use File::Slurp qw(read_file);
use List::MoreUtils qw(uniq);

our @EXPORT_OK=qw( readarr readhash );

sub readarr;
sub readhash;

=head2 readarr

=head3 Usage

	# $file - input dat-file
	my @vars = readarr($file);

	# separator between records on the same line
	my @vars = readarr($file,{ sep => $sep });

=head3 Returns

	Array in list context, arrayref in scalar context

=cut

sub readarr {
    my $if   = shift || '';

	my $opts = shift || {};

	my $splitsep = $opts->{sep} || qr/\s+/;
	my $joinsep  = $opts->{sep} || ' ';

    unless ($if) {
        warn "empty file name provided: $if";
        return wantarray ? () : [];
    }

    unless ( -e $if ) {
        warn "file does not exist: $if";
        return wantarray ? () : [];
    }
    my @lines=read_file($if);

    my @vars;

    foreach(@lines) {
        chomp;
        s/^\s*//g;
        s/\s*$//g;
        next if ( /^\s*#/ || /^\s*$/ );
        my $line = $_;
        my @F = split( $splitsep, $line );
        push( @vars, @F );
    }

    @vars = uniq(@vars);

    wantarray ? @vars : \@vars;

}

=head2 readhash

=cut

sub readhash {
    my $if = shift;

    my $opts = shift || {};

    my $splitsep = $opts->{sep} || qr/\s+/;
    my $joinsep  = $opts->{sep} || ' ';
	my $valtype  = $opts->{valtype} || 'scalar';

    unless ( -e $if ) {
        if (wantarray) {
            return ();
        }
        else {
            return {};
        }
    }

    open( FILE, "<$if" ) || die $!;

    my %hash = ();
    my ( @F, $line, $var );

    my $mainline = 1;

    while (<FILE>) {
        chomp;

        s/\s*$//g;

        next if ( /^\s*#/ || /^\s*$/ );

        $mainline = 1 if (/^\w/);
        $mainline = 0 if (/^\s+/);

        $line = $_;

        $line =~ s/\s*$//g;
        $line =~ s/^\s*//g;

        if ($mainline) {

            @F = split( $splitsep, $line );

            for (@F) {
                s/^\s*//g;
                s/\s*$//g;
            }

            $var = shift @F;

			if ($valtype eq 'scalar'){
            	$hash{$var} = '' unless defined $hash{$var};

	            if (@F) {
	                $hash{$var} .= join( $joinsep, @F );
	            }

			} elsif ($valtype eq 'array'){
            	$hash{$var} = [] unless defined $hash{$var};

	            if (@F) {
	                push(@{$hash{$var}},@F );
	            }
			}


        }
        else {

			if ($valtype eq 'scalar'){
            	$hash{$var} .= ' ' . $line;

			} elsif ($valtype eq 'array'){
            	push(@{$hash{$var}},$line);

			}
        }

		if ($valtype eq 'scalar'){
        	$hash{$var} =~ s/\s+/ /g;
		}
    }

    close(FILE);

    wantarray ? %hash : \%hash;

}

1;

