
package File::Dat::Utils;

use strict;
use warnings;

use parent qw(Exporter);
our @EXPORT_OK=qw( readarr readhash );

sub readarr;
sub readhash;

sub readarr {
    my $if = shift // '';

	my $opts=shift // {};

	my $splitsep=$opts->{sep} // qr/\s+/;
	my $joinsep=$opts->{sep} // ' ';

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

sub readhash {
    my $if = shift;

    my $opts = shift // {};

    my $splitsep = $opts->{sep} // qr/\s+/;
    my $joinsep = $opts->{sep} // ' ';
	my $valtype=$opts->{valtype} // 'scalar';

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

