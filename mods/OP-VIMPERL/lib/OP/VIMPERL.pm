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
use OP::Base qw(readarr);
use Data::Dumper;
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
    
    $CurBuf
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
          VimCmd
          VimEcho
          VimEditBufFiles
          VimEval
          VimExists
          VimGrep
          VimJoin
          VimLen
          VimLet
          VimSet
          VimMsg
          VimMsgE
          VimPieceFullFile
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
sub VimCmd;
sub VimEcho;
sub VimEditBufFiles;
sub VimEval;
sub VimExists;
sub VimGrep;
sub VimJoin;
sub VimLet;
sub VimSet;
sub VimMsg;
sub VimMsgE;
sub VimPieceFullFile;
sub VimSo;
sub VimSetTags;
sub VimVar;
sub VimVarType;
sub VimVarDump;
sub VimLen;

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT    = qw( );
our $VERSION   = '0.01';

###our
our @BUFLIST;
our @BFILES;
our $ArgString;
our ($EvalCode,$res);
our %DIRS;
our @PIECES;
our(@Args,@NamedArgs);
our($NumArgs);
our($SubName);
our($CurBuf);
our(@INITIDS);

=head1 SUBROUTINES

=cut

sub VimCmd {
    my $cmd=shift;

    return VIM::DoCommand("$cmd");

}

sub VimArg {
    my $num=shift;

    my $arg=VimEval("a:$num");

    $arg;

}

sub VimSo {
    my $file=shift;

    return unless $file;

    VimCmd("source $file");

}

sub VimLen {
    my $name=shift;

    my $len=0;

    if (VimExists($name)){
        $len=VimEval("len($name)");
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

    my $var=shift;

    return '' unless VimExists($var);

    my $res;
    my $vartype=VimVarType($var);

    for($vartype){
      /^(String|Number|Float)$/ && do {
        $res=VimEval($var);
        
        next;
      };
      /^List$/ && do {
        my $len=VimEval('len(' . $var . ')');
        my $i=0;
        $res=[];

        while ($i<$len) {
          my @v=split("\n",VimEval($var . '[' . $i . ']'));
          my $first=shift @v;

          if (@v){
              $res->[$i]=[ $first, @v ];
          }else{
              $res->[$i]=$first ;
          }

          $i++;
        }
        
        next;
      };
      /^Dictionary$/ && do {
        $res={};
        my @keys=VimVar('keys(' . $var . ')');

        foreach my $k (@keys) {
           $res->{$k}=VimVar($var . '[' . $k . ']');
        }
        
        next;
      };
    }

    unless(ref $res){
        $res;
    }elsif(ref $res eq "ARRAY"){
        wantarray ? @$res : $res ;
    }elsif(ref $res eq "HASH"){
        wantarray ? %$res : $res ;
    }

}

sub VimVarDump {
    my $var=shift;

    my $ref=VimVar($var);

    VIM::Msg("--------------------------------------");
    VIM::Msg("Type of Vim variable $var : " . VimVarType($var));
    VIM::Msg("Contents of Vim variable $var :");
    VIM::Msg(Data::Dumper->Dump([ $ref ], [ $var ]));

}

sub VimVarType {
    my $var=shift;

    return '_NOT_EXIST_' unless VimExists($var);

		my $vimcode=<<"EOV";

		if exists("*F_type")
    	let type=F_type($var)
		else
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
		endif
	
EOV
		VimCmd("$vimcode");

    my $vartype=VimEval('type');
    return $vartype;

}


sub VimGrep {
  my $pat=shift;

  my $ref=shift;
  my @files;

  unless(ref $ref){
    
  }elsif(ref $ref eq "ARRAY"){
    @files=@$ref;
    VimCmd("vimgrep /$pat/ @files");
  }

  return 1;

}


sub VimEcho {
  my $cmd=shift;

  ($EvalCode,$res)=VIM::Eval("$cmd");

  return '' unless $EvalCode;

  VIM::Msg($res);

}

sub VimEval {
  my $cmd=shift;

  #return '' unless VimExists($cmd);

  ($EvalCode,$res)=VIM::Eval("$cmd");

  unless($EvalCode){
    _die "VIM::Eval evaluation failed for command: $cmd";
  }
  
  $res;

}

sub VimExists {
    my $expr=shift;

    ($EvalCode,$res)=VIM::Eval('exists("' . $expr . '")');

    $res;

}

sub VimMsg {
    my $text=shift;

    my $opts=shift;

    if ($opts->{warn}){	
        VimCmd("echohl WarningMsg");
    }

    VIM::Msg("VIMPERL_$SubName() : $text");

    VimCmd("echohl None");
}

sub VimMsgE {
    my $text=shift;

    VIM::Msg("VIMPERL_$SubName() : $text","ErrorMsg");
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
    my $var=shift;
    # contains value(s) to be assigned to $var
    my $ref=shift;

    my $valstr='';

    my $lhs="let $var";

    unless(ref $ref){
      $valstr.="'$ref'";
    }elsif(ref $ref eq "ARRAY"){
      $valstr.="[ '";
      $valstr.=join("' , '", @$ref);
      $valstr.="' ]";
    }elsif(ref $ref eq "HASH"){
      unless(%$ref){
          $valstr='{}' ;
      }else{
	      $valstr.="{ ";
          while(my($k,$v)=each %{$ref}){
	        $valstr.=" '$k' : '$v', "; 
          }
	      $valstr.=" }";
     }
    }

    if ($valstr){
        VimCmd('if exists("' . $var . '") | unlet ' . $var . ' | endif ');
        VimCmd($lhs . '=' . $valstr);
    }
    
}

sub VimSet {
    my $opt=shift;
    my $val=shift;

    VimCmd("set $opt=$val");

}

sub VimPieceFullFile {
    my $piece=shift;

    my $path=catfile($DIRS{MKVIMRC},$piece . '.vim');

}

sub VimSetTags {
    my $ref=shift;

    unless(ref $ref){
        VimSet("tags", $ref  );
        
    }elsif(ref $ref eq "ARRAY"){
        my $first=$ref->[0];

        VimSet("tags", join(',',@$ref));
        VimLet("g:CTAGS_CurrentTagID",'_buf_');
        VimLet("g:tagfile",$first);

    }
}
=head3 VimJoin( $arrname, $sep,  $vtype )

=over 4

=item Apply join() on the vimscript array $arrname; returns string

=item Examples: 

=over 4

=item VimJoin('000',' ','a') - Equivalent to join(a:000,' ') in vimscript

=back

=back

=cut

sub VimJoin {
    my $arr=shift;
    my $sep=shift;
    my $vtype=shift // 'l';

    return '' unless VimExists($arr);

    ($EvalCode,$res)=VIM::Eval("join($arr,'" . $sep . "')");

    return '' unless $EvalCode;

    $res;

}

sub init {

    my %opts=@_;

    unless(defined ){
        $SubName=$opts{SubName} // '';
        $SubName=VimVar('g:SubName');
    }

    VimMsg("g:SubName is: ");

    @INITIDS=qw(
            Args 
            CurBuf
            PIECES
            );

    @BUFLIST = VIM::Buffers();


    %DIRS=(
        'TAGS'  => catfile($ENV{HOME},'tags'),
        'MKVIMRC'  => catfile($ENV{HOME},qw( config mk vimrc )),
    );

    @BFILES=();

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

}

sub VimEditBufFiles {
    my $cmds=shift // $ArgString;

	foreach my $bfile (@BFILES) {
	    my $evs='edit_file_lines { ' . $cmds . ' } $bfile;' ; 
	    eval "$evs";
	    die $@ if $@;
	}
	
}

sub _die {
    my $text=shift;

    die "VIMPERL_$SubName : $text"
}

=head3 init_Args()

Process optional vimscript command-line arguments ( specified as ... in
vimscript function declarations )

=cut

sub init_Args {

    $NumArgs=0;
    @Args=();

    $ArgString=VimJoin('a:000',' ');
    return '' unless $ArgString;

    $NumArgs=VimLen('a:000');

    if ($NumArgs){
        @Args=VimVar('a:000');
    }
}

sub init_CurBuf {

    $CurBuf->{name}=VimEval("bufname('%')");
    $CurBuf->{number}=VimEval("bufnr('%')");

}

sub init_PIECES {
    @PIECES=readarr(catfile($DIRS{MKVIMRC}, qw(files.i.dat)));
}


sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );

    return $self;

}

BEGIN {
    if (exists &VIM::Eval){
        init;
    }
}

1;

