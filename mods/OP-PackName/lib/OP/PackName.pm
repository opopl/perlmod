package OP::PackName;

use strict;

use warnings;

use File::Slurp qw(
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

use File::Spec::Functions qw(catfile rel2abs curdir catdir );

use File::Basename;
use Getopt::Long;

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    moddef
    notpod
    ifile
    packstr
    printdir
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
    accdesc
    opts
    optsnew
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
    packnames
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);


# _begin() {{{

=head3 _begin()

=cut

sub _begin() {
    my $self = shift;

    $self->{package_name} = __PACKAGE__ unless defined $self->{package_name};

    $self->accessors(
        array    => \@array_accessors,
        hash     => \@hash_accessors,
        'scalar' => \@scalar_accessors
    );

}

# }}}
# get_opt() {{{

sub get_opt () {
    my $self=shift;
    
    $self->OP::Script::get_opt();
}

# }}}

sub set_these_cmdopts() {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts();

    my $o = [];
    my $desc = {};

###define_opt_ifile
    push(
        @$o,
        {
            name => "ifile",
            desc => "Input Perl package name",
            type => "s"
        }
    );

###define_opt_printdir
    push( @$o, { 
            name => "printdir", 
            desc => "Return the package's root directory" 
        } );

    $self->add_cmd_opts($o);

}

# new() {{{

sub new() {
    my $pack = shift;

    my $o = shift // '';

    my $self=$pack->OP::Script::new();

    $self->optsnew($o);

    return $self;

}

# }}}
# init_vars() {{{

sub init_vars () {
    my $self=shift;

    $self->notpod(1);

    $self->opts(
        { skip_get_opt  => 0 }
    );

    $self->opts($self->optsnew);

    $self->opts_to_scalar_vars(qw( ifile ));
    $self->opts_bool_to_scalar_vars(qw( printdir ));

}

# }}}

sub process_opts {
    my $self=shift;

    my $o=shift // '';

    return unless $o;

    foreach my $id (qw( ifile printdir )) {
        eval 'next unless defined $o->{' . $id . '}' ;

        my $evs='$self->' . $id . '($o->{' . $id . '})' ;
        eval "$evs";
        die $@ if $@;

        eval "die 'Failed to set accessor: " . $id . "' unless \$self->" . $id;
    }


}

sub printresult {
    my $self=shift;

    unless ($self->ifile) {
        warn "OP::PackName::printresult(): ifile accessor is zero!";
        return;
    }

    my $fpath=rel2abs($self->ifile);
	
    if ($self->printdir){
        my $moddef=$self->moddef;
        if ($fpath =~ m/$moddef$/){
            $fpath =~ s/$moddef//g;
        }
        print $fpath . "\n";
    }else{

	    unless ($self->packstr) {
			#warn "OP::PackName::printresult(): packstr accessor is zero!";
	        return;
	    }

        print $self->packstr . "\n";
    }

}

sub getpackstr {
    my $self=shift;

    my @lines;
    my $str='';
    my $moddef;

    unless ($self->ifile) {
        warn "OP::PackName::getpackstr(): ifile accessor is zero!";
        return;
    }

	if ( -e $self->ifile ){
		@lines=read_file $self->ifile;
        $self->packnames();
	
		foreach my $line (@lines) {
			chomp($line);
	
			do { $self->notpod(0); next; } if ($line=~ m/^=(head|pod)/);
			do { $self->notpod(1); next; } if ($line=~ m/^=(cut)/);
	
			if ($self->notpod){
				$self->packnames_push($1) if  ($line =~ m/^\s*package\s+(.*);\s*$/);
			}
		}
	
        if ($self->packnames){
		    $str= $self->packnames_join(',');
        }else{
            die "Could not identify the package name!"
        }
        $self->moddef(join('/',split('::',$str)) . '.pm');

	}else{
		$str=basename($self->ifile);
	}

    $self->packstr($str);
}

sub run() {
    my $self=shift;

    my $o=shift // '';

    # $o -> $self->opts
    $self->process_opts($o);

    $self->getpackstr;

    $self->printresult;

}

sub main() {
    my $self=shift;

    my $o=shift // '';

    $self->get_opt() unless $self->opts('skip_get_opt');

    $self->init_vars();

    $self->run($o);

    return $self->packstr;

}

1;
