
package OP::tex::defs::tocNesting;

our $c;

sub tocNesting {
   my $N=shift;
  
   if ( level$N->() == \relax ){
      if $N == 0 "\HCode{<ul onclick='showHide(event)' id='menuTop'>}"  
      if $N > 0  "\HCode{<ul>}" 
      level$N=sub { "\HCode{</ul>}" }; 
   }
  
   $c=1;
   $c++;
  
   while($c < 10)
    level$N->();
    level$N = 0 ;
    $c++;
  
   }
}

1;
