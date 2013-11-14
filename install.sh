#!/bin/bash - 

dat="$PERLMODDIR/inc/modules_to_install.i.dat" 
modules_to_install=( ` cat $dat | sed '/^\s*#/d'` )

source $PERLMODDIR/sh/funcs.sh

for module in ${modules_to_install[@]}; do 
  install_module $module
done
