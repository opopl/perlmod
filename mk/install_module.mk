
LocalPaths:= $(shell $(PERLMODDIR)/iall.pl --list_local_paths  $(Module))
InstallPaths:= $(shell $(PERLMODDIR)/iall.pl --list_install_paths $(Module))

define MODULE_MAKE_TEST_INSTALL
@if [[ -f ./Makefile.PL ]]; then \
	if [[ -f ./Makefile ]]; then \
		make realclean	 ; \
	fi ; \
	perl ./Makefile.PL && make && make test && make install ;\
elif [[ -f ./Build.PL ]]; then \
	perl ./Build.PL && perl ./Build && perl ./Build test && perl ./Build install ;\
fi ;
endef

define MODULE_MAKE_NOTEST_INSTALL
@if [[ -f ./Makefile.PL ]]; then \
	if [[ -f ./Makefile ]]; then \
		make realclean	 ; \
	fi ; \
	perl ./Makefile.PL && make && make install ;\
elif [[ -f ./Build.PL ]]; then \
	perl ./Build.PL && perl ./Build && perl ./Build install ;\
fi ;
endef

.PHONY: all install reinstall install_deps remove 
.PHONY: list list_installed list_local list_deps
.PHONY: install_notest

all: install 

reinstall: remove install

install_notest:
	$(call MODULE_MAKE_NOTEST_INSTALL)

install: $(InstallPaths)

$(InstallPaths): $(LocalPaths)
	$(call MODULE_MAKE_TEST_INSTALL)
	touch $@

install_deps:
	@if [[ -f ./deps.i.dat ]]; then \
		deps=`cat deps.i.dat | sed '/^\s*#/d'`; \
		for dep in $${deps[@]}; do \
			install_module.zsh $${dep} ;\
		done ; \
	else \
		echo "No deps.i.dat file found" ;\
	fi 

remove:
	@for path in $(InstallPaths); do \
		rm -rf $${path}  ; \
	done ;

list: list_installed list_local
	
list_deps: 
	@if [[ -f ./deps.i.dat ]]; then \
		deps=`cat deps.i.dat | sed '/^\s*#/d'`; \
		for dep in $${deps[@]}; do \
			echo $${dep}  ; \
		done ; \
	fi ;


list_installed:
	@for path in $(InstallPaths); do \
		if [ -f $${path} ]; then \
			ls -la $${path}  ; \
		fi ; \
	done ;

list_local:
	@for path in $(LocalPaths); do \
		if [ -f $${path} ]; then \
			ls -la $${path}  ; \
		fi ; \
	done ;

