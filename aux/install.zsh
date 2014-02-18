#!/bin/zsh

source $hm/config/zshrc
source $PERLMODDIR/sh/funcs.sh

if [[ -z $1 ]]; then
     dat="$PERLMODDIR/inc/modules_to_install.i.dat" 
     modules_to_install=( ` cat $dat | sed '/^\s*#/d'` )
else
     modules_to_install=( $1 )
fi

for module in ${modules_to_install[@]}; do 
  install_module $module
done
