package OP::VIMPERL;

use strict;
use warnings;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use File::Spec::Functions qw(catfile rel2abs curdir catdir );

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT = qw();

###export_vars_scalar
my @ex_vars_scalar = qw(
    $ArgString
    $NumArgs
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
);

%EXPORT_TAGS = (
###export_funcs
    'funcs' => [
        qw(
          init
          VimArg
          VimCmd
          VimEval
          VimExists
          VimGrep
          VimLen
          VimLet
          VimSo
          VimSetTags
          VimVar
        )
    ],
    'vars' => [ @ex_vars_scalar, @ex_vars_array, @ex_vars_hash ]
);

sub init;

sub VimArg;
sub VimCmd;
sub VimEval;
sub VimExists;
sub VimGrep;
sub VimLet;
sub VimSo;
sub VimSetTags;
sub VimVar;
sub VimLen;

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT    = qw( );
our $VERSION   = '0.01';

###our
our @BUFLIST;
our @BFILES;
our $ArgString;
our ($se,$res);
our %DIRS;
our(@Args,@NamedArgs);
our($NumArgs);

sub VimCmd {
    my $cmd=shift;

    VIM::DoCommand("$cmd");

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
    my $vtype=shift // 'l';

    my $len=0;
    my $vimname="$vtype" . ":$name";

    if (VimExists($vimname)){
        $len=VimEval("len($vimname)");
    }

    return $len;
}

sub VimVar {
    my $var=shift;
    my $rtype=shift;
    my $vtype=shift // 'l';

    my $res;

    my $vimvar=$vtype . ':' . $var;

    for($rtype){
        /^(a|arr)$/ && do {
            my $len=VimLen("$var","$vtype");
            my $i=0;
            while ($i<$len) {
                $res->[$i]=VimEval("$vimvar" . "[$i]");
                $i++;
            }
            
            next;
        };
        $res=VimEval("$vimvar");
    }

    unless(ref $res){
        $res;
    }elsif(ref $res eq "ARRAY"){
        wantarray ? @$res : $res ;
    }elsif(ref $res eq "HASH"){
        wantarray ? %$res : $res ;
    }

}

sub VimLet {

    my $var=shift;
    my $ref=shift;
    my $vtype=shift // 'l';
    my $valstr='';

    my $lhs="let $vtype" . ":" . $var;

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

    VimCmd($lhs . '=' . $valstr) if $valstr; 
    
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


sub VimSetTags {
    my $ref=shift;

    unless(ref $ref){
        VimCmd("set tags=" . $ref  );
        
    }elsif(ref $ref eq "ARRAY"){
        my $first=$ref->[0];
        VimCmd("set tags=" . join(',',@$ref));
        VimCmd("let g:CTAGS_CurrentTagID='_buf_'");
        VimCmd("let g:tagfile='$first'");
    }
}

sub VimEval {
  my $cmd=shift;

  ($se,$res)=VIM::Eval("$cmd");

  unless($se){
    die "VIM::Eval evaluation failed for command: $cmd";
  }
  
  $res;

}

sub VimExists {
    my $expr=shift;

    return VimEval("exists('$expr')");

}

sub init {

    @BUFLIST = VIM::Buffers();

    $ArgString=VimEval("join(a:000,' ')");

    %DIRS=(
        'TAGS'  => catfile($ENV{HOME},'tags'),
    );

    foreach my $buf (@BUFLIST) {
        my $name = $buf->Name();
        $name =~ s/^\s*//g;
        $name =~ s/\s*$//g;
        push( @BFILES, $name ) if -e $name;
    }

    $NumArgs=VimLen('000','a');

    if ($NumArgs){
        @Args=VimVar('a:000','arr');
    }
}

sub new {
    my ( $class, %parameters ) = @_;
    my $self = bless( {}, ref($class) || $class );
    return $self;
}

1;

