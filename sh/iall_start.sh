
incdir="./inc/iall"
dat_modules="$incdir/modules_to_install.i.dat"
dat_paths="$incdir/paths_to_install.i.dat"

if [[ ! -d  $incdir ]]; then
  mkdir -p $incdir
fi

if [[ -n "$*" ]]; then
  while [[ -n $1 ]]; do
	  case $1 in
	     make_escape) opt_make_escape=1 ;;
	     rw)          opt_rw=1          ;;
	  esac
    shift 
  done
fi

