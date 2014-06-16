 
# ---------------- DEFINITIONS ----------------- 
 
PERLMODDIR:=/home/op/wrk/perlmod
 
include /home/op/wrk/perlmod/mk/iall/defs.mk
 
# ---------------- TARGETS ----------------- 
 
.PHONY: Bib2HTML Class-Accessor-Complex Data-Dumper Directory-Iterator Directory-Iterator-PP File-Basename File-Copy File-Path File-Slurp File-Spec-Functions File-Util Getopt-Long IO-File IPC-Cmd LaTeX-BibTeX LaTeX-TOM LaTeX-Table OP-App-Cpan OP-BIBTEX OP-Base OP-ConvBib OP-GOPS OP-GOPS-BBH OP-GOPS-KW OP-GOPS-MKDEP OP-GOPS-RIF OP-GOPS-TEST OP-Git OP-HTML OP-MOD OP-ManViewer OP-Module-Build OP-PAPERS-MKPDF OP-PAPERS-PSH OP-PERL-PMINST OP-POD OP-PROJSHELL OP-PSH-PEF OP-PackName OP-PaperConf OP-Parse-BL OP-Perl-Edit OP-Perl-Installer OP-RE OP-RENAME OP-RENAME-PMOD OP-Script OP-Script-Simple OP-TEX-Driver OP-TEX-LATEX2HTML OP-TEX-NICE OP-TEX-PERLTEX OP-TEX-PNC OP-TEX-Text OP-Time OP-UTIL-APACK OP-VIMPERL OP-VIMPERL-TEST OP-Viewer OP-VimTag OP-Writer OP-Writer-Pod PDL-Graphics-PLplot PerlMagick Pod-Usage Sman Term-ANSIColor Term-ShellUI Text-Table Text-TabularDisplay
 
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
     OP-VIMPERL-TEST \
     OP-Writer \
     OP-Writer-Pod
remove_dat:  \
     remove_dat_installed_cpan \
     remove_dat_install_paths \
     remove_dat_local_paths
 
remove_dat_installed_cpan: 
	@rm -rf /home/op/wrk/perlmod/inc/iall/installed_cpan.i.dat
remove_dat_install_paths: 
	@rm -rf /home/op/wrk/perlmod/inc/iall/install_paths.i.dat
remove_dat_local_paths: 
	@rm -rf /home/op/wrk/perlmod/inc/iall/local_paths.i.dat
 
Bib2HTML: $(Bib2HTML_ipaths)
 
$(Bib2HTML_ipaths):  \
     $(Bib2HTML_lpaths)
	@cd $(PERLMODDIR)/mods/Bib2HTML/; make -f ./imod.mk install
	@touch $@
 
Class-Accessor-Complex: $(Class_Accessor_Complex_ipaths)
 
$(Class_Accessor_Complex_ipaths):  \
     $(Class_Accessor_Complex_lpaths)
	@cd $(PERLMODDIR)/mods/Class-Accessor-Complex/; make -f ./imod.mk install
	@touch $@
 
Directory-Iterator: $(Directory_Iterator_ipaths)
 
$(Directory_Iterator_ipaths):  \
     $(Directory_Iterator_lpaths)
	@cd $(PERLMODDIR)/mods/Directory-Iterator/; make -f ./imod.mk install
	@touch $@
 
Directory-Iterator-PP: $(Directory_Iterator_PP_ipaths)
 
$(Directory_Iterator_PP_ipaths):  \
     $(Directory_Iterator_PP_lpaths)
	@cd $(PERLMODDIR)/mods/Directory-Iterator-PP/; make -f ./imod.mk install
	@touch $@
 
File-Slurp: $(File_Slurp_ipaths)
 
$(File_Slurp_ipaths):  \
     $(File_Slurp_lpaths)
	@cd $(PERLMODDIR)/mods/File-Slurp/; make -f ./imod.mk install
	@touch $@
 
LaTeX-BibTeX: $(LaTeX_BibTeX_ipaths)
 
$(LaTeX_BibTeX_ipaths):  \
     $(LaTeX_BibTeX_lpaths)
	@cd $(PERLMODDIR)/mods/LaTeX-BibTeX/; make -f ./imod.mk install
	@touch $@
 
LaTeX-Table: $(LaTeX_Table_ipaths)
 
$(LaTeX_Table_ipaths):  \
     $(LaTeX_Table_lpaths)
	@cd $(PERLMODDIR)/mods/LaTeX-Table/; make -f ./imod.mk install
	@touch $@
 
OP-App-Cpan: $(OP_App_Cpan_ipaths)
 
$(OP_App_Cpan_ipaths):  \
     $(OP_App_Cpan_lpaths)
	@cd $(PERLMODDIR)/mods/OP-App-Cpan/; make -f ./imod.mk install
	@touch $@
 
OP-BIBTEX: $(OP_BIBTEX_ipaths)
 
$(OP_BIBTEX_ipaths):  \
     $(OP_BIBTEX_lpaths)
	@cd $(PERLMODDIR)/mods/OP-BIBTEX/; make -f ./imod.mk install
	@touch $@
 
OP-Base: $(OP_Base_ipaths)
 
$(OP_Base_ipaths):  \
     $(OP_Base_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Base/; make -f ./imod.mk install
	@touch $@
 
OP-ConvBib: $(OP_ConvBib_ipaths)
 
$(OP_ConvBib_ipaths):  \
     $(OP_ConvBib_lpaths)
	@cd $(PERLMODDIR)/mods/OP-ConvBib/; make -f ./imod.mk install
	@touch $@
 
OP-GOPS: $(OP_GOPS_ipaths)
 
$(OP_GOPS_ipaths):  \
     $(OP_GOPS_lpaths)
	@cd $(PERLMODDIR)/mods/OP-GOPS/; make -f ./imod.mk install
	@touch $@
 
OP-GOPS-BBH: $(OP_GOPS_BBH_ipaths)
 
$(OP_GOPS_BBH_ipaths):  \
     $(OP_GOPS_BBH_lpaths)
	@cd $(PERLMODDIR)/mods/OP-GOPS-BBH/; make -f ./imod.mk install
	@touch $@
 
OP-GOPS-KW: $(OP_GOPS_KW_ipaths)
 
$(OP_GOPS_KW_ipaths):  \
     $(OP_GOPS_KW_lpaths)
	@cd $(PERLMODDIR)/mods/OP-GOPS-KW/; make -f ./imod.mk install
	@touch $@
 
OP-GOPS-MKDEP: $(OP_GOPS_MKDEP_ipaths)
 
$(OP_GOPS_MKDEP_ipaths):  \
     $(OP_GOPS_MKDEP_lpaths)
	@cd $(PERLMODDIR)/mods/OP-GOPS-MKDEP/; make -f ./imod.mk install
	@touch $@
 
OP-GOPS-RIF: $(OP_GOPS_RIF_ipaths)
 
$(OP_GOPS_RIF_ipaths):  \
     $(OP_GOPS_RIF_lpaths)
	@cd $(PERLMODDIR)/mods/OP-GOPS-RIF/; make -f ./imod.mk install
	@touch $@
 
OP-GOPS-TEST: $(OP_GOPS_TEST_ipaths)
 
$(OP_GOPS_TEST_ipaths):  \
     $(OP_GOPS_TEST_lpaths)
	@cd $(PERLMODDIR)/mods/OP-GOPS-TEST/; make -f ./imod.mk install
	@touch $@
 
OP-Git: $(OP_Git_ipaths)
 
$(OP_Git_ipaths):  \
     $(OP_Git_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Git/; make -f ./imod.mk install
	@touch $@
 
OP-HTML: $(OP_HTML_ipaths)
 
$(OP_HTML_ipaths):  \
     OP-Writer \
     OP-Base \
     $(OP_HTML_lpaths)
	@cd $(PERLMODDIR)/mods/OP-HTML/; make -f ./imod.mk install
	@touch $@
 
OP-MOD: $(OP_MOD_ipaths)
 
$(OP_MOD_ipaths):  \
     $(OP_MOD_lpaths)
	@cd $(PERLMODDIR)/mods/OP-MOD/; make -f ./imod.mk install
	@touch $@
 
OP-ManViewer: $(OP_ManViewer_ipaths)
 
$(OP_ManViewer_ipaths):  \
     $(OP_ManViewer_lpaths)
	@cd $(PERLMODDIR)/mods/OP-ManViewer/; make -f ./imod.mk install
	@touch $@
 
OP-Module-Build: $(OP_Module_Build_ipaths)
 
$(OP_Module_Build_ipaths):  \
     $(OP_Module_Build_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Module-Build/; make -f ./imod.mk install
	@touch $@
 
OP-PAPERS-MKPDF: $(OP_PAPERS_MKPDF_ipaths)
 
$(OP_PAPERS_MKPDF_ipaths):  \
     $(OP_PAPERS_MKPDF_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PAPERS-MKPDF/; make -f ./imod.mk install
	@touch $@
 
OP-PAPERS-PSH: $(OP_PAPERS_PSH_ipaths)
 
$(OP_PAPERS_PSH_ipaths):  \
     Data-Dumper \
     Directory-Iterator \
     File-Basename \
     File-Copy \
     File-Path \
     File-Slurp \
     File-Spec-Functions \
     IO-File \
     IPC-Cmd \
     LaTeX-BibTeX \
     LaTeX-TOM \
     LaTeX-Table \
     OP-BIBTEX \
     OP-Base \
     OP-PROJSHELL \
     OP-TEX-Driver \
     OP-TEX-NICE \
     OP-TEX-Text \
     Term-ShellUI \
     Text-Table \
     Text-TabularDisplay \
     $(OP_PAPERS_PSH_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PAPERS-PSH/; make -f ./imod.mk install
	@touch $@
 
OP-PERL-PMINST: $(OP_PERL_PMINST_ipaths)
 
$(OP_PERL_PMINST_ipaths):  \
     $(OP_PERL_PMINST_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PERL-PMINST/; make -f ./imod.mk install
	@touch $@
 
OP-POD: $(OP_POD_ipaths)
 
$(OP_POD_ipaths):  \
     $(OP_POD_lpaths)
	@cd $(PERLMODDIR)/mods/OP-POD/; make -f ./imod.mk install
	@touch $@
 
OP-PROJSHELL: $(OP_PROJSHELL_ipaths)
 
$(OP_PROJSHELL_ipaths):  \
     $(OP_PROJSHELL_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PROJSHELL/; make -f ./imod.mk install
	@touch $@
 
OP-PSH-PEF: $(OP_PSH_PEF_ipaths)
 
$(OP_PSH_PEF_ipaths):  \
     $(OP_PSH_PEF_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PSH-PEF/; make -f ./imod.mk install
	@touch $@
 
OP-PackName: $(OP_PackName_ipaths)
 
$(OP_PackName_ipaths):  \
     File-Slurp \
     File-Spec-Functions \
     File-Basename \
     Getopt-Long \
     OP-Script \
     Class-Accessor-Complex \
     $(OP_PackName_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PackName/; make -f ./imod.mk install
	@touch $@
 
OP-PaperConf: $(OP_PaperConf_ipaths)
 
$(OP_PaperConf_ipaths):  \
     File-Slurp \
     File-Spec-Functions \
     Term-ANSIColor \
     Data-Dumper \
     File-Basename \
     OP-TEX-PNC \
     OP-Base \
     $(OP_PaperConf_lpaths)
	@cd $(PERLMODDIR)/mods/OP-PaperConf/; make -f ./imod.mk install
	@touch $@
 
OP-Parse-BL: $(OP_Parse_BL_ipaths)
 
$(OP_Parse_BL_ipaths):  \
     $(OP_Parse_BL_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Parse-BL/; make -f ./imod.mk install
	@touch $@
 
OP-Perl-Edit: $(OP_Perl_Edit_ipaths)
 
$(OP_Perl_Edit_ipaths):  \
     $(OP_Perl_Edit_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Perl-Edit/; make -f ./imod.mk install
	@touch $@
 
OP-Perl-Installer: $(OP_Perl_Installer_ipaths)
 
$(OP_Perl_Installer_ipaths):  \
     $(OP_Perl_Installer_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Perl-Installer/; make -f ./imod.mk install
	@touch $@
 
OP-RE: $(OP_RE_ipaths)
 
$(OP_RE_ipaths):  \
     $(OP_RE_lpaths)
	@cd $(PERLMODDIR)/mods/OP-RE/; make -f ./imod.mk install
	@touch $@
 
OP-RENAME: $(OP_RENAME_ipaths)
 
$(OP_RENAME_ipaths):  \
     $(OP_RENAME_lpaths)
	@cd $(PERLMODDIR)/mods/OP-RENAME/; make -f ./imod.mk install
	@touch $@
 
OP-RENAME-PMOD: $(OP_RENAME_PMOD_ipaths)
 
$(OP_RENAME_PMOD_ipaths):  \
     $(OP_RENAME_PMOD_lpaths)
	@cd $(PERLMODDIR)/mods/OP-RENAME-PMOD/; make -f ./imod.mk install
	@touch $@
 
OP-Script: $(OP_Script_ipaths)
 
$(OP_Script_ipaths):  \
     File-Util \
     File-Basename \
     Getopt-Long \
     Pod-Usage \
     File-Spec-Functions \
     Term-ANSIColor \
     Data-Dumper \
     IPC-Cmd \
     OP-Base \
     OP-VIMPERL \
     $(OP_Script_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Script/; make -f ./imod.mk install
	@touch $@
 
OP-Script-Simple: $(OP_Script_Simple_ipaths)
 
$(OP_Script_Simple_ipaths):  \
     Term-ANSIColor \
     $(OP_Script_Simple_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Script-Simple/; make -f ./imod.mk install
	@touch $@
 
OP-TEX-Driver: $(OP_TEX_Driver_ipaths)
 
$(OP_TEX_Driver_ipaths):  \
     $(OP_TEX_Driver_lpaths)
	@cd $(PERLMODDIR)/mods/OP-TEX-Driver/; make -f ./imod.mk install
	@touch $@
 
OP-TEX-LATEX2HTML: $(OP_TEX_LATEX2HTML_ipaths)
 
$(OP_TEX_LATEX2HTML_ipaths):  \
     $(OP_TEX_LATEX2HTML_lpaths)
	@cd $(PERLMODDIR)/mods/OP-TEX-LATEX2HTML/; make -f ./imod.mk install
	@touch $@
 
OP-TEX-NICE: $(OP_TEX_NICE_ipaths)
 
$(OP_TEX_NICE_ipaths):  \
     $(OP_TEX_NICE_lpaths)
	@cd $(PERLMODDIR)/mods/OP-TEX-NICE/; make -f ./imod.mk install
	@touch $@
 
OP-TEX-PERLTEX: $(OP_TEX_PERLTEX_ipaths)
 
$(OP_TEX_PERLTEX_ipaths):  \
     $(OP_TEX_PERLTEX_lpaths)
	@cd $(PERLMODDIR)/mods/OP-TEX-PERLTEX/; make -f ./imod.mk install
	@touch $@
 
OP-TEX-PNC: $(OP_TEX_PNC_ipaths)
 
$(OP_TEX_PNC_ipaths):  \
     $(OP_TEX_PNC_lpaths)
	@cd $(PERLMODDIR)/mods/OP-TEX-PNC/; make -f ./imod.mk install
	@touch $@
 
OP-TEX-Text: $(OP_TEX_Text_ipaths)
 
$(OP_TEX_Text_ipaths):  \
     $(OP_TEX_Text_lpaths)
	@cd $(PERLMODDIR)/mods/OP-TEX-Text/; make -f ./imod.mk install
	@touch $@
 
OP-Time: $(OP_Time_ipaths)
 
$(OP_Time_ipaths):  \
     $(OP_Time_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Time/; make -f ./imod.mk install
	@touch $@
 
OP-UTIL-APACK: $(OP_UTIL_APACK_ipaths)
 
$(OP_UTIL_APACK_ipaths):  \
     $(OP_UTIL_APACK_lpaths)
	@cd $(PERLMODDIR)/mods/OP-UTIL-APACK/; make -f ./imod.mk install
	@touch $@
 
OP-VIMPERL: $(OP_VIMPERL_ipaths)
 
$(OP_VIMPERL_ipaths):  \
     File-Spec-Functions \
     OP-Base \
     Text-TabularDisplay \
     Data-Dumper \
     File-Basename \
     File-Slurp \
     $(OP_VIMPERL_lpaths)
	@cd $(PERLMODDIR)/mods/OP-VIMPERL/; make -f ./imod.mk install
	@touch $@
 
OP-VIMPERL-TEST: $(OP_VIMPERL_TEST_ipaths)
 
$(OP_VIMPERL_TEST_ipaths):  \
     $(OP_VIMPERL_TEST_lpaths)
	@cd $(PERLMODDIR)/mods/OP-VIMPERL-TEST/; make -f ./imod.mk install
	@touch $@
 
OP-Viewer: $(OP_Viewer_ipaths)
 
$(OP_Viewer_ipaths):  \
     $(OP_Viewer_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Viewer/; make -f ./imod.mk install
	@touch $@
 
OP-VimTag: $(OP_VimTag_ipaths)
 
$(OP_VimTag_ipaths):  \
     $(OP_VimTag_lpaths)
	@cd $(PERLMODDIR)/mods/OP-VimTag/; make -f ./imod.mk install
	@touch $@
 
OP-Writer: $(OP_Writer_ipaths)
 
$(OP_Writer_ipaths):  \
     OP-Script \
     Class-Accessor-Complex \
     $(OP_Writer_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Writer/; make -f ./imod.mk install
	@touch $@
 
OP-Writer-Pod: $(OP_Writer_Pod_ipaths)
 
$(OP_Writer_Pod_ipaths):  \
     OP-Writer \
     $(OP_Writer_Pod_lpaths)
	@cd $(PERLMODDIR)/mods/OP-Writer-Pod/; make -f ./imod.mk install
	@touch $@
 
PDL-Graphics-PLplot: $(PDL_Graphics_PLplot_ipaths)
 
$(PDL_Graphics_PLplot_ipaths):  \
     $(PDL_Graphics_PLplot_lpaths)
	@cd $(PERLMODDIR)/mods/PDL-Graphics-PLplot/; make -f ./imod.mk install
	@touch $@
 
PerlMagick: $(PerlMagick_ipaths)
 
$(PerlMagick_ipaths):  \
     $(PerlMagick_lpaths)
	@cd $(PERLMODDIR)/mods/PerlMagick/; make -f ./imod.mk install
	@touch $@
 
Sman: $(Sman_ipaths)
 
$(Sman_ipaths):  \
     $(Sman_lpaths)
	@cd $(PERLMODDIR)/mods/Sman/; make -f ./imod.mk install
	@touch $@
 
Term-ShellUI: $(Term_ShellUI_ipaths)
 
$(Term_ShellUI_ipaths):  \
     $(Term_ShellUI_lpaths)
	@cd $(PERLMODDIR)/mods/Term-ShellUI/; make -f ./imod.mk install
	@touch $@
