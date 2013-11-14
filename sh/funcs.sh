#!/bin/bash - 

install_deps(){ 

  depsdat="./deps.i.dat"

  if [[ -f "$depsdat" ]]; then
    deps=`cat $depsdat | sed '/^\s*#/d'`

	  for dep in ${deps[@]}; do  
	    install_module $dep
	  done
  fi

}

get_installed_paths(){

    module=$1
    modslash=`echo $module | sed 's/::/\//g'`

    PerlLibDirs=( `echo $PERLLIB | sed 's/:/ /g'` )

    for dir in ${PerlLibDirs[@]}; do 
       if [[ -d $dir ]]; then
        find $dir -path "*/$modslash.pm"
       fi
    done
}

install_this_module(){

  install_deps

  ThisModule=`basename $PWD | sed 's/-/::/g'`

  x1=`echo $ThisModule | sed 's/::/\//g'`
  ThisModuleLocalPath="./lib/$x1.pm"

  ThisModuleInstalledPaths=( `get_installed_paths $ThisModule` )

  mk='./imod.mk'

  if [[ ! -f $mk ]]; then

cat > $mk << EOF
#!/usr/bin/make -f

all: ${ThisModuleInstalledPaths[@]}

${ThisModuleInstalledPaths[@]}: $ThisModuleLocalPath
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

install_module(){

  ThisModuleDir=`pwd`

  if [[ -z $1 ]]; then
    install_this_module
  else
    module=$1
    moddef=`echo $module | sed 's/::/-/g'`
    cd ../$moddef/
    install_this_module
  fi

  cd $ThisModuleDir
        
}

install_install(){

	for dir in `find $PERLMODDIR/mods/ -maxdepth 1 -type d` ; do
	    cp ./install.sh $dir
	    git add $dir/install.sh
	done

}
