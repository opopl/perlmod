package OP::Time;
use strict;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

    $VERSION = '0.01';
    @ISA     = qw(Exporter);

    @EXPORT      = qw();

###export_vars_scalar
    my @ex_vars_scalar=qw(
     );
###export_vars_hash
    my @ex_vars_hash=qw(
                  );
###export_vars_array
    my @ex_vars_array=qw(
        @starttime
        @endtime
        $totaltime
         );

    %EXPORT_TAGS = (
###export_funcs
        'funcs' => [qw( 
            elapsed_time
            fix_time
         )],
        'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
    );

    our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );

    our @EXPORT  = qw( );
    our $VERSION = '0.01';

}

###our
our(@starttime,@endtime,@totaltime);

sub fix_time {
    @starttime=localtime;

    wantarray ? @starttime : \@starttime;
}

sub elapsed_time {
  my @time;
  
  if(@_){
      @time=@_;
  }else{
      @time=@starttime;
  }

  @endtime=localtime;

  for(my $i=0 ; $i < 3 ; $i++ ){
    $totaltime[$i]=$endtime[$i]-$time[$i];
  }

  my $secs=$totaltime[0] % 60;
  my $mins=$totaltime[1] % 60;
  my $hours=$totaltime[2];

  my $str=  $mins . " (mins) " . $secs . " (secs) " ; 

  if ($hours){
      $str=$hours  . " (hours) " . $str;
  }

  $str;

}

sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}

1;
