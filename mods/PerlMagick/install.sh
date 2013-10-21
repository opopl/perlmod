#!/bin/bash - 

LIBS="-L$HOME/lib -L/usr/local/lib -lMagickCore-Q16 -lperl -lm"
opts="PREFIX=$HOME INSTALLBIN=$HOME/bin"

if [ -f ./Makefile ]; then 
  make clean
fi

#perl Makefile.PL $opts 
perl Makefile.PL $opts && make && make test && make install   
