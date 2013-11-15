#!/usr/bin/make -f

ModulesToInstall := $(shell ./list_modules_to_install.sh make_escape )

AllInstallPaths := $(shell ./list_paths_to_install.sh )

mkdir:=./mk/iall/

install_modules_mk:=$(mkdir)/install_modules.mk

.PHONY: $(ModulesToInstall)

all:  install

install_modules_mk: $(install_modules_mk)
$(install_modules_mk):
	perl ./iall_gen_install_modules_mk.pl

install: install_modules 
install_modules: $(AllInstallPaths)

-include $(install_modules_mk)

list_modules: $(ModulesToInstall)
	@for emod in $(ModulesToInstall); do \
		echo $${emod} | sed 's/\\//g' ; \
	done ;

