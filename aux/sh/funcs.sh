



module_install_paths(){

    module=$1
    modslash=`echo $module | sed 's/::/\//g'`

    PerlLibDirs=( `echo $PERLLIB | sed 's/:/ /g'` )

    for dir in ${PerlLibDirs[@]}; do 
       if [[ -d $dir ]]; then
        find $dir -path "*/$modslash.pm"
       fi
    done
}    

module_all_install_paths(){

    module=$1
    
    paths=`module_install_paths $module`
    modslash=`echo $module | sed 's/::/\//g'`

    if (( ! ${#paths} )); then 
        paths=( $PERL_INSTALL_PREFIX/$modslash.pm )    
    fi
    for path in ${paths[@]}; do 
        echo $path
    done

}

module_is_installed(){
    paths=( `module_install_paths $module` )

    if (( ${#paths} )); then
      return true
    fi

    return false
}

module_local_path(){
  module=$1

  modslash=`echo $module | sed 's/::/\//g'`
  moddef=`echo $module | sed 's/::/-/g'`

  LocalPath="$PERLMODDIR/mods/$moddef/lib/$modslash.pm"

  echo $LocalPath

}

install_deps(){ 

  depsdat="./deps.i.dat"

  if [[ -f "$depsdat" ]]; then
    deps=( `cat $depsdat | sed '/^\s*#/d'` )

    if (( ${#deps} )); then
	    echo_blue "FOUND DEPENDENCIES:"
		  for dep in ${deps[@]}; do  
	        echo "  $dep"
		  done
	
		  for dep in ${deps[@]}; do  
		    install_module $dep
		  done
    fi
  fi

}

create_imod_mk(){

  mk='./imod.mk'

  ThisModule=`basename $PWD | sed 's/-/::/g'`
  module=$ThisModule

  rm -rf $mk
  if [[ ! -f $mk ]]; then

cat > $mk << EOF
#!/usr/bin/make -f

Module:=$module

include \$(PERLMODDIR)/mk/install_module.mk

EOF

  fi

}

install_this_module(){

  ThisModule=`basename $PWD | sed 's/-/::/g'`

  modslash=`echo $ThisModule | sed 's/::/\//g'`
  ThisModuleLocalPath="./lib/$modslash.pm"

  ThisModuleInstalledPaths=( `module_all_install_paths $ThisModule` )

  create_imod_mk 

  chmod +rx $mk
  make -f $mk all

}

cpan_install(){
  module=$1 

  echo_red "CPAN Installing module: $module"

  perl -MCPAN -e "install(\"$module\");"

}

install_module(){

  ThisModuleDir=`pwd`

  if [[ -z $1 ]]; then
    install_this_module
  else
    module=$1
    moddef=`echo $module | sed 's/::/-/g'`
    moddir=$PERLMODDIR/mods/$moddef/
    if [[ -d "$moddir" ]]; then
        cd $moddir
        install_this_module
    else
        if [[ -z `module_install_paths $module` ]]; then 
            cpan_install $module
        fi
    fi
  fi

  cd $ThisModuleDir
        
}

install_install(){

	for dir in `find $PERLMODDIR/mods/ -maxdepth 1 -type d` ; do
	    cp ./install.zsh $dir
	    git add $dir/install.zsh
	    git rm $dir/install.sh -f
	done

}

install_imod_mk(){

    ThisDir=`pwd`

	for dir in `find $PERLMODDIR/mods/ -maxdepth 1 -type d` ; do
	    cp ./imod.mk $dir
        Module=`basename $dir | sed 's/-/::/g'`
        perl -p -i -e "s/^Module:=.*/Module:=$Module/g" $dir/imod.mk
	done

    cd $ThisDir

}
