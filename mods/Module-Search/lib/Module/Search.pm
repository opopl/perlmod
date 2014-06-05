
package Module::Search;

use strict;
use warnings;

=head1 NAME

Module::Search - simple perl module searching tool.

=cut

use File::Find ();

sub new {
    my ( $class, %ipars ) = @_;
    my $self = bless( \%ipars, ref($class) || $class );

    $self->init;

    return $self;

}

sub init {
	my $self=shift;

    $self->{pattern} =~ s/::/\//g;

	$self->init_incdirs;
	$self->init_wanted;

}

sub init_incdirs {
	my $self=shift;

    $self->{incdirs}=\@INC unless defined $self->{incdirs};

}

sub init_wanted {
	my $self=shift;

	$self->{wanted}=sub {
	
	    my($fullpath,$module,$relpath,$modslash);

        my $incdir=$self->{incdir};
        my $pattern=$self->{pattern};
	
	    # skip files that do not end with .pm
	    return unless /\.pm$/;
	
	    $fullpath = $File::Find::name;
	
	    $fullpath =~ s/\s*$//g;
	
	    # $relpath  = File/Slurp.pm
	    (  $relpath = $fullpath ) =~ s{^\Q$incdir}{};
	    $relpath =~ s{^[\/]*}{}g;
	
	    # $modslash = File/Slurp
	    (  $modslash=$relpath ) =~ s/\.pm$//g;
	
	    # File::Slurp
	    ( $module = $modslash ) =~ s{\Q/}{::}g;
	
        return if not $modslash =~ /$pattern/;
	
		if ( not grep {/^$fullpath$/ } @{$self->{modpaths}->{$module}}){
	    	push(@{$self->{modpaths}->{$module}},$fullpath);
		}
	
	};
}

sub print_modpaths { 
	my $self=shift;

	my $modpaths=$self->{modpaths};

	while(my($module,$paths)=each %{$modpaths}){
		foreach my $path (@$paths) {
			print $module  . ' ' . $path . "\n";
		}
	}
}

sub print_modules { 
	my $self=shift;

	foreach my $module (@{$self->{modules}}) {
		print $module . "\n";
	}
}

sub search { 
	my $self=shift;

	my %opts=@_;

    my $incdirs=$self->{incdirs};

    foreach my $idir (@$incdirs) {
		next if not -d $idir;

        $self->{incdir}=$idir;

		File::Find::find({ 
			wanted => $self->{wanted}, %opts,
		},  $idir );
    }

	$self->{modules}=[ sort keys %{$self->{modpaths}} ];

}

1;
