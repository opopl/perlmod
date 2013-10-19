#!/bin/bash - 

rm -rf ./*.pod
perl Makefile.PL && make && make test && make install

