package OP::VIMPERL::TEST;

use warnings;
use strict;
use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

use OP::Base qw( ListModuleSubs );
use OP::VIMPERL qw( :funcs :vars );

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT = qw();

###export_vars_scalar
my @ex_vars_scalar = qw(
);
###export_vars_hash
my @ex_vars_hash = qw(
);
###export_vars_array
my @ex_vars_array = qw(
);

###list_of_tests
my @tests=qw(
    ListModuleSubs
    VimInput
    VimChooseFromPrompt
);

s/^/_vimtest_/g for(@tests);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [ @tests, qw() ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT = qw( );
our $VERSION = '0.01';

###subs
sub _vimtest_ListModuleSubs;
sub _vimtest_VimInput;
sub _vimtest_VimChoosePrompt;

#sub _vimtest_<++>;
#sub _vimtest_<++>;
#sub _vimtest_<++>;

sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );
    return $self;
}

sub _vimtest_VimInput {
    my $inp;

    my $default='DDD';
    
    VimMsg("-----------------------------");
    VimMsg("Will test VimInput...");

    $inp=VimInput("Enter a value: ");
    VimMsgNL;
    VimMsg("You have entered: $inp",{hl => 'Title'});

    $inp=VimInput("Enter a value (default=$default): ",$default);
    VimMsgNL;
    VimMsg("You have entered: $inp",{hl => 'Title'});

    VimMsg("Done.");
    VimMsg("-----------------------------");

}

sub _vimtest_VimChooseFromPrompt {
    my $inp;

    my $default='DDD';

    VimMsg("-----------------------------");
    VimMsg("Will test VimChooseFromPrompt...");

    my $opt=VimChooseFromPrompt("Enter the number of option: ", "a:b:c", ":" , "empty");

    VimMsgNL;
    VimMsg("You selected option: $opt",{color => 'yellow'});
    
   
}

sub _vimtest_ListModuleSubs {

    Vim_MsgColor('green');
    VimMsg("Running $FullSubName...");

    # ListModuleSubs
    VimMsg("-----------------------------");
    VimMsg("Will test ListModuleSubs...");
    my @modules = qw(OP::Script OP::Base);

    #my @modules=qw( OP::Base);
    #my @modules=@LOCALMODULES;

    foreach my $module (@modules) {
        my @subs = ListModuleSubs($module);
        Vim_MsgColor('yellow');
        VimMsg("  Module: $module");
        Vim_MsgColor('red');
        VimMsg("  $_\n") for (@subs);
    }

    Vim_MsgColor('');

}
