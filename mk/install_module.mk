

all: $(InstalledPaths)

$(InstalledPaths): $(LocalPath)
	@if [[ -f ./Makefile.PL ]]; then \
		perl ./Makefile.PL && make && make test && make install ;\
	elif [[ -f ./Build.PL ]]; then \
		perl ./Build.PL && perl ./Build && perl ./Build test && perl ./Build install ;\
	fi ;

remove:
	@for path in $(InstalledPaths); do \
		rm -rf $${path}  ; \
	done ;

list: list_installed list_local

list_installed:
	@for path in $(InstalledPaths); do \
		if [ -f $${path} ]; then \
			ls -la $${path}  ; \
		fi ; \
	done ;

list_local:
	@for path in $(LocalPath); do \
		if [ -f $${path} ]; then \
			ls -la $${path}  ; \
		fi ; \
	done ;
