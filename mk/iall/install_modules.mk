 
.PHONY: Bib2HTML Class-Accessor-Complex Data-Dumper Directory-Iterator Directory-Iterator-PP File-Basename File-Copy File-Path File-Slurp File-Spec-Functions File-Util Getopt-Long IO-File IPC-Cmd LaTeX-BibTeX LaTeX-TOM LaTeX-Table OP-App-Cpan OP-BIBTEX OP-Base OP-ConvBib OP-GOPS OP-GOPS-BBH OP-GOPS-KW OP-GOPS-MKDEP OP-GOPS-RIF OP-GOPS-TEST OP-Git OP-HTML OP-MOD OP-ManViewer OP-Module-Build OP-PAPERS-MKPDF OP-PAPERS-PSH OP-PERL-PMINST OP-POD OP-PROJSHELL OP-PSH-PEF OP-PackName OP-PaperConf OP-Parse-BL OP-Perl-Edit OP-Perl-Installer OP-RE OP-RENAME OP-RENAME-PMOD OP-Script OP-Script-Simple OP-TEX-Driver OP-TEX-LATEX2HTML OP-TEX-NICE OP-TEX-PERLTEX OP-TEX-PNC OP-TEX-Text OP-Time OP-UTIL-APACK OP-VIMPERL OP-VIMPERL-TEST OP-Viewer OP-VimTag OP-Writer PDL-Graphics-PLplot PerlMagick Pod-Usage Sman Term-ANSIColor Term-ShellUI Text-Table Text-TabularDisplay
 
install_modules:  \
     Class-Accessor-Complex \
     OP-BIBTEX \
     OP-Base \
     OP-GOPS-MKDEP \
     OP-Git \
     OP-HTML \
     OP-ManViewer \
     OP-PAPERS-MKPDF \
     OP-PAPERS-PSH \
     OP-PERL-PMINST \
     OP-PROJSHELL \
     OP-PackName \
     OP-PaperConf \
     OP-Perl-Installer \
     OP-RE \
     OP-RENAME-PMOD \
     OP-Script \
     OP-Script-Simple \
     OP-TEX-NICE \
     OP-TEX-PNC \
     OP-TEX-Text \
     OP-VIMPERL \
     OP-VIMPERL-TEST
 
remove_dat_installed_cpan:
	@rm -rf /home/opopl/wrk/perlmod/inc/installed_cpan.i.dat
 
Bib2HTML: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Bib2HTML.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Bib2HTML.pm:  \
     /home/opopl/wrk/perlmod/mods/Bib2HTML/lib/Bib2HTML.pm
	@cd /home/opopl/wrk/perlmod/mods/Bib2HTML; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Bib2HTML.pm
 
Class-Accessor-Complex: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Class/Accessor/Complex.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Class/Accessor/Complex.pm:  \
     /home/opopl/wrk/perlmod/mods/Class-Accessor-Complex/lib/Class/Accessor/Complex.pm
	@cd /home/opopl/wrk/perlmod/mods/Class-Accessor-Complex; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Class/Accessor/Complex.pm
 
Directory-Iterator: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Directory/Iterator.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Directory/Iterator.pm:  \
     /home/opopl/wrk/perlmod/mods/Directory-Iterator/lib/Directory/Iterator.pm
	@cd /home/opopl/wrk/perlmod/mods/Directory-Iterator; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Directory/Iterator.pm
 
Directory-Iterator-PP: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Directory/Iterator/PP.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Directory/Iterator/PP.pm:  \
     /home/opopl/wrk/perlmod/mods/Directory-Iterator-PP/lib/Directory/Iterator/PP.pm
	@cd /home/opopl/wrk/perlmod/mods/Directory-Iterator-PP; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/Directory/Iterator/PP.pm
 
File-Slurp: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/File/Slurp.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/File/Slurp.pm:  \
     /home/opopl/wrk/perlmod/mods/File-Slurp/lib/File/Slurp.pm
	@cd /home/opopl/wrk/perlmod/mods/File-Slurp; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/File/Slurp.pm
 
LaTeX-BibTeX: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/i686-linux/LaTeX/BibTeX.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/i686-linux/LaTeX/BibTeX.pm:  \
     /home/opopl/wrk/perlmod/mods/LaTeX-BibTeX/lib/LaTeX/BibTeX.pm
	@cd /home/opopl/wrk/perlmod/mods/LaTeX-BibTeX; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/i686-linux/LaTeX/BibTeX.pm
 
LaTeX-Table: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/LaTeX/Table.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/LaTeX/Table.pm:  \
     /home/opopl/wrk/perlmod/mods/LaTeX-Table/lib/LaTeX/Table.pm
	@cd /home/opopl/wrk/perlmod/mods/LaTeX-Table; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/LaTeX/Table.pm
 
OP-App-Cpan: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/App/Cpan.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/App/Cpan.pm:  \
     /home/opopl/wrk/perlmod/mods/OP-App-Cpan/lib/OP/App/Cpan.pm
	@cd /home/opopl/wrk/perlmod/mods/OP-App-Cpan; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/App/Cpan.pm
 
OP-BIBTEX: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/BIBTEX.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/BIBTEX.pm:  \
     /home/opopl/wrk/perlmod/mods/OP-BIBTEX/lib/OP/BIBTEX.pm
	@cd /home/opopl/wrk/perlmod/mods/OP-BIBTEX; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/BIBTEX.pm
 
OP-Base: /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/Base.pm
 
/home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/Base.pm:  \
     /home/opopl/wrk/perlmod/mods/OP-Base/lib/OP/Base.pm
	@cd /home/opopl/wrk/perlmod/mods/OP-Base; ./imod.mk install
	@touch /home/opopl/perldist/5.16.2/lib/site_perl/5.16.2/OP/Base.pm
