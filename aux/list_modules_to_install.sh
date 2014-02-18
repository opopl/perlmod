#!/bin/bash

source "./sh/iall_start.sh"

list_modules(){

	for module in ${modules[@]} ; do 
	   if (( $opt_make_escape )); then 
	    echo $module | sed 's/:/\\:/g'
     else
	    echo $module
     fi
	done

}

if (( $opt_rw )); then
   rm -rf $dat_modules
fi

if (( $opt_make_escape )); then
  dat_modules="$incdir/modules_to_install_make_escape.i.dat"
  opt_make_escape=0
fi

if [[ -f $dat_modules ]]; then
  modules=( `cat $dat_modules ` )
else
  modules=( `cat ./inc/modules_to_install.i.dat | sed '/^\s*#/d'` )
  touch $dat_modules
  list_modules >> $dat_modules
fi

list_modules
