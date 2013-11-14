#!/bin/bash - 

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

module_local_path(){
  module=$1

  modslash=`echo $module | sed 's/::/\//g'`
  moddef=`echo $module | sed 's/::/-/g'`

  LocalPath="$PERLMODDIR/mods/$moddef/lib/$modslash.pm"

  echo $LocalPath

}

install_this_module(){

  install_deps

  ThisModule=`basename $PWD | sed 's/-/::/g'`

  x1=`echo $ThisModule | sed 's/::/\//g'`
  ThisModuleLocalPath="./lib/$x1.pm"

  ThisModuleInstalledPaths=( `module_install_paths $ThisModule` )

  mk='./imod.mk'

  rm -rf $mk
  if [[ ! -f $mk ]]; then

cat > $mk << EOF
#!/usr/bin/make -f

LocalPath:= $ThisModuleLocalPath
InstalledPaths:= ${ThisModuleInstalledPaths[@]}

all: \$(InstalledPaths)

\$(InstalledPaths): \$(LocalPath)
	@if [[ -f ./Makefile.PL ]]; then \\
		perl ./Makefile.PL && make && make test && make install ;\\
	elif [[ -f ./Build.PL ]]; then \\
		perl ./Build.PL && perl ./Build && perl ./Build test && perl ./Build install ;\\
	fi ;

EOF

  fi

  chmod +rx $mk
  make -f $mk all

}

cpan_install(){
  module=$1 

  perl -MCPAN -e "install(\"$module\");"

}

install_module(){

  ThisModuleDir=`pwd`

  if [[ -z $1 ]]; then
    install_this_module
  else
    module=$1
    echo_red "Installing module: $module"
    moddef=`echo $module | sed 's/::/-/g'`
    moddir=$PERLMODDIR/mods/$moddef/
    if [[ -d "$moddir" ]]; then
        cd $moddir
        install_this_module
    else
        cpan_install $module
    fi
  fi

  cd $ThisModuleDir
        
}

install_install(){

	for dir in `find $PERLMODDIR/mods/ -maxdepth 1 -type d` ; do
	    cp ./install.sh $dir
	    git add $dir/install.sh
	done

}
