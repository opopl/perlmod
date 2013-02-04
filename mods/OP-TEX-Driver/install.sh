#!/bin/bash - 

#perl Build.PL
#./Build
#./Build test
#./Build install

perl Makefile.PL
make
make test
make install



