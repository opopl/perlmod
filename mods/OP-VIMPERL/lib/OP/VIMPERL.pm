package OP::VIMPERL;

=head1 NAME 

OP::VIMPERL - Perl package for efficient interaction with VimScript

=head1 USAGE

=cut

use strict;
use warnings;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use File::Spec::Functions qw(catfile rel2abs curdir catdir );

use OP::Base qw( readarr _hash_add );
use OP::Perl::Installer;
use OP::PERL::PMINST;
use OP::PackName;
use Text::TabularDisplay;

use Data::Dumper;
use File::Basename qw(basename dirname);
use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT = qw();

=head1 EXPORTS

=head2 SUBROUTINES

=head2 VARIABLES

=cut

###export_vars_scalar
my @ex_vars_scalar = qw(
  $ArgString
  $NumArgs
  $MsgColor
  $MsgPrefix
  $MsgDebug
  $ModuleName
  $SubName
  $FullSubName
  $CurBuf
  $UnderVim
);
###export_vars_hash
my @ex_vars_hash = qw(
  %DIRS
);
###export_vars_array
my @ex_vars_array = qw(
  @BUFLIST
  @BFILES
  @Args
  @NamedArgs
  @PIECES
  @LOCALMODULES
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [
        qw(
          _die
          init
          init_Args
          init_PIECES
          VimArg
          VimBufFiles_Insert_SubName
          VimChooseFromPrompt
          VimCreatePrompt
          VimCurBuf_Basename
          VimCmd
          VimEcho
          VimEditBufFiles
          VimEval
          VimExists
          VimPerlGetModuleName
          VimGetFromChooseDialog
          VimGrep
          VimInput
          VimJoin
          VimLen
          VimLet
          VimSet
          VimMsg
          VimMsgDebug
          VimMsgE
          VimMsgNL
          Vim_MsgColor
          Vim_MsgPrefix
          Vim_MsgDebug
          Vim_Files
          VimPerlInstallModule
          VimPerlViewModule
          VimPerlModuleNameFromPath
          VimPerlPathFromModuleName
          VimPerlGetModuleNameFromDialog
          VimPieceFullFile
          VimResetVars
          VimSo
          VimSetTags
          VimVar
          VimVarType
          VimVarDump
          )
    ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

sub _die;
sub init;
sub init_Args;
sub init_PIECES;

sub VimArg;
sub VimCurBuf_Basename;
sub VimBufFiles_Insert_SubName;
sub VimCmd;
sub VimChooseFromPrompt;
sub VimCreatePrompt;
sub VimEcho;
sub VimEditBufFiles;
sub VimEval;
sub VimExists;
sub VimGetFromChooseDialog;
sub VimGrep;
sub VimInput;
sub VimJoin;
sub VimLet;
sub VimSet;
# -------------- messages --------------------
sub VimMsg;
sub VimMsgNL;
sub VimMsgDebug;
sub VimMsgE;
sub VimMsgPack;
sub VimMsg_PE;
# -------------- perl --------------------
sub VimPerlGetModuleName;
sub VimPerlInstallModule;
sub VimPerlViewModule;
sub VimPerlModuleNameFromPath;
sub VimPerlPathFromModuleName;
sub VimPerlGetModuleNameFromDialog;
# -------------- vimrc pieces ------------
sub VimPieceFullFile;
sub VimResetVars;
sub VimSo;
sub VimSetTags;
sub VimVar;
sub VimVarType;
sub VimVarDump;
sub VimLen;

sub Vim_Files;

sub Vim_MsgColor;
sub Vim_MsgPrefix;
sub Vim_MsgDebug;

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT    = qw( );
our $VERSION   = '0.01';

################################
# GLOBAL VARIABLE DECLARATIONS
################################
###our
###our_scalar
# --- package loading, running under vim  
our $UnderVim;
#
# --- join(a:000,' ')
our $ArgString;

# --- len(a:000)
our ($NumArgs);

# --- VIM::Eval return values
our ( $EvalCode, $res );

# ---
our ($SubName);        #   => x
our ($FullSubName);    #   => VIMPERL_x

# ---
our ($CurBuf);

# ---
our ($MsgColor);
our ($MsgPrefix);
our ($MsgDebug);

# ---
our ($ModuleName);
###our_array
our @BUFLIST;
our @BFILES;
our @PIECES;
our @LOCALMODULES;
our ( @Args, @NamedArgs );
###our_hash
our %DIRS;
our (@INITIDS);

=head1 SUBROUTINES

=cut

sub VimCmd {
    my $cmd = shift;

    return VIM::DoCommand("$cmd");

}

sub VimArg {
    my $num = shift;

    my $arg = VimEval("a:$num");

    $arg;

}

sub VimSo {
    my $file = shift;

    return unless $file;

    VimCmd("source $file");

}

sub VimLen {
    my $name = shift;

    my $len = 0;

    if ( VimExists($name) ) {
        $len = VimEval("len($name)");
    }

    return $len;
}

#   examples:
#       VimVar('000','arr','a')
#       VimVar('confdir','','g')

=head3 VimVar($var,$rtype,$vtype)

Return Perl representation of VimScript variable

=cut

sub VimVar {

    my $var = shift;

    return '' unless VimExists($var);

    my $res;
    my $vartype = VimVarType($var);

    for ($vartype) {
        /^(String|Number|Float)$/ && do {
            $res = VimEval($var);

            next;
        };
        /^List$/ && do {
            my $len = VimEval( 'len(' . $var . ')' );
            my $i   = 0;
            $res = [];

            while ( $i < $len ) {
                my @v = split( "\n", VimEval( $var . '[' . $i . ']' ) );
                my $first = shift @v;

                if (@v) {
                    $res->[$i] = [ $first, @v ];
                }
                else {
                    $res->[$i] = $first;
                }

                $i++;
            }

            next;
        };
        /^Dictionary$/ && do {
            $res = {};
            my @keys = VimVar( 'keys(' . $var . ')' );

            foreach my $k (@keys) {
                $res->{$k} = VimVar( $var . '[' . $k . ']' );
            }

            next;
        };
    }

    unless ( ref $res ) {
        $res;
    }
    elsif ( ref $res eq "ARRAY" ) {
        wantarray ? @$res : $res;
    }
    elsif ( ref $res eq "HASH" ) {
        wantarray ? %$res : $res;
    }

}

sub VimVarDump {
    my $var = shift;

    my $ref = VimVar($var);

    VIM::Msg("--------------------------------------");
    VIM::Msg( "Type of Vim variable $var : " . VimVarType($var) );
    VIM::Msg("Contents of Vim variable $var :");
    VIM::Msg( Data::Dumper->Dump( [$ref], [$var] ) );

}

sub VimVarType {
    my $var = shift;

    return '_NOT_EXIST_' unless VimExists($var);

    my $vimcode = <<"EOV";

      if type($var) == type('')
        let type='String'
      elseif type($var) == type(1)
        let type='Number'
      elseif type($var) == type(1.1)
        let type='Float'
      elseif type($var) == type([])
        let type='List'
      elseif type($var) == type({})
        let type='Dictionary'
      endif
  
EOV
    VimCmd("$vimcode");

    my $vartype = VimEval('type');
    return $vartype;

}

sub VimGrep {
    my $pat = shift;

    my $ref = shift;
    my @files;

    unless ( ref $ref ) {

    }
    elsif ( ref $ref eq "ARRAY" ) {
        @files = @$ref;
        VimCmd("vimgrep /$pat/ @files");
    }

    return 1;

}

sub VimEcho {
    my $cmd = shift;

    VimMsg( VimEval($cmd), { prefix => 'none' } );

}

sub VimEval {
    my $cmd = shift;

    #return '' unless VimExists($cmd);

    ( $EvalCode, $res ) = VIM::Eval("$cmd");

    unless ($EvalCode) {
        _die "VIM::Eval evaluation failed for command: $cmd";
    }

    $res;

}

sub VimExists {
    my $expr = shift;

    ( $EvalCode, $res ) = VIM::Eval( 'exists("' . $expr . '")' );

    $res;

}

sub VimMsgPack {
    my $text = shift;

    VIM::Msg( __PACKAGE__ . "> $text" );

}

sub VimInput {
    my ( $dialog, $default ) = @_;

    unless ( defined $default ) {
        VimCmd( "let input=input(" . "'" . $dialog . "'" . ")" );
    }
    else {
        VimCmd(
            "let input=input(" . "'" . $dialog . "','" . $default . "'" . ")" );
    }

    my $inp = VimVar("input");

    return $inp;
}

=head3 VimChooseFromPrompt($dialog,$list,$sep,@args)

=over 4

=item $dialog (SCALAR) Input dialog message string
=item $list   (SCALAR) String, containing list of values to be selected (separated by $sep)
=item $sep   (SCALAR) Separator of values in $list 

=back

This is perl implementation of 
vimscript function F_ChooseFromPrompt(dialog, list, sep, ...)
in funcs.vim

=cut

#function! F_ChooseFromPrompt(dialog, list, sep, ...)

sub VimChooseFromPrompt {
    my ( $dialog, $list, $sep, @args ) = @_;

    unless ( ref $list eq "" ) {
        VimMsg_PE("Input list is not SCALAR ");
        return 0;
    }

    #let inp = input(a:dialog)
    my $inp = VimInput($dialog);

    my @opts = split( "$sep", $list );

    my $empty;
    if (@args) {
        $empty = shift @args;
    }
    else {
        $empty = $list->[0];
    }

    my $result;

    unless ($inp) {
        $result = $empty;
    }
    elsif ( $inp =~ /^\s*(?<num>\d+)\s*$/ ) {
        $result = $opts[ $+{num} - 1 ];
    }
    else {
        $result = $inp;
    }

    return $result;

    #endfunction
}

sub VimCreatePrompt {
    my ( $list, $cols, $listsep ) = @_;

    my $numcommon;

    use integer;

    $numcommon = scalar @$list;

    my $promptstr = "";

    my @tableheader = split( " ", "Number Option" x $cols );
    my $table = Text::TabularDisplay->new(@tableheader);
    my @row;

    my $i     = 0;
    my $nrows = $numcommon / $cols;

    while ( $i < $nrows ) {
        @row = ();
        my $j = $i;

        for my $ncol ( ( 1 .. $cols ) ) {
            $j = $i + ( $ncol - 1 ) * $nrows;

            my $modj = $list->[$j];
            push( @row, $j + 1 );
            push( @row, $modj );

        }
        $table->add(@row);
        $i++;
    }

    $promptstr = $table->render;

    return $promptstr;

}

sub VimGetFromChooseDialog {
    my $iopts = shift;

    unless ( ref $iopts eq "HASH" ) {
        VimMsg_PE("input parameter opts should be HASH");
        return undef;
    }
    my $opts;

    $opts = {
        numcols  => 1,
        list     => [],
        startopt => '',
        header   => 'Option Choose Dialog',
        bottom   => 'Choose an option: ',
        selected => 'Selected: ',
    };

    my ( $dialog, $liststr );
    my $opt;

    $opts = _hash_add( $opts, $iopts );
    $liststr = _join( "\n", $opts->{list} );

    $dialog .= $opts->{header} . "\n";
    $dialog .= VimCreatePrompt( $opts->{list}, $opts->{numcols} ) . "\n";
    $dialog .= $opts->{bottom} . "\n";

    $opt = VimChooseFromPrompt( $dialog, $liststr, "\n", $opts->{startopt} );
    VimMsgNL;
    VimMsg( $opts->{selected} . $opt, { hl => 'Title' } );

    return $opt;

}

sub VimPerlGetModuleNameFromDialog {

    my $opts = {
        header  => "Choose the module name",
        bottom  => "Select the number of the module: ",
        list    => [@LOCALMODULES],
        numcols => 2,
    };

    my $module = VimGetFromChooseDialog($opts);

    return $module;

}

##TODO todo_GetModuleName

sub VimPerlGetModuleName {

    my $path = $CurBuf->{name} // '';
    my $module = '';

    unless ($path) {
        VimMsgE('Failed to get $CurBuf->{name} from OP::VIMPERL');

        $module = VimPerlGetModuleNameFromDialog;
    }
    else {
        $module = VimPerlModuleNameFromPath($path);
    }
    VimMsg("Module name is set as: $module");

    $ModuleName = $module if $module;

    return $module;

}

sub VimPerlPathFromModuleName {
    my $module = shift // $ModuleName // '';

    return '' unless $module;

    my $pmi = OP::PERL::PMINST->new;

    my $i = OP::Perl::Installer->new;
    $i->main;

    my $opts    = {};
    my $pattern = '.';

    $opts = {
        PATTERN    => "^" . $module . '$',
        mode       => "fullpath",
        searchdirs => $i->module_libdir($module),
    };

    $pmi->main($opts);

    my @localpaths = $pmi->MPATHS;

    return shift @localpaths;

}

sub VimPerlModuleNameFromPath {
    my $path = shift;

    unless ( -e $path ) {
        VimMsgE( 'File :' . $path . ' does not exist' );
        return '';
    }

    my $module;

    VimMsgDebug('Going to create OP::PackName instance ');

    my $p = OP::PackName->new(
        {
            skip_get_opt => 1,
            ifile        => "$path",
        }
    );

    VimMsgDebug( 'Have initialized OP::PackName instance to '
          . Data::Dumper->Dump( [$p], [qw($p)] ) );

    $p->init_vars;

    VimMsgDebug( 'After OP::PackName::init_vars '
          . Data::Dumper->Dump( [$p], [qw($p)] ) );

    $p->run;

    VimMsgDebug(
        'After OP::PackName::run ' . Data::Dumper->Dump( [$p], [qw($p)] ) );

    my $packstr = $p->packstr;

    VimMsg($packstr);

    if ($packstr) {
        VimLet( "g:PMOD_ModuleName", $packstr );
        $ModuleName = $packstr;
        $module     = $packstr;

        VimMsgDebug( '$ModuleName is set to ' . $ModuleName );
    }
    else {
        VimMsgE('Failed to get $packstr from OP::PackName');
    }

    return $module;

}

sub Vim_MsgColor {
    my $color = shift;

    $MsgColor = $color;
    VimLet( "g:MsgColor", "$color" );

}

sub Vim_Files {
    my $id = shift;

    my $file = VimVar("g:files['$id']");

    return $file;
}

sub VimResetVars {
    my $vars = shift // '';

    return '' unless $vars;

    foreach my $var (@$vars) {
        my $evs = 'Vim_' . $var . "('')";
        eval "$evs";
        if ($@) {
            VimMsg_PE($@);
        }
    }
}

sub Vim_MsgPrefix {
    my $prefix = shift;

    if ( defined $prefix ) {
        $MsgPrefix = $prefix;
        VimLet( "g:MsgPrefix", "$prefix" );
    }

}

sub Vim_MsgDebug {
    my $val = shift;

    if ( defined $val ) {
        $MsgDebug = $val;
        VimLet( "g:MsgDebug", $val );
    }

    return $MsgPrefix;

}

sub VimMsgNL {
    VimMsg( " ", { prefix => 'none' } );
}

sub VimMsg {
    my $text = shift // '';

    return '' unless $text;

    my @o   = @_;
    my $ref = shift @o;
    my ($opts);
    my $prefix;

    my $keys = [qw(warn hl prefix color )];
    foreach my $k (@$keys) { $opts->{$k} = ''; }

    $opts->{prefix} = 'subname';

    unless ( ref $ref ) {
        if (@o) {
            my %oo = ( $ref, @o );
            $opts->{$_} = $oo{$_} for ( keys %oo );
        }
        else {
            $opts->{hl} = $ref unless @o;
        }
    }
    elsif ( ref $ref eq "HASH" ) {
        $opts->{$_} = $ref->{$_} for ( keys %$ref );
    }

    for ( $opts->{prefix} ) {
        /^none$/ && do { $prefix = ''; next; };
        /^subname$/ && do { $prefix = "$FullSubName()> "; next; };
    }
    $prefix = $MsgPrefix if $MsgPrefix;

    $opts->{hl} = 'WarningMsg' if $opts->{warn};
    $opts->{hl} = 'ErrorMsg'   if $opts->{error};

    my $colors = {
        yellow => 'CursorLineNr',
        red    => 'WarningMsg',
        green  => 'DiffChange',
    };
    my $color = $MsgColor // '';
    $color = $opts->{color} if $opts->{color};

    $opts->{hl} = $colors->{$color} if $color;

    $text = $prefix . $text;

    if ( $opts->{hl} ) {
        VIM::Msg( "$text", $opts->{hl} );
    }
    else {
        VIM::Msg("$text");
    }

}

sub VimMsg_PE {
    my $text = shift;

    my $subname = ( caller(1) )[3];

    VimMsg( "Error in $subname : " . $text, { error => 1 } );

}

sub VimMsgE {
    my $text = shift;

    #VIM::Msg( "$FullSubName() : $text", "ErrorMsg" );
    VIM::Msg( " $text", "ErrorMsg" );
}

=head3 VimLet ( $var, $ref, $vtype )

=over 4

=item Set the value of a vimscript variable

=item Examples: 

=over 4

=item VimLet('paths',\%paths,'g')

=item VimLet('PMOD_ModSubs',\@SUBS,'g')

=back

=back

=cut

sub VimLet {

    # name of the vimscript variable to be assigned
    my $var = shift;

    # contains value(s) to be assigned to $var
    my $ref = shift;

    my $valstr = '';

    my $lhs = "let $var";

    unless ( ref $ref ) {
        $valstr .= "'$ref'";
    }
    elsif ( ref $ref eq "ARRAY" ) {
        $valstr .= "[ '";
        $valstr .= join( "' , '", @$ref );
        $valstr .= "' ]";
    }
    elsif ( ref $ref eq "HASH" ) {
        unless (%$ref) {
            $valstr = '{}';
        }
        else {
            $valstr .= "{ ";
            while ( my ( $k, $v ) = each %{$ref} ) {
                $valstr .= " '$k' : '$v', ";
            }
            $valstr .= " }";
        }
    }

    if ($valstr) {
        VimCmd( 'if exists("' . $var . '") | unlet ' . $var . ' | endif ' );
        VimCmd( $lhs . '=' . $valstr );
    }

}

sub VimSet {
    my $opt = shift;
    my $val = shift;

    VimCmd("set $opt=$val");

}

sub VimMsgDebug {
    my $msg = shift;

    if ( $MsgDebug eq "1" ) {

        #VimMsg("(D) $msg",{ color => 'green'} );
        VimMsg( "(D) $msg", { hl => 'Folded' } );
    }
}

##TODO todo_PerlInstallModule
###imod

sub VimPerlInstallModule {

    VimPerlGetModuleName;

    my $module = $NumArgs ? $ArgString : $ModuleName;

    my $i=OP::Perl::Installer->new;
    $i->main;
    VimMsg("Running install for module $module");
    $i->run_build_install($module);

}

sub VimPerlViewModule {

    my $module;

    unless($NumArgs){
        $module = VimPerlGetModuleNameFromDialog;
    }else{
        $module = $ArgString;
    }

    my $path = VimPerlPathFromModuleName($module);

    if ( -e $path ) {
        VimCmd("tabnew $path");
    }

}

sub VimPieceFullFile {
    my $piece = shift;

    my $path = catfile( $DIRS{MKVIMRC}, $piece . '.vim' );

}

sub VimSetTags {
    my $ref = shift;

    unless ( ref $ref ) {
        VimSet( "tags", $ref );

    }
    elsif ( ref $ref eq "ARRAY" ) {
        my $first = $ref->[0];

        VimSet( "tags", join( ',', @$ref ) );
        VimLet( "g:CTAGS_CurrentTagID", '_buf_' );
        VimLet( "g:tagfile",            $first );

    }
}

=head3 VimJoin( $arrname, $sep,  $vtype )

=over 4

=item Apply join() on the vimscript array $arrname; returns string

=item Examples: 

=over 4

=item VimJoin('a:000') - Equivalent to join(a:000,' ') in vimscript

=back

=back

=cut

sub VimJoin {
    my $arr = shift;

    my $sep = shift;

    return '' unless VimExists($arr);

    ( $EvalCode, $res ) = VIM::Eval( "join($arr,'" . $sep . "')" );

    return '' unless $EvalCode;

    $res;

}

sub VimCurBuf_Basename {
    my $opts = shift // '';

    my $name=$CurBuf->{name} // '';

		return $name unless $name;

    $name = basename( $name );

    if ($opts) {
        if ( $opts->{remove_extension} ) {
            $name =~ s/\.(\w+)$//g;
        }
    }

    $name;
}

sub VimBufFiles_Edit {

    my $opts = shift;

    my $editopt = $opts->{editopt} // '';

    foreach my $bfile (@BFILES) {
        next unless $bfile =~ /\.vim$/;

        VimMsg("Processing vim file: $bfile");

        ( my $piece = $bfile ) =~ s/(\w+)\.vim/$1/g;

        my @lines = read_file $bfile;

        my %onfun;
        my $fname;
        my @nlines;

        foreach (@lines) {
            chomp;

###BufFiles_InsertSubName
            if ( $editopt == "Insert_SubName" ) {

                /^\s*(?<fdec>fun|function)!\s+(?<fname>\w+)/ && do {
                    $fname = $+{fname};
                    $onfun{$fname} = 1;
                    $_ .= "\n" . " let g:SubName='" . $fname . "'";
                    push( @nlines, $_ );

                    next;
                };

                /^\s*let\s*g:SubName=/ && do {
                    $_ = '';
                    next;
                };
                /^\s*endf(|un|unction)/ && do {
                    $onfun{$fname} = 0 if $fname;

                };
###BufFiles_EditSlurp
            }
            elsif ( $editopt == "EditSlurp" ) {
                my $cmds = $opts->{cmds};
                foreach my $cmd (@$cmds) {
                    my $evs = $cmd;
                    eval "$evs";
                    die $@ if $@;
                }
            }

            push( @nlines, $_ );
        }
        open( F, ">$bfile" ) || die $!;
        foreach my $nline (@nlines) {
            print F $nline . "\n";
        }

        if ( $editopt == "Append_g_Loaded_Pieces" ) {
            print F "let g:LoadedPieces_$piece=1";
        }
        close(F);
    }
}

sub init {

    my %opts = @_;

    eval 'Vim::Eval("1")';
    unless ($@) {
        $UnderVim=1;
    }else{
        $UnderVim=0;
        return;
    }

    unless ( defined $SubName ) {
        $FullSubName = VimVar('g:SubName');
    }

    ( $SubName = $FullSubName ) =~ s/^VIMPERL_//g;

    @INITIDS = qw(
      Args
      CurBuf
      PIECES
      MODULES
    );

    @BUFLIST = VIM::Buffers();

    %DIRS = (
        'TAGS'    => catfile( $ENV{HOME}, 'tags' ),
        'MKVIMRC' => catfile( $ENV{HOME}, qw( config mk vimrc ) ),
    );

    @BFILES = ();

    foreach my $buf (@BUFLIST) {
        my $name = $buf->Name();
        $name =~ s/^\s*//g;
        $name =~ s/\s*$//g;
        push( @BFILES, $name ) if -e $name;
    }

    foreach my $id (@INITIDS) {
        eval 'init_' . $id;
        _die $@ if $@;
    }

    $MsgColor  = VimVar("g:MsgColor");
    $MsgPrefix = VimVar("g:MsgPrefix");
    $MsgDebug  = VimVar("g:MsgDebug");

}

sub VimEditBufFiles {
    my $cmds = shift // $ArgString;

    unless ($cmds) {
        VimMsgE("No commands were provided");
        return 0;
    }

    my $slurpsub = shift // 'edit_file_lines';

    VimMsg("Will apply to all buffers: $cmds");

    foreach my $bfile (@BFILES) {
        VimMsg("Processing buffer: $bfile");
        my $evs = $slurpsub . ' { ' . $cmds . ' } $bfile';
        eval "$evs";
        die $@ if $@;
    }

}

sub _die {
    my $text = shift;

    die "VIMPERL_$SubName : $text";
}

=head3 init_Args()

Process optional vimscript command-line arguments ( specified as ... in
vimscript function declarations )

=cut

sub init_Args {

    $NumArgs   = 0;
    $ArgString = '';
    @Args      = ();

    $NumArgs = VimLen('a:000');

    if ($NumArgs) {
        @Args = VimVar('a:000');
        $ArgString = VimJoin( 'a:000', ' ' );
    }
}

sub init_MODULES {
    @LOCALMODULES = VimVar('g:PMOD_available_mods');
}

sub init_CurBuf {

    $CurBuf->{name}   = VimEval("bufname('%')");
    $CurBuf->{number} = VimEval("bufnr('%')");

}

sub init_PIECES {
    @PIECES = readarr( catfile( $DIRS{MKVIMRC}, qw(files.i.dat) ) );
}

###BEGIN
BEGIN {
    init;
}

1;

