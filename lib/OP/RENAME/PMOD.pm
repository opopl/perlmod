
package OP::RENAME::PMOD;

use strict;
use warnings;

use OP::Perl::Installer;
use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use File::Slurp qw(
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

# =======================
# accessors {{{

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    module
    mpath
    textcolor
    pi
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
);

###__ACCESSORS_ARRAY
our @array_accessors=qw(
  hashes
  scalars
  arrays
);

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);

# }}}
# =======================
# Core {{{

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

=head3 get_opt()

=cut

sub get_opt() {
    my $self = shift;

    $self->OP::Script::get_opt();

    $self->opts_to_scalar_vars(qw(module));

}

# }}}
# init_vars() {{{

=head3 init_vars()

=cut

sub init_vars() {
    my $self = shift;

    $self->_begin();

    $self->pi(OP::Perl::Installer->new);
    $self->pi->init_vars;
    $self->pi->init;
    $self->pi->install_modules;

    $self->module("OP::GOPS::RIF");

}

# }}}
# main() {{{

##TODO main

sub main() {
    my $self = shift;

    $self->init_vars();
    $self->get_opt();
    $self->run();

}

# }}}
# new() {{{

sub new() {
    my $self = shift;

    $self->OP::Script::new();

}

# }}}
# run() {{{

##TODO run

sub run() {
    my $self = shift;

    my $mpath=$self->pi->module_full_local_path($self->module);
    $self->mpath(catfile($self->pi->dirs("mods"),$mpath));

    unless (-e $self->mpath) {
      die "Module file not found";
    }

    $self->do_rename;
}

sub do_rename {
  my $self=shift;

  $self->say("Renaming module: " . $self->module );

  $self->scalars(qw(
      oph
      opname
      boolparser
  ));

  $self->hashes(qw(
    fortranops
    match
    perlops
    reif
    re
    reend
    linevars
  ));

  # Parser::BL
  #my($oph,$opname,$boolparser);

  $self->arrays(qw(
    matchkeys 
    kreif
    flines
    ifs
    flines
    lvarkeysall
  ));

  edit_file_lines {
  } $self->mpath;

}

# }}}
# set_these_cmdopts() {{{

=head3 set_these_cmdopts()

=cut

sub set_these_cmdopts() {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts();

    my $opts = [];
    my $desc = {};

    push(
        @$opts,
        {
            name => "module",
            desc => "Specify the name of the module to be renamed",
            type => "s"
        },
        {
            name => "run",
            desc => "Run"
        },
    );

    $self->add_cmd_opts($opts);

}

# }}}

# }}}
# =======================

1;

