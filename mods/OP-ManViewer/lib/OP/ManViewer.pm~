
package OP::ManViewer;

use warnings;
use strict;

use Env qw($hm @MANPATH);
use OP::Script::Simple qw(:vars :funcs);
use File::Spec::Functions qw(catfile rel2abs curdir catdir );
use File::Find;
use Data::Dumper;
use OP::Base qw(uniq);

use parent qw( OP::Script Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors=qw(
    textcolor
    TOPIC
);

###__ACCESSORS_HASH
our @hash_accessors=qw(
    accessors
    runopts
);


###__ACCESSORS_ARRAY
our @array_accessors=qw();

__PACKAGE__
    ->mk_scalar_accessors(@scalar_accessors)
    ->mk_array_accessors(@array_accessors)
    ->mk_hash_accessors(@hash_accessors);


###our
our $TOPIC;
our $FOUND;

sub new {
    my $self = shift;

    $self->OP::Script::new;

}

sub init_vars {
}

sub set_these_cmdopts {
    my $self = shift;

    $self->OP::Script::set_these_cmdopts;

    my $opts = [];
    my $desc = {};

    push( @$opts, { name => "less", desc => "Use less" } );
    push( @$opts, { name => "shell", desc => "Start the interactive shell" } );

    $self->add_cmd_opts($opts);

}



sub main {
    my $self=shift;

    $self->init_vars;
    $self->get_opt;
    $self->run;

}

sub get_opt {
    my $self=shift;

    $self->OP::Script::get_opt;

    $self->TOPIC(shift @ARGV);

}

sub wanted {

    if (/^$TOPIC\.(\d+)$/){
        push(@{$FOUND->{nums}},$1);
        push(@{$FOUND->{paths}->{$1}},$File::Find::name);
    }
}

sub run {
    my $self=shift;

    $self->runopts(@_);

    unshift(@MANPATH,catdir(qw( /usr share man) ));
    unshift(@MANPATH,catdir(qw( /usr local share man) ));

    $TOPIC=$self->TOPIC;

    foreach my $dir (@MANPATH) {
        find({ wanted => \&wanted }, $dir );
    }

    my @nums=@{$FOUND->{nums}};
    my %paths=%{$FOUND->{paths}};

    @nums=uniq(@nums);

    if ( @nums == 1 ){
        my $num=shift @nums;
        my @files=@{$paths{$num}};

        @files=uniq(@files);
            
        $self->viewman(shift @files);

    }
}

sub viewman {
    my $self=shift;

    my $file=shift;

    my $cmd="cat $file | groff -Tascii -man ";
    
    if($self->_opt_true('less')){
        $cmd.=" | less";
    }
    system("$cmd");

}

1;

