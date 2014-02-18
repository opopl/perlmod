#!/bin/sh 

# This is for generating include file
# ./mk/iall/install_modules.mk

mkdir="$PERLMODDIR/mk/iall"

if [[ -d $mkdir ]]; then
  mkdir -p $mkdir
fi

modules=( `list_modules_to_install.sh ` )
mk="$mkdir/install_modules.mk"

rm -rf $mk
touch $mk

for module in ${modules[@]} ; do 

   ipaths=( `module_install_paths.zsh $module` )
   lpath=( `module_local_path.zsh $module` )
   echo "" >> $mk
   echo "${ipaths[@]}: $lpath" >> $mk
   echo "\tinstall_module.zsh $module" >> $mk
        
done
