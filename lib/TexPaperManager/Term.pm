
package TexPaperManager::Term;

use strict;
use warnings;

use Term::ShellUI;
use File::Spec::Functions qw(catfile rel2abs curdir );

# Shell Terminal stuff {{{

# _term_get_commands()  {{{

=head3 _term_get_commands

=cut

sub _term_get_commands {
    my ($self) = @_;

    my $commands = {
        #########################
        # Aliases           {{{
        #########################
        "q"   => { alias => "quit" },
        "h"   => { alias => "help" },
        "m"   => { alias => "make" },
        "tns" => { alias => "texnices" },

        #               }}}
        #########################
        # General purpose        {{{
        #########################
##cmd_quit
        "quit" => {
            desc    => "Quit",
            maxargs => 0,
            method  => sub {
                $self->_term_exit;
                shift->exit_requested(1);
            },
        },
##cmd_help
        "help" => {
            desc => "Print helpful information",
            args => sub { shift->help_args( undef, @_ ); },
            meth => sub {
                $self->termcmd_reset("help @_");
                shift->help_call( undef, @_ );
              }
        },
##cmd_cat
        "cat" => {
            desc => "Use the 'cat' system command"
        },
##cmd_clear
        "clear" => {
            desc => "Use the 'clear' system command",
            proc => sub {
                system("clear");
            },
        },
##cmd_pdf2tex
        "pdf2tex" => {
            desc => "Convert PDF file(s) to LaTeX",
            proc => sub { $self->_pdf2tex(@_); },
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
        },
##cmd_pwd
        "pwd" => {
            desc => "Return the current directory",
            proc => sub {
                $self->termcmd_reset("pwd");
                print rel2abs( curdir() ) . "\n";
              }
        },
        "ui" => {
            desc    => "Update info",
            maxargs => 0,
            proc    => sub {
                $self->termcmd_reset("ui");
                $self->update_info();
            },
        },

        #                 }}}
        #########################
        # List ...       {{{
        #########################
        "lpdf" => {
            desc => "List PDF files of different type",
            cmds => {
                xp => {
                    desc => "List compiled (from LaTeX source) PDF files",
                    proc => sub { $self->list_compiled("pdf_papers"); }
                },
                pa => {
                    desc => "List compiled PDF parts",
                    proc => sub { $self->list_compiled("pdf_parts"); }
                },
                b => {
                    desc    => "List base PDF files (original paper files)",
                    minargs => 0,
                    args    => sub {
                        shift;
                        $self->_complete_papers( "original_pdf", @_ );
                    },
                    proc => sub { $self->list_pdf_papers(@_); }
                }
            }
        },
##cmd_part
        "part" => {
            cmds => {
                gentex => {
                    desc => "Generate pap_part_PART.tex file",
                    args =>
                      sub { shift; $self->_complete_cmd( [qw(lparts)] ); },
                    proc => sub {
                        $self->part(@_);
                        $self->_part_make_set_opts();
                        $self->_part_make_tmpdir();
                        $self->_part_make_generate_tex(@_);
                      }
                },
                runtex => {
                    desc => "Run tex for pap_part_PART.tex file",
                    args =>
                      sub { shift; $self->_complete_cmd( [qw(lparts)] ); },
                    proc => sub {
                        $self->part(@_);
                        $self->_part_make_set_opts();
                        $self->_part_make_tmpdir();
                        $self->_part_make_generate_tex(@_);
                        $self->_tex_paper_run_tex( 'part', @_ );
                      }
                },
            }
        },
##cmd_x
        "x" => {
            desc => "Execute file with psh commands",
        },
##cmd_nwp
        nwp => {
            desc => "Create LaTeX sources for the given bibtex key",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            proc => sub { system("bash nwp @_"); }
        },
##cmd_list
        "list" => {
            cmds => {
                commands => {},
##cmd_list_pdf_papers
                pdfpapers => {
                    desc => "List original PDF papers",
                    proc => sub { $self->original_pdf_papers_print; }
                },
                "refs" => {
                    desc => "List references for the given paper key",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub { $self->_tex_paper_list_refs(@_); }
                },
                "eqs" => {
                    desc => "List equations for the given paper key",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub { $self->_tex_paper_list_eqs(@_); }
                },
##cmd_list_papsecs
                papsecs => {
                    desc =>
                      "List paper section names and ids for the given paper",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub {
                        my $pkey = shift || '';

                        $self->pkey($pkey) if $pkey;
                        $self->_tex_paper_load_conf();
                        $self->_tex_paper_get_secfiles();
                        $self->papsecs_print();
                      }
                },
##cmd_list_papfigs
                papfigs => {
                    desc =>
                      "List paper figure names and ids for the given paper",
                    args =>
                      sub { shift; $self->_complete_papers( "tex", @_ ); },
                    proc => sub {
                        $self->pkey(shift);
                        $self->_tex_paper_get_figs();
                        $self->papfigs_print();
                      }
                },
##cmd_list_accessors
                accessors => {
                    desc =>
                      "List Class::Accessor::Complex accessors for psh.pl",
                    proc => sub { $self->list_accessors(); }
                },
                bibkeys => {
                    desc => "List BibTeX keys",
                    proc => sub { $self->bibtex->list_keys(); }
                },
                figtex => {
                    desc => "List available p.*.fig.*.tex files ",
                    proc => sub { $self->list_fig_tex(); }
                },
                texpapers => {
                    desc => "List LaTeX source papers",
                    proc => sub { print $_ . "\n" for ( $self->tex_papers ); }
                },
                shorttexpapers => {
                    desc => "List short keys for LaTeX source papers",
                    proc =>
                      sub { print $_ . "\n" for ( $self->short_tex_papers ); }
                },
                compiledtexpapers => {
                    desc => "List compiled PDFs for LaTeX source papers",
                    proc => sub {
                        print $_ . "\n" for ( $self->compiled_tex_papers );
                      }
                },
                compiledparts => {
                    desc => "List compiled PDFs for LaTeX source papers",
                    proc => sub {
                        print $_ . "\n" for ( $self->compiled_parts );
                      }
                },
                parts => {
                    desc => "List parts",
                    proc => sub { $self->_parts_list(); }
                },
##cmd_list_vars
                vars => {
                    desc => "List variables (used by mktex.pl etc. )",

                    #TODO list vars
                    proc => sub { $self->list_vars(); }
                },
##cmd_list_scripts
                scripts => {
                    desc => "List scripts ( in this directory )",
                    proc => sub { $self->list_scripts(); }
                },
##cmd_list_partpaps
                partpaps => {
                    desc => "List paper keys for the given part",
                    args =>
                      sub { shift; $self->_complete_cmd( [qw(lparts)], @_ ); },
                    proc => sub { $self->list_partpaps(@_); }
                  }

            }
        },

        # }}}
        #########################
        # Builds {{{
        build => {
            desc    => "Perform a build",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(builds)], @_ ); },
            proc => sub { $self->_build(@_); },
        },

        # }}}
        #########################
        # View ... {{{
##cmd_view
		view => {
            desc    => "View ...",
            minargs => 1,
            args => sub { shift; $self->_complete_cmd( "view", @_ ); },
            proc => sub { $self->view_tex_short( "ref", @_ ); },
			cmds => {
##cmd_view_pdfpaper
				pdfpaper => {
					desc => "vep - View original PDF paper(s)",
					args => sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
					proc => sub {
						$self->read_VARS;
						$self->view_pdf_paper(@_);
					},
				},
##cmd_view_myself
				myself => {
					desc => "vm - View myself",
            		proc => sub { $self->view("vm"); }
				},
##cmd_view_confpl
		        confpl => {
		            desc    => "vcnf - View the p.PKEY.conf.pl file",
		            minargs => 1,
		            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
		            proc    => sub { $self->view_tex( "cnf", @_ ); },
		        },
##cmd_view_ref
		        ref => {
		            desc    => "vref - View the refs",
		            minargs => 1,
		            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
		            proc    => sub { $self->view_tex( "ref", @_ ); },
		        },
##cmd_view_refshort
		        refshort => {
		            desc    => "vrefs - View the refs (short)",
		            minargs => 1,
		            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
		            proc => sub { $self->view_tex_short( "ref", @_ ); },
		        },
##cmd_view_bib
		        bib => {
		            desc => "vbib - View the bibtex file currently in use",
		            proc => sub { $self->view( "bib", @_ ); },
		        },
			},
		},
        vrefs => {
            desc    => "View the refs (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_tex_short( "ref", @_ ); },
        },
        vref => {
            desc    => "View the refs",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "ref", @_ ); },
        },
        vcits => {
            desc    => "View the citing papers (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_tex_short( "cit", @_ ); },
        },
        vcit => {
            desc    => "View the citing papers",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "cit", @_ ); },
        },
        vidx => {
            desc    => "View the *.ind, *.idx  files",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "idx", @_ ); },
        },
        vnc => {
            desc => "View the nc files",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "nc", @_ ); }
        },
        vm => {
            desc => "View myself",
            proc => sub { $self->view("vm"); }
        },
        vcnf => {
            desc    => "View the p.PKEY.conf.pl file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "cnf", @_ ); },
        },
        vcnfs => {
            desc    => "View the p.PKEY.conf.pl file (using the short key)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_tex_short( "cnf", @_ ); },
        },
        vref => {
            desc    => "View the p.PKEY.refs.tex file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "ref", @_ ); },
        },
        vbib => {
            desc => "View the bibtex file currently in use",
            proc => sub { $self->view( "bib", @_ ); },
        },
        vxpdf => {
            desc    => "View the p.PKEY.pdf.tex file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->view_tex( "pdf", @_ ); },
        },

        # }}}
        #########################
        # Print ... {{{
        p => {
            desc    => "Print full info for the given pkey",
            proc    => sub { $self->_p(@_); },
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "bib", @_ ); },
        },
        ps => {
            desc    => "Print full info for the given pkey (short)",
            proc    => sub { $self->_p_short(@_); },
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
        },

        # }}}
        #########################
        # Remove ... {{{
        rmcnf => {
            desc    => "Remove Perl configuration file for the given paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_conf_remove(@_); },
        },

        # }}}
        #########################
        # Parts {{{
        #########################
        lparts => {
            desc => "Alias for list parts",
            proc => sub { $self->_parts_list(); }
        },
##cmd_gitco
        gitco => {
            desc => "Run git co -- *",
            proc => sub { $self->_gitco(@_); },
            args => sub { shift; $self->_complete_cmd( [qw( gitco )], @_ ); }
        },
##cmd_vpr
        vpr => {
            desc => "View (edit) the list of papers for a specific part",
            proc => sub { $self->_part_view_tex(@_); },
            args => sub { shift; $self->_complete_cmd( [qw(lparts)], @_ ); }
        },
##cmd_vpap
        vpap => {
            desc =>
              "View the compiled PDF file which corresponds to the given part ",
            minargs => 1,
            proc    => sub { $self->_part_view_pdf(@_); },
            args    => sub { shift; $self->_complete_cmd( [qw(lparts)], @_ ); }
        },

        #           }}}
        #########################
        # PDF (base) paper files      {{{
        #########################
        #"pget" => {
        #desc => "Download PDF files",
        #minargs => 1,
        #args => sub { shift; $self->_complete_papers("pdf",@_); },
        #proc => sub { $self->view_pdf_paper(@_); }
        #},
##cmd_vep
		"vep" => {
			desc    => "View the PDF file for the corresponding paper key",
			minargs => 1,
			args =>
				sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
			proc => sub {
				$self->read_VARS;
				$self->view_pdf_paper(@_);
			}
        },
        "veqs" => {
            desc    => "View the PDF eqs file for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_view_pdfeqs(@_); }
        },
        "veps" => {
            desc    => "View the PDF file given the short key",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->view_pdf_paper_short(@_); }
        },
        "vepist" => {
            desc    => "vep -i -s SKEY -t",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_vepist(@_); }
        },
        "cnp" => {
            desc =>
              "(bash script) OCR the PDF file and then convert it to DJVU",
            minargs => 1,
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); },
            proc => sub { $self->_cnp(@_); }
        },
        "lsp" => {
            desc    => "List all PDF papers starting with the given pattern",
            minargs => 0,
            proc    => sub { $self->list_pdf_papers(@_); },
            args =>
              sub { shift; $self->_complete_papers( "original_pdf", @_ ); }
        },

        #                }}}
        #########################
        # PDF LaTeX files      {{{
        #########################
        rtex => {
            desc => "Run LaTeX single time",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_run_tex( 'pdf', @_ ); }
        },
        splitmain => {
            desc => "Run LaTeX main file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub {
                $self->_tex_paper_splitpiece( 'fig', @_ );
                $self->_tex_paper_splitmain(@_);
              }
        },
        rtexs => {
            desc => "Run LaTeX single time (short form)",
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_run_tex_short(@_); }
        },
        cbib2cite => {
            desc =>
"Convert all cbib/cbibr/cbibm occurences to cite{...} (leaving cbib... inside comments )",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_cbib2cite(@_); }
        },
        latex => {
            desc => "Run LaTeX single time",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_run_latex(@_); }
        },
        latexs => {
            desc => "Run LaTeX single time",
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_run_latex_short(@_); }
        },
        "ctex" => {
            desc => "Clean LaTeX intermediate files",
            proc => sub {
                $self->termcmd_reset("ctex @_");
                $self->_tex_clean(@_);
              }
        },
        "wconf" => {
            desc    => "Write Perl configuration file for the given paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_write_conf(@_); }
        },
        "lconf" => {
            desc    => "Load Perl configuration file for the given paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_load_conf(@_); }
        },
        "latexml" => {
            desc    => "LaTeX parsing through LaTeXML",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_latexml(@_); }
        },
        "hermes" => {
            desc    => "LaTeX parsing through hermes",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_hermes(@_); }
        },
        "tralics" => {
            desc    => "LaTeX parsing through tralics",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_tralics(@_); }
        },
        "htlatex" => {
            desc    => "LaTeX-to-HTML conversion through (customized) htlatex",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_htlatex(@_); }
        },
        "l2h" => {
            desc    => "LaTeX -> HTML conversion",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_latex_2_html(@_); }
        },
        "l2hs" => {
            desc    => "LaTeX -> HTML conversion (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_latex_2_html_short(@_); }
        },
        "lconfs" => {
            desc =>
              "Load Perl configuration file for the given paper key (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_load_conf_short(@_); }
        },
        "renames" => {
            desc => "Perform renames on LaTeX paper source using renames.sh ",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_renames(@_); }
        },
        "setp" => {
            desc    => "Set the given pkey as the current one",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "bib", @_ ); },
            proc => sub { $self->_pkey_set_current(@_); }
        },
        "setps" => {
            desc    => "Set the given pkey as the current one (short key)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_pkey_set_current_short(@_); }
        },
        "genrefs" => {
            desc => "Generate p.PKEY.refs.tex "
              . " file from the Perl configuration file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'refs', @_ ); }
        },
##cmd_geneqs
        "geneqs" => {
            desc => "Generate p.PKEY.eqs.tex "
              . " file from the Perl configuration file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'eqs', @_ ); }
        },
##cmd_gen_make_pdf_tex_mk
        "gen_make_pdf_tex_mk" => {
            desc => "",
            proc => sub { $self->_gen_make_pdf_tex_mk(); }
        },
##cmd_geneqsdat
        "geneqsdat" => {
            desc => "Generate p.PKEY.eqs.dat "
              . " file from the LaTeX paper source files",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_eqsdat(@_); }
        },
        "sepeqs" => {
            desc => "Generate p.PKEY.eq.*.tex "
              . " file from the tex paper sources",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_sep( 'eqs', @_ ); }
        },
        "genfigs" => {
            desc => "Generate p.PKEY.figs.tex "
              . " file from the corresponding .dat file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'figs', @_ ); }
        },
        "gentabs" => {
            desc => "Generate p.PKEY.tabs.tex "
              . " file from the corresponding .dat file",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_file( 'tabs', @_ ); }
        },
        "genrefsdat" => {
            desc => "Generate p.PKEY.refs.i.dat "
              . " file from the Perl configuration file",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_refsdat(@_); }
        },
        "gensecsdat" => {
            desc => "Generate p.PKEY.secs.i.dat "
              . " file from the corresponding LaTeX source file(s)",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_gen_secsdat(@_); }
        },
        "texnice" => {
            desc => "Make TeX files nicer",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_tex_nice(@_); }
        },
        "texnices" => {
            desc    => "Make TeX files nicer (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_tex_nice( $self->_long_key(@_) ); }
        },
        "lrefs" => {
            desc => "List references for the given paper key",
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_list_refs(@_); }
        },
        "vp" => {
            desc    => "View the LaTeX files for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_view(@_); }
        },
        "vps" => {
            desc    => "View the LaTeX paper source given its short key",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_view_short(@_); }
        },
        "vxp" => {
            desc    => "View the LaTeX files for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_tex_paper_view( @_, "--remote-tab-silent" ); }
        },
        "vpp" => {
            desc => "View the PDF file (compiled from LaTeX sources)"
              . " for the corresponding paper key",
            minargs => 1,
            args    => sub { shift; $self->_complete_papers( "tex", @_ ); },
            proc => sub { $self->_compiled_tex_paper_view(@_); }
        },
        "vpps" => {
            desc => "View the PDF file (compiled from LaTeX sources)"
              . " for the corresponding paper key (short form)",
            minargs => 1,
            args =>
              sub { shift; $self->_complete_cmd( [qw(short_tex_papers)], @_ ); }
            ,
            proc => sub {
                $self->read_VARS;
                $self->_compiled_tex_paper_view_short(@_);
              }
        },
##cmd_make
###cmd_make
        "make" => {
            desc => "Compile the LaTeX file for the"
              . " given paper key into a PDF document ",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(make)], @_ ); },
            proc => sub { $self->_make(@_); }
        },
##cmd_mpa
        "mpa" => {
            desc    => "Compile the part PDF file",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(mpa)], @_ ); },
            proc    => sub {
                $self->termcmd_reset("mpa @_");
                $self->_part_make(@_);
              }
        },
##cmd_mpdfeqs
        "mpdfeqs" => {
            desc => "Compile the pdfeqs PDF file",
            args => sub { shift; $self->_complete_papers( 'tex', @_ ); },
            proc => sub {
                $self->_tex_paper_mpdfeqs(@_);
              }
        },
##cmd_mpdfrevtex
        "mpdfrevtex" => {
            desc => "Compile the paper PDF file in revtex style",
            args => sub { shift; $self->_complete_papers( 'tex', @_ ); },
            proc => sub {
                $self->_tex_paper_mpdfrevtex(@_);
              }
        },
        "ppc" => {
            desc    => "Copy the part PDF file from remote host to ~/pdfout",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(mpa)], @_ ); },
            proc    => sub {
                $self->termcmd_reset("ppc @_");
                $self->_part_pdf_remote_copy(@_);
              }
##cmd_mps
        },
        "mps" => {
            desc =>
              "Compile the LaTeX paper source using as input its short key",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub {
                $self->termcmd_reset("mps @_");
                $self->_tex_paper_make_short(@_);
              }
        },
        "mh" => {
            desc    => "Compile the LaTeX paper source to HTML",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(make)], @_ ); },
            proc => sub { $self->_tex_paper_mh(@_); }
        },
        "mhs" => {
            desc    => "Compile the LaTeX paper source to HTML (short)",
            minargs => 1,
            args => sub { shift; $self->_complete_papers( "short_tex", @_ ); },
            proc => sub { $self->_tex_paper_mh_short(@_); }
        },

        #             }}}
        #########################
        # HTML {{{

        "makehtml" => {
            desc    => "Generate HTML from LaTeX sources",
            minargs => 1,
            args    => sub { shift; $self->_complete_cmd( [qw(make)], @_ ); },
            proc => sub { $self->make_html_paper(@_); }
        },

        # }}}
        #########################
        # BibTeX       {{{
        #########################
        "bibexpand" => {
            desc => "Expand a BiBTeX file using the LaTeX file 
            with journal definitions",
            proc => sub { $self->_bib_expand(); }
        },
        "rmfields" => {
            desc => "Remove unnecessary fields from the BibTeX file",
            proc => sub { $self->_bibtex_rmfields(); }
        },
        "cbib" => {
            desc => "Create p.PKEY.cbib.tex file for the given paper key PKEY",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            minargs => 1,
            proc    => sub { $self->sysrun("cbib.pl --pkey @_ --wcbib"); }
        },
        "spk" => {
            desc =>
"Print (if exists), or compute short paper key given its long form",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            minargs => 1,
            proc    => sub { $self->sysrun("spk @_"); }
        },
        "bt" => {
            desc => "BibTeX wrapper command",
            args => sub { shift; $self->_complete_cmd( [qw(bt)], @_ ); },
            proc => sub { $self->_bt(@_); },
            cmds => {
                lk => {
                    desc => "List BibTeX "
                      . " keys starting with the specified string pattern",
                    args =>
                      sub { shift; $self->_complete_papers( "bib", @_ ); },
                    proc => sub { $self->_bt( "lk", @_ ); }
                },
                pkt => {
                    desc =>
                      "Given the BibTeX key, print the corresponding title ",
                    args =>
                      sub { shift; $self->_complete_papers( "bib", @_ ); },
                    proc => sub { $self->_bt( "pkt", @_ ); }
                }
            }
        },
        "lbib" => {
            desc => "List all BibTeX keys starting with the given pattern",
            args => sub { shift; $self->_complete_papers( "bib", @_ ); },
            proc => sub { $self->_bt( "lk", @_ ); }
        },

        #             }}}
        #########################
        # Makeindex {{{
        #########################
        "mist" => {
            desc => "Change makeindex style (PDF part generation) ",
            proc => sub { $self->makeindexstyle(@_); },
            args => sub { shift; $self->_complete_cmd( [qw(mistyles)], @_ ); },
        },

        # }}}
        #########################
        # Sync {{{
        "updateppics" => {
            desc => "Update ppics directory ",
            proc => sub { $self->update_ppics(@_); }
        },
        "convertppics" => {
            desc => "Convert pics for the given paper",
            proc => sub { $self->_tex_paper_convert_ppics(@_); },
            args => sub { shift; $self->_complete_papers( "tex", @_ ); },
        },
        #########################
    };
##cmd_set
    $commands->{set} = { desc => "(Re-)Set scalar accessor value", };
    foreach my $acc ( @{ $self->accessors("scalar") } ) {
        $commands->{set}->{cmds}->{$acc} = {
            proc => sub { $self->set_scalar_accessor( $acc, @_ ); },
            args => sub {
                shift;
                $self->_complete_cmd( ["scalar_accessor_$acc"], @_ );
            },
        };
    }

    #########################
    # System commands   {{{
    #########################
    $self->shellterm_sys_commands(qw( cat less more ));

    foreach my $cmd ( $self->shellterm_sys_commands ) {
        $commands->{$cmd} = {
            desc => "Wrapper for the system command: $cmd",
            proc => sub { $self->sysrun("$cmd @_"); },
            args => sub { shift->complete_files(@_); }
        };
    }

    #           }}}
    #########################

    $self->term_commands($commands);
    $self->shellterm( commands => $commands );

}

# }}}
# _term_list_commands() {{{

=head3 _term_list_commands()

=cut

sub _term_list_commands() {
    my $self = shift;
}

# }}}
# _term_init() {{{

=head3 _term_init()

Initialize a shell terminal L<Term::ShellUI> instance.

=cut

sub _term_init() {
    my $self = shift;

	$self->say('Start _term_init()');

	$self->say('Initializing Term::ShellUI instance...');

    $self->inputcmdfile("x.psh");

    $self->_term_get_commands();

    $self->shellterm( history_file => $self->files('history') );

    $self->shellterm( prompt       => "PaperShell>" );

    my $term = Term::ShellUI->new(
        commands     => $self->shellterm("commands"),
        history_file => $self->shellterm("history_file"),
        prompt       => $self->shellterm("prompt")
    );

    $self->shellterm( obj => $term );

	$self->say('End _term_init()');
}

sub _term_x() {
    my $self = shift;

    $self->read_cmdfile();

    foreach my $cmd ( $self->xcommands ) {
        $self->x($cmd) if $self->_opt_true("runx");
    }
}

sub x {
    my $self = shift;

    my $cmd = shift;

    system("pshcmd $cmd");
}

sub read_cmdfile() {
    my $self = shift;

    return 0 unless -e $self->inputcmdfile;

    my @lines = read_file $self->inputcmdfile;

    foreach (@lines) {
        next if /^\s*#/;
        next if /^\s*$/;
        chomp;
        $self->xcommands_push( split( ';', $_ ) );
    }
}

# }}}
# _term_run() {{{

=head3 _term_run()

=cut

sub _term_run() {
    my $self = shift;

    my $cmds = shift || [qw()];

	$self->say('Start _term_run()');

    unless (@$cmds) {
        if ( $self->inputcommands ) {
            @$cmds = split( ';', $self->inputcommands );
        }
    }

    if (@$cmds) {

        # Single command with arguments
        unless ( ref $cmds ) {
            $self->shellterm("obj")->run($cmds);
        }
        elsif ( ref $cmds eq "ARRAY" ) {
            foreach my $cmd (@$cmds) {
                $self->shellterm("obj")->run($cmd);
            }
        }
    }
    else {
        exit 0 unless $self->_opt_true("shell");
        $self->shellterm("obj")->run();
    }
}

# }}}
# _term_exit() {{{

=head3 _term_exit() 

=cut

sub _term_exit() {
    my $self = shift;

    $self->LOGFILE->close;
}

# }}}

# }}}

# }}}


1;
 

