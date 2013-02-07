#!/bin/bash - 

meth=Makefile

case $meth in 
  "Module::Build")
		perl Build.PL
		./Build
		./Build test
		./Build install
	;;
  "Makefile")
		perl Makefile.PL
		make && make test && make install
		;;
esac



