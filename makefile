
all: docs

docs: _html_pods2html _html_pdoc

_html_pods2html:
	-op_pods2html --frames --index 'LOCAL_MODS' ./lib ./html/$@

_html_pdoc:
	-mkdir ./html/$@
	-pdoc.pl -source ./lib -target ./html/$@
