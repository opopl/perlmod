#!/bin/sh

source "./sh/iall_start.sh"

if (( $opt_rw )); then
     rm -rf $dat_paths
fi

if [[ -f $dat_paths ]]; then
    cat $dat_paths
else
	if [[ -f $dat_modules ]]; then
	    modules=`cat $dat_modules`
	else
	    modules=`./list_modules_to_install.sh $opt_rw`
        touch $dat_modules
        for module in ${modules[@]}; do  
           echo "$module" >> $dat_modules
        done
	fi
	
    touch $dat_paths

	for module in ${modules[@]} ; do 
      for path in `module_install_paths.zsh $module`; do
          echo $path >> $dat_paths
          echo $path
      done
	done

fi
