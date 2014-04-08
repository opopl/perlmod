
package OP::TEX::LATEXMK;


use warnings;
use strict;

no strict 'refs';
###use

use Exporter ();

use Config;
use File::Copy;
use File::Basename;
use FileHandle;
use File::Find;
use List::Util qw( max );
use Cwd;            # To be able to change cwd
use Cwd "chdir";    # Ensure $ENV{PWD}  tracks cwd
use Digest::MD5;
use Term::ANSIColor;
use FindBin qw($Bin $Script);

use OP::Script::Simple qw( 
	_debug
	_say 
	pre_init 
);

# The following variables are assigned once and then used in symbolic
#     references, so we need to avoid warnings 'name used only once':
use vars qw( $dvi_update_command $ps_update_command $pdf_update_command );

###our
our @ISA     = qw(Exporter);
our @EXPORT_OK = qw( main);
our @EXPORT  = qw( );
our $VERSION = '0.01';

our $makeindexstyle;
our ($fh);
our ($i);
our (@result);
our ($PA_extra_generated);
our ($PAfile_data);
our ($PAint_cmd);
our ($PArule_data);
our ($PHdest);
our ($PHsource);
our ($P_allowed_primaries);
our ($Paux_files);
our ($Pbase);
our ($Pbib_files);
our ($Pbst_files);
our ($Pchanged);
our ($Pcheck_time);
our ($Pcmd_type);
our ($Pcorrect_after_primary);
our ($Pext_cmd);
our ($Pfrom_rule);
our ($Plast_message);
our ($Plast_result);
our ($Pmd5);
our ($Pneed_to_get_viewer_process);
our ($Prun_time);
our ($Psize);
our ($Pviewer_process);
our ($action1);
our ($base_name);
our ($check_time);
our ($compiling_cmd);
our ($count_rules);
our ($cus_dep_target);
our ($depth);
our ($dest_mtime);
our ($exists);
our ($ext);
our ($failure_cmd);
our ($file1);
our ($file_act);
our ($file_act1);
our ($file_act2);
our ($filename);
our ($given_name);
our ($have_break);
our ($ignore_run_time);
our ($missing_dvi_pdf);
our ($new_dest);
our ($new_file);
our ($new_files);
our ($new_from_rule);
our ($newrule_nofile);
our ($out_handle);
our ($out_name);
our ($retcode);
our ($rule_act1);
our ($rule_act2);
our ($runs);
our ($set_not_exists);
our ($state);
our ($success_cmd);
our ($tex_name);
our ($too_many_passes);
our ($view_file);
our ($viewer_update_method);
our (%PHsource);
our (%current_primaries);
our (%first_read_after_write);
our (%from_rules);
our (%input_extensions);
our (%new_sources);
our (%old_sources);
our (%pass);
our (%rules_applied);
our (%visited);
our (@PAnew_cmd);
our (@accessible);
our (@changed);
our (@classify_stack);
our (@deletions);
our (@dests);
our (@disappeared);
our (@errors);
our (@files);
our (@heads);
our (@new_sources);
our (@no_dest);
our (@post_primary);
our (@pre_primary);
our (@requested_targets);
our (@rules_never_run);
our (@rules_to_apply);
our (@warnings);

our ( $aux_main, $fdb_name, $log_name );
our (%rule_list);
our ($have_fdb);
our %generated_log;
our $error_count;
our $error_message_count;
our $dvi_final;
our $ps_final;
our $pdf_final;
our $file;
our %source_list;
our %source_fls;
our %accessible_filerules;
our @accessible_filerules;
our $rdb_errors;
our $Ptest_kind;
our $Ptime;
our $Pout_of_date;
our $Pout_of_date_user;
our @misparse;
our @bbl_files;
our $rule;
our %dependents;
our %idx_files;
our %conversions;
our $primary_out;
our @accessible_all;
our %generated_fls;
our $path;
our $Psource;
our $Pdest;
our $texfile_name;
our (@default_includes);
our ($root_filename);
our ($quell_uptodate_msgs);
our ( $failure, $failure_msg );
our ($failure_count);
our (@failed_primaries);
our ($deps_handle);
our ($original);
our (%generated_exts_all);
our ( $num_files, $num_specified );
our (@file_list);
our ( %one_time, %possible_one_time, %possible_primaries, %primaries,
    %requested_filerules );
our @one_time;
our (%rule_db);
our (%fdb_current);
our ($HOME);
our ($bad_options);
our (@command_line_file_list);
our ( $aux_dir1, $out_dir1 );

our (@BIBINPUTS);
our ($BIBINPUTS);
our ($MSWin_back_slash);
our ($MSWin_fudge_break);
our ($My_name);
our (%allowed_latex_options);
our (%allowed_latex_options_with_arg);
our ($always_view_file_via_temporary);
our ($auto_rc_use);
our ($aux_dir);
our ($bad_citation);
our ($bad_reference);
our ($banner);
our ($banner_intensity);
our ($banner_message);
our ($banner_scale);
our ($biber);
our ($biber_silent_switch);
our ($bibtex);
our ($bibtex_silent_switch);
our ($bibtex_use);
our (%cache);
our ($clean_ext);
our ($clean_full_ext);
our ($cleanup_fdb);
our ($cleanup_includes_cusdep_generated);
our ($cleanup_includes_generated);
our ($cleanup_mode);
our ($cleanup_only);
our (@cus_dep_list);
our (@default_excluded_files);
our (@default_files);
our ($del_dir);
our ($dependents_list);
our ($dependents_phony);
our ($deps_file);
our ($diagnostics);
our (@dir_stack);
our ($do_cd);
our ($dvi_filter);
our ($dvi_mode);
our ($dvi_previewer);
our ($dvi_previewer_landscape);
our ($dvi_update_command);
our ($dvi_update_method);
our ($dvi_update_signal);
our ($dvipdf);
our ($dvipdf_silent_switch);
our ($dvips);
our ($dvips_landscape);
our ($dvips_pdf_switch);
our ($dvips_silent_switch);
our ($extension_treatment);
our (@extra_latex_options);
our (@extra_pdflatex_options);
our ($fdb_ext);
our ($fdb_ver);
our (@file_not_found);
our ($force_mode);
our (@generated_exts);
our ($go_mode);
our (%hash_calc_ignore_pattern);
our ($jobname);
our ($kpsewhich);
our ($landscape_mode);
our ($latex);
our ($latex_default_switches);
our ($latex_silent_switch);
our ($log_file_binary);
our ($log_wrap);
our ($lpr);
our ($lpr_dvi);
our ($lpr_pdf);
our ($make);
our ($makeindex);
our ($makeindex_exe);
our ($makeindex_silent_switch);
our ($max_repeat);
our ($my_name);
our ($new_viewer_always);
our ($out_dir);
our ($pdf_mode);
our ($pdf_previewer);
our ($pdf_update_command);
our ($pdf_update_method);
our ($pdf_update_signal);
our ($pdflatex);
our ($pdflatex_default_switches);
our ($pdflatex_silent_switch);
our ($pid_position);
our ($postscript_mode);
our ($preview_continuous_mode);
our ($preview_mode);
our ($print_type);
our ($printout_mode);
our ($processing_time1);
our ($ps2pdf);
our ($ps_filter);
our ($ps_previewer);
our ($ps_previewer_landscape);
our ($ps_update_command);
our ($ps_update_method);
our ($ps_update_signal);
our ($pscmd);
our ($pvc_view_file_via_temporary);
our ($quote_filenames);
our (@rc_system_files);
our ($recorder);
our ($reference_changed);
our ($rules_list);
our ($search_path_separator);
our ($show_time);
our (@signame);
our (%signo);
our ($silent);
our ($sleep_time);
our ($start_NT);
our ($texfile_search);
our (@timings);
our ($tmpdir);
our ($updated);
our ($use_make_for_missing_files);
our ($version_details);
our ($version_num);
our ($view);
our ($waiting);

sub run;
sub invoke;
###subs
sub main;

sub OS_preferred_filename;
sub Parray;
sub Run;
sub Run_Detached;
sub Run_msg;
sub Run_subst;
sub add_cus_dep;
sub add_input_ext;
sub add_option;
sub cache_good_cwd;
sub catch_break;
sub check_biber_log;
sub check_bibtex_log;
sub clean_filename;
sub cleanup1;
sub cleanup_cusdep_generated;
sub cleanup_one_cusdep_generated;
sub cus_dep_delete_dest;
sub cus_dep_require_primary_run;
sub default_break;
sub deps_list;
sub die_trace;
sub do_cusdep;
sub do_update_view;
sub do_viewfile;
sub end_wait;
sub execute_code_string;
sub exit_msg1;
sub ext;
sub ext_no_period;
sub fdb_get;
sub fdb_set;
sub fdb_show;
sub fileparseA;
sub fileparseB;
sub find_dirs;
sub find_dirs1;
sub find_file1;
sub find_file_list1;
sub find_process_id;
sub finish_dir_stack;
sub fix_cmds;
sub get_checksum_md5;
sub get_mtime;
sub get_mtime0;
sub get_mtime_raw;
sub get_opt;
sub get_size;
sub get_size_raw;
sub get_time_size;
sub get_time_size_raw;
sub glob_list;
sub glob_list1;
sub good_cwd;
sub if_source;
sub ifcd_popd;
sub init_cmds;
sub init_default;
sub init_options;
sub init_os;
sub init_vars;
sub kpsewhich;
sub make_preview_continuous;
sub normalize_clean_filename;
sub normalize_filename;
sub normalize_force_directory;
sub parse_aux;
sub parse_fls;
sub parse_log;
sub parse_quotes;
sub popd;
sub prefix;
sub print_commands;
sub print_help;
sub process_rc_file;
sub processing_time;
sub pushd;
sub rdb_accessible;
sub rdb_add_generated;
sub rdb_classify1;
sub rdb_classify2;
sub rdb_classify_rules;
sub rdb_clear_change_record;
sub rdb_create_rule;
sub rdb_diagnose_changes;
sub rdb_do_files;
sub rdb_dummy_file;
sub rdb_dummy_run1;
sub rdb_ensure_file;
sub rdb_file_change1;
sub rdb_file_exists;
sub rdb_find_new_files;
sub rdb_flag_changes_here;
sub rdb_for_all;
sub rdb_for_one_file;
sub rdb_for_some;
sub rdb_initialize_generated;
sub rdb_list;
sub rdb_make;
sub rdb_make1;
sub rdb_make_links;
sub rdb_make_rule_list;
sub rdb_new_changes;
sub rdb_one_dep;
sub rdb_one_file;
sub rdb_one_rule;
sub rdb_primary_run;
sub rdb_read;
sub rdb_recurse;
sub rdb_recurse_file;
sub rdb_recurse_rule;
sub rdb_remove_files;
sub rdb_remove_rule;
sub rdb_rule_exists;
sub rdb_run1;
sub rdb_set_dependents;
sub rdb_set_file1;
sub rdb_set_latex_deps;
sub rdb_set_rules;
sub rdb_show;
sub rdb_show_rule_errors;
sub rdb_update1;
sub rdb_update_files;
sub rdb_update_gen_files;
sub rdb_write;
sub read_first_rc_file_in_list;
sub read_rc;
sub remove_cus_dep;
sub remove_input_ext;
sub run_bibtex;
sub set_MSWin32;
sub set_cygwin;
sub set_trivial_aux_fdb;
sub set_unix;
sub show_array;
sub show_cus_dep;
sub show_input_ext;
sub show_timing;
sub split_search_path;
sub tempfile1;
sub test_gen_file;
sub traceback;
sub uniq1;
sub uniqs;
sub unlink_or_move;
sub view_file_via_temporary;
sub warn_running;
sub init_HOME;
sub init_other;
sub process_opts;

###main
sub main {

  pre_init;

  my $subs=[qw(
    init_vars
    init_options
    init_cmds
    init_os
    init_default
    init_other
    init_HOME
    read_rc
    get_opt
    process_opts
    run
    )];

  invoke($subs);

}


###invoke
sub invoke {
  my $ref=shift;

  unless(ref $ref){
    my $sub=$ref;
    
    my @evs;
    
    push(@evs,"_debug('Invoking: $sub')");
    push(@evs,"&$sub");

    eval(join(";",@evs));
    die $@ if $@;
    
  }elsif(ref $ref eq "ARRAY"){
    my @subs=@$ref;
    foreach my $sub (@subs) {
      invoke($sub);
    }
    
  }
}




sub init_os {

    if ( $^O eq "MSWin32" ) {
        set_MSWin32;
    }
    elsif ( $^O eq "cygwin" ) {
        set_cygwin;
    }
    else {
        set_unix;
    }

}

###init_vars

sub init_vars {
    $my_name         = "latexmk";
    $My_name         = "Latexmk";
    $version_num     = "4.35";
    $version_details = "$My_name, John Collins, 11 Nov. 2012";


    %signo   = ();
    @signame = ();

    if ( defined $Config{sig_name} ) {
        my $i = 0;
        foreach my $name ( split( ' ', $Config{sig_name} ) ) {
            $signo{$name} = $i;
            $signame[$i] = $name;
            $i++;
        }
    }
    else {
        warn "Something wrong with the perl configuration: No signals?\n";
    }

    #########################################################################
    ## Default parsing and file-handling settings

    #Line length in log file that indicates wrapping.
    # This number EXCLUDES line-end characters, and is one-based
    # It is the parameter max_print_line in the TeX program.  (tex.web)

    $log_wrap = 79;

    ## Array of reg-exps for patterns in log-file for file-not-found
    ## Each item is the string in a regexp, without the enclosing slashes.
    ## First parenthesized part is the filename.
    ## Note the need to quote slashes and single right quotes to make them
    ## appear in the regexp.
    ## Add items by push, e.g.,
    ##     push @file_not_found, '^No data file found `([^\\\']*)\\\'';
    ## will give match to line starting "No data file found `filename'"
    @file_not_found = (
        '^No file\\s*(.*)\\.$',
        '^\\! LaTeX Error: File `([^\\\']*)\\\' not found\\.',
        '.*?:\\d*: LaTeX Error: File `([^\\\']*)\\\' not found\\.',
        '^LaTeX Warning: File `([^\\\']*)\\\' not found',
        '^Package .* [fF]ile `([^\\\']*)\\\' not found',
        'Error: pdflatex \(file ([^\)]*)\): cannot find image file',
        ': File (.*) not found:\s*$',
    );

    ## Hash mapping file extension (w/o period, e.g., 'eps') to a single regexp,
   #  whose matching by a line in a file with that extension indicates that the
   #  line is to be ignored in the calculation of the hash number (md5 checksum)
   #  for the file.  Typically used for ignoring datestamps in testing whether
   #  a file has changed.
   #  Add items e.g., by
   #     $hash_calc_ignore_pattern{'eps'} = '^%%CreationDate: ';
   #  This makes the hash calculation for an eps file ignore lines starting with
   #  '%%CreationDate: '
   #  ?? Note that a file will be considered changed if
   #       (a) its size changes
   #    or (b) its hash changes
   #  So it is useful to ignore lines in the hash calculation only if they
   #  are of a fixed size (as with a date/time stamp).
    %hash_calc_ignore_pattern = ();

    #########################################################################
    ## Default document processing programs, and related settings,
    ## These are mostly the same on all systems.
    ## Most of these variables represents the external command needed to
    ## perform a certain action.  Some represent switches.

    ## Commands to invoke latex, pdflatex
    $latex    = "latex %O %S";
    $pdflatex = "PDFLATEX %O %S";

    ## Default switches:
    $latex_default_switches    = "";
    $pdflatex_default_switches = "";

    ## Switch(es) to make them silent:
    $latex_silent_switch    = "-interaction=batchmode";
    $pdflatex_silent_switch = "-interaction=batchmode";

# %input_extensions maps primary_rule_name to pointer to hash of file extensions
#    used for extensionless files specified in the source file by constructs
#    like \input{file}  \includegraphics{file}
#  Could write
#%input_extensions = ( 'latex' => { 'tex' => 1, 'eps' => 1 };,
#        'pdflatex' => { 'tex' => 1, 'pdf' => 1, 'jpg' => 1, 'png' => 1 }; );
# Instead we'll exercise the user-friendly access routines:
    add_input_ext( 'latex', 'tex', 'eps' );
    add_input_ext( 'pdflatex', 'tex', 'jpg', 'pdf', 'png' );

    #show_input_ext( 'latex' ); show_input_ext( 'pdflatex' );

    # Information about options to latex and pdflatex that latexmk will simply
    #   pass through to (pdf)latex
    # Option without arg. maps to itself.
    # Option with arg. maps the option part to the full specification
    #  e.g., -kpathsea-debug => -kpathsea-debug=NUMBER
    %allowed_latex_options          = ();
    %allowed_latex_options_with_arg = ();

##Printing:
    $print_type = "ps";

    # When printing, print the postscript file.
    # Possible values: "dvi", "ps", "pdf", "none"

## Which treatment of default extensions and filenames with
##   multiple extensions is used, for given filename on
##   tex/latex"s command line?  See sub find_basename for the
##   possibilities.
## Current tex"s treat extensions like UNIX teTeX:
    $extension_treatment = "unix";

## Substitute backslashes in file and directory names for
##  MSWin command line
    $MSWin_back_slash = 1;

    $dvi_update_signal = undef;
    $ps_update_signal  = undef;
    $pdf_update_signal = undef;

    $dvi_update_command = undef;
    $ps_update_command  = undef;
    $pdf_update_command = undef;

    $new_viewer_always = 0;

    # If 1, always open a new viewer in pvc mode.
    # If 0, only open a new viewer if no previous
    #     viewer for the same file is detected.

    $quote_filenames = 1;

    # Quote filenames in external commands

    $del_dir = "";

    # Directory into which cleaned up files are to be put.
    # If $del_dir is "", just delete the files

#########################################################################

################################################################
##  Special variables for system-dependent fudges, etc.
    $log_file_binary = 0;

    # Whether to treat log file as binary
    # Normally not, since the log file SHOULD be pure text.
    # But Miktex 2.7 sometimes puts binary characters
    #    in it.  (Typically in construct \OML ... after
    #    overfull box with mathmode.)
    # Sometimes there is ctrl/Z, which is not only non-text,
    #    but is end-of-file marker for MS-Win in text mode.

    $MSWin_fudge_break = 1;

    # Give special treatment to ctrl/C and ctrl/break
    #    in -pvc mode under MSWin
    # Under MSWin32 (at least with perl 5.8 and WinXP)
    #   when latexmk is running another program, and the
    #   user gives ctrl/C or ctrl/break, to stop the
    #   daughter program, not only does it reach
    #   the daughter, but also latexmk/perl, so
    #   latexmk is stopped also.  In -pvc mode,
    #   this is not normally desired.  So when the
    #   $MSWin_fudge_break variable is set,
    #   latexmk arranges to ignore ctrl/C and
    #   ctrl/break during processing of files;
    #   only the daughter programs receive them.
    # This fudge is not applied in other
    #   situations, since then having latexmk also
    #   stopping because of the ctrl/C or
    #   ctrl/break signal is desirable.
    # The fudge is not needed under UNIX (at least
    #   with Perl 5.005 on Solaris 8).  Only the
    #   daughter programs receive the signal.  In
    #   fact the inverse would be useful: In
    #   normal processing, as opposed to -pvc, if
    #   force mode (-f) is set, a ctrl/C is
    #   received by a daughter program does not
    #   also stop latexmk.  Under tcsh, we get
    #   back to a command prompt, while latexmk
    #   keeps running in the background!

################################################################

}

###init_options

sub init_options {

    ###TeXLiveOptions
    foreach (
        #####
        # TeXLive options
"-draftmode              switch on draft mode (generates no output PDF)",
        "-enc                    enable encTeX extensions such as \\mubyte",
        "-etex                   enable e-TeX extensions",
        "-file-line-error        enable file:line:error style messages",
        "-no-file-line-error     disable file:line:error style messages",
"-fmt=FMTNAME            use FMTNAME instead of program name or a %& line",
        "-halt-on-error          stop processing at the first error",
"-interaction=STRING     set interaction mode (STRING=batchmode/nonstopmode/\n"
        . "                           scrollmode/errorstopmode)",
"-ipc                    send DVI output to a socket as well as the usual\n"
        . "                           output file",
"-ipc-start              as -ipc, and also start the server at the other end",
"-kpathsea-debug=NUMBER  set path searching debugging flags according to\n"
        . "                           the bits of NUMBER",
        "-mktex=FMT              enable mktexFMT generation (FMT=tex/tfm/pk)",
        "-no-mktex=FMT           disable mktexFMT generation (FMT=tex/tfm/pk)",
        "-mltex                  enable MLTeX extensions such as \charsubdef",
"-output-comment=STRING  use STRING for DVI file comment instead of date\n"
        . "                           (no effect for PDF)",
"-output-format=FORMAT   use FORMAT for job output; FORMAT is `dvi\" or `pdf\"",
        "-parse-first-line       enable parsing of first line of input file",
        "-no-parse-first-line    disable parsing of first line of input file",
        "-progname=STRING        set program (and fmt) name to STRING",
        "-shell-escape           enable \\write18{SHELL COMMAND}",
        "-no-shell-escape        disable \\write18{SHELL COMMAND}",
        "-shell-restricted       enable restricted \\write18",
        "-src-specials           insert source specials into the DVI file",
        "-src-specials=WHERE     insert source specials in certain places of\n"
        . "                           the DVI file. WHERE is a comma-separated value\n"
        . "                           list: cr display hbox math par parend vbox",
"-synctex=NUMBER         generate SyncTeX data for previewers if nonzero",
        "-translate-file=TCXNAME use the TCX file TCXNAME",
        "-8bit                   make all characters printable by default",

        #####
        # MikTeX options not in TeXLive
        "-alias=app              pretend to be app",
"-buf-size=n             maximum number of characters simultaneously present\n"
        . "                           in current lines",
        "-c-style-errors         C-style error messages",
"-disable-installer      disable automatic installation of missing packages",
"-disable-pipes          disable input (output) from (to) child processes",
        "-disable-write18        disable the \\write18{command} construct",
"-dont-parse-first-line  disable checking whether the first line of the main\n"
        . "                           input file starts with %&",
        "-enable-enctex          enable encTeX extensions such as \\mubyte",
"-enable-installer       enable automatic installation of missing packages",
        "-enable-mltex           enable MLTeX extensions such as \charsubdef",
"-enable-pipes           enable input (output) from (to) child processes",
        "-enable-write18         fully enable the \\write18{command} construct",
"-error-line=n           set the width of context lines on terminal error\n"
        . "                           messages",
"-extra-mem-bot=n        set the extra size (in memory words) for large data\n"
        . "                           structures",
"-extra-mem-top=n        set the extra size (in memory words) for chars,\n"
        . "                           tokens, et al",
        "-font-max=n             set the maximum internal font number",
"-font-mem-size=n        set the size, in TeX memory words, of the font memory",
"-half-error-line=n      set the width of first lines of contexts in terminal\n"
        . "                           error messages",
"-hash-extra=n           set the extra space for the hash table of control\n"
        . "                           sequences",
"-job-time=file          set the time-stamp of all output files equal to\n"
        . "                           file'stime-stamp",
"-main-memory=n          change the total size (in memory words) of the main\n"
        . "                           memory array",
"-max-in-open=n          set the maximum number of input files and error\n"
        . "                           insertions that can be going on simultaneously",
        "-max-print-line=n       set the width of longest text lines output",
        "-max-strings=n          set the maximum number of strings",
        "-nest-size=n            set the maximum number of semantic levels\n"
        . "                           simultaneously active",
        "-no-c-style-errors      standard error messages",
"-param-size=n           set the the maximum number of simultaneous macro\n"
        . "                           parameters",
"-pool-size=n            set the maximum number of characters in strings",
"-record-package-usages=file record all package usages and write them into\n"
        . "                           file",
"-restrict-write18       partially enable the \\write18{command} construct",
"-save-size=n            set the the amount of space for saving values\n"
        . "                           outside of current group",
"-stack-size=n           set the maximum number of simultaneous input sources",
"-string-vacancies=n     set the minimum number of characters that should be\n"
        . "                           available for the user's control sequences and font\n"
        . "                           names",
        "-tcx=name               process the TCX table name",
        "-time-statistics        show processing time statistics",
        "-trace                  enable trace messages",
"-trace=tracestreams     enable trace messages. The tracestreams argument is\n"
        . "                           a comma-separated list of trace stream names",
"-trie-size=n            set the amount of space for hyphenation patterns",
"-undump=name            use name as the name of the format to be used,\n"
        . "                           instead of the name by which the program was\n"
        . "                           called or a %& line.",

        #####
# Options passed to (pdf)latex that have special processing by latexmk,
#   so they are commented out here.
#-jobname=STRING         set the job name to STRING
#-aux-directory=dir    Set the directory dir to which auxiliary files are written
#-output-directory=DIR   use existing DIR as the directory to write files in
#-quiet
#-recorder               enable filename recorder
#
# Options with different processing by latexmk than (pdf)latex
#-help
#-version
#
# Options NOT used by latexmk
#-includedirectory=dir    prefix dir to the search path
#-initialize              become the INI variant of the compiler
#-ini                     be pdfinitex, for dumping formats; this is implicitly
#                          true if the program name is `pdfinitex'
      )
    {
        if (/^([^\s=]+)=/) {
            $allowed_latex_options_with_arg{$1} = $_;
        }
        elsif (/^([^\s=]+)\s/) {
            $allowed_latex_options{$1} = $_;
        }
        else {
            $allowed_latex_options{$_} = $_;
        }
    }

    # Arrays of options that will be added to latex and pdflatex.
    # These need to be stored until after the command line parsing is finished,
    #  in case the values of $latex and/or $pdflatex change after an option
    #  is added.
    @extra_latex_options    = ();
    @extra_pdflatex_options = ();

}

###init_cmds
sub init_cmds {

    ## Command to invoke biber & bibtex
    $biber  = "biber %O %B";
    $bibtex = "bibtex %O %B";

    # Switch(es) to make biber & bibtex silent:
    $biber_silent_switch  = "--onlylog";
    $bibtex_silent_switch = "-terse";
    $bibtex_use           = 1;

    # Whether to actually run bibtex to update bbl files
    # 0:  Never run bibtex
    # 1:  Run bibtex only if the bibfiles exists
    #     according to kpsewhich, and the bbl files
    #     appear to be out-of-date
    # 2:  Run bibtex when the bbl files are out-of-date
    # In any event bibtex is only run if the log file
    #   indicates that the document uses bbl files.

    ## Command to invoke makeindex
    $makeindex_exe='MAKEINDEX';

    $makeindex = "$makeindex_exe  %O -o %D %S";

    # Switch(es) to make makeindex silent:
    $makeindex_silent_switch = "-q";

    ## Command to convert dvi file to pdf file directly:
    $dvipdf = "dvipdf %O %S %D";

    # N.B. Standard dvipdf runs dvips and gs with their silent switch, so for
    #      standard dvipdf $dvipdf_silent_switch is unneeded, but innocuous.
    #      But dvipdfmx can be used instead, and it has a silent switch (-q).
    #      So implementing $dvipdf_silent_switch is useful.

    $dvipdf_silent_switch = "-q";

    ## Command to convert dvi file to ps file:
    $dvips = "dvips %O -o %D %S";
    ## Command to convert dvi file to ps file in landscape format:
    $dvips_landscape = "dvips -tlandscape %O -o %D %S";

  # Switch(es) to get dvips to make ps file suitable for conversion to good pdf:
  #    (If this is not used, ps file and hence pdf file contains bitmap fonts
  #       (type 3), which look horrible under acroread.  An appropriate switch
  #       ensures type 1 fonts are generated.  You can put this switch in the
  #       dvips command if you prefer.)
    $dvips_pdf_switch = "-P pdf";

    # Switch(es) to make dvips silent:
    $dvips_silent_switch = "-q";

    ## Command to convert ps file to pdf file:
    $ps2pdf = "ps2pdf  %O %S %D";

    ## Command to search for tex-related files
    $kpsewhich = "kpsewhich %S";

    ## Command to run make:
    $make = "make";

}

###set_unix
sub set_unix {

    # Assume anything else is UNIX or clone

    ## Configuration parameters:

    ## Use first existing case for $tmpdir:
    $tmpdir = $ENV{TMPDIR} || '/tmp';

    ## List of possibilities for the system-wide initialization file.
    ## The first one found (if any) is used.
    ## Normally on a UNIX it will be in a subdirectory of /opt/local/share or
    ## /usr/local/share, depending on the local conventions.
    ## /usr/local/lib/latexmk/LatexMk is put in the list for
    ## compatibility with older versions of latexmk.
    @rc_system_files = (
        '/opt/local/share/latexmk/LatexMk',
        '/usr/local/share/latexmk/LatexMk',
        '/usr/local/lib/latexmk/LatexMk'
    );

    $search_path_separator = ':';    # Separator of elements in search_path

    $dvi_update_signal = $signo{USR1}
      if ( defined $signo{USR1} );    # Suitable for xdvi
    $ps_update_signal = $signo{HUP}
      if ( defined $signo{HUP} );     # Suitable for gv
    $pdf_update_signal = $signo{HUP}
      if ( defined $signo{HUP} );     # Suitable for gv
    ## default document processing programs.
    # Viewer update methods:
    #    0 => auto update: viewer watches file (e.g., gv)
    #    1 => manual update: user must do something: e.g., click on window.
    #         (e.g., ghostview, MSWIN previewers, acroread under UNIX)
    #    2 => send signal.  Number of signal in $dvi_update_signal,
    #                         $ps_update_signal, $pdf_update_signal
    #    3 => viewer can't update, because it locks the file and the file
    #         cannot be updated.  (acroread under MSWIN)
    #    4 => Run command to update.  Command in $dvi_update_command,
    #    $ps_update_command, $pdf_update_command.
    $dvi_previewer           = 'start xdvi %O %S';
    $dvi_previewer_landscape = 'start xdvi -paper usr %O %S';
    if ( defined $dvi_update_signal ) {
        $dvi_update_method = 2;    # xdvi responds to signal to update
    }
    else {
        $dvi_update_method = 1;
    }

    #    if ( defined $ps_update_signal ) {
    #        $ps_update_method = 2;  # gv responds to signal to update
    #        $ps_previewer  = 'start gv -nowatch';
    #        $ps_previewer_landscape  = 'start gv -swap -nowatch';
    #    } else {
    #        $ps_update_method = 0;  # gv -watch watches the ps file
    #        $ps_previewer  = 'start gv -watch';
    #        $ps_previewer_landscape  = 'start gv -swap -watch';
    #    }
    # Turn off the fancy options for gv.  Regular gv likes -watch etc
    #   GNU gv likes --watch etc.  User must configure
    $ps_update_method = 0;                  # gv -watch watches the ps file
    $ps_previewer     = 'start gv %O %S';
    $ps_previewer_landscape = 'start gv -swap %O %S';
    $pdf_previewer          = 'start acroread %O %S';
    $pdf_update_method = 1;    # acroread under unix needs manual update
    $lpr = 'lpr %O %S';   # Assume lpr command prints postscript files correctly
    $lpr_dvi =
      'NONE $lpr_dvi variable is not configured to allow printing of dvi files';
    $lpr_pdf =
      'NONE $lpr_pdf variable is not configured to allow printing of pdf files';

    # The $pscmd below holds a command to list running processes.  It
    # is used to find the process ID of the viewer looking at the
    # current output file.  The output of the command must include the
    # process number and the command line of the processes, since the
    # relevant process is identified by the name of file to be viewed.
    # Uses:
    #   1.  In preview_continuous mode, to save running a previewer
    #       when one is already running on the relevant file.
    #   2.  With xdvi in preview_continuous mode, xdvi must be
    #       signalled to make it read a new dvi file.
    #
    # The following works on Solaris, LINUX, HP-UX, IRIX
    # Use -f to get full listing, including command line arguments.
    # Use -u $ENV{CMD} to get all processes started by current user (not just
    #   those associated with current terminal), but none of other users'
    #   processes.
    $pscmd = "ps -f -u $ENV{USER}";
    $pid_position = 1;    # offset of PID in output of pscmd; first item is 0.
    if ( $^O eq "linux" ) {

        # Ps on Redhat (at least v. 7.2) appears to truncate its output
        #    at 80 cols, so that a long command string is truncated.
        # Fix this with the --width option.  This option works under
        #    other versions of linux even if not necessary (at least
        #    for SUSE 7.2).
        # However the option is not available under other UNIX-type
        #    systems, e.g., Solaris 8.
        # But (19 Aug 2010), the truncation doesn't happen on RHEL4 and 5,
        #    unless the output is written to a terminal.  So the --width
        #    option is now unnecessary
        # $pscmd = "ps --width 200 -f -u $ENV{USER}";
    }
    elsif ( $^O eq "darwin" ) {

        # OS-X on Macintosh
        # open starts command associated with a file.
        # For pdf, this is set by default to OS-X's preview, which is suitable.
        #     Manual update is simply by clicking on window etc, which is OK.
        # For ps, this is set also to preview.  This works, but since it
        #     converts the file to pdf and views the pdf file, it doesn't
        #     see updates, and a refresh cannot be done.  This is far from
        #     optimal.
        # For a full installation of MacTeX, which is probably the most common
        #     on OS-X, an association is created between dvi files and TeXShop.
        #     This also converts the file to pdf, so again while it works, it
        #     does not deal with changed dvi files, as far as I can see.
        $pdf_previewer     = 'open %S';
        $pdf_update_method = 1;                                   # manual
        $dvi_previewer     = $dvi_previewer_landscape = 'NONE';
        $ps_previewer      = $ps_previewer_landscape = 'NONE';

        # Others
        $lpr_pdf = 'lpr %O %S';
        $pscmd   = "ps -ww -u $ENV{USER}";
    }
}

###set_MSWin32
sub set_MSWin32 {

    # Pure MSWindows configuration
    ## Configuration parameters:

    ## Use first existing case for $tmpdir:
    $tmpdir = $ENV{TMPDIR} || $ENV{TEMP} || ".";
    $log_file_binary = 1;    # Protect against ctrl/Z in log file from
                             # Miktex 2.7.

    ## List of possibilities for the system-wide initialization file.
    ## The first one found (if any) is used.
    @rc_system_files = ("C:/latexmk/LatexMk");

    $search_path_separator = ";";    # Separator of elements in search_path

    # For a pdf-file, "start x.pdf" starts the pdf viewer associated with
    #   pdf files, so no program name is needed:
    $pdf_previewer           = "start %O %S";
    $ps_previewer            = "start %O %S";
    $ps_previewer_landscape  = $ps_previewer;
    $dvi_previewer           = "start %O %S";
    $dvi_previewer_landscape = "$dvi_previewer";

    # Viewer update methods:
    #    0 => auto update: viewer watches file (e.g., gv)
    #    1 => manual update: user must do something: e.g., click on window.
    #         (e.g., ghostview, MSWIN previewers, acroread under UNIX)
    #    2 => send signal.  Number of signal in $dvi_update_signal,
    #                         $ps_update_signal, $pdf_update_signal
    #    3 => viewer can"t update, because it locks the file and the file
    #         cannot be updated.  (acroread under MSWIN)
    #    4 => run a command to force the update.  The commands are
    #         specified by the variables $dvi_update_command,
    #         $ps_update_command, $pdf_update_command
    $dvi_update_method = 1;
    $ps_update_method  = 1;
    $pdf_update_method = 3;    # acroread locks the pdf file
         # Use NONE as flag that I am not implementing some commands:
    $lpr =
      "NONE \$lpr variable is not configured to allow printing of ps files";
    $lpr_dvi =
"NONE \$lpr_dvi variable is not configured to allow printing of dvi files";
    $lpr_pdf =
"NONE \$lpr_pdf variable is not configured to allow printing of pdf files";

    # The $pscmd below holds a command to list running processes.  It
    # is used to find the process ID of the viewer looking at the
    # current output file.  The output of the command must include the
    # process number and the command line of the processes, since the
    # relevant process is identified by the name of file to be viewed.
    # Its use is not essential.
    $pscmd =
      "NONE $pscmd variable is not configured to detect running processes";
    $pid_position = -1;    # offset of PID in output of pscmd.
                           # Negative means I cannot use ps

}

###set_cygwin
sub set_cygwin {

    # The problem is a mixed MSWin32 and UNIX environment.
    # Perl decides the OS is cygwin in two situations:
    # 1. When latexmk is run from a cygwin shell under a cygwin
    #    environment.  Perl behaves in a UNIX way.  This is OK, since
    #    the user is presumably expecting UNIXy behavior.
    # 2. When CYGWIN exectuables are in the path, but latexmk is run
    #    from a native NT shell.  Presumably the user is expecting NT
    #    behavior. But perl behaves more UNIXy.  This causes some
    #    clashes.
    # The issues to handle are:
    # 1.  Perl sees both MSWin32 and cygwin filenames.  This is
    #     normally only an advantage.
    # 2.  Perl uses a UNIX shell in the system command
    #     This is a nasty problem: under native NT, there is a
    #     start command that knows about NT file associations, so that
    #     we can do, e.g., (under native NT) system("start file.pdf");
    #     But this won"t work when perl has decided the OS is cygwin,
    #     even if it is invoked from a native NT command line.  An
    #     NT command processor must be used to deal with this.
    # 3.  External executables can be native NT (which only know
    #     NT-style file names) or cygwin executables (which normally
    #     know both cygwin UNIX-style file names and NT file names,
    #     but not always; some do not know about drive names, for
    #     example).
    #     Cygwin executables for tex and latex may only know cygwin
    #     filenames.
    # 4.  The BIBINPUTS environment variables may be
    #     UNIX-style or MSWin-style depending on whether native NT or
    #     cygwin executables are used.  They are therefore parsed
    #     differently.  Here is the clash:
    #        a. If a user is running under an NT shell, is using a
    #           native NT installation of tex (e.g., fptex or miktex),
    #           but has the cygwin executables in the path, then perl
    #           detects the OS as cygwin, but the user needs NT
    #           behavior from latexmk.
    #        b. If a user is running under an UNIX shell in a cygwin
    #           environment, and is using the cygwin installation of
    #           tex, then perl detects the OS as cygwin, and the user
    #           needs UNIX behavior from latexmk.
    #     Latexmk has no way of detecting the difference.  The two
    #     situations may even arise for the same user on the same
    #     computer simply by changing the order of directories in the
    #     path environment variable

    ## Configuration parameters: We"ll assume native NT executables.
    ## The user should override if they are not.

    # This may fail: perl converts MSWin temp directory name to cygwin
    # format. Names containing this string cannot be handled by native
    # NT executables.
    $tmpdir = $ENV{TMPDIR} || $ENV{TEMP} || ".";

    ## List of possibilities for the system-wide initialization file.
    ## The first one found (if any) is used.
    ## We could stay with MSWin files here, since cygwin perl understands them
    ## @rc_system_files = ( "C:/latexmk/LatexMk" );
    ## But they are deprecated in v. 1.7.  So use the UNIX version, prefixed
    ##   with a cygwin equivalent of the MSWin location
    @rc_system_files = (
        "/cygdrive/c/latexmk/LatexMk",
        "/opt/local/share/latexmk/LatexMk",
        "/usr/local/share/latexmk/LatexMk",
        "/usr/local/lib/latexmk/LatexMk"
    );

    $search_path_separator = ";";    # Separator of elements in search_path
         # This is tricky.  The search_path_separator depends on the kind
         # of executable: native NT v. cygwin.
         # So the user will have to override this.

    # We will assume that files can be viewed by native NT programs.
    #  Then we must fix the start command/directive, so that the
    #  NT-native start command of a cmd.exe is used.
    # For a pdf-file, "start x.pdf" starts the pdf viewer associated with
    #   pdf files, so no program name is needed:
    $start_NT                = "cmd /c start \" \"";
    $pdf_previewer           = "$start_NT %O %S";
    $ps_previewer            = "$start_NT %O %S";
    $ps_previewer_landscape  = $ps_previewer;
    $dvi_previewer           = "$start_NT %O %S";
    $dvi_previewer_landscape = $dvi_previewer;

    # Viewer update methods:
    #    0 => auto update: viewer watches file (e.g., gv)
    #    1 => manual update: user must do something: e.g., click on window.
    #         (e.g., ghostview, MSWIN previewers, acroread under UNIX)
    #    2 => send signal.  Number of signal in $dvi_update_signal,
    #                         $ps_update_signal, $pdf_update_signal
    #    3 => viewer can"t update, because it locks the file and the file
    #         cannot be updated.  (acroread under MSWIN)
    $dvi_update_method = 1;
    $ps_update_method  = 1;
    $pdf_update_method = 3;    # acroread locks the pdf file
         # Use NONE as flag that I am not implementing some commands:
    $lpr =
      "NONE \$lpr variable is not configured to allow printing of ps files";
    $lpr_dvi =
"NONE \$lpr_dvi variable is not configured to allow printing of dvi files";
    $lpr_pdf =
"NONE \$lpr_pdf variable is not configured to allow printing of pdf files";

    # The $pscmd below holds a command to list running processes.  It
    # is used to find the process ID of the viewer looking at the
    # current output file.  The output of the command must include the
    # process number and the command line of the processes, since the
    # relevant process is identified by the name of file to be viewed.
    # Its use is not essential.
    # When the OS is detected as cygwin, there are two possibilities:
    #    a.  Latexmk was run from an NT prompt, but cygwin is in the
    #        path. Then the cygwin ps command will not see commands
    #        started from latexmk.  So we cannot use it.
    #    b.  Latexmk was started within a cygwin environment.  Then
    #        the ps command works as we need.
    # Only the user, not latemk knows which, so we default to not
    # using the ps command.  The user can override this in a
    # configuration file.
    $pscmd =
      "NONE \$pscmd variable is not configured to detect running processes";
    $pid_position = -1;    # offset of PID in output of pscmd.
                           # Negative means I cannot use ps
                           # System-dependent overrides:

}

###init_default
sub init_default {
    ## default parameters
    $auto_rc_use = 1;    # Whether to read rc files automatically
    $max_repeat  = 5;    # Maximum times I repeat latex.  Normally
                         # 3 would be sufficient: 1st run generates aux file,
                         # 2nd run picks up aux file, and maybe toc, lof which
                         # contain out-of-date information, e.g., wrong page
                         # references in toc, lof and index, and unresolved
                         # references in the middle of lines.  But the
                         # formatting is more-or-less correct.  On the 3rd
                         # run, the page refs etc in toc, lof, etc are about
                         # correct, but some slight formatting changes may
                         # occur, which mess up page numbers in the toc and lof,
                         # Hence a 4th run is conceivably necessary.
                         # At least one document class (JHEP.cls) works
                         # in such a way that a 4th run is needed.
                         # We allow an extra run for safety for a
                         # maximum of 5. Needing further runs is
                         # usually an indication of a problem; further
                         # runs may not resolve the problem, and
                         # instead could cause an infinite loop.
    $clean_ext   = "";   # space separated extensions of files that are
                         # to be deleted when doing cleanup, beyond
                         # standard set
    $clean_full_ext = "";        # space separated extensions of files that are
                                 # to be deleted when doing cleanup_full, beyond
                                 # standard set and those in $clean_ext
    @cus_dep_list   = ();        # Custom dependency list
    @default_files  = ("*.tex"); # Array of LaTeX files to process when
                                 # no files are specified on the command line.
                                 # Wildcards allowed
                                 # Best used for project specific files.
    @default_excluded_files = ();

    # Array of LaTeX files to exclude when using
    # @default_files, i.e., when no files are specified
    # on the command line.
    # Wildcards allowed
    # Best used for project specific files.
    $texfile_search = "";    # Specification for extra files to search for
                             # when no files are specified on the command line
                             # and the @default_files variable is empty.
                             # Space separated, and wildcards allowed.
                             # These files are IN ADDITION to *.tex in current
                             # directory.
                             # This variable is obsolete, and only in here for
                             # backward compatibility.
    $fdb_ext = "fdb_latexmk";    # Extension for the file for latexmk"s
                                 # file-database
                                 # Make it long to avoid possible collisions.
    $fdb_ver = 3;                # Version number for kind of fdb_file.
    $jobname = "";               # Jobname: as with current tex, etc indicates
                                 # basename of generated files.
                                 # Defined so that --jobname=STRING on latexmk"s
                                 # command line has same effect as with current
                                 # tex, etc.  (If $jobname is non-empty, then
                                 # the --jobname=... option is used on tex.)
    $out_dir = "";               # Directory for output files.
                                 # Cf. --output-directory of current (pdf)latex
    $aux_dir = "";               # Directory for aux files (log, aux, etc).
         # Cf. --aux-directory of current (pdf)latex in MiKTeX.
## default flag settings.
    $recorder       = 1;    # Whether to use recorder option on latex/pdflatex
    $silent         = 0;    # silence latex"s messages?
    $landscape_mode = 0;    # default to portrait mode

    # The following two arrays contain lists of extensions (without
    # period) for files that are read in during a (pdf)LaTeX run but that
    # are generated automatically from the previous run, as opposed to
    # being user generated files (directly or indirectly from a custom
    # dependency).  These files get two kinds of special treatment:
    #     1.  In clean up, where depending on the kind of clean up, some
    #         or all of these generated files are deleted.
    #         (Note that special treatment is given to aux files.)
    #     2.  In analyzing the results of a run of (pdf)LaTeX, to
    #         determine if another run is needed.  With an error free run,
    #         a rerun should be provoked by a change in any source file,
    #         whether a user file or a generated file.  But with a run
    #         that ends in an error, only a change in a user file during
    #         the run (which might correct the error) should provoke a
    #         rerun, but a change in a generated file should not.
    # These arrays can be user-configured.
    @generated_exts = qw( aux bcf fls idx ind lof lot out toc );

    # N.B. "out" is generated by hyperref package
    # Which kinds of file do I have requests to make?
    # If no requests at all are made, then I will make dvi file
    # If particular requests are made then other files may also have to be
    # made.  E.g., ps file requires a dvi file
    $dvi_mode        = 0;    # No dvi file requested
    $postscript_mode = 0;    # No postscript file requested
    $pdf_mode        = 0;    # No pdf file requested to be made by pdflatex
                             # Possible values:
                             #     0 don"t create pdf file
                             #     1 to create pdf file by pdflatex
                             #     2 to create pdf file by ps2pdf
                             #     3 to create pdf file by dvipdf
    $view = "default";       # Default preview is of highest of dvi, ps, pdf
    $sleep_time = 2;    # time to sleep b/w checks for file changes in -pvc mode
    $banner     = 0;    # Non-zero if we have a banner to insert
    $banner_scale     = 220;        # Original default scale
    $banner_intensity = 0.95;       # Darkness of the banner message
    $banner_message   = "DRAFT";    # Original default message
    $do_cd            = 0;          # Do not do cd to directory of source file.
                                    #   Thus behave like latex.
    $dependents_list  = 0;          # Whether to display list(s) of dependencies
    $dependents_phony =
      0;    # Whether list(s) of dependencies includes phony targets
            # (as with "gcc -MP").
    $deps_file    = "-";    # File for dependency list output.  Default stdout.
    $rules_list   = 0;      # Whether to display list(s) of dependencies
    @dir_stack    = ();     # Stack of pushed directories, each of form of
                            # pointer to array  [ cwd, good_cwd ], where
                            # good_cwd differs from cwd by being converted
                            # to native MSWin path when cygwin is used.
    $cleanup_mode = 0;      # No cleanup of nonessential LaTex-related files.
                            # $cleanup_mode = 0: no cleanup
                            # $cleanup_mode = 1: full cleanup
                            # $cleanup_mode = 2: cleanup except for dvi,
                            #                    dviF, pdf, ps, & psF
    $cleanup_fdb  = 0;      # No removal of file for latexmk"s file-database
    $cleanup_only = 0;      # When doing cleanup, do not go-on to making files
    $cleanup_includes_generated = 0;

    # Determines whether cleanup deletes files generated by
    #    custom dependencies
    $cleanup_includes_cusdep_generated = 0;

    # Determines whether cleanup deletes files generated by
    #    (pdf)latex (found from \openout lines in log file).
    $diagnostics  = 0;
    $dvi_filter   = "";    # DVI filter command
    $ps_filter    = "";    # Postscript filter command
    $force_mode   = 0;     # =1 to force processing past errors
    $go_mode      = 0;     # =1 to force processing regardless of time-stamps
                           # =2 full clean-up first
    $preview_mode = 0;
    $preview_continuous_mode = 0;
    $printout_mode           = 0;                   # Don"t print the file
    $show_time               = 0;
    @timings                 = ();
    $processing_time1        = processing_time();
    $use_make_for_missing_files =
      0;    # Whether to use make to try to make missing files.

    # Do we make view file in temporary then move to final destination?
    #  (To avoid premature updating by viewer).
    $always_view_file_via_temporary = 0;    # Set to 1 if  viewed file is always
                                            #    made through a temporary.
    $pvc_view_file_via_temporary = 1;  # Set to 1 if only in -pvc mode is viewed
                                       #    file made through a temporary.

    # State variables initialized here:
    $updated = 0;    # Flags when something has been remade
                     # Used to allow convenient user message in -pvc mode
    $waiting = 0;    # Flags whether we are in loop waiting for an event
                     # Used to avoid unnecessary repeated o/p in wait loop

    # Used for some results of parsing log file:
    $reference_changed = 0;
    $bad_reference     = 0;
    $bad_citation      = 0;

    # Cache of expensive-to-compute state variables, e.g., cwd in form
    # fixed to deal with cygwin issues.
    %cache = ();
    &cache_good_cwd;

    # Set search paths for includes.
    # Set them early so that they can be overridden
    $BIBINPUTS = $ENV{"BIBINPUTS"};
    if ( !$BIBINPUTS ) { $BIBINPUTS = "."; }

    # Convert search paths to arrays:
    # If any of the paths end in "//" then recursively search the
    # directory.  After these operations, @BIBINPUTS  should
    # have all the directories that need to be searched
    @BIBINPUTS = find_dirs1($BIBINPUTS);
}

sub init_other {

######################################################################
######################################################################
    #
    #  ???  UPDATE THE FOLLOWING!!
    #
    # We will need to determine whether source files for runs of various
    # programs are out of date.  In a normal situation, this is done by
    # asking whether the times of the source files are later than the
    # destination files.  But this won't work for us, since a common
    # situation is that a file is written on one run of latex, for
    # example, and read back in on the next run (e.g., an .aux file).
    # Some situations of this kind are standard in latex generally; others
    # occur with particular macro packages or with particular
    # postprocessors.
    #
    # The correct criterion for whether a source is out-of-date is
    # therefore NOT that its modification time is later than the
    # destination file, but whether the contents of the source file have
    # changed since the last successful run.  This also handles the case
    # that the user undoes some changes to a source file by replacing the
    # source file by reverting to an earlier version, which may well have
    # an older time stamp.  Since a direct comparison of old and new files
    # would involve storage and access of a large number of backup files,
    # we instead use the md5 signature of the files.  (Previous versions
    # of latexmk used the backup file method, but restricted to the case
    # of .aux and .idx files, sufficient for most, but not all,
    # situations.)
    #
    # We will have a database of (time, size, md5) for the relevant
    # files. If the time and size of a file haven't changed, then the file
    # is assumed not to have changed; this saves us from having to
    # determine its md5 signature, which would involve reading the whole
    # file, which is naturally time-consuming, especially if network file
    # access to a server is needed, and many files are involved, when most
    # of them don't change.  It is of course possible to change a file
    # without changing its size, but then to adjust its timestamp
    # to what it was previously; this requires a certain amount of
    # perversity.  We can safely assume that if the user edits a file or
    # changes its contents, then the file's timestamp changes.  The
    # interesting case is that the timestamp does change, because the file
    # has actually been written to, but that the contents do not change;
    # it is for this that we use the md5 signature.  However, since
    # computing the md5 signature involves reading the whole file, which
    # may be large, we should avoid computing it more than necessary.
    #
    # So we get the following structure:
    #
    #     1.  For each relevant run (latex, pdflatex, each instance of a
    #         custom dependency) we have a database of the state of the
    #         source files that were last used by the run.
    #     2.  On an initial startup, the database for a primary tex file
    #         is read that was created by a previous run of latex or
    #         pdflatex, if this exists.
    #     3.  If the file doesn't exist, then the criterion for
    #         out-of-dateness for an initial run is that it goes by file
    #         timestamps, as in previous versions of latexmk, with due
    #         (dis)regard to those files that are known to be generated by
    #         latex and re-read on the next run.
    #     4.  Immediately before a run, the database is updated to
    #         represent the current conditions of the run's source files.
    #     5.  After the run, it is determined whether any of the source
    #         files have changed.  This covers both files written by the
    #         run, which are therefore in a dependency loop, and files that
    #         the user may have updated during the run.  (The last often
    #         happens when latex takes a long time, for a big document,
    #         and the user makes edits before latex has finished.  This is
    #         particularly prevalent when latexmk is used with
    #         preview-continuous mode.)
    #     6.  In the case of latex or pdflatex, the custom dependencies
    #         must also be checked and redone if out-of-date.
    #     7.  If any source files have changed, the run is redone,
    #         starting at step 1.
    #     8.  There is naturally a limit on the number of reruns, to avoid
    #         infinite loops from bugs and from pathological or unforeseen
    #         conditions.
    #     9.  After the run is done, the run's file database is updated.
    #         (By hypothesis, the sizes and md5s are correct, if the run
    #         is successful.)
    #    10.  To allow reuse of data from previous runs, the file database
    #         is written to a file after every complete set of passes
    #         through latex or pdflatex.  (Note that there is separate
    #         information for latex and pdflatex; the necessary
    #         information won't coincide: Out-of-dateness for the files
    #         for each program concerns the properties of the files when
    #         the other program was run, and the set of source files could
    #         be different, e.g., for graphics files.)
    #
    # We therefore maintain the following data structures.:
    #
    #     a.  For each run (latex, pdflatex, each custom dependency) a
    #         database is maintained.  This is a hash from filenames to a
    #         reference to an array:  [time, size, md5].  The semantics of
    #         the database is that it represents the state of the source
    #         files used in the run.  During a run it represents the state
    #         immediately before the run; after a run, with all reruns, it
    #         represents the state of the files used, modified by having
    #         the latest timestamps for generated files.
    #     b.  There is a global database for all files, which represents
    #         the current state.  This saves having to recompute the md5
    #         signatures of a changed file used in more than one run
    #         (e.g., latex and pdflatex).
    #     c.  Each of latex and pdflatex has a list of the relevant custom
    #         dependencies.
    #
    # In all the following a fdb-hash is a hash of the form:
    #                      filename -> [time, size, md5]
    # If a file is found to disappear, its entry is removed from the hash.
    # In returns from fdb access routines, a size entry of -1 indicates a
    # non-existent file.

    # List of known rules.  Rule types: primary,
    #     external (calls program), internal (calls routine), cusdep.
    %possible_primaries = (
        "latex"    => "primary",
        "pdflatex" => "primary"
    );
    %primaries = ();    # Hash of rules for primary part of make.  Keys are
                        # currently "latex", "pdflatex" or both.  Value is
                        # currently irrelevant.  Use hash for ease of lookup
                        # Make remove this later, if use rdb_makeB

    # Hashes, whose keys give names of particular kinds of rule.  We use
    # hashes for ease of lookup.
    %possible_one_time = (
        "view"        => 1,
        "print"       => 1,
        "update_view" => 1,
    );
    %requested_filerules =
      ();    # Hash for rules corresponding to requested files.
             # The keys are the rulenames and the value is
             # currently irrelevant.
    %one_time = ();    # Hash for requested one-time-only rules, currently
                       # possible values "print" and "view".
                       # possible values "print" and "view".

    %rule_db = ();

    # Database of all rules:
    # Hash: rulename -> [array of rule data]
    # Rule data:
    #   0: [ cmd_type, ext_cmd, int_cmd, test_kind,
    #       source, dest, base,
    #       out_of_date, out_of_date_user,
    #       time_of_last_run, time_of_last_file_check,
    #       changed
    #       last_result, last_message,
    #       default_extra_generated
    #      ]
    # where
    #     cmd_type is 'primary', 'external', or 'cusdep'
    #     ext_cmd is string for associated external command
    #       with substitutions (%D for destination, %S
    #       for source, %B for base of current rule,
    #       %R for base of primary tex file, %T for
    #       texfile name, %O for options,
    #       %Y for $aux_dir1, and %Z for $out_dir1
    #     int_cmd specifies any internal command to be
    #       used to implement the application of the
    #       rule.  If this is present, it overrides
    #       the external command, and it is the
    #       responsibility of the perl subroutine
    #       specified in intcmd to execute the
    #       external command if this is appropriate.
    #       This variable intcmd is a reference to an array,
    #       $$intcmd[0] = internal routine
    #       $$intcmd[1...] = its arguments (if any)
    #     test_kind specifies method of determining
    #       whether a file is out-of-date:
    #         0 for never
    #         1 for usual: whether there is a source
    #              file change
    #         2 for dest earlier than source
    #         3 for method 2 at first run, 1 thereafter
    #              (used when don't have file data from
    #              previous run).
    #     source = name of primary source file, if any
    #     dest   = name of primary destination file,
    #              if any
    #     base   = base name, if any, of files for
    #              this rule
    #     out_of_date = 1 if it has been detected that
    #                     this rule needs to be run
    #                     (typically because a source
    #                     file has changed).
    #                   0 otherwise
    #     out_of_date_user is like out_of_date, except
    #         that the detection of out-of-dateness
    #         has been made from a change of a
    #         putative user file, i.e., one that is
    #         not a generated file (e.g., aux). This
    #         kind of out-of-dateness should provoke a
    #         rerun whether or not there was an error
    #         during a run of (pdf)LaTeX.  Normally,
    #         if there is an error, one should wait
    #         for the user to correct the error.  But
    #         it is possible the error condition is
    #         already corrected during the run, e.g.,
    #         by the user changing a source file in
    #         response to an error message.
    #     time_of_last_run = time that this rule was
    #              last applied.  (In standard units
    #              from perl, to be directly compared
    #              with file modification times.)
    #     time_of_last_file_check = last time that a check
    #              was made for changes in source files.
    #     changed flags whether special changes have been made
    #          that require file-existence status to be ignored
    #     last_result is
    #                 -1 if no run has been made,
    #                  0 if the last run was successful
    #                  1 if last run was successful, but
    #                    failed to create an output file
    #                  2 if last run failed
    #                  200 if last run gave a warning that is
    #                    important enough to be reported with
    #                    the error summary.  The warning
    #                    message is stored in last_message.
    #     last_message is error message for last run
    #     default_extra_generated is a reference to an array
    #       of specifications of extra generated files (beyond
    #       the main dest file.  Standard place holders are used.
    #       Example ['%Y%R.log'] for (pdf)latex, and ['%R.blg']
    #          for bibtex.  (There's no need for '%R.aux', here,
    #          since such generated files are detected dynamically.)
    #   1: {Hash sourcefile -> [source-file data] }
    # Source-file data array:
    #   0: time
    #   1: size
    #   2: md5
    #   3: name of rule to make this file
    #   4: whether the file is of the kind made by epstopdf.sty
    #      during a primary run.  It will have been read during
    #      the run, so that even though the file changes during
    #      a primary run, there is no need to trigger another
    #      run because of this.
    #  Size and md5 correspond to the values at the last run.
    #  But time may be updated to correspond to the time
    #  for the file, if the file is otherwise unchanged.
    #  This saves excessive md5 calculations, which would
    #  otherwise be done everytime the file is checked,
    #  in the following situation:
    #     When the file has been rewritten after a run
    #     has started (commonly aux, bbl files etc),
    #     but the actual file contents haven't
    #     changed.  Then because the filetime has
    #     changed, on every file-change check latexmk
    #     would normally redo the md5 calculation to
    #     test for actual changes.  Once one such
    #     check is done, and the contents are
    #     unchanged, later checks are superfluous, and
    #     can be avoided by changing the file's time
    #     in the source-file list.
    #   2: {Hash generated_file -> 1 }
    #      This lists all generated files; the values
    #          are currently unused, only the keys

    %fdb_current = ();    # Fdb-hash for all files used.

}

sub init_HOME {

    # User's home directory
    $HOME = "";
    if ( exists $ENV{'HOME'} ) {
        $HOME = $ENV{'HOME'};
    }
    elsif ( exists $ENV{'USERPROFILE'} ) {
        $HOME = $ENV{'USERPROFILE'};
    }

}

#==================================================
#==================================================
## Read rc files with this subroutine

sub read_first_rc_file_in_list {
    foreach my $rc_file (@_) {

        #print "===Testing for rc file \"$rc_file\" ...\n";
        if ( -e $rc_file ) {

            #print "===Reading rc file \"$rc_file\" ...\n";
            process_rc_file($rc_file);
            return;
        }
    }
}

sub read_rc {

    # Options that are to be obeyed before rc files are read:

    foreach $_ (@ARGV) {
        if (/^-{1,2}norc$/) {
            $auto_rc_use = 0;
        }
    }

    # Note that each rc file may unset $auto_rc_use to
    # prevent lower-level rc files from being read.
    # So test on $auto_rc_use in each case.
    if ($auto_rc_use) {

        # System rc file:
        read_first_rc_file_in_list(@rc_system_files);
    }
    if ($auto_rc_use) {

        # User rc file:
        read_first_rc_file_in_list("$HOME/.latexmkrc");
    }
    if ($auto_rc_use) {

        # Rc file in current directory:
        read_first_rc_file_in_list( "latexmkrc", ".latexmkrc" );
    }

}

###get_opt
sub get_opt {

    ## Process command line args.
    @command_line_file_list = ();
    $bad_options            = 0;

    while ( @ARGV ) {
        $_ = shift @ARGV;
        _say "Processing: $_";

        # Make -- and - equivalent at beginning of option,
        # but save original for possible use in (pdf)latex command line
        $original = $_;
        s/^--/-/;

        if ( /^-aux-directory=(.*)$/ || /^-auxdir=(.*)$/ ) {
            $aux_dir = $1;
        }
        elsif (/^-bibtex$/)      { $bibtex_use = 2; }
        elsif (/^-bibtex-$/)     { $bibtex_use = 0; }
        elsif (/^-nobibtex$/)    { $bibtex_use = 0; }
        elsif (/^-bibtex-cond$/) { $bibtex_use = 1; }
        elsif (/^-c$/) {
            $cleanup_mode = 2;
            $cleanup_fdb  = 1;
            $cleanup_only = 1;
        }
        elsif ( /^-C$/ || /^-CA$/ ) {
            $cleanup_mode = 1;
            $cleanup_fdb  = 1;
            $cleanup_only = 1;
        }
        elsif (/^-CF$/)  { $cleanup_fdb = 1; }
        elsif (/^-cd$/)  { $do_cd       = 1; }
        elsif (/^-cd-$/) { $do_cd       = 0; }
        elsif (/^-commands$/) { &print_commands; exit; }
        elsif (/^-d$/) { $banner = 1; }
        elsif ( /^-dependents$/ || /^-deps$/ || /^-M$/ ) {
            $dependents_list = 1;
        }
        elsif ( /^-nodependents$/ || /^-dependents-$/ || /^-deps-$/ ) {
            $dependents_list = 0;
        }
        elsif (/^-deps-out=(.*)$/) {
            $deps_file       = $1;
            $dependents_list = 1;
        }
        elsif (/^-diagnostics/) { $diagnostics = 1; }
        elsif (/^-dvi$/)        { $dvi_mode    = 1; }
        elsif (/^-dvi-$/)       { $dvi_mode    = 0; }
        elsif (/^-f$/)          { $force_mode  = 1; }
        elsif (/^-f-$/)         { $force_mode  = 0; }
        elsif (/^-g$/)          { $go_mode     = 1; }
        elsif (/^-g-$/)         { $go_mode     = 0; }
        elsif (/^-gg$/) {
            $go_mode      = 2;
            $cleanup_mode = 1;
            $cleanup_fdb  = 1;
            $cleanup_only = 0;
        }
        elsif ( /^-h$/ || /^-help$/ ) { &print_help; exit; }
        elsif (/^-jobname=(.*)$/) {
            $jobname = $1;
        }
        elsif (/^-l$/)  { $landscape_mode = 1; }
        elsif (/^-l-$/) { $landscape_mode = 0; }
###_opt_latex
        elsif (/^-latex=(.*)$/) {
            $latex = $1;
        }
        elsif (/^-latexoption=(.*)$/) {
            push @extra_latex_options,    $1;
            push @extra_pdflatex_options, $1;
        }

        # See above for -M
        elsif (/^-MF$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No file name specified after -MF switch");
            }
            $deps_file = $ARGV[0];
            shift;
        }
        elsif (/^-MP$/) { $dependents_phony = 1; }
###_opt_makeindexstyle
         elsif (/^-makeindexstyle=(.*)$/) {
            $makeindexstyle = $1;
            add_option( ' -s ' . $makeindexstyle, \$makeindex );
        }
        elsif (/^-new-viewer$/) {
            $new_viewer_always = 1;
        }
        elsif (/^-new-viewer-$/) {
            $new_viewer_always = 0;
        }
        elsif (/^-norc$/) {
            $auto_rc_use = 0;

            # N.B. This has already been obeyed.
        }
        elsif ( /^-output-directory=(.*)$/ || /^-outdir=(.*)$/ ) {
            $out_dir = $1;
        }
        elsif (/^-p$/) {
            $printout_mode           = 1;
            $preview_continuous_mode = 0;    # to avoid conflicts
            $preview_mode            = 0;
        }
        elsif (/^-p-$/)     { $printout_mode = 0; }
###_opt_pdf
        elsif (/^-pdf$/)    { $pdf_mode      = 1; }
        elsif (/^-pdf-$/)   { $pdf_mode      = 0; }
        elsif (/^-pdfdvi$/) { $pdf_mode      = 3; }
###_opt_pdflatex
        elsif (/^-pdflatex=(.*)$/) {
            $pdflatex = $1;
        }
###_opt_pdfps
        elsif (/^-pdfps$/) { $pdf_mode = 2; }
        elsif (/^-print=(.*)$/) {
            my $value = $1;
            if ( $value =~ /^dvi$|^ps$|^pdf$/ ) {
                $print_type    = $value;
                $printout_mode = 1;
            }
            else {
                &exit_help(
                    "$My_name: unknown print type '$value' in option '$_'");
            }
        }
        elsif (/^-ps$/)  { $postscript_mode = 1; }
        elsif (/^-ps-$/) { $postscript_mode = 0; }
        elsif (/^-pv$/) {
            $preview_mode            = 1;
            $preview_continuous_mode = 0;    # to avoid conflicts
            $printout_mode           = 0;
        }
        elsif (/^-pv-$/) { $preview_mode = 0; }
        elsif (/^-pvc$/) {
            $preview_continuous_mode = 1;
            $force_mode              = 0;    # So that errors do not cause loops
            $preview_mode            = 0;    # to avoid conflicts
            $printout_mode           = 0;
        }
        elsif (/^-pvc-$/)      { $preview_continuous_mode = 0; }
        elsif (/^-recorder$/)  { $recorder                = 1; }
        elsif (/^-recorder-$/) { $recorder                = 0; }
        elsif (/^-rules$/)     { $rules_list              = 1; }
        elsif ( /^-norules$/ || /^-rules-$/ ) { $rules_list = 0; }
        elsif (/^-showextraoptions$/) {
            print
"List of extra latex and pdflatex options recognized by $my_name.\n",
"These are passed as is to (pdf)latex.  They may not be recognized by\n",
"particular versions of (pdf)latex.  This list is a combination of those\n",
              "for TeXLive and MikTeX.\n",
              "\n",
"Note that in addition to the options in this list, there are several\n",
"options known to the (pdf)latex programs that are also recognized by\n",
"latexmk and trigger special behavior by latexmk.  Since these options\n",
"appear in the main list given by running 'latexmk --help', they do not\n",
              "appear in the following list\n",
              "\n";
            foreach my $option (
                sort( keys %allowed_latex_options,
                    keys %allowed_latex_options_with_arg )
              )
            {
                if ( exists $allowed_latex_options{$option} ) {
                    print "   $allowed_latex_options{$option}\n";
                }
                if ( exists $allowed_latex_options_with_arg{$option} ) {
                    print "   $allowed_latex_options_with_arg{$option}\n";
                }
            }
            exit;
        }
        elsif ( /^-silent$/ || /^-quiet$/ ) { $silent = 1; }
        elsif (/^-time$/)      { $show_time                  = 1; }
        elsif (/^-time-$/)     { $show_time                  = 0; }
        elsif (/^-use-make$/)  { $use_make_for_missing_files = 1; }
        elsif (/^-use-make-$/) { $use_make_for_missing_files = 0; }
        elsif ( /^-v$/ || /^-version$/ ) {
            print "\n$version_details. Version $version_num\n";
            exit;
        }
        elsif (/^-verbose$/)      { $silent = 0; }
        elsif (/^-view=default$/) { $view   = "default"; }
        elsif (/^-view=dvi$/)     { $view   = "dvi"; }
        elsif (/^-view=none$/)    { $view   = "none"; }
        elsif (/^-view=ps$/)      { $view   = "ps"; }
        elsif (/^-view=pdf$/)     { $view   = "pdf"; }
        elsif (/^-xelatex$/) {
            $pdflatex = "xelatex %O %S";
            $pdf_mode = 1;
            $dvi_mode = $postscript_mode = 0;
        }
        elsif (/^-e$/) {
            if ( $#ARGV < 0 ) {
                &exit_help("No code to execute specified after -e switch");
            }
            execute_code_string( $ARGV[0] );
            shift;
        }
        elsif (/^-r$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No RC file specified after -r switch");
            }
            if ( -e $ARGV[0] ) {
                process_rc_file( $ARGV[0] );
            }
            else {
                die "$My_name: RC file [$ARGV[0]] does not exist\n";
            }
            shift;
        }
        elsif (/^-bm$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No message specified after -bm switch");
            }
            $banner         = 1;
            $banner_message = $ARGV[0];
            shift;
        }
        elsif (/^-bi$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No intensity specified after -bi switch");
            }
            $banner_intensity = $ARGV[0];
            shift;
        }
        elsif (/^-bs$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No scale specified after -bs switch");
            }
            $banner_scale = $ARGV[0];
            shift;
        }
        elsif (/^-dF$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No dvi filter specified after -dF switch");
            }
            $dvi_filter = $ARGV[0];
            shift;
        }
        elsif (/^-pF$/) {
            if ( $ARGV[0] eq '' ) {
                &exit_help("No ps filter specified after -pF switch");
            }
            $ps_filter = $ARGV[0];
            shift;
        }
        elsif (( exists( $allowed_latex_options{$_} ) )
            || ( /^(-.+)=/ && exists( $allowed_latex_options_with_arg{$1} ) ) )
        {
            push @extra_latex_options,    $original;
            push @extra_pdflatex_options, $original;
        }
        elsif (/^-/) {
            warn "$My_name: $_ bad option\n";
            $bad_options++;
        }
        else {
            push @command_line_file_list, $_;
        }
    }

    if ( $bad_options > 0 ) {
        &exit_help("Bad options specified");
    }

    warn "$My_name: This is $version_details, version: $version_num.\n",
      "**** Report bugs etc to John Collins <collins at phys.psu.edu>. ****\n"
      unless $silent;

}

###process_opts
sub process_opts {

    if ( ( $out_dir ne '' ) && ( $aux_dir eq '' ) ) {
        $aux_dir = $out_dir;
    }

    foreach ( $out_dir, $aux_dir ) {

        # Remove aliases to cwd:
        $_ = normalize_filename($_);
        if ( $_ eq '.' ) { $_ = ''; }
    }

    # Versions terminating in directory/path separator
    $out_dir1 = $out_dir;
    $aux_dir1 = $aux_dir;

    foreach ( $aux_dir1, $out_dir1 ) {
        if ( ( $_ ne '' ) && !m([\\/\:]$) ) {
            $_ .= '/';
        }
    }

    if ( $bibtex_use > 1 ) {
        push @generated_exts, 'bbl';
    }

    # For backward compatibility, convert $texfile_search to @default_files
    # Since $texfile_search is initialized to "", a nonzero value indicates
    # that an initialization file has set it.
    if ( $texfile_search ne "" ) {
        @default_files = split / /, "*.tex $texfile_search";
    }

    #Glob the filenames command line if the script was not invoked under a
    #   UNIX-like environment.
    #   Cases: (1) MS/MSwin native    Glob
    #                      (OS detected as MSWin32)
    #          (2) MS/MSwin cygwin    Glob [because we do not know whether
    #                  the cmd interpreter is UNIXy (and does glob) or is
    #                  native MS-Win (and does not glob).]
    #                      (OS detected as cygwin)
    #          (3) UNIX               Don't glob (cmd interpreter does it)
    #                      (Currently, I assume this is everything else)
    if ( ( $^O eq "MSWin32" ) || ( $^O eq "cygwin" ) ) {

        # Preserve ordering of files
        @file_list = glob_list1(@command_line_file_list);

    #print "A1:File list:\n";
    #for ($i = 0; $i <= $#file_list; $i++ ) {  print "$i: '$file_list[$i]'\n"; }
    }
    else {
        @file_list = @command_line_file_list;
    }
    @file_list = uniq1(@file_list);

    # Check we haven't selected mutually exclusive modes.
    # Note that -c overrides all other options, but doesn't cause
    # an error if they are selected.
    if (   ( $printout_mode && ( $preview_mode || $preview_continuous_mode ) )
        || ( $preview_mode && $preview_continuous_mode ) )
    {
        # Each of the options -p, -pv, -pvc turns the other off.
        # So the only reason to arrive here is an incorrect inititalization
        #   file, or a bug.
        &exit_help(
            "Conflicting options (print, preview, preview_continuous) selected"
        );
    }

    if (@command_line_file_list) {

       # At least one file specified on command line (before possible globbing).
        if ( !@file_list ) {
            &exit_help("Wildcards in file names didn't match any files");
        }
    }
    else {
        # No files specified on command line, try and find some
        # Evaluate in order specified.  The user may have some special
        #   for wanting processing in a particular order, especially
        #   if there are no wild cards.
        # Preserve ordering of files
        my @file_list1         = uniq1( glob_list1(@default_files) );
        my @excluded_file_list = uniq1( glob_list1(@default_excluded_files) );

        # Make hash of excluded files, for easy checking:
        my %excl = ();
        foreach my $file (@excluded_file_list) {
            $excl{$file} = '';
        }
        foreach my $file (@file_list1) {
            push( @file_list, $file ) unless ( exists $excl{$file} );
        }
        if ( !@file_list ) {
            &exit_help("No file name specified, and I couldn't find any");
        }
    }

    $num_files     = $#file_list + 1;
    $num_specified = $#command_line_file_list + 1;

#print "Command line file list:\n";
#for ($i = 0; $i <= $#command_line_file_list; $i++ ) {  print "$i: '$command_line_file_list[$i]'\n"; }
#print "File list:\n";
#for ($i = 0; $i <= $#file_list; $i++ ) {  print "$i: '$file_list[$i]'\n"; }

# If selected a preview-continuous mode, make sure exactly one filename was specified
    if ( $preview_continuous_mode && ( $num_files != 1 ) ) {
        if ( $num_specified > 1 ) {
            &exit_help( "Need to specify exactly one filename for "
                  . "preview-continuous mode\n"
                  . "    but $num_specified were specified" );
        }
        elsif ( $num_specified == 1 ) {
            &exit_help( "Need to specify exactly one filename for "
                  . "preview-continuous mode\n"
                  . "    but wildcarding produced $num_files files" );
        }
        else {
            &exit_help( "Need to specify exactly one filename for "
                  . "preview-continuous mode.\n"
                  . "    Since none were specified on the command line, I looked for \n"
                  . "    files in '@default_files'.\n"
                  . "    But I found $num_files files, not 1." );
        }
    }

    # If selected jobname, can only apply that to one file:
    if ( ( $jobname ne '' ) && ( $num_files > 1 ) ) {
        &exit_help( "Need to specify at most one filename if "
              . "jobname specified, \n"
              . "    but $num_files were found (after defaults and wildcarding)."
        );
    }

    # Normalize the commands, to have place-holders for source, dest etc:
    &fix_cmds;

    # Add common options
    add_option( $latex_default_switches,    \$latex );
    add_option( $pdflatex_default_switches, \$pdflatex );

    foreach (@extra_latex_options)    { add_option( $_, \$latex ); }
    foreach (@extra_pdflatex_options) { add_option( $_, \$pdflatex ); }

    # If landscape mode, change dvips processor, and the previewers:
    if ($landscape_mode) {
        $dvips         = $dvips_landscape;
        $dvi_previewer = $dvi_previewer_landscape;
        $ps_previewer  = $ps_previewer_landscape;
    }

    if ($silent) {
        add_option( "$latex_silent_switch",     \$latex );
        add_option( "$pdflatex_silent_switch",  \$pdflatex );
        add_option( "$biber_silent_switch",     \$biber );
        add_option( "$bibtex_silent_switch",    \$bibtex );
        add_option( "$makeindex_silent_switch", \$makeindex );
        add_option( "$dvipdf_silent_switch",    \$dvipdf );
        add_option( "$dvips_silent_switch",     \$dvips );
    }

    if ($recorder) {
        add_option( "-recorder", \$latex, \$pdflatex );
    }

    if ($out_dir) {
        add_option( "-output-directory=\"$out_dir\"", \$latex, \$pdflatex );
        if ( !-e $out_dir ) {
            warn "$My_name: making output directory '$out_dir'\n"
              if !$silent;
            mkdir $out_dir;
        }
        elsif ( !-d $out_dir ) {
            warn "$My_name: you requested output directory '$out_dir',\n",
              "     but an ordinary file of the same name exists, which will\n",
              "     probably give an error later\n";
        }
    }

    if ( $aux_dir && ( $aux_dir ne $out_dir ) ) {

        # N.B. If $aux_dir and $out_dir are the same, then the -output-directory
        # option is sufficient, especially because the -aux-directory exists
        # only in MiKTeX, not in TeXLive.
        add_option( "-aux-directory=\"$aux_dir\"", \$latex, \$pdflatex );
        if ( !-e $aux_dir ) {
            warn "$My_name: making auxiliary directory '$aux_dir'\n"
              if !$silent;
            mkdir $aux_dir;
        }
        elsif ( !-d $aux_dir ) {
            warn "$My_name: you requested aux directory '$aux_dir',\n",
              "     but an ordinary file of the same name exists, which will\n",
              "     probably give an error later\n";
        }
    }

    if ( $jobname ne '' ) {
        my $jobstring = "--jobname=$jobname";
        add_option( "$jobstring", \$latex, \$pdflatex );
    }

    # Which kind of file do we preview?
    if ( $view eq "default" ) {

        # If default viewer requested, use "highest" of dvi, ps and pdf
        #    that was requested by user.
        # No explicit request means view dvi.
        $view = "dvi";
        if ($postscript_mode) { $view = "ps"; }
        if ($pdf_mode)        { $view = "pdf"; }
    }

    # Make sure we make the kind of file we want to view:
    if ( $view eq 'dvi' ) { $dvi_mode        = 1; }
    if ( $view eq 'ps' )  { $postscript_mode = 1; }
    if ( ( $view eq 'pdf' ) && ( $pdf_mode == 0 ) ) {
        $pdf_mode = 1;
    }

    # Make sure that we make something if all requests are turned off
    if ( !( $dvi_mode || $pdf_mode || $postscript_mode || $printout_mode ) ) {
        print "No specific requests made, so default to dvi by latex\n";
        $dvi_mode = 1;
    }

    # Set new-style requested rules:
    if ($dvi_mode)        { $requested_filerules{'latex'}    = 1; }
    if ( $pdf_mode == 1 ) { $requested_filerules{'pdflatex'} = 1; }
    elsif ( $pdf_mode == 2 ) {
        $requested_filerules{'latex'}  = 1;
        $requested_filerules{'dvips'}  = 1;
        $requested_filerules{'ps2pdf'} = 1;
    }
    elsif ( $pdf_mode == 3 ) {
        $requested_filerules{'latex'}  = 1;
        $requested_filerules{'dvipdf'} = 1;
    }
    if ($postscript_mode) {
        $requested_filerules{'latex'} = 1;
        $requested_filerules{'dvips'} = 1;
    }
    if ($printout_mode) { $one_time{'print'} = 1; }
    if ( $preview_continuous_mode || $preview_mode ) { $one_time{'view'} = 1; }
    if ( length($dvi_filter) != 0 ) { $requested_filerules{'dvi_filter'} = 1; }
    if ( length($ps_filter) != 0 )  { $requested_filerules{'ps_filter'}  = 1; }
    if ($banner)                    { $requested_filerules{'dvips'}      = 1; }

    if ( $pdf_mode == 2 ) {

        # We generate pdf from ps.  Make sure we have the correct kind of ps.
        add_option( "$dvips_pdf_switch", \$dvips );
    }

    # Note sleep has granularity of 1 second.
    # Sleep periods 0 < $sleep_time < 1 give zero delay,
    #    which is probably not what the user intended.
    # Sleep periods less than zero give infinite delay
    if ( $sleep_time < 0 ) {
        warn "$My_name: Correcting negative sleep_time to 1 sec.\n";
        $sleep_time = 1;
    }
    elsif ( ( $sleep_time < 1 ) && ( $sleep_time != 0 ) ) {
        warn
"$My_name: Correcting nonzero sleep_time of less than 1 sec to 1 sec.\n";
        $sleep_time = 1;
    }
    elsif ( $sleep_time == 0 ) {
        warn "$My_name: sleep_time was configured to zero.\n",
          "    Do you really want to do this?  It will give 100% CPU usage.\n";
    }

    # Make convenient forms for lookup.
    # Extensions always have period.

    # Convert @generated_exts to a hash for ease of look up and deletion
    # Keep extension without period!
    %generated_exts_all = ();
    foreach (@generated_exts) {
        $generated_exts_all{$_} = 1;
    }

    if ($aux_dir) {

        # Ensure $aux_dir is in TEXINPUTS search path.
        # This is used by dvips for files generated by mpost.
        if ( !exists $ENV{TEXINPUTS} ) {

            # Note the trailing ":" which ensures that the last item
            # in the list of paths is the empty path, which actually
            # means the default path, i.e., the following means that
            # the TEXINPUTS search path is $aux_dir and the standard
            # value.
            $ENV{TEXINPUTS} = $aux_dir . $search_path_separator;
        }
        elsif ( $ENV{TEXINPUTS} !~ /$aux_dir$search_path_separator/ ) {
            $ENV{TEXINPUTS} =
              $aux_dir . $search_path_separator . $ENV{TEXINPUTS};
        }
    }

    $quell_uptodate_msgs = $silent;

    # Whether to quell informational messages when files are uptodate
    # Will turn off in -pvc mode

    $failure_count    = 0;
    @failed_primaries = ();

    if ( $deps_file eq '' ) {

        # Standardize name used for stdout
        $deps_file = '-';
    }

    if ($dependents_list) {
        $deps_handle = new FileHandle "> $deps_file";
        if ( !defined $deps_handle ) {
            die
              "Cannot open '$deps_file' for output of dependency information\n";
        }
    }

}

###run
sub run {

  _debug("Files provided: " . join(@file_list));

  FILE:
    foreach my $filename (@file_list) {

        # Global variables for making of current file:
        $updated     = 0;
        $failure     = 0;     # Set nonzero to indicate failure at some point of
                              # a make.  Use value as exit code if I exit.
        $failure_msg = "";    # Indicate reason for failure

        if ($do_cd) {
            ( $filename, $path ) = fileparse($filename);
            warn "$My_name: Changing directory to '$path'\n";
            pushd($path);
        }
        else {
            $path = '';
        }

        ## remove extension from filename if was given.
        if ( &find_basename( $filename, $root_filename, $texfile_name ) ) {
            if ($force_mode) {
                warn "$My_name: Could not find file [$texfile_name]\n";
            }
            else {
                &ifcd_popd;
                &exit_msg1( "Could not find file [$texfile_name]", 11 );
            }
        }
        if ( $jobname ne '' ) {
            $root_filename = $jobname;
        }

        $aux_main = "$aux_dir1$root_filename.aux";
        $log_name = "$aux_dir1$root_filename.log";
        $fdb_name = "$aux_dir1$root_filename.$fdb_ext";

        # Initialize basic dependency information:

        # For use under error conditions:
        @default_includes = ( $texfile_name, $aux_main );

        # Initialize rule database.
        # ?? Should I also initialize file database?
        %rule_list = ();
        &rdb_make_rule_list;
        &rdb_set_rules( \%rule_list );

        if ( $cleanup_mode > 0 ) {

            # ?? MAY NEED TO FIX THE FOLLOWING IF $aux_dir or $out_dir IS SET.
            my %other_generated        = ();
            my @index_bibtex_generated = ();
            my @aux_files              = ();
            $have_fdb = 0;
            if ( -e $fdb_name ) {
                print
                  "$My_name: Examining fdb file '$fdb_name' for rules ...\n";
                $have_fdb = ( 0 == rdb_read($fdb_name) );
            }
            if ($have_fdb) {
                rdb_for_all(
                    sub {    # Find generated files at rule level
                        my ( $base, $path, $ext ) = fileparseA($$Psource);
                        $base = $path . $base;
                        if ( $rule =~ /^makeindex/ ) {
                            push @index_bibtex_generated, $$Psource, $$Pdest,
                              "$base.ilg";
                        }
                        elsif ( $rule =~ /^(bibtex|biber)/ ) {
                            push @index_bibtex_generated, $$Pdest, "$base.blg";
                            push @aux_files, $$Psource;
                        }
                        elsif ( exists $other_generated{$$Psource} ) {
                            $other_generated{$$Pdest};
                        }
                    },
                    sub {    # Find generated files at source file level
                        if ( $file =~ /\.aux$/ ) { push @aux_files, $file; }
                    }
                );
            }
            else {
                # No fdb file, so do inferior job by parse_log
                print
"$My_name: Examining log file '$log_name' for generated files...\n";

                # Variables set by parse_log. Can I remove them
                local %generated_log = ();
                local %dependents = ();  # Maps files to status.  Not used here.
                local @bbl_files  = ();  # Not used here.
                local %idx_files =
                  ();    # Maps idx_file to (ind_file, base). Not used here.
                local %conversions =
                  ();    # (pdf)latex-performed conversions.  Not used here.
                         # Maps output file created and read by (pdf)latex
                         #    to source file of conversion.
                local $primary_out =
                  '';    # Actual output file (dvi or pdf). Not used here.
                &parse_log;
                %other_generated = %generated_log;
            }

            if ( ( $go_mode == 2 ) && !$silent ) {
                warn "$My_name: Removing all generated files\n" unless $silent;
            }
            if ( $bibtex_use < 2 ) {
                delete $generated_exts_all{'bbl'};
            }

            # Convert two arrays to hashes:
            my %index_bibtex_generated = ();
            my %aux_files              = ();
            foreach (@index_bibtex_generated) {
                $index_bibtex_generated{$_} = 1
                  unless ( /\.bbl$/ && ( $bibtex_use < 2 ) );
                delete( $other_generated{$_} );
            }
            foreach (@aux_files) {
                $aux_files{$_} = 1;
                delete( $other_generated{$_} );
            }
            if ($diagnostics) {
                show_array(
                    "For deletion:\n"
                      . " Generated (from makeindex and bibtex):",
                    keys %index_bibtex_generated
                );
                show_array( " Aux files:", keys %aux_files );
                show_array(
                    "Other generated files:\n"
                      . " (only deleted if \$cleanup_includes_generated is set): ",
                    keys %other_generated
                );
            }
            &cleanup1(
                $aux_dir1, $fdb_ext, 'blg', 'ilg', 'log', 'aux.bak', 'idx.bak',
                split( ' ', $clean_ext ),
                keys %generated_exts_all
            );
            unlink_or_move(
                'texput.log', "texput.aux",
                keys %index_bibtex_generated,
                keys %aux_files
            );
            if ($cleanup_includes_generated) {
                unlink_or_move( keys %other_generated );
            }
            if ($cleanup_includes_cusdep_generated) {
                &cleanup_cusdep_generated;
            }
            if ( $cleanup_mode == 1 ) {
                &cleanup1( $out_dir1, 'dvi', 'dviF', 'ps', 'psF', 'pdf',
                    split( ' ', $clean_full_ext ) );
            }
        }
        if ($cleanup_fdb) {
            unlink_or_move($fdb_name);

         # If the fdb file exists, it will have been read, and therefore changed
         #   rule database.  But deleting the fdb file implies we also want
         #   a virgin rule database, so we must reset it:
            rdb_set_rules( \%rule_list );
        }
        if ($cleanup_only) { next FILE; }

        #??? The following are not needed if use rdb_make.
        #    ?? They may be set too early?
        # Arrays and hashes for picking out accessible rules.
        # Distinguish rules for making files and others
        @accessible_all =
          sort ( &rdb_accessible( keys %requested_filerules, keys %one_time ) );
        %accessible_filerules = ();
        foreach (@accessible_all) {
            unless ( /view/ || /print/ ) { $accessible_filerules{$_} = 1; }
        }
        @accessible_filerules = sort keys %accessible_filerules;

#    show_array ( "=======All rules used", @accessible_all );
#    show_array ( "=======Requested file rules", sort keys %requested_filerules );
#    show_array ( "=======Rules for files", @accessible_filerules );

        if ($diagnostics) {
            print "$My_name: Rules after start up for '$texfile_name'\n";
            rdb_show();
        }

        %primaries = ();
        foreach (@accessible_all) {
            if ( ( $_ eq 'latex' ) || ( $_ eq 'pdflatex' ) ) {
                $primaries{$_} = 1;
            }
        }

        $have_fdb = 0;
        if ( ( !-e $fdb_name ) && ( !-e $aux_main ) ) {

            # No aux and no fdb file => set up trivial aux file
            #    and corresponding fdb_file.  Arrange them to provoke one run
            #    as minimum, but no more if actual aux file is trivial.
            #    (Useful on big files without cross references.)
            &set_trivial_aux_fdb;
        }

        if ( -e $fdb_name ) {
            $rdb_errors = rdb_read($fdb_name);
            $have_fdb   = ( $rdb_errors == 0 );
        }
        if ( !$have_fdb ) {

            # We didn't get a valid set of data on files used in
            # previous run.  So use filetime criterion for make
            # instead of change from previous run, until we have
            # done our own make.
            rdb_recurse(
                [ keys %possible_primaries ],
                sub {
                    if ( $$Ptest_kind == 1 ) { $$Ptest_kind = 3; }
                }
            );
            if ( -e $log_name ) {
                rdb_for_some( [ keys %possible_primaries ],
                    \&rdb_set_latex_deps );
            }
        }
        foreach $rule ( rdb_accessible( uniq1( keys %requested_filerules ) ) ) {

            # For all source files of all accessible rules,
            #    if the file data are not already set (e.g., from fdb_latexmk
            #    file, set them from disk.
            rdb_one_rule(
                $rule, undef,
                sub {
                    if ( $$Ptime == 0 ) { &rdb_update1; }
                }
            );
        }

        if ($go_mode) {

            # Force everything to be remade.
            rdb_recurse( [ keys %requested_filerules ],
                sub { $$Pout_of_date = 1; } );
        }

        if ($diagnostics) {
            print "$My_name: Rules after initialization\n";
            rdb_show();
        }

        #************************************************************

        if ($preview_continuous_mode) {
            &make_preview_continuous;

            # Will probably exit by ctrl/C and never arrive here.
            next FILE;
        }

## Handling of failures:
##    Variable $failure is set to indicate a failure, with information
##       put in $failure_msg.
##    These variables should be set to 0 and '' at any point at which it
##       should be assumed that no failures have occurred.
##    When after a routine is called it is found that $failure is set, then
##       processing should normally be aborted, e.g., by return.
##    Then there is a cascade of returns back to the outermost level whose
##       responsibility is to handle the error.
##    Exception: An outer level routine may reset $failure and $failure_msg
##       after initial processing, when the error condition may get
##       ameliorated later.
        #Initialize failure flags now.
        $failure     = 0;
        $failure_msg = '';
        $failure     = rdb_make( keys %requested_filerules );
        if ( $failure > 0 ) { next FILE; }
        rdb_for_some( [ keys %one_time ], \&rdb_run1 );
    }    # end FILE
    continue {
        if ($dependents_list) { deps_list($deps_handle); }
        if ($rules_list)      { rdb_list(); }

        # Handle any errors
        $error_message_count = rdb_show_rule_errors();
        if ( ( $error_message_count == 0 ) || ( $failure > 0 ) ) {
            if ($failure_msg) {

                #Remove trailing space
                $failure_msg =~ s/\s*$//;
                warn "$My_name: Did not finish processing file '$filename':\n",
                  "   $failure_msg\n";
                $failure = 1;
            }
        }
        if ( ( $failure > 0 ) || ( $error_message_count > 0 ) ) {
            $failure_count++;
            push @failed_primaries, $filename;
        }
        &ifcd_popd;
    }
    close($deps_handle) if ($deps_handle);

    if ($show_time) { show_timing(); }

    # If we get here without going through the continue section:
    if ( $do_cd && ( $#dir_stack > -1 ) ) {

        # Just in case we did an abnormal exit from the loop
        warn
"$My_name: Potential bug: dir_stack not yet unwound, undoing all directory changes now\n";
        &finish_dir_stack;
    }

    if ( $failure_count > 0 ) {
        if ( $#file_list > 0 ) {

            # Error occured, but multiple files were processed, so
            #     user may not have seen all the error messages
            warn "\n------------\n";
            show_array(
"$My_name: Some operations failed, for the following tex file(s)",
                @failed_primaries
            );
        }
        if ( !$force_mode ) {
            warn "$My_name: Use the -f option to force complete processing,\n",
              " unless error was exceeding maximum runs of latex/pdflatex.\n";
        }
        exit 12;
    }

}

# end MAIN PROGRAM
#############################################################

sub fix_cmds {

    # If commands do not have placeholders for %S etc, put them in
    foreach (
        $latex,                   $pdflatex,               $lpr,
        $lpr_dvi,                 $lpr_pdf,                $pdf_previewer,
        $ps_previewer,            $ps_previewer_landscape, $dvi_previewer,
        $dvi_previewer_landscape, $kpsewhich
      )
    {
        # Source only
        if ( $_ && !/%/ ) { $_ .= " %O %S"; }
    }
    foreach (
        $pdf_previewer, $ps_previewer, $ps_previewer_landscape,
        $dvi_previewer, $dvi_previewer_landscape,
      )
    {
        # Run previewers detached
        if ( $_ && !/^(nostart|NONE|internal) / ) {
            $_ = "start $_";
        }
    }
    foreach ( $biber, $bibtex ) {

        # Base only
        if ( $_ && !/%/ ) { $_ .= " %O %B"; }
    }
    foreach ( $dvipdf, $ps2pdf ) {

        # Source and dest without flag for destination
        if ( $_ && !/%/ ) { $_ .= " %O %S %D"; }
    }
    foreach ( $dvips, $makeindex ) {

        # Source and dest with -o dest before source
        if ( $_ && !/%/ ) { $_ .= " %O -o %D %S"; }
    }
    foreach ( $dvi_filter, $ps_filter ) {

        # Source and dest, but as filters
        if ( $_ && !/%/ ) { $_ .= " %O <%S >%D"; }
    }
}    #END fix_cmds

#############################################################

sub show_timing {
    my $processing_time = processing_time() - $processing_time1;
    print @timings, "Accumulated processing time = $processing_time\n";
    @timings          = ();
    $processing_time1 = processing_time();
}

#############################################################

sub add_option {

    # Call add_option( $opt, \$cmd ... )
    # Add option to one or more commands
    my $option = shift;
    while (@_) {
        if ( ${ $_[0] } !~ /%/ ) { &fix_cmds; }
        ${ $_[0] } =~ s/%O/$option %O/;
        shift;
    }
}    #END add_option

#############################################################

sub rdb_make_rule_list {

    # Substitutions: %S = source, %D = dest, %B = this rule's base
    #                %T = texfile, %R = root = base for latex.
    #                %Y for $aux_dir1, %Z for $out_dir1

    # Defaults for dvi, ps, and pdf files
    # Use local, not my, so these variables can be referenced
    local $dvi_final = "%Z%R.dvi";
    local $ps_final  = "%Z%R.ps";
    local $pdf_final = "%Z%R.pdf";
    if ( length($dvi_filter) > 0 ) {
        $dvi_final = "%Z%R.dviF";
    }
    if ( length($ps_filter) > 0 ) {
        $ps_final = "%Z%R.psF";
    }

    my $print_file = '';
    my $print_cmd  = '';
    if ( $print_type eq 'dvi' ) {
        $print_file = $dvi_final;
        $print_cmd  = $lpr_dvi;
    }
    elsif ( $print_type eq 'pdf' ) {
        $print_file = $pdf_final;
        $print_cmd  = $lpr_pdf;
    }
    elsif ( $print_type eq 'ps' ) {
        $print_file = $ps_final;
        $print_cmd  = $lpr;
    }

    my $view_file             = '';
    my $viewer                = '';
    my $viewer_update_method  = 0;
    my $viewer_update_signal  = undef;
    my $viewer_update_command = undef;

    if ( ( $view eq 'dvi' ) || ( $view eq 'pdf' ) || ( $view eq 'ps' ) ) {
      my @evs;

      push(@evs,'$view_file = $' . $view . '_final' );
      push(@evs,'$viewer    = $' . $view . '_previewer' );
      push(@evs,'$viewer_update_method    = $' . $view . '_update_method' );
      push(@evs,'$viewer_update_signal    = $' . $view . '_update_signal' );

        #$viewer               = ${ $view . '_previewer' };
        #$viewer_update_method = ${ $view . '_update_method' };
        #$viewer_update_signal = ${ $view . '_update_signal' };
        push(@evs,'if ( defined $' . $view . '_update_command  ) { ');
        push(@evs,'$viewer_update_command    = $' . $view . '_update_command; } ' );

        eval(join(";",@evs));
        die $@ if $@;
    }

    # Specification of internal command for viewer update:
    my $PA_update =
      [ 'do_update_view', $viewer_update_method, $viewer_update_signal, 0, 1 ];

# For test_kind: Use file contents for latex and friends, but file time for the others.
# This is because, especially for dvi file, the contents of the file may contain
#    a pointer to a file to be included, not the contents of the file!
    %rule_list = (
        'latex' =>
          [ 'primary', "$latex", '', "%T", "%Z%B.dvi", "%R", 1, ["%Y%R.log"] ],
        'pdflatex' => [
            'primary', "$pdflatex", '', "%T",
            "%Z%B.pdf", "%R", 1, ["%Y%R.log"]
        ],
        'dvipdf' => [
            'external', "$dvipdf", 'do_viewfile', $dvi_final,
            "%B.pdf",   "%Z%R",    2
        ],
        'dvips' => [
            'external', "$dvips", 'do_viewfile', $dvi_final,
            "%B.ps",    "%Z%R",   2
        ],
        'dvifilter' => [
            'external', $dvi_filter, 'do_viewfile', "%B.dvi",
            "%B.dviF",  "%Z%R",      2
        ],
        'ps2pdf' => [
            'external', "$ps2pdf", 'do_viewfile', $ps_final,
            "%B.pdf",   "%Z%R",    2
        ],
        'psfilter' => [
            'external', $ps_filter, 'do_viewfile', "%B.ps",
            "%B.psF",   "%Z%R",     2
        ],
        'print' =>
          [ 'external', "$print_cmd", 'if_source', $print_file, "", "", 2 ],
        'update_view' => [
            'external', $viewer_update_command, $PA_update,
            $view_file, "", "", 2
        ],
        'view' => [ 'external', "$viewer", 'if_source', $view_file, "", "", 2 ],
    );
    %source_list = ();
    foreach my $rule ( keys %rule_list ) {
        $source_list{$rule} = [];
        my $PAsources = $source_list{$rule};
        my ( $cmd_type, $cmd, $source, $dest, $root ) = @{ $rule_list{$rule} };
        if ($source) {
            push @$PAsources, [ $rule, $source, '' ];
        }
    }

    # Ensure we only have one way to make pdf file, and that it is appropriate:
    if ( $pdf_mode == 1 ) {
        delete $rule_list{'dvipdf'};
        delete $rule_list{'ps2pdf'};
    }
    elsif ( $pdf_mode == 2 ) {
        delete $rule_list{'dvipdf'};
        delete $rule_list{'pdflatex'};
    }
    else { delete $rule_list{'pdflatex'}; delete $rule_list{'ps2pdf'}; }

}    # END rdb_make_rule_list

#************************************************************

sub rdb_set_rules {

    # Call rdb_set_rules( \%rule_list, ...)
    # Set up rule database from definitions

    # Map of files to rules that MAKE them:
    %rule_db = ();

    foreach my $Prule_list (@_) {
        foreach my $rule ( keys %$Prule_list ) {
            my ( $cmd_type, $ext_cmd, $int_cmd, $source, $dest, $base,
                $test_kind, $PA_extra_gen )
              = @{ $$Prule_list{$rule} };
            if ( !$PA_extra_gen ) { $PA_extra_gen = []; }
            my $needs_making = 0;

            # Substitute in the filename variables, since we will use
            # those for determining filenames.  But delay expanding $cmd
            # until run time, in case of changes.
            foreach ( $base, $source, $dest, @$PA_extra_gen ) {
                s/%R/$root_filename/;
                s/%Y/$aux_dir1/;
                s/%Z/$out_dir1/;
            }
            foreach ( $source, $dest ) {
                s/%B/$base/;
                s/%T/$texfile_name/;
            }

 #        print "$rule: $cmd_type, EC='$ext_cmd', IC='$int_cmd', $test_kind,\n",
 #              "    S='$source', D='$dest', B='$base' $needs_making\n";
            rdb_create_rule(
                $rule,         $cmd_type, $ext_cmd, $int_cmd,
                $test_kind,    $source,   $dest,    $base,
                $needs_making, undef,     undef,    1,
                $PA_extra_gen
            );

            # !! ?? Last line was
            #			     $needs_making, undef, ($test_kind==1) );
        }
    }    # End arguments of subroutine
    &rdb_make_links;
}    # END rdb_set_rules

#************************************************************

sub rdb_make_links {

    # ?? Problem if there are multiple rules for getting a file.  Notably pdf.
    #    Which one to choose?
    # Create $from_rule if there's a suitable rule.
    # Map files to rules:
    local %from_rules = ();
    rdb_for_all(
        sub {
            if ($$Pdest) { $from_rules{$$Pdest} = $rule; }
        }
    );

   #??    foreach (sort keys %from_rules) {print "D='$_' F='$from_rules{$_}\n";}
    rdb_for_all(
        0,
        sub {
            # Set from_rule, but only if it isn't set or is invalid.
            # Don't forget the biber v. bibtex issue
            if ( exists $from_rules{$file}
                && ( ( !$$Pfrom_rule ) || ( !exists $rule_db{$$Pfrom_rule} ) ) )
            {
                $$Pfrom_rule = $from_rules{$file};
            }
        }
    );
    rdb_for_all(
        0,
        sub {
            if ( exists $from_rules{$file} ) {
                $$Pfrom_rule = $from_rules{$file};
            }
            if ( $$Pfrom_rule && ( !rdb_rule_exists($$Pfrom_rule) ) ) {
                $$Pfrom_rule = '';
            }

            #??            print "$rule: $file, $$Pfrom_rule\n";
        }
    );
}    # END rdb_make_links

#************************************************************

sub set_trivial_aux_fdb {

    # 1. Write aux file EXACTLY as would be written if the tex file
    #    had no cross references, etc. I.e., a minimal .aux file.
    # 2. Write a corresponding fdb file
    # 3. Provoke a run of (pdf)latex (actually of all primaries).

    local *aux_file;
    open( aux_file, '>', $aux_main )
      or die "Cannot write file '$aux_main'\n";
    print aux_file "\\relax \n";
    close(aux_file);

    foreach my $rule ( keys %primaries ) {
        rdb_ensure_file( $rule, $texfile_name );
        rdb_ensure_file( $rule, $aux_main );
        rdb_one_rule( $rule, sub { $$Pout_of_date = 1; } );
    }
    &rdb_write($fdb_name);
}    #END set_trivial_aux_fdb

#************************************************************
#### Particular actions
#************************************************************
#************************************************************

sub do_cusdep {

    # Unconditional application of custom-dependency
    # except that rule is not applied if the source file source
    # does not exist, and an error is returned if the dest is not made.
    #
    # Assumes rule context for the custom-dependency, and that my first
    # argument is the name of the subroutine to apply
    my $func_name = $_[0];
    my $return    = 0;
    if ( !-e $$Psource ) {

        # Source does not exist.  Users of this rule will need to turn
        # it off when custom dependencies are reset
        if ( !$silent ) {
## ??? Was commented out.  1 Sep. 2008 restored, for cusdep no-file-exists issue
            warn "$My_name: In trying to apply custom-dependency rule\n",
              "  to make '$$Pdest' from '$$Psource'\n",
              "  the source file has disappeared since the last run\n";
        }

        # Treat as successful
    }
    elsif ( !$func_name ) {
        warn "$My_name: Possible misconfiguration or bug:\n",
          "  In trying to apply custom-dependency rule\n",
          "  to make '$$Pdest' from '$$Psource'\n",
          "  the function name is blank.\n";
    }
    elsif ( !defined &$func_name ) {
        warn "$My_name: Misconfiguration or bug,",
          " in trying to apply custom-dependency rule\n",
          "  to make '$$Pdest' from '$$Psource'\n",
          "  function name '$func_name' does not exists.\n";
    }
    else {
        my $cusdep_ret = &$func_name($$Pbase);
        if ( defined $cusdep_ret && ( $cusdep_ret != 0 ) ) {
            $return = $cusdep_ret;
            if ($return) {
                warn "Rule '$rule', function '$func_name'\n",
                  "   failed with return code = $return\n";
            }
        }
        elsif ( !-e $$Pdest ) {

            # Destination non-existent, but routine failed to give an error
            warn "$My_name: In running custom-dependency rule\n",
              "  to make '$$Pdest' from '$$Psource'\n",
              "  function '$func_name' did not make the destination.\n";
            $return = -1;
        }
    }
    return $return;
}    # END do_cusdep

#************************************************************

sub do_viewfile {

    # Unconditionally make file for viewing, going through temporary file if
    # Assumes rule context

    my $return = 0;
    my ( $base, $path, $ext ) = fileparseA($$Pdest);
    if (&view_file_via_temporary) {
        if ( $$Pext_cmd =~ /%D/ ) {
            my $tmpfile = tempfile1( "${root_filename}_tmp", $ext );
            warn "$My_name: Making '$$Pdest' via temporary '$tmpfile'...\n";
            $return = &Run_subst( undef, undef, undef, undef, $tmpfile );
            move( $tmpfile, $$Pdest );
        }
        else {
            warn
              "$My_name is configured to make '$$Pdest' via a temporary file\n",
"    but the command template '$$Pext_cmd' does not have a slot\n",
"    to set the destination file, so I won't use a temporary file\n";
            $return = &Run_subst();
        }
    }
    else {
        $return = &Run_subst();
    }
    return $return;
}    #END do_viewfile

#************************************************************

sub do_update_view {

    # Update viewer
    # Assumes rule context
    # Arguments: (method, signal, viewer_process)

    my $return = 0;

    # Although the process is passed as an argument, we'll need to update it.
    # So (FUDGE??) bypass the standard interface for the process.
    # We might as well do this for all the arguments.
    my $viewer_update_method        = ${$PAint_cmd}[1];
    my $viewer_update_signal        = ${$PAint_cmd}[2];
    my $Pviewer_process             = \${$PAint_cmd}[3];
    my $Pneed_to_get_viewer_process = \${$PAint_cmd}[4];

    if ( $viewer_update_method == 2 ) {
        if ($$Pneed_to_get_viewer_process) {
            $$Pviewer_process = &find_process_id($$Psource);
            if ( $$Pviewer_process != 0 ) {
                $$Pneed_to_get_viewer_process = 0;
            }
        }
        if ( $$Pviewer_process == 0 ) {
            print
"$My_name: need to signal viewer for file '$$Psource', but didn't get \n",
"   process ID for some reason, e.g., no viewer, bad configuration, bug\n"
              if $diagnostics;
        }
        elsif ( defined $viewer_update_signal ) {
            print "$My_name: signalling viewer, process ID $$Pviewer_process\n"
              if $diagnostics;
            kill $viewer_update_signal, $$Pviewer_process;
        }
        else {
            warn "$My_name: viewer is supposed to be sent a signal\n",
              "  but no signal is defined.  Misconfiguration or bug?\n";
            $return = 1;
        }
    }
    elsif ( $viewer_update_method == 4 ) {
        if ( defined $$Pext_cmd ) {
            $return = &Run_subst();
        }
        else {
            warn
"$My_name: viewer is supposed to be updated by running a command,\n",
              "  but no command is defined.  Misconfiguration or bug?\n";
        }
    }
    return $return;
}    #END do_update_view

#************************************************************

sub if_source {

    # Unconditionally apply rule if source file exists.
    # Assumes rule context
    if ( -e $$Psource ) {
        return &Run_subst();
    }
    else {
        return -1;
    }
}    #END if_source

#************************************************************
#### Subroutines
#************************************************************
#************************************************************

# Finds the basename of the root file
# Arguments:
#  1 - Filename to breakdown
#  2 - Where to place base file
#  3 - Where to place tex file
#  Returns non-zero if tex file does not exist
#
# The rules for determining this depend on the implementation of TeX.
# The variable $extension_treatment determines which rules are used.

sub find_basename

  #?? Need to use kpsewhich, if possible
{
    local ( $given_name, $base_name, $ext, $path, $tex_name );
    $given_name = $_[0];
    if ( "$extension_treatment" eq "miktex_old" ) {

        # Miktex v. 1.20d:
        #   1. If the filename has an extension, then use it.
        #   2. Else append ".tex".
        #   3. The basename is obtained from the filename by
        #      removing the path component, and the extension, if it
        #      exists.  If a filename has a multiple extension, then
        #      all parts of the extension are removed.
        #   4. The names of generated files (log, aux) are obtained by
        #      appending .log, .aux, etc to the basename.  Note that
        #      these are all in the CURRENT directory, and the drive/path
        #      part of the originally given filename is ignored.
        #
        #   Thus when the given filename is "\tmp\a.b.c", the tex
        #   filename is the same, and the basename is "a".

        ( $base_name, $path, $ext ) = fileparse( $given_name, '\..*' );
        if   ( "$ext" eq "" ) { $tex_name = "$given_name.tex"; }
        else                  { $tex_name = $given_name; }
        $_[1] = $base_name;
        $_[2] = $tex_name;
    }
    elsif ( "$extension_treatment" eq "unix" ) {

        # unix (at least web2c 7.3.1) =>
        #   1. If filename.tex exists, use it,
        #   2. else if filename exists, use it.
        #   3. The base filename is obtained by deleting the path
        #      component and, if an extension exists, the last
        #      component of the extension, even if the extension is
        #      null.  (A name ending in "." has a null extension.)
        #   4. The names of generated files (log, aux) are obtained by
        #      appending .log, .aux, etc to the basename.  Note that
        #      these are all in the CURRENT directory, and the drive/path
        #      part of the originally given filename is ignored.
        #
        #   Thus when the given filename is "/tmp/a.b.c", there are two
        #   cases:
        #      a.  /tmp/a.b.c.tex exists.  Then this is the tex file,
        #          and the basename is "a.b.c".
        #      b.  /tmp/a.b.c.tex does not exist.  Then the tex file is
        #          "/tmp/a.b.c", and the basename is "a.b".

        if ( -e "$given_name.tex" ) {
            $tex_name = "$given_name.tex";
        }
        else {
            $tex_name = "$given_name";
        }
        ( $base_name, $path, $ext ) = fileparse( $tex_name, '\.[^\.]*' );
        $_[1] = $base_name;
        $_[2] = $tex_name;
    }
    else {
        die "$My_name: Incorrect configuration gives \$extension_treatment=",
          "'$extension_treatment'\n";
    }
    if ($diagnostics) {
        print "Given='$given_name', tex='$tex_name', base='$base_name'\n";
    }
    return !-e $tex_name;
}    #END find_basename

#************************************************************

sub make_preview_continuous {
    local @changed         = ();
    local @disappeared     = ();
    local @no_dest         = ();    # Non-existent destination files
    local @rules_never_run = ();
    local @rules_to_apply  = ();

    local $failure       = 0;
    local %rules_applied = ();
    local $updated       = 0;

    # What to make?
    my @targets = keys %requested_filerules;

    $quell_uptodate_msgs = 1;

    local $view_file = '';
    rdb_one_rule( 'view', sub { $view_file = $$Psource; } );

    if ( ( $view eq 'dvi' ) || ( $view eq 'pdf' ) || ( $view eq 'ps' ) ) {
        warn "Viewing $view\n";
    }
    elsif ( $view eq 'none' ) {
        warn "Not using a previewer\n";
        $view_file = '';
    }
    else {
        warn "$My_name:  BUG: Invalid preview method '$view'\n";
        exit 20;
    }

    my $viewer_running = 0;    # No viewer known to be running yet
                               # Get information from update_view rule
    local $viewer_update_method = 0;

    # Pointers so we can update the following:
    local $Pviewer_process             = undef;
    local $Pneed_to_get_viewer_process = undef;
    rdb_one_rule(
        'update_view',
        sub {
            $viewer_update_method        = $$PAint_cmd[1];
            $Pviewer_process             = \$$PAint_cmd[3];
            $Pneed_to_get_viewer_process = \$$PAint_cmd[4];
        }
    );

    # Note that we don't get the previewer process number from the program
    # that starts it; that might only be a script to get things set up and the
    # actual previewer could be (and sometimes IS) another process.

    if ( ( $view_file ne '' ) && ( -e $view_file ) && !$new_viewer_always ) {

        # Is a viewer already running?
        #    (We'll save starting up another viewer.)
        $$Pviewer_process = &find_process_id($view_file);
        if ($$Pviewer_process) {
            warn "$My_name: Previewer is already running\n"
              if !$silent;
            $viewer_running               = 1;
            $$Pneed_to_get_viewer_process = 0;
        }
    }

    # Loop forever, rebuilding .dvi and .ps as necessary.
    # Set $first_time to flag first run (to save unnecessary diagnostics)
  CHANGE:
    for ( my $first_time = 1 ; 1 ; $first_time = 0 ) {
        my %rules_to_watch = %requested_filerules;
        $updated     = 0;
        $failure     = 0;
        $failure_msg = '';
        if ( $MSWin_fudge_break && ( $^O eq "MSWin32" ) ) {

            # Fudge under MSWin32 ONLY, to stop perl/latexmk from
            #   catching ctrl/C and ctrl/break, and let it only reach
            #   downstream programs. See comments at first definition of
            #   $MSWin_fudge_break.
            $SIG{BREAK} = $SIG{INT} = 'IGNORE';
        }
        if ($compiling_cmd) {
            Run_subst($compiling_cmd);
        }
        $failure = rdb_make(@targets);

##     warn "=========Viewer PID = $$Pviewer_process; updated=$updated\n";

        if ( $MSWin_fudge_break && ( $^O eq "MSWin32" ) ) {
            $SIG{BREAK} = $SIG{INT} = 'DEFAULT';
        }

        # Start viewer if needed.
        if ( ( $failure > 0 ) && ( !$force_mode ) ) {

            # No viewer yet
        }
        elsif (( $view_file ne '' )
            && ( -e $view_file )
            && $updated
            && $viewer_running )
        {
 # A viewer is running.  Explicitly get it to update screen if we have to do it:
            rdb_one_rule( 'update_view', \&rdb_run1 );
        }
        elsif ( ( $view_file ne '' ) && ( -e $view_file ) && !$viewer_running )
        {
            # Start the viewer
            if ( !$silent ) {
                if ($new_viewer_always) {
                    warn "$My_name: starting previewer for '$view_file'\n",
                      "------------\n";
                }
                else {
                    warn "$My_name: I have not found a previewer that ",
                      "is already running. \n",
                      "   So I will start it for '$view_file'\n",
                      "------------\n";
                }
            }
            local $retcode = 0;
            rdb_one_rule( 'view', sub { $retcode = &rdb_run1; } );
            if ( $retcode != 0 ) {
                if ($force_mode) {
                    warn "$My_name: I could not run previewer\n";
                }
                else {
                    &exit_msg1( "I could not run previewer", $retcode );
                }
            }
            else {
                $viewer_running               = 1;
                $$Pneed_to_get_viewer_process = 1;
            }    # end analyze result of trying to run viewer
        }    # end start viewer
        if ( $failure > 0 ) {
            if ( !$failure_msg ) {
                $failure_msg = 'Failure to make the files correctly';
            }
            my @pre_primary  = ();    # Array of rules
            my @post_primary = ();    # Array of rules
            my @one_time     = ();    # Array of rules
            &rdb_classify_rules( \%possible_primaries,
                keys %requested_filerules );

            # There will be files changed during the run that are irrelevant.
            # We need to wait for the user to change the files.

            # So set the GENERATED files from (pdf)latex as up-to-date:
            rdb_for_some( [ keys %current_primaries ], \&rdb_update_gen_files );

            # And don't watch for changes for post_primary rules (ps and pdf
            # from dvi, etc haven't been run after an error in (pdf)latex, so
            # are out-of-date by filetime criterion, but they should not be run
            # until after another (pdf)latex run:
            foreach (@post_primary) { delete $rules_to_watch{$_}; }

            $failure_msg =~ s/\s*$//;    #Remove trailing space
            warn "$My_name: $failure_msg\n",
"    ==> You will need to change a source file before I do another run <==\n";
            if ($failure_cmd) {
                Run_subst($failure_cmd);
            }
        }
        else {
            if ($success_cmd) {
                Run_subst($success_cmd);
            }
        }
        rdb_show_rule_errors();
        if ( $show_time && !$first_time ) { show_timing(); }
        if ( $first_time || $updated || $failure ) {
            print "\n=== Watching for updated files. Use ctrl/C to stop ...\n";
        }
        $waiting = 1;
        if ($diagnostics) { warn "WAITING\n"; }

# During waiting for file changes, handle ctrl/C and ctrl/break here, rather than letting
#   system handle them by terminating script (and any script that calls it).  This allows,
#   for example, the clean up code in the following command line to work:
#          latexmk -pvc foo; cleanup;
        &catch_break;
        $have_break = 0;
      WAIT: while (1) {
            sleep($sleep_time);
            if ($have_break) { last WAIT; }
            if ( rdb_new_changes( keys %rules_to_watch ) ) {
                if ( !$silent ) {
                    warn "$My_name: Need to remake files.\n";
                    &rdb_diagnose_changes('  ');
                }
                last WAIT;
            }

            #  Don't count waiting time in processing:
            $processing_time1 = processing_time();

            # Does this do this job????
            local $new_files = 0;
            rdb_for_some( [ keys %current_primaries ],
                sub { $new_files += &rdb_find_new_files } );
            if ( $new_files > 0 ) {
                warn "$My_name: New file(s) found.\n";
                last WAIT;
            }
            if ($have_break) { last WAIT; }
        }    # end WAIT:
        &default_break;
        if ($have_break) {
            print "$My_name: User typed ctrl/C or ctrl/break.  I'll stop.\n";
            exit;
        }
        $waiting = 0;
        if ($diagnostics) { warn "NOT       WAITING\n"; }
    }    #end infinite_loop CHANGE:
}    #END sub make_preview_continuous

#************************************************************

sub process_rc_file {

    # Usage process_rc_file( filename )
    # NEW VERSION
    # Run rc_file whose name is given in first argument
    #    Exit with code 0 on success
    #    Exit with code 1 if file cannot be read or does not exist.
    #    Stop if there is a syntax error or other problem.
    # PREVIOUSLY:
    #    Exit with code 2 if is a syntax error or other problem.
    my $rc_file  = $_[0];
    my $ret_code = 0;
    warn "$My_name: Executing Perl code in file '$rc_file'...\n"
      if $diagnostics;

    # I could use the do command of perl, but the preceeding -r test
    # to get good diagnostics gets the wrong result under cygwin
    # (e.g., on /cygdrive/c/latexmk/LatexMk)
    my $RCH = new FileHandle;
    if ( !-e $rc_file ) {
        warn "$My_name: The rc-file '$rc_file' does not exist\n";
        return 1;
    }
    elsif ( open $RCH, "<$rc_file" ) {
        { local $/; eval <$RCH>; }
        close $RCH;
    }
    else {
        warn "$My_name: I cannot read the rc-file '$rc_file'\n";
        return 1;
    }

    # PREVIOUS VERSION
    #    if ( ! -r $rc_file ) {
    #        warn "$My_name: I cannot read the rc-file '$rc_file'\n",
    #  	     "          or at least that's what Perl (for $^O) reports\n";
    #        return 1;
    #    }
    #    do( $rc_file );
    if ($@) {

        # Indent each line of possibly multiline message:
        my $message = prefix( $@, "     " );
        warn "$My_name: Initialization file '$rc_file' gave an error:\n",
          "$message\n";
        die "$My_name: Stopping because of problem with rc file\n";

        # Use the following if want non-fatal error.
        return 2;
    }
    return 0;
}    #END process_rc_file

#************************************************************

sub execute_code_string {

    # Usage execute_code_string( string_of_code )
    # Run the perl code contained in first argument
    #    Halt if there is a syntax error or other problem.
    # ???Should I leave the exiting to the caller (perhaps as an option)?
    #     But I can always catch it with an eval if necessary.
    #     That confuses ctrl/C and ctrl/break handling.
    my $code = $_[0];
    warn "$My_name: Executing initialization code specified by -e:\n",
      "   '$code'...\n"
      if $diagnostics;
    eval $code;

    # The return value from the eval is not useful, since it is the value of
    #    the last expression evaluated, which could be anything.
    # The correct test of errors is on the value of $@.

    if ($@) {

        # Indent each line of possibly multiline message:
        my $message = prefix( $@, "    " );
        die "$My_name: ",
          "Stopping because executing following code from command line\n",
          "    $code\n",
          "gave an error:\n",
          "$message\n";
    }
}    #END execute_code_string

#************************************************************

sub cleanup1 {

    # Usage: cleanup1( directory, exts_without_period, ... )
    my $dir = shift;
    foreach (@_) {
        ( my $name = /%R/ ? $_ : "%R.$_" ) =~ s/%R/$dir$root_filename/;
        unlink_or_move("$name");
    }
}    #END cleanup1

#************************************************************

sub cleanup_cusdep_generated {

    # Remove files generated by custom dependencies
    rdb_for_all( \&cleanup_one_cusdep_generated );
}    #END cleanup_cusdep_generated

#************************************************************

sub cleanup_one_cusdep_generated {

    # Remove destination file generated by one custom dependency
    # Assume rule context, but not that the rule is a custom dependency.
    # Only delete destination file if source file exists (so destination
    #   file can be recreated)
    if ( $$Pcmd_type ne 'cusdep' ) {

        # NOT cusdep
        return;
    }
    if ( ( -e $$Pdest ) && ( -e $$Psource ) ) {
        unlink_or_move($$Pdest);
    }
    elsif ( ( -e $$Pdest ) && ( !-e $$Psource ) ) {
        warn "$My_name: For custom dependency '$rule',\n",
          "    I won't delete destination file '$$Pdest'\n",
          "    because the source file '$$Psource' doesn't exist,\n",
          "    so the destination file may not be able to be recreated\n";
    }
}    #END cleanup_one_cusdep_generated

#************************************************************
#************************************************************
#************************************************************

#   Error handling routines, warning routines, help

#************************************************************

sub die_trace {

    # Call: die_trace( message );
    &traceback;    # argument(s) passed unchanged
    die "\n";
}    #END die_trace

#************************************************************

sub traceback {

    # Call: &traceback
    # or traceback( message,  )
    my $msg = shift;
    if ($msg) { warn "$msg\n"; }
    warn "Traceback:\n";
    my $i = 0;    # Start with immediate caller
    while ( my ( $pack, $file, $line, $func ) = caller( $i++ ) ) {
        if ( $func eq 'die_trace' ) { next; }
        warn "   $func called from line $line\n";
    }
}    #END traceback

#************************************************************

sub exit_msg1 {

    # exit_msg1( error_message, retcode [, action])
    #    1. display error message
    #    2. if action set, then restore aux file
    #    3. exit with retcode
    warn "\n------------\n";
    warn "$My_name: $_[0].\n";
    warn "-- Use the -f option to force complete processing.\n";

    my $retcode = $_[1];
    if ( $retcode >= 256 ) {

        # Retcode is the kind returned by system from an external command
        # which is 256 * command's_retcode
        $retcode /= 256;
    }
    exit $retcode;
}    #END exit_msg1

#************************************************************

sub warn_running {

    # Message about running program:
    if ($silent) {
        warn "$My_name: @_\n";
    }
    else {
        warn "------------\n@_\n------------\n";
    }
}    #END warn_running

#************************************************************

sub exit_help

  # Exit giving diagnostic from arguments and how to get help.
{
    warn "\n$My_name: @_\n",
      "Use\n",
      "   $my_name -help\nto get usage information\n";
    exit 10;
}    #END exit_help

#************************************************************

sub print_help {
    print
      "$My_name $version_num: Automatic LaTeX document generation routine\n\n",
      "Usage: $my_name [latexmk_options] [filename ...]\n\n",
      "  Latexmk_options:\n",
      "   -aux-directory=dir or -auxdir=dir \n",
"                 - set name of directory for auxiliary files (aux, log)\n",
      "                 - Currently this only works with MiKTeX\n",
      "   -bibtex       - use bibtex when needed (default)\n",
      "   -bibtex-      - never use bibtex\n",
"   -bibtex-cond  - use bibtex when needed, but only if the bib files exist\n",
"   -bm <message> - Print message across the page when converting to postscript\n",
      "   -bi <intensity> - Set contrast or intensity of banner\n",
      "   -bs <scale> - Set scale for banner\n",
      "   -commands  - list commands used by $my_name for processing files\n",
      "   -c     - clean up (remove) all nonessential files, except\n",
      "            dvi, ps and pdf files.\n",
"            This and the other clean-ups are instead of a regular make.\n",
      "   -C     - clean up (remove) all nonessential files\n",
      "            including aux, dep, dvi, postscript and pdf files\n",
      "            and file of database of file information\n",
      "   -CA     - clean up (remove) all nonessential files.\n",
      "            Equivalent to -C option.\n",
"   -CF     - Remove file of database of file information before doing \n",
      "            other actions\n",
      "   -cd    - Change to directory of source file when processing it\n",
"   -cd-   - Do NOT change to directory of source file when processing it\n",
"   -dependents or -deps - Show list of dependent files after processing\n",
      "   -dependents- or -deps- - Do not show list of dependent files\n",
      "   -deps-out=file - Set name of output file for dependency list,\n",
      "                    and turn on showing of dependency list\n",
      "   -dF <filter> - Filter to apply to dvi file\n",
      "   -dvi   - generate dvi\n",
      "   -dvi-  - turn off required dvi\n",
"   -e <code> - Execute specified Perl code (as part of latexmk start-up\n",
      "               code)\n",
      "   -f     - force continued processing past errors\n",
      "   -f-    - turn off forced continuing processing past errors\n",
      "   -gg    - Super go mode: clean out generated files (-CA), and then\n",
      "            process files regardless of file timestamps\n",
      "   -g     - process regardless of file timestamps\n",
      "   -g-    - Turn off -g\n",
      "   -h     - print help\n",
      "   -help - print help\n",
      "   -jobname=STRING - set basename of output file(s) to STRING.\n",
      "            (Like --jobname=STRING on command line for many current\n",
      "            implementations of latex/pdflatex.)\n",
      "   -l     - force landscape mode\n",
      "   -l-    - turn off -l\n",
      "   -latex=<program> - set program used for latex.\n",
      "                      (replace '<program>' by the program name)\n",
"   -latexoption=<option> - add the given option to the (pdf)latex command\n",
      "   -M     - Show list of dependent files after processing\n",
      "   -MF file - Specifies name of file to receives list dependent files\n",
"   -MP    - List of dependent files includes phony target for each source file.\n",
      "   -new-viewer    - in -pvc mode, always start a new viewer\n",
      "   -new-viewer-   - in -pvc mode, start a new viewer only if needed\n",
      "   -nobibtex      - never use bibtex\n",
"   -nodependents  - Do not show list of dependent files after processing\n",
"   -norc          - omit automatic reading of system, user and project rc files\n",
      "   -output-directory=dir or -outdir=dir\n",
      "                  - set name of directory for output files\n",
      "   -pdf   - generate pdf by pdflatex\n",
      "   -pdfdvi - generate pdf by dvipdf\n",
      "   -pdflatex=<program> - set program used for pdflatex.\n",
      "                      (replace '<program>' by the program name)\n",
      "   -pdfps - generate pdf by ps2pdf\n",
      "   -pdf-  - turn off pdf\n",
      "   -ps    - generate postscript\n",
      "   -ps-   - turn off postscript\n",
      "   -pF <filter> - Filter to apply to postscript file\n",
      "   -p     - print document after generating postscript.\n",
      "            (Can also .dvi or .pdf files -- see documentation)\n",
      "   -print=dvi     - when file is to be printed, print the dvi file\n",
"   -print=ps      - when file is to be printed, print the ps file (default)\n",
      "   -print=pdf     - when file is to be printed, print the pdf file\n",
"   -pv    - preview document.  (Side effect turn off continuous preview)\n",
      "   -pv-   - turn off preview mode\n",
"   -pvc   - preview document and continuously update.  (This also turns\n",
"                on force mode, so errors do not cause $my_name to stop.)\n",
      "            (Side effect: turn off ordinary preview mode.)\n",
      "   -pvc-  - turn off -pvc\n",
      "   -quiet    - silence progress messages from called programs\n",
      "   -r <file> - Read custom RC file\n",
"               (N.B. This file could override options specified earlier\n",
      "               on the command line.)\n",
      "   -recorder - Use -recorder option for (pdf)latex\n",
      "               (to give list of input and output files)\n",
      "   -recorder- - Do not use -recorder option for (pdf)latex\n",
      "   -rules    - Show list of rules after processing\n",
      "   -rules-   - Do not show list of rules after processing\n",
"   -showextraoptions  - Show other allowed options that are simply passed\n",
      "               as is to latex and pdflatex\n",
      "   -silent   - silence progress messages from called programs\n",
      "   -time     - show CPU time used\n",
      "   -time-    - don't show CPU time used\n",
      "   -use-make - use the make program to try to make missing files\n",
"   -use-make- - don't use the make program to try to make missing files\n",
      "   -v        - display program version\n",
      "   -verbose  - display usual progress messages from called programs\n",
      "   -version      - display program version\n",
      "   -view=default - viewer is default (dvi, ps, pdf)\n",
      "   -view=dvi     - viewer is for dvi\n",
      "   -view=none    - no viewer is used\n",
      "   -view=ps      - viewer is for ps\n",
      "   -view=pdf     - viewer is for pdf\n",
      "   -xelatex      - use xelatex for processing files to pdf\n",
      "\n",
      "   filename = the root filename of LaTeX document\n",
      "\n",
      "-p, -pv and -pvc are mutually exclusive\n",
      "-h, -c and -C override all other options.\n",
      "-pv and -pvc require one and only one filename specified\n",
"All options can be introduced by '-' or '--'.  (E.g., --help or -help.)\n",
      " \n",
      "In addition, latexmk recognizes many other options that are passed to\n",
      "latex and/or pdflatex without interpretation by latexmk.  Run latexmk\n",
      "with the option -showextraoptions to see a list of these\n";

}    #END print_help

#************************************************************
sub print_commands {
    warn "Commands used by $my_name:\n",
      "   To run latex, I use \"$latex\"\n",
      "   To run pdflatex, I use \"$pdflatex\"\n",
      "   To run biber, I use \"$biber\"\n",
      "   To run bibtex, I use \"$bibtex\"\n",
      "   To run makeindex, I use \"$makeindex\"\n",
      "   To make a ps file from a dvi file, I use \"$dvips\"\n",
      "   To make a ps file from a dvi file with landscape format, ",
      "I use \"$dvips_landscape\"\n",
      "   To make a pdf file from a dvi file, I use \"$dvipdf\"\n",
      "   To make a pdf file from a ps file, I use \"$ps2pdf\"\n",
      "   To view a pdf file, I use \"$pdf_previewer\"\n",
      "   To view a ps file, I use \"$ps_previewer\"\n",
      "   To view a ps file in landscape format, ",
      "I use \"$ps_previewer_landscape\"\n",
      "   To view a dvi file, I use \"$dvi_previewer\"\n",
      "   To view a dvi file in landscape format, ",
      "I use \"$dvi_previewer_landscape\"\n",
      "   To print a ps file, I use \"$lpr\"\n",
      "   To print a dvi file, I use \"$lpr_dvi\"\n",
      "   To print a pdf file, I use \"$lpr_pdf\"\n",
      "   To find running processes, I use \"$pscmd\", \n",
      "      and the process number is at position $pid_position\n";
    warn "Notes:\n",
      "  Command starting with \"start\" is run detached\n",
      "  Command that is just \"start\" without any other command, is\n",
      "     used under MS-Windows to run the command the operating system\n",
      "     has associated with the relevant file.\n",
      "  Command starting with \"NONE\" is not used at all\n";
}    #END print_commands

#************************************************************

sub view_file_via_temporary {
    return $always_view_file_via_temporary
      || ( $pvc_view_file_via_temporary && $preview_continuous_mode );
}    #END view_file_via_temporary

#************************************************************
#### Tex-related utilities

#**************************************************

sub check_biber_log {

    # Check for biber warnings:
    # Usage: check_biber_log( base_of_biber_run, \@biber_source )
    # return 0: OK;
    #        1: biber warnings;
    #        2: biber errors;
    #        3: could not open .blg file;
    #        4: failed to find one or more source files, except for bibfile;
    #        5: failed to find bib file;
    #        6: missing file, one of which is control file
    #       10: only error is missing \citation commands.
    # Side effect: add source files @biber_source
    my $base          = $_[0];
    my $Pbiber_source = $_[1];
    my $log_name      = "$base.blg";
    my $log_file      = new FileHandle;
    open( $log_file, "<$log_name" )
      or return 3;
    my $have_warning         = 0;
    my $have_error           = 0;
    my $missing_citations    = 0;
    my $no_citations         = 0;
    my $error_count          = 0;    # From my counting of error messages
    my $warning_count        = 0;    # From my counting of warning messages
                                     # The next two occur only from biber
    my $bibers_error_count   = 0;    # From biber's counting of errors
    my $bibers_warning_count = 0;    # From biber's counting of warnings
    my $not_found_count      = 0;
    my $control_file_missing = 0;

    while (<$log_file>) {
        if (/> WARN /) {
            print "Biber warning: $_";
            $have_warning = 1;
            $warning_count++;
        }
        elsif (/> (FATAL|ERROR) /) {
            print "Biber error: $_";
            if (
                /> (FATAL|ERROR) - Cannot find file '([^']+)'/    #'
                || /> (FATAL|ERROR) - Cannot find '([^']+)'/
              )
            {                                                     #'
                $not_found_count++;
                push @$Pbiber_source, $2;
            }
            elsif (/> (FATAL|ERROR) - Cannot find control file '([^']+)'/) {  #'
                $not_found_count++;
                $control_file_missing = 1;
                push @$Pbiber_source, $2;
            }
            else {
                $have_error = 1;
                $error_count++;
                if (
/> (FATAL|ERROR) - The file '[^']+' does not contain any citations!/
                  )
                {                                                             #'
                    $no_citations++;
                }
            }
        }
        elsif (/> INFO - Found .* '([^']+)'\s*$/
            || /> INFO - Found '([^']+)'\s*$/
            || /> INFO - Reading '([^']+)'\s*$/
            || /> INFO - Reading (.*)$/
            || /> INFO - Processing .* file '([^']+)' .*$/ )
        {
            if ( defined $Pbiber_source ) {
                push @$Pbiber_source, $1;
            }
        }
        elsif (/> INFO - WARNINGS: ([\d]+)\s*$/) {
            $bibers_warning_count = $1;
        }
        elsif (/> INFO - ERRORS: ([\d]+)\s*$/) {
            $bibers_error_count = $1;
        }
    }
    close $log_file;

    my @not_found =
      &find_file_list1( $Pbiber_source, $Pbiber_source, '', \@BIBINPUTS );
    @$Pbiber_source = uniqs(@$Pbiber_source);
    if ( ( $#not_found < 0 ) && ( $#$Pbiber_source >= 0 ) ) {
        warn "$My_name: Found biber source file(s) [@$Pbiber_source]\n"
          unless $silent;
    }
    elsif ( ( $#not_found == 0 ) && ( $not_found[0] =~ /\.bib$/ ) ) {

        # Special treatment if sole missing file is bib file
        # I don't want to treat that as an error
        warn "$My_name: Biber did't find bib file [$not_found[0]]\n";
        return 5;
    }
    else {
        show_array( "$My_name: Failed to find one or more biber source files:",
            @not_found );
        if ($force_mode) {
            warn "==== Force_mode is on, so I will continue.  ",
              "But there may be problems ===\n";
        }
        if ($control_file_missing) {
            return 6;
        }
        return 4;
    }

#    print "$My_name: #Biber errors = $error_count, warning messages = $warning_count,\n  ",
#          "missing citation messages = $missing_citations, no_citations = $no_citations\n";
    if ( !$have_error && $no_citations ) {

   # If the only errors are missing citations, or lack of citations, that should
   # count as a warning.
   # HOWEVER: biber doesn't generate a new bbl.  So it is an error condition.
        return 10;
    }
    if ($have_error)   { return 2; }
    if ($have_warning) { return 1; }
    return 0;
}    #END check_biber_log

#**************************************************

sub run_bibtex {
    my $return = 999;
    if ($aux_dir) {
        if ( $$Psource =~ /^$aux_dir1/ ) {

            # Run bibtex in $aux_dir, fixing input search path
            # to allow for finding files in original directory
            my ( $base, $path, $ext ) = fileparseA($$Psource);
            my $cwd = good_cwd();
            foreach ( 'BIBINPUTS', 'BSTINPUTS' ) {
                if ( exists $ENV{$_} ) {
                    $ENV{$_} = $cwd . $search_path_separator . $ENV{$_};
                }
                else {
                    $ENV{$_} = $cwd . $search_path_separator;
                }
            }
            pushd($path);
            $return = &Run_subst( undef, undef, '', $base . $ext, '', $base );
            popd();
        }
        else {
            warn "$My_name: Directory in file name '$$Psource' for bibtex\n",
              "   but it is not the output directory '$aux_dir'\n";
            $return = Run_subst();
        }
    }
    else {
        $return = Run_subst();
    }
    return $return;
}

#**************************************************

sub check_bibtex_log {

    # Check for bibtex warnings:
    # Usage: check_bibtex_log( base_of_bibtex_run )
    # return 0: OK, 1: bibtex warnings, 2: bibtex errors,
    #        3: could not open .blg file.
    #       10: only error is missing \citation commands or a missing aux file
    #           (which would normally be corrected after a later run of
    #           (pdf)latex).

    my $base     = $_[0];
    my $log_name = "$base.blg";
    my $log_file = new FileHandle;
    open( $log_file, "<$log_name" )
      or return 3;
    my $have_warning      = 0;
    my $have_error        = 0;
    my $missing_citations = 0;
    my @missing_aux       = ();
    my $error_count       = 0;
    while (<$log_file>) {

        if (/^Warning--/) {

            #print "Bibtex warning: $_";
            $have_warning = 1;
        }
        elsif (/^I couldn\'t open auxiliary file (.*\.aux)/) {
            push @missing_aux, $1;
        }
        elsif (/^I found no \\citation commands---while reading file/) {
            $missing_citations++;
        }
        elsif (/There (were|was) (\d+) error message/) {
            $error_count = $2;

            #print "Bibtex error: count=$error_count $_";
            $have_error = 1;
        }
    }
    close $log_file;
    my $missing = $missing_citations + $#missing_aux + 1;

    if ( $#missing_aux > -1 ) {

        # Need to make the missing files.
        warn
          "$My_name: One or more aux files is missing for bibtex. I'll try\n",
          "          to get (pdf)latex to remake them.\n";
        rdb_for_some( [ keys %current_primaries ],
            sub { $$Pout_of_date = 1; } );
    }

#print "Bibtex errors = $error_count, missing aux files and citations = $missing\n";
    if (   $have_error
        && ( $error_count <= $missing )
        && ( $missing > 0 ) )
    {
        # If the only error is a missing citation line, that should only
        # count as a warning.
        # Also a missing aux file should be innocuous; it will be created on
        # next run of (pdf)latex.  ?? HAVE I HANDLED THAT CORRECTLY?
        # But have to deal with the problem that bibtex gives a non-zero
        # exit code.  So leave things as they are so that the user gets
        # a better diagnostic ??????????????????????????
        #        $have_error = 0;
        #        $have_warning = 1;
        return 10;
    }
    if ($have_error)   { return 2; }
    if ($have_warning) { return 1; }
    return 0;
}    #END check_bibtex_log

#**************************************************

sub normalize_force_directory {

    #  Usage, normalize_force_directory( dir, filename )
    #  Perform the following operations:
    #    Clean filename
    #    If filename contains no path component, insert dir in front
    #    Normalize filename
    #  Return result
    my $default_dir = $_[0];
    my $filename    = clean_filename( $_[1] );
    my ( $base_name, $path ) = fileparse($filename);
    if ( $base_name eq $filename ) {
        $filename = "$default_dir$filename";
    }
    return normalize_filename($filename);
}    #END normalize force_directory

# ------------------------------

sub parse_log {

 # Scan log file for: dependent files
 #    reference_changed, bad_reference, bad_citation
 # Return value: 1 if success, 0 if no log file.
 # Set global variables:
 #   %dependents: maps definite dependents to code:
 #      0 = from missing-file line
 #            May have no extension
 #            May be missing path
 #      1 = from 'File: ... Graphic file (type ...)' line
 #            no path.  Should exist, but may need a search, by kpsewhich.
 #      2 = from regular '(...' coding for input file,
 #            Has NO path, which it would do if LaTeX file
 #            Highly likely to be mis-parsed line
 #      3 = ditto, but has a path character ('/').
 #            Should be LaTeX file that exists.
 #            If it doesn't exist, we have probably a mis-parsed line.
 #            There's no need to do a search.
 #      4 = definitive, which in this subroutine is only done:
 #             for default dependents,
 #             and for files that exist and are source of conversion
 #                reported by epstopdf et al.
 #      5 = Had a missing file line.  Now the file exists.
 #      6 = File was written during run.  (Overrides 5)
 #      7 = File was created during run to be read in.  (Overrides 5 and 6)
 #          (e.g., by epstopdf)
 # Treat the following specially, since they have special rules
 #   @bbl_files to list of .bbl files.
 #   %idx_files to map from .idx files to .ind files.
 # %generated_log: keys give set of files written by (pdf)latex (e.g., aux, idx)
 #   as determined by \openout = ... lines in log file.
 # Also set
 #   $reference_changed, $bad_reference, $bad_citation
 # Trivial or default values if log file does not exist/cannot be opened

    # Give a quick way of looking up custom-dependency extensions
    my %cusdep_from = ();
    my %cusdep_to   = ();
    foreach (@cus_dep_list) {
        my ( $fromext, $toext ) = split;
        $cusdep_from{$fromext} = $cusdep_from{".$fromext"} = $_;
        $cusdep_to{$toext}     = $cusdep_to{".$toext"}     = $_;
    }

#    print "==== Cusdep from-exts:"; foreach (keys %cusdep_from) {print " '$_'";} print "\n";
#    print "==== Cusdep to-exts:"; foreach (keys %cusdep_to) {print " '$_'";} print "\n";

    # Returned info:
    %dependents = ();
    foreach (@default_includes) { $dependents{$_} = 4; }
    @bbl_files     = ();
    %idx_files     = ();    # Maps idx_file to (ind_file, base)
    %generated_log = ();
    %conversions   = ();

    # $primary_out is actual output file (dvi or pdf)
    # It is initialized before the call to this routine, to ensure
    # a sensible default in case of misparsing

    $reference_changed = 0;
    $bad_reference     = 0;
    $bad_citation      = 0;

    my $log_file = new FileHandle;
    if ( !open( $log_file, "<$log_name" ) ) {
        return 0;
    }
    if ($log_file_binary) { binmode $log_file; }

    # Collect lines of log file
    my @lines = ();
    while (<$log_file>) {

        # Could use chomp here, but that fails if there is a mismatch
        #    between the end-of-line sequence used by latex and that
        #    used by perl.  (Notably a problem with MSWin latex and
        #    cygwin perl!)
        s/[\n\r]*$//;

        # Handle wrapped lines:
        # They are lines brutally broken at exactly $log_wrap chars
        #    excluding line-end.  Sometimes a line $log_wrap chars
        #    long is an ordinary line, sometimes it is part of a line
        #    that was wrapped.  To handle all cases, I keep both
        #    options open by putting the line into @lines before
        #    and after appending the next line:
        my $len = length($_);
        while ( ( $len == $log_wrap ) && !eof($log_file) ) {
            push @lines, $_;
            my $extra = <$log_file>;
            $extra =~ s/[\n\r]*$//;
            $len = length($extra);
            $_ .= $extra;
        }
        push @lines, $_;
    }
    close $log_file;

    push @lines, ""; # Blank line to terminate.  So multiline blocks
                     # are always terminated by non-block line, rather than eof.

    my $line = 0;

    # For parsing multiple line blocks of info
    my $current_pkg      = "";    # non-empty string for package name, if in
                                  # middle of parsing multi-line block of form:
                                  #       Package name ....
                                  #       (name) ...
                                  #       ...
    my $block_type       = "";    # Specify information in such a block
    my $delegated_source = "";    # If it is a file conversion, specify source
    my $delegated_output = "";    #    and output file.  (Don't put in
                                  #    data structure until block is ended.)
    my %new_conversions  = ();
    my @retries          = ();
  LINE:

    while ( ( $line <= $#lines ) || ( $#retries > -1 ) ) {
        if ( $#retries > -1 ) {
            $_ = pop @retries;
        }
        else {
            $_ = $lines[$line];
            $line++;
        }
        if ( /^! pdfTeX warning/ || /^pdfTeX warning/ ) {

            # This kind of warning is produced by some versions of pdftex
            # or produced by my reparse of warnings from other
            # versions.
            next;
        }
        elsif (/^(.+)(pdfTeX warning.*)$/) {

            # Line contains a pdfTeX warnings that may have been
            # inserted directly after other material without an
            # intervening new line.  I think pdfTeX always inserts a
            # newline after the warning.  (From examination of source
            # code.)
            push @retries, $1;

            # But continue parsing the original line, in case it was a
            # misparse, e.g., of a filename ending in 'pdfTeX';
        }
        if ( $line == 1 ) {
            if (/^This is /) {

                # First line OK
                next LINE;
            }
            else {
                warn "$My_name: Error on first line of '$log_name'.\n"
                  . "This is apparently not a TeX log file.  ",
                  "The first line is:\n$_\n";
                $failure = 1;
                $failure_msg =
                  "Log file '$log_name' appears to have wrong format.";
                return 0;
            }
        }
        if ($block_type) {

            # In middle of parsing block
            if (/^\($current_pkg\)/) {

                # Block continues
                if ( ( $block_type eq 'conversion' )
                    && /^\($current_pkg\)\s+Output file: <([^>]+)>/ )
                {
                    $delegated_output = normalize_clean_filename($1);
                }
                next LINE;
            }

            # Block has ended.
            if ( $block_type eq 'conversion' ) {
                $new_conversions{$delegated_source} = $delegated_output;
            }
            $current_pkg = $block_type = $delegated_source =
              $delegated_output = "";

            # Then process current line
        }

        # Check for changed references, bad references and bad citations:
        if (/Rerun to get/) {
            warn "$My_name: References changed.\n" if !$silent;
            $reference_changed = 1;
        }
        if (/LaTeX Warning: (Reference[^\001]*undefined)./) {
            warn "$My_name: $1 \n" unless $silent;
            $bad_reference++;
        }
        if (/LaTeX Warning: (Citation[^\001]*undefined)./) {
            warn "$My_name: $1 \n" unless $silent;
            $bad_citation++;
        }
        if (/Package natbib Warning: (Citation[^\001]*undefined)./) {
            warn "$My_name: $1 \n" unless $silent;
            $bad_citation++;
        }
        if (/^Document Class: /) {

            # Class sign-on line
            next LINE;
        }
        if (/^\(Font\)/) {

            # Font info line
            next LINE;
        }
        if (/^No pages of output\./) {
            $primary_out = '';
            warn "$My_name: Log file says no output from latex\n";
            next LINE;
        }
        if (/^Output written on\s+(.*)\s+\(\d+\s+page/) {
            $primary_out = normalize_clean_filename($1);
            warn "$My_name: Log file says output to '$primary_out'\n"
              unless $silent;
            next LINE;
        }
        if (   /^Overfull /
            || /^Underfull /
            || /^or enter new name\. \(Default extension: .*\)/
            || /^\*\*\* \(cannot \\read from terminal in nonstop modes\)/ )
        {
            # Latex error/warning, etc.
            next LINE;
        }
        if (/^\\openout\d+\s*=\s*\`([^\']+)\'\.$/) {

            #  When (pdf)latex is run with an -output-directory
            #    or an -aux_directory, the file name does not contain
            #    the output path; fix this, after removing quotes:
            $generated_log{ normalize_force_directory( $aux_dir1, $1 ) } = 1;
            next LINE;
        }

        # Test for conversion produced by package:
        if (/^Package (\S+) Info: Source file: <([^>]+)>/) {

            # Info. produced by epstopdf (and possibly others)
            #    about file conversion
            $current_pkg      = normalize_clean_filename($1);
            $delegated_source = normalize_clean_filename($2);
            $block_type       = 'conversion';
            next LINE;
        }

      #    Test for writing of index file.  The precise format of the message
      #    depends on which package (makeidx.sty , multind.sty or index.sty) and
      #    which version writes the message.
        if (/Writing index file (.*)$/) {
            my $idx_file = '';
            if (/^Writing index file (.*)$/) {

                # From makeidx.sty or multind.sty
                $idx_file = $1;
            }
            elsif (/^index\.sty> Writing index file (.*)$/) {

                # From old versions of index.sty
                $idx_file = $1;
            }
            elsif (/^Package \S* Info: Writing index file (.*) on input line/) {

                # From new versions of index.sty
                $idx_file = $1;
            }
            else {
                warn "$My_name: Message indicates index file was written\n",
                  "  ==> but I do not know how to understand it: <==\n",
                  "  '$_'\n";
                next LINE;
            }

            # Typically, there is trailing space, not part of filename:
            $idx_file =~ s/\s*$//;

            #  When (pdf)latex is run with an -output-directory
            #    or an -aux_directory, the file name does not contain
            #    the output path; fix this, after removing quotes:
            $idx_file = normalize_force_directory( $aux_dir1, $idx_file );
            my ( $idx_base, $idx_path, $idx_ext ) = fileparseA($idx_file);
            $idx_base = $idx_path . $idx_base;
            $idx_file = $idx_base . $idx_ext;
            if ( $idx_ext eq '.idx' ) {
                warn "$My_name: Index file '$idx_file' was written\n"
                  unless $silent;
                $idx_files{$idx_file} = [ "$idx_base.ind", $idx_base ];
            }
            elsif ( exists $cusdep_from{$idx_ext} ) {
                if ( !$silent ) {
                    warn "$My_name: Index file '$idx_file' was written\n";
                    warn "   Cusdep '$cusdep_from{$idx_ext}' should be used\n";
                }

                # No action needed here
            }
            else {
                warn "$My_name: Index file '$idx_file' written\n",
"  ==> but it has an extension I do not know how to handle <==\n";
            }

            next LINE;
        }
        if (/^No file (.*?\.bbl)./) {

            #  When (pdf)latex is run with an -output-directory
            #    or an -aux_directory, the file name does not contain
            #    the output path; fix this, after removing quotes:
            my $bbl_file = normalize_force_directory( $aux_dir1, $1 );
            warn "$My_name: Non-existent bbl file '$bbl_file'\n $_\n";
            $dependents{$bbl_file} = 0;
            push @bbl_files, $bbl_file;
            next LINE;
        }
        foreach my $pattern (@file_not_found) {
            if (/$pattern/) {
                my $file = clean_filename($1);
                warn "$My_name: Missing input file: '$file' from line\n  '$_'\n"
                  unless $silent;
                $dependents{ normalize_filename($file) } = 0;
                my $file1 = $file;
                if ($aux_dir) {

                    # Allow for the possibility that latex generated
                    # a file in $aux_dir, from which the missing file can
                    # be created by a cusdep (or other) rule that puts
                    # the result in $out_dir.  If the announced missing file
                    # has no path, then it would be effectively a missing
                    # file in $aux_dir, with a path.  So give this alternate
                    # location.
                    my $file1 = normalize_force_directory( $aux_dir1, $file );
                    $dependents{$file1} = 0;
                }
                next LINE;
            }
        }
        if (/^File: (.+) Graphic file \(type /) {

            # First line of message from includegraphics/x
            $dependents{ normalize_clean_filename($1) } = 1;
            next LINE;
        }

        # Now test for generic lines to ignore, only after special cases!
        if (/^File: /) {

            # Package sign-on line. Includegraphics/x also produces a line
            # with this signature, but I've already handled it.
            next LINE;
        }
        if (/^Package: /) {

            # Package sign-on line
            next LINE;
        }
        if (/^\! LaTeX Error: /) {
            next LINE;
        }
      INCLUDE_CANDIDATE:
        while (/\((.*$)/) {

          # Filename found by
          # '(', then filename, then terminator.
          # Terminators: obvious candidates: ')':  end of reading file
          #                                  '(':  beginning of next file
          #                                  ' ':  space is an obvious separator
          #                                  ' [': start of page: latex
          #                                        and pdflatex put a
          #                                        space before the '['
          #                                  '[':  start of config file
          #                                        in pdflatex, after
          #                                        basefilename.
          #                                  '{':  some kind of grouping
          # Problem:
          #   All or almost all special characters are allowed in
          #   filenames under some OS, notably UNIX.  Luckily most cases
          #   are rare, if only because the special characters need
          #   escaping.  BUT 2 important cases are characters that are
          #   natural punctuation
          #   Under MSWin, spaces are common (e.g., "C:\Program Files")
          #   Under VAX/VMS, '[' delimits directory names.  This is
          #   tricky to handle.  But I think few users use this OS
          #   anymore.
          #
          # Solution: use ' [', but not '[' as first try at delimiter.
          # Then if candidate filename is of form 'name1[name2]', then
          #   try splitting it.  If 'name1' and/or 'name2' exists, put
          #   it/them in list, else just put 'name1[name2]' in list.
          # So form of filename is now:
          #  '(',
          # then any number of characters that are NOT ')', '(', or '{'
          #   (these form the filename);
          # then ' [', or ' (', or ')', or end-of-string.
          # That fails for pdflatex
          # In log file:
          #   '(' => start of reading of file, followed by filename
          #   ')' => end of reading of file
          #   '[' => start of page (normally preceeded by space)
          # Remember:
          #    filename (on VAX/VMS) may include '[' and ']' (directory
          #             separators)
          #    filenames (on MS-Win) commonly include space.
          #    filenames on UNIX can included space.
          #    Miktex quotes filenames
          #    But web2c doesn't.  Then
          #       (string  message
          #    is ambiguous: is the filename "string" or "string message".
          #    Allow both as candidates, since user filenames with spaces
          #    are rare.  System filenames with spaces are common, but
          #    they are normally followed by a newline rather than messages.

            # First step: replace $_ by whole of line after the '('
            #             Thus $_ is putative filename followed by other stuff.
            $_ = $1;

            # Array of new candidate include files; sometimes more than one.
            my @new_includes = ();
            my $quoted       = 0;
            if (/^\"([^\"]+)\"/) {

                # Quoted file name, as from MikTeX
                $quoted = 1;
            }
            elsif (/^([^\(^\)]*?)\s+[\[\{\<]/) {

                # Terminator: space then '[' or '{' or '<'
                # Use *? in condition: to pick up first ' [' (etc)
                # as terminator
            }
            elsif (/^([^\(^\)]*)\s+(?=\()/) {

                # Terminator is ' (', but '(' isn't in matched string,
                # so we keep the '(' ready for the next match
            }
            elsif (/^([^\(^\)]*)(\))/) {

                # Terminator is ')'
            }
            else {
                #Terminator is end-of-string
            }
            $_ = $';    # Put $_ equal to the unmatched tail of string '
            my $include_candidate = $1;
            $include_candidate =~ s/\s*$//;    # Remove trailing space.
            if ( !$quoted && ( $include_candidate =~ /(\S+)\s/ ) ) {

                # Non-space-containing filename-candidate
                # followed by space followed by message
                # (Common)
                push @new_includes, $1;
            }
            if ( $include_candidate eq "[]" ) {

                # Part of overfull hbox message
                next INCLUDE_CANDIDATE;
            }
            if ( $include_candidate =~ /^\\/ ) {

                # Part of font message
                next INCLUDE_CANDIDATE;
            }

            # Remove quotes around filename, as for MikTeX.  I've already
            # treated this as a special case.  For safety check here:
            $include_candidate =~ s/^\"(.*)\"$/$1/;

            push @new_includes, $include_candidate;
            if ( $include_candidate =~ /^(.+)\[([^\]]+)\]$/ ) {

                # Construct of form 'file1[file2]', as produced by pdflatex
                if ( -e $1 ) {

                    # If the first component exists, we probably have the
                    #   pdflatex form
                    push @new_includes, $1, $2;
                }
                else {
                    # We have something else.
                    # So leave the original candidate in the list
                }
            }
          INCLUDE_NAME:
            foreach my $include_name (@new_includes) {
                $include_name = normalize_filename($include_name);
                my ( $base, $path, $ext ) = fileparseB($include_name);
                if ( ( $path eq './' ) || ( $path eq '.\\' ) ) {
                    $include_name = $base . $ext;
                }
                if ( $include_name !~ m'[/|\\]' ) {

                    # Filename does not include a path character
                    # High potential for misparsed line
                    $dependents{$include_name} = 2;
                }
                else {
                    $dependents{$include_name} = 3;
                }
                if ( $ext eq '.bbl' ) {
                    warn "$My_name: Found input bbl file '$include_name'\n"
                      unless $silent;
                    push @bbl_files, $include_name;
                }
            }    # INCLUDE_NAME
        }    # INCLUDE_CANDIDATE
    }    # LINE

    # Default includes are always definitive:
    foreach (@default_includes) { $dependents{$_} = 4; }

    ###print "New parse: \n";
    ###foreach (sort keys %dependents) { print "  '$_': $dependents{$_}\n"; }

    my @misparsed = ();
    my @missing   = ();
    my @not_found = ();
  CANDIDATE:
    foreach my $candidate ( keys %dependents ) {
        my $code = $dependents{$candidate};
        if ( -d $candidate ) {

            #  If $candidate is directory, it was presumably found from a
            #     mis-parse, so remove it from the list.  (Misparse can
            #     arise, for example from a mismatch of latexmk's $log_wrap
            #     value and texmf.cnf value of max_print_line.)
            delete $dependents{$candidate};
        }
        elsif ( -e $candidate ) {
            if ( exists $generated_log{$candidate} ) {
                $dependents{$candidate} = 6;
            }
            elsif ( $code == 0 ) {
                $dependents{$candidate} = 5;
            }
            else {
                $dependents{$candidate} = 4;
            }
        }
        elsif ( $code == 1 ) {

            # Graphics file that is supposed to have been read.
            # Candidate name is as given in source file, not as path
            #   to actual file.
            # We have already tested that file doesn't exist, as given.
            #   so use kpsewhich.
            # If the file still is not found, assume non-existent;
            my @kpse_result = kpsewhich($candidate);
            if ( $#kpse_result > -1 ) {
                delete $dependents{$candidate};
                $dependents{ $kpse_result[0] } = 4;
                next CANDIDATE;
            }
            else {
                push @not_found, $candidate;
            }
        }
        elsif ( $code == 2 ) {

            # Candidate is from '(...' construct in log file, for input file
            #    which should include pathname if valid input file.
            # Name does not have pathname-characteristic character (hence
            #    $code==2.
            # We get here if candidate file does not exist with given name
            # Almost surely result of a misparsed line in log file.
            delete $dependents{$candidate};
            push @misparse, $candidate;
        }
        elsif ( $code == 3 ) {

            # Candidate is from '(...' construct in log file, for input file
            #    which should include pathname if valid input file.
            # Name does have pathname-characteristic character (hence
            #    $code==3.
            # But we get here only if candidate file does not exist with
            # given name.
            # Almost surely result of a misparsed line in log file.
            # But with lower probability than $code == 2
            delete $dependents{$candidate};
            push @misparse, $candidate;
        }
        elsif ( $code == 0 ) {
            my ( $base, $path, $ext ) = fileparseA($candidate);
            $ext =~ s/^\.//;
            if ( ( $ext eq '' ) && ( -e "$path$base.tex" ) ) {

                # I don't think the old version was correct.
                # If the missing-file report was of a bare
                #    extensionless file, and a corresponding .tex file
                #    exists, then the missing file does not correspond
                #    to the missing file, unless the .tex file was
                #    created during the run.
                # OLD $dependents{"$path$base.tex"} = 4;
                # OLD delete $dependents{$candidate};
                # NEW:
                $dependents{"$path$base.tex"} = 4;
            }
            push @missing, $candidate;
        }
    }
  CANDIDATE_PAIR:
    foreach my $delegated_source ( keys %new_conversions ) {
        my $delegated_output = $new_conversions{$delegated_source};
        my $rule             = "Delegated $delegated_source, $delegated_output";

        # N.B. $delegated_source eq '' means the output file
        #      was created without a named input file.
        foreach my $candidate ( $delegated_source, $delegated_output ) {
            if ( !-e $candidate ) {

                # The file might be somewhere that can be found
                #   in the search path of kpathsea:
                my @kpse_result = kpsewhich( $candidate, );
                if ( $#kpse_result > -1 ) {
                    $candidate = $kpse_result[0];
                }
            }
        }
        if (   ( ( -e $delegated_source ) || ( $delegated_source eq '' ) )
            && ( -e $delegated_output ) )
        {
            $conversions{$delegated_output} = $delegated_source;
            $dependents{$delegated_output}  = 7;
            if ($delegated_source) {
                $dependents{$delegated_source} = 4;
            }
        }
        elsif ( !$silent ) {
            print "Logfile claimed conversion from '$delegated_source' ",
              "to '$delegated_output'.  But:\n";
            if ( !-e $delegated_output ) {
                print "   Output file does not exist\n";
            }
            if ( ( $delegated_source ne '' ) && ( !-e $delegated_source ) ) {
                print "   Input file does not exist\n";
            }
        }
    }

    if ($diagnostics) {
        @misparse  = uniqs(@misparse);
        @missing   = uniqs(@missing);
        @not_found = uniqs(@not_found);
        my @dependents = sort( keys %dependents );

        my $dependents = $#dependents + 1;
        my $misparse   = $#misparse + 1;
        my $missing    = $#missing + 1;
        my $not_found  = $#not_found + 1;
        my $exist      = $dependents - $not_found - $missing;
        my $bbl        = $#bbl_files + 1;

        print "$dependents dependent files detected, of which ",
          "$exist exist, $not_found were not found,\n",
          "   and $missing appear not to exist.\n";
        print "Dependents:\n";
        foreach (@dependents) {
            print "   '$_' ";
            if ( $dependents{$_} == 6 ) { print " written by (pdf)latex"; }
            if ( $dependents{$_} == 7 ) { print " converted by (pdf)latex"; }
            print "\n";
        }
        if ( $not_found > 0 ) {
            print "Not found:\n";
            foreach (@not_found) { print "   $_\n"; }
        }
        if ( $missing > 0 ) {
            print "Not existent:\n";
            foreach (@missing) { print "   $_\n"; }
        }
        if ( $bbl > 0 ) {
            print "Input bbl files:\n";
            foreach (@bbl_files) { print "   $_\n"; }
        }

        if ( $misparse > 0 ) {
            print
"Possible input files, perhaps from misunderstood lines in .log file:\n";
            foreach (@misparse) { print "   $_\n"; }
        }
    }
    return 1;
}    #END parse_log

#************************************************************

sub parse_fls {
    my ( $fls_name, $Pinputs, $Poutputs, $Pfirst_read_after_write ) = @_;
    %$Pinputs = %$Poutputs = %$Pfirst_read_after_write = ();
    my $fls_file = new FileHandle;

    # Make a note of current working directory
    # I'll update it from the fls file later
    # Currently I don't use this, but it would be useful to use
    # this when testing prefix for cwd in a filename, by
    # giving (pdf)latex's best view of the cwd.  Note that the
    # value given by the cwd() function may be mangled, e.g., by cygwin
    # compared with native MSWin32.
    my $cwd = good_cwd();
    if ( !open( $fls_file, "<$fls_name" ) ) {
        return 1;
    }
    foreach $_ (<$fls_file>) {

    # Remove trailing CR and LF. Thus we get correct behavior when an fls file
    #  is produced by MS-Windows program (e.g., in MiKTeX) with CRLF line ends,
    #  but is read by Unix Perl (which treats LF as line end, and preserves CRLF
    #  in read-in lines):
        $_ =~ s/[\n\r]*$//;
        if (/^\s*PWD\s+(.*)$/) {
            $cwd = $1;
        }
        elsif (/^\s*INPUT\s+(.*)$/) {

# Take precautions against aliasing of foo, ./foo and other possibilities for cwd.
            my $file = normalize_filename($1);
            if ( ( exists $$Poutputs{$file} ) && ( !exists $$Pinputs{$file} ) )
            {
                $$Pfirst_read_after_write{$file} = 1;
            }
            $$Pinputs{$file} = 1;
        }
        elsif (/^\s*OUTPUT\s+(.*)$/) {

# Take precautions against aliasing of foo, ./foo and other possibilities for cwd.
            $$Poutputs{ normalize_filename($1) } = 1;
        }
    }
    close($fls_file);
    return 0;
}    #END parse_fls

#************************************************************

sub clean_filename {

    # Convert quoted filename as found in log file to filename without quotes
    # Allows arbitrarily embedded double-quoted substrings, includes the
    # cases
    # 1. `"string".ext', which arises e.g., from \jobname.bbl:
    #    when the base filename contains spaces, \jobname has quotes.
    #    and from \includegraphics with basename specified.
    #    Also deals with filenames written by asymptote.sty
    # 2. Or "string.ext" from \includegraphcs with basename and ext specified.
    #    and from MiKTeX logfile for input files with spaces.
    # Doubled quotes (e.g., A""B) don't get converted.
    # Neither do unmatched quotes.
    my $filename = $_[0];
    while ( $filename =~ s/^([^\"]*)\"([^\"]+)\"(.*)$/$1$2$3/ ) { }
    return $filename;
}

# ------------------------------

sub normalize_filename {

    # Remove various forms for cwd at start of filename.
    # Convert to have directory separator = '/' only
    my $file  = $_[0];
    my $file1 = $file;        # Saved original value
    my $cwd   = good_cwd();

    # Normalize files to use / to separate directory components:
    # (Note both / and \ are allowed under MSWin.)
    $cwd =~ s(\\)(/)g;
    $file =~ s(\\)(/)g;

    # Remove current directory string:
    $file =~ s(^\./)();
    $file =~ s(^$cwd/)();

    return $file;
}

# ------------------------------

sub normalize_clean_filename {

# Remove quotes around filename --- see clean_filename --- as from log file.
# Then remove any string for cwd, and convert to use '/' for directory separator,
# (and any other standardization) done by normalize_filename.
    return normalize_filename( clean_filename( $_[0] ) );
}

#************************************************************

sub OS_preferred_filename {

    # Usage: OS_preferred_filename(name)
    # Returns filename with directory separator '/' converted
    # to preferred conventions for current OS.
    # Currently implemented: only '\' for MSWin32
    my $file = $_[0];
    if ( $^O eq 'MSWin32' ) {
        $file =~ s(/)(\\)g;
    }
    return $file;
}

#************************************************************

sub parse_aux {

#Usage: parse_aux( $aux_file, \@new_bib_files, \@new_aux_files, \@new_bst_files )
# Parse aux_file (recursively) for bib files, and bst files.
# If can't open aux file, then
#    Return 0 and leave @new_bib_files empty
# Else set @new_bib_files from information in the aux files
#    And:
#    Return 1 if no problems
#    Return 2 with @new_bib_files empty if there are no \bibdata
#      lines.
#    Return 3 if I couldn't locate all the bib_files
# Set @new_aux_files to aux files parsed

    my $aux_file = $_[0];
    local $Pbib_files = $_[1];
    local $Paux_files = $_[2];
    local $Pbst_files = $_[3];

    @$Pbib_files = ();
    @$Pbst_files = ();
    @$Paux_files = ();

    parse_aux1($aux_file);
    if ( $#{$Paux_files} < 0 ) {
        return 0;
    }
    @$Pbib_files = uniqs(@$Pbib_files);
    @$Pbst_files = uniqs(@$Pbst_files);

    if ( $#{$Pbib_files} == -1 ) {
        warn "$My_name: No .bib files listed in .aux file '$aux_file' \n",
          return 2;
    }
    my @not_found =
      &find_file_list1( $Pbib_files, $Pbib_files, '.bib', \@BIBINPUTS );
    @$Pbib_files = uniqs(@$Pbib_files);
    &find_file_list1( $Pbst_files, $Pbst_files, '.bst' );
    @$Pbst_files = uniqs(@$Pbst_files);
    if ( $#not_found < 0 ) {
        warn "$My_name: Found bibliography file(s) [@$Pbib_files]\n"
          unless $silent;
    }
    else {
        show_array( "$My_name: Failed to find one or more bibliography files ",
            @not_found );
        if ($force_mode) {
            warn "==== Force_mode is on, so I will continue.  ",
              "But there may be problems ===\n";
        }
        else {
            #$failure = -1;
            #$failure_msg = 'Failed to find one or more bib files';
            #warn "$My_name: Failed to find one or more bib files\n";
        }
        return 3;
    }
    return 1;
}    #END parse_aux

#************************************************************

sub parse_aux1

  # Parse single aux file for bib files.
  # Usage: &parse_aux1( aux_file_name )
  #   Append newly found bib_filenames in @$Pbib_files, already
  #        initialized/in use.
  #   Append aux_file_name to @$Paux_files if aux file opened
  #   Recursively check \@input aux files
  #   Return 1 if success in opening $aux_file_name and parsing it
  #   Return 0 if fail to open it
{
    my $aux_file = $_[0];
    my $aux_fh   = new FileHandle;
    if ( !open( $aux_fh, $aux_file ) ) {
        warn "$My_name: Couldn't find aux file '$aux_file'\n";
        return 0;
    }
    push @$Paux_files, $aux_file;
  AUX_LINE:
    while (<$aux_fh>) {
        if (/^\\bibdata\{(.*)\}/) {

            # \\bibdata{comma_separated_list_of_bib_file_names}
            # (Without the '.bib' extension)
            push( @$Pbib_files, split /,/, $1 );
        }
        elsif (/^\\bibstyle\{(.*)\}/) {

            # \\bibstyle{bst_file_name}
            # (Without the '.bst' extension)
            push( @$Pbst_files, $1 );
        }
        elsif (/^\\\@input\{(.*)\}/) {

            # \\@input{next_aux_file_name}
            &parse_aux1( $aux_dir1 . $1 );
        }
    }
    close($aux_fh);
    return 1;
}    #END parse_aux1

#************************************************************

#************************************************************
#************************************************************
#************************************************************

#   Manipulations of main file database:

#************************************************************

sub fdb_get {

    # Call: fdb_get(filename [, check_time])
    # Returns an array (time, size, md5) for the current state of the
    #    named file.
    # The optional argument check_time is either the run_time of some command
    #    that may have changed the file or the last time the file was checked
    #    for changes --- see below.
    # For non-existent file, deletes its entry in fdb_current,
    #    and returns (0,-1,0)
    # As an optimization, the md5 value is taken from the cache in
    #    fdb_current, if the time and size stamp indicate that the
    #    file has not changed.
    # The md5 value is recalculated if
    #    the current filetime differs from the cached value:
    #               file has been written
    #    the current filesize differs from the cached value:
    #               file has definitely changed
    # But the file can also be rewritten without change in filetime when
    #    file processing happens within the 1-second granularity of the
    #    timestamp (notably for aux files from latex on a short source file).
    # The only case that concerns us is when the file is an input to a program
    #    at some runtime t, the file is rewritten later by the same or another
    #    program, with timestamp t, and when the initial file also has
    #    timestamp t.
    # A test is applied for this situation if the check_time argument is
    #    supplied and is nonzero.

    my ( $file, $check_time ) = @_;
    if ( !defined $check_time ) { $check_time = 0; }
    my ( $new_time, $new_size ) = get_time_size($file);
    my @nofile = ( 0, -1, 0 );    # What we use for initializing
                                  # a new entry in fdb or flagging
                                  # non-existent file
    if ( $new_size < 0 ) {
        delete $fdb_current{$file};
        return @nofile;
    }
    my $recalculate_md5 = 0;
    if ( !exists $fdb_current{$file} ) {

        # Ensure we have a record.
        $fdb_current{$file} = [@nofile];
        $recalculate_md5 = 1;
    }
    my $file_data = $fdb_current{$file};
    my ( $time, $size, $md5 ) = @$file_data;

    if (   ( $new_time != $time )
        || ( $new_size != $size )
        || ( $check_time && ( $check_time == $time ) ) )
    {
        # Only force recalculation of md5 if time or size changed.
        # However, the physical file time may have changed without
        #   affecting the value of the time coded in $time, because
        #   times are computed with a 1-second granularity.
        #   The only case to treat specially is where the file was created,
        #   then used by the current rule, and then rewritten, all within
        #   the granularity size, otherwise the value of the reported file
        #   time changed, and we've handled it.  But we may have already
        #   checked this at an earlier time than the current check.  So the
        #   only dangerous case is where the file time equals a check_time,
        #   which is either the run_time of the command or the time of a
        #   previous check.
        # Else we assume file is really unchanged.
        $recalculate_md5 = 1;
    }
    if ($recalculate_md5) {

#warn "--------- RECALC MD5: $rule $file: (N,O,R,C) \n  = $new_time, $time, $$Prun_time, $check_time\n";
        @$file_data = ( $new_time, $new_size, get_checksum_md5($file) );
    }
    return @$file_data;
}    #END fdb_get

#************************************************************

sub fdb_set {

    # Call: fdb_set(filename, $time, $size, $md5 )
    # Set data in file data cache, i.e., %fdb_current
    my ( $file, $time, $size, $md5 ) = @_;
    if ( !exists $fdb_current{$file} ) {
        $fdb_current{$file} = [ 0, -1, 0 ];
    }
    @{ $fdb_current{$file} } = ( $time, $size, $md5 );
}    #END fdb_set

#************************************************************

sub fdb_show {

    # Displays contents of fdb
    foreach my $file ( sort keys %fdb_current ) {
        print "'$file': @{$fdb_current{$file}}\n";
    }
}    #END fdb_show

#************************************************************
#************************************************************
#************************************************************

# Routines for manipulating rule database

#************************************************************

sub rdb_read {

    # Call: rdb_read( $in_name  )
    # Sets rule database from saved file, in format written by rdb_write.
    # Returns -1 if file could not be read else number of errors.
    # Thus return value on success is 0
    my $in_name   = $_[0];
    my $in_handle = new FileHandle;
    $in_handle->open( $in_name, '<' )
      or return ();
    my $errors   = 0;
    my $state    = -1;    # Values: -1: before start; 0: outside rule;
                          # 1: in source section; 2: in generated file section;
                          # 10: ignored rule
    my $rule     = '';
    my $run_time = 0;
    my $source   = '';
    my $dest     = '';
    my $base     = '';
    local %new_sources =
      ();    # Hash: rule => { file=>[ time, size, md5, fromrule ] }
    my $new_source = undef;    # Reference to hash of sources for current rule
  LINE:

    while (<$in_handle>) {

        # Remove leading and trailing white space.
        s/^\s*//;
        s/\s*$//;
        if ( $state == -1 ) {
            if ( !/^# Fdb version ([\d]+)$/ ) {
                warn
"$My_name: File-database '$in_name' is not of correct format\n";
                return 1;
            }
            if ( $1 > $fdb_ver ) {
                warn
"$My_name: File-database '$in_name' is of too new version, $1 > $fdb_ver\n";
                return 1;
            }
            $state = 0;
        }

        # Ignore blank lines and comments
        if ( /^$/ || /^#/ || /^%/ ) { next LINE; }
        if (/^\[\"([^\"]+)\"\]/) {

            # Start of section
            $rule = $1;
            my $tail = $';    #'  Single quote in comment tricks the parser in
                              # emacs from misparsing an isolated single quote
            $run_time = $check_time = 0;
            $source = $dest = $base = '';
            if ( $tail =~ /^\s*(\S+)\s*$/ ) {
                $run_time = $1;
            }
            elsif ( $tail =~
                /^\s*(\S+)\s+\"([^\"]*)\"\s+\"([^\"]*)\"\s+\"([^\"]*)\"\s*$/ )
            {
                $run_time = $1;
                $source   = $2;
                $dest     = $3;
                $base     = $4;
            }
            elsif ( $tail =~
/^\s*(\S+)\s+\"([^\"]*)\"\s+\"([^\"]*)\"\s+\"([^\"]*)\"\s+(\S+)\s*$/
              )
            {
                $run_time   = $1;
                $source     = $2;
                $dest       = $3;
                $base       = $4;
                $check_time = $5;
            }
            if ( rdb_rule_exists($rule) ) {
                rdb_one_rule(
                    $rule,
                    sub {
                        if ( $$Ptest_kind == 3 ) { $$Ptest_kind = 1; }
                        $$Prun_time   = $run_time;
                        $$Pcheck_time = $check_time;
                    }
                );
            }
            elsif ( $rule =~ /^cusdep\s+(\S+)\s+(\S+)\s+(.+)$/ ) {

                # Create custom dependency
                my $fromext = $1;
                my $toext   = $2;
                my $base    = $3;
                $source = "$base.$fromext";
                $dest   = "$base.$toext";
                my $PAnew_cmd = [ 'do_cusdep', '' ];
                foreach my $dep (@cus_dep_list) {
                    my ( $tryfromext, $trytoext, $must, $func_name ) =
                      split( ' ', $dep );
                    if (   ( $tryfromext eq $fromext )
                        && ( $trytoext eq $toext ) )
                    {
                        $$PAnew_cmd[1] = $func_name;
                    }
                }

                # Set source file as non-existent.
                # If it existed on last run, it will be in later
                #    lines of the fdb file
                rdb_create_rule(
                    $rule, 'cusdep',  '',          $PAnew_cmd,
                    1,     $source,   $dest,       $base,
                    0,     $run_time, $check_time, 1
                );
            }
            elsif ( $rule =~ /^(makeindex|bibtex|biber)\s*(.*)$/ ) {
                my $PA_extra_gen = [];
                my $rule_generic = $1;
                my $int_cmd      = '';
                if ( !$source ) {

                    # If fdb_file was old-style (v. 1)
                    $source = $2;
                    my $path = '';
                    my $ext  = '';
                    ( $base, $path, $ext ) = fileparseA($source);
                    $base = $path . $base;
                    if ( $rule_generic eq 'makeindex' ) {
                        $dest = "$base.ind";
                    }
                    elsif ( $rule_generic eq 'bibtex' ) {
                        $dest   = "$base.bbl";
                        $source = "$base.aux";
                    }
                    elsif ( $rule_generic eq 'biber' ) {
                        $dest   = "$base.bbl";
                        $source = "$base.bcf";
                    }
                }
                if ( $rule =~ /^makeindex/ ) { $PA_extra_gen = ["$base.ilg"]; }
                if ( $rule =~ /^(bibtex|biber)/ ) {
                    $PA_extra_gen = ["$base.blg"];
                }
                if ( $rule =~ /^bibtex/ ) { $int_cmd = "run_bibtex"; }
                warn
                  "$My_name: File-database '$in_name': setting rule '$rule'\n"
                  if $diagnostics;
                my $cmd_type = 'external';
                my $ext_cmd  = ${$rule_generic};
                warn "  Rule kind = '$rule_generic'; ext_cmd = '$ext_cmd';\n",
                  "  int_cmd = '$int_cmd';\n",
                  "  source = '$source'; dest = '$dest'; base = '$base';\n"
                  if $diagnostics;

                # Set source file as non-existent.
                # If it existed on last run, it will be in later
                #    lines of the fdb file
                rdb_create_rule(
                    $rule, $cmd_type, $ext_cmd,    $int_cmd,
                    1,     $source,   $dest,       $base,
                    0,     $run_time, $check_time, 1,
                    $PA_extra_gen
                );
            }
            else {
                warn "$My_name: In file-database '$in_name' rule '$rule'\n",
                  "   is not in use in this session\n"
                  if $diagnostics;
                $new_source = undef;
                $state      = 10;
                next LINE;
            }
            $new_source = $new_sources{$rule} = {};
            $state = 1;    #Reading a section, source part
        }
        elsif ( ( $state <= 0 ) || ( $state >= 3 ) ) {
            next LINE;
        }
        elsif (/^\(source\)/)    { $state = 1; next LINE; }
        elsif (/^\(generated\)/) { $state = 2; next LINE; }
        elsif ( ( $state == 1 )
            && /^\"([^\"]*)\"\s+(\S+)\s+(\S+)\s+(\S+)\s+\"([^\"]*)\"/ )
        {
            # Source file line
            my $file      = $1;
            my $time      = $2;
            my $size      = $3;
            my $md5       = $4;
            my $from_rule = $5;

            #??            print "  --- File '$file'\n";
            if ( $state != 1 ) {
                warn "$My_name: In file-database '$in_name' ",
                  "line $. is outside a section:\n   '$_'\n";
                $errors++;
                next LINE;
            }

            # Set file in database.  But ensure we don't do an unnecessary
            #    fdb_get, which can trigger a new MD5 calculation, which is
            #    lengthy for a big file.  Ininitially flagging the file
            #    as non-existent solves the problem:
            rdb_ensure_file( $rule, $file, undef, 1 );
            rdb_set_file1( $rule, $file, $time, $size, $md5 );
            fdb_set( $file, $time, $size, $md5 );

         # Save the rest of the data, especially the from_fule until we know all
         #   the rules, otherwise the from_rule may not exist.
         # Also we'll have a better chance of looping through files.
            ${$new_source}{$file} = [ $time, $size, $md5, $from_rule ];
        }
        elsif ( ( $state == 2 ) && /^\"([^\"]*)\"/ ) {
            my $file = $1;
            rdb_one_rule( $rule, sub { rdb_add_generated($file); } );
        }
        else {
            warn "$My_name: In file-database '$in_name' ",
              "line $. is of wrong format:\n   '$_'\n";
            $errors++;
            next LINE;
        }
    }
    undef $in_handle;

    # Set cus dependencies.
    &rdb_set_dependents( keys %rule_db );

    #?? Check from_rules exist.

    return $errors;
}    # END rdb_read

#************************************************************

sub rdb_write {

    # Call: rdb_write( $out_name )
    # Writes to the given file name the database of file and rule data
    #   for all rules needed to make final output
    # !!?? Previously was:
    # OLD Writes to the given file name the database of file and rule data
    # OLD   accessible from the primary rules.
    # Returns 1 on success, 0 if file couldn't be opened.
    local $out_name   = $_[0];
    local $out_handle = new FileHandle;
    if ( ( $out_name eq "" ) || ( $out_name eq "-" ) ) {

        # Open STDOUT
        $out_handle->open('>-');
    }
    else {
        $out_handle->open( $out_name, '>' );
    }
    if ( !$out_handle ) { return 0; }

    local %current_primaries = ();    # Hash whose keys are primary rules
         # needed, i.e., known latex-like rules which trigger
         # circular dependencies
    local @pre_primary  = ();    # Array of rules
    local @post_primary = ();    # Array of rules
    local @one_time     = ();    # Array of rules
    &rdb_classify_rules( \%possible_primaries, keys %requested_filerules );

    print $out_handle "# Fdb version $fdb_ver\n";

    # !!??   Rules or rules accessible from primary
    #    my @rules = rdb_accessible( uniq1( keys %possible_primaries )  ) ;
    my @rules =
      rdb_accessible(
        uniq1( keys %possible_primaries, keys %requested_filerules ) );

 # Separate call to sort.  Otherwise rdb_accessible seems to get wrong argument.
    @rules = sort(@rules);
    rdb_for_some(
        \@rules,
        sub {
            # Omit data on a unused and never-run primary rule:
            if (   ( $$Prun_time == 0 )
                && exists( $possible_primaries{$rule} )
                && !exists( $current_primaries{$rule} ) )
            {
                return;
            }
            print $out_handle
"[\"$rule\"] $$Prun_time \"$$Psource\" \"$$Pdest\" \"$$Pbase\" $$Pcheck_time\n";
            rdb_do_files(
                sub {
                    print $out_handle
                      "  \"$file\" $$Ptime $$Psize $$Pmd5 \"$$Pfrom_rule\"\n";
                }
            );
            print $out_handle "  (generated)\n";
            foreach ( keys %$PHdest ) {
                print $out_handle "  \"$_\"\n";
            }
        }
    );
    undef $out_handle;
    return 1;
}    #END rdb_write

#************************************************************

sub rdb_set_latex_deps {

    # Assume rule context.
    # This is intended to be applied only for a primary (LaTeX-like) rule.
    # Set its dependents etc, using information from log, aux, and fls files.
    # Use fls file only if $recorder is set, and the fls file was generated
    # on this run.

    # Rules should only be primary
    if ( $$Pcmd_type ne 'primary' ) {
        warn "\n$My_name: ==========$My_name: Probable BUG======= \n   ",
          "   rdb_set_latex_deps called to set files ",
          "for non-primary rule '$rule'\n\n";
        return;
    }

#??    # We'll prune this by all files determined to be needed for source files.
#??    my %unneeded_source = %$PHsource;

    # Parse log file to find relevant filenames
    # Result in the following variables:
    local %dependents    = ();    # Maps files to status
    local @bbl_files     = ();
    local %idx_files     = ();    # Maps idx_file to (ind_file, base)
    local %generated_log = ();    # Lists generated files found in log file
    local %generated_fls = ();    # Lists generated files found in fls file
    local %source_fls    = ();    # Lists source files found in fls file
    local %first_read_after_write = ();  # Lists source files that are only read
                                         # after being written (so are not true
                                         # source files.
    local $primary_out = $$Pdest;        # output file (dvi or pdf)
    local %conversions = ();             # (pdf)latex-performed conversions.
         # Maps output file created and read by (pdf)latex
         #    to source file of conversion.
         # The following are also returned, but are global, to be used by caller
         # $reference_changed, $bad_reference $bad_citation

    &parse_log;
    my $fls_file = "$aux_dir1$root_filename.fls";
    if ( $recorder && test_gen_file($fls_file) ) {
        parse_fls( $fls_file, \%source_fls, \%generated_fls,
            \%first_read_after_write );
        foreach ( keys %source_fls ) {
            $dependents{$_} = 4;
        }
        foreach ( keys %generated_fls ) {
            $_ = normalize_filename($_);
            rdb_add_generated($_);
            if ( exists( $dependents{$_} ) ) {
                $dependents{$_} = 6;
            }
        }
    }

    # ?? !! Should also deal with .run.xml file

    # Handle result on output file:
    #   1.  Non-existent output file, which is because of no content.
    #         This could either be because the source file has genuinely
    #         no content, or because of a missing input file.  Since a
    #         missing input file might be correctable by a run of some
    #         other program whose running is provoked AFTER a run of
    #         (pdf)latex, we'll set a diagnostic and leave it to the
    #         rdb_make to handle after all circular dependencies are
    #         resolved.
    #   2.  The output file might be of a different kind than expected
    #         (i.e., dvi instead of pdf, or vv).  This could
    #         legitimately occur when the source file (or an invoked
    #         package or class) sets \pdfoutput.
    $missing_dvi_pdf = '';
    if ( $primary_out eq '' ) {
        warn "$My_name: For rule '$rule', no output was made\n";
        $missing_dvi_pdf = $$Pdest;
    }
    elsif ( $primary_out ne $$Pdest ) {
        warn "$My_name: ===For rule '$rule', actual output '$primary_out'\n",
          "       ======appears not to match expected output '$$Pdest'\n";
    }

  IDX_FILE:
    foreach my $idx_file ( keys %idx_files ) {
        my ( $ind_file, $ind_base ) = @{ $idx_files{$idx_file} };
        my $from_rule = "makeindex $idx_file";
        if ( !rdb_rule_exists($from_rule) ) {
            print
              "!!!===Creating rule '$from_rule': '$ind_file' from '$idx_file'\n"
              if ($diagnostics);
            rdb_create_rule(
                $from_rule, 'external', $makeindex, '',
                1,          $idx_file,  $ind_file,  $ind_base,
                1,          0,          0
            );
            print "  ===Source file '$ind_file' for '$rule'\n"
              if ($diagnostics);
            rdb_ensure_file( $rule, $ind_file, $from_rule );
        }

        # Make sure the .ind file is treated as a detected source file;
        # otherwise if the log file has it under a different name (as
        # with MiKTeX which gives full directory information), there
        # will be problems with the clean-up of the rule concerning
        # no-longer-in-use source files:
        $dependents{$ind_file} = 4;
        if ( !-e $ind_file ) {

            # Failure was non-existence of makable file
            # Leave failure issue to other rules.
            $failure = 0;
        }
    }

  BBL_FILE:
    foreach my $bbl_file ( uniqs(@bbl_files) ) {
        my ( $bbl_base, $bbl_path, $bbl_ext ) = fileparseA($bbl_file);
        $bbl_base = $bbl_path . $bbl_base;
        my @new_bib_files = ();
        my @new_aux_files = ();
        my @new_bst_files = ();
        my @biber_source  = ("$bbl_base.bcf");
        my $bib_program   = 'bibtex';
        if ( test_gen_file("$bbl_base.bcf") ) {
            $bib_program = 'biber';
        }
        my $from_rule = "$bib_program $bbl_base";
        print "=======  Dealing with '$from_rule'\n" if ($diagnostics);
        if ( $bib_program eq 'biber' ) {
            check_biber_log( $bbl_base, \@biber_source );

            # Remove OPPOSITE kind of bbl generation:
            rdb_remove_rule("bibtex $bbl_base");
        }
        else {
            parse_aux(
                "$bbl_base.aux", \@new_bib_files,
                \@new_aux_files, \@new_bst_files
            );

            # Remove OPPOSITE kind of bbl generation:
            rdb_remove_rule("biber $bbl_base");
        }
        if ( !rdb_rule_exists($from_rule) ) {
            print "   ===Creating rule '$from_rule'\n" if ($diagnostics);
            if ( $bib_program eq 'biber' ) {
                rdb_create_rule( $from_rule, 'external', $biber, '', 1,
                    "$bbl_base.bcf", $bbl_file, $bbl_base, 1, 0, 0 );
            }
            else {
                rdb_create_rule(
                    $from_rule, 'external',      $bibtex,   'run_bibtex',
                    1,          "$bbl_base.aux", $bbl_file, $bbl_base,
                    1,          0,               0
                );
            }
        }
        local %old_sources = ();
        rdb_one_rule( $from_rule, sub { %old_sources = %$PHsource; } );
        foreach my $source ( @new_bib_files, @new_aux_files, @new_bst_files,
            @biber_source )
        {
            print "  === Source file '$source' for '$from_rule'\n"
              if ($diagnostics);
            rdb_ensure_file( $from_rule, $source );
            delete $old_sources{$source};
        }
        if ($diagnostics) {
            foreach ( keys %old_sources ) {
                print
"Removing no-longer-needed dependent '$_' from rule '$from_rule'\n";
            }
        }
        rdb_remove_files( $from_rule, keys %old_sources );
        print "  ===Source file '$bbl_file' for '$rule'\n"
          if ($diagnostics);
        rdb_ensure_file( $rule, $bbl_file, $from_rule );
        if ( !-e $bbl_file ) {

            # Failure was non-existence of makable file
            # Leave failure issue to other rules.
            $failure = 0;
        }
    }

  NEW_SOURCE:
    foreach my $new_source ( keys %dependents, keys %conversions ) {
        print "  ===Source file for rule '$rule': '$new_source'\n"
          if ($diagnostics);
        if (   ( $dependents{$new_source} == 5 )
            || ( $dependents{$new_source} == 6 ) )
        {
            # (a) File was detected in "No file..." line in log file.
            #     Typically file was searched for early in run of
            #     latex/pdflatex, was not found, and then was written
            #     later in run.
            # or (b) File was written during run.
            # In both cases, if file doesn't already exist in database, we
            #    don't know its previous status.  Therefore we tell
            #    rdb_ensure_file that if it needs to add the file to its
            #    database, then the previous version of the file should be
            #    treated as non-existent, to ensure another run is forced.
            rdb_ensure_file( $rule, $new_source, undef, 1 );
        }
        elsif ( $dependents{$new_source} == 7 ) {

            # File was result of conversion by (pdf)latex.
            my $cnv_source = $conversions{$new_source};
            rdb_ensure_file( $rule, $new_source );
            if ($cnv_source) {

                # Conversion from $cnv_source to $new_source
                #   implies that effectively $cnv_source is a source
                #   of the (pdf)latex run.
                rdb_ensure_file( $rule, $cnv_source );
            }

            # Flag that changes of the generated file during a run
            #    do not require a rerun:
            rdb_one_file( $new_source, sub { $$Pcorrect_after_primary = 1; } );
        }
        else {
            # But we don't need special precautions for ordinary user files
            #    (or for files that are generated outside of latex/pdflatex).
            rdb_ensure_file( $rule, $new_source );
        }
        if (   ( $dependents{$new_source} == 6 )
            || ( $dependents{$new_source} == 7 ) )
        {
            rdb_add_generated($new_source);
        }
    }

    my @more_sources = &rdb_set_dependents($rule);
    my $num_new      = $#more_sources + 1;
    foreach (@more_sources) {
        $dependents{$_} = 4;
        if ( !-e $_ ) {

            # Failure was non-existence of makable file
            # Leave failure issue to other rules.
            $failure   = 0;
            $$Pchanged = 1;    # New files can be made.  Ignore error.
        }
    }
    foreach ( keys %first_read_after_write ) {
        delete $dependents{$_};
    }
    if ($diagnostics) {
        if ( $num_new > 0 ) {
            print "$num_new new source files for rule '$rule':\n";
            foreach (@more_sources) { print "   '$_'\n"; }
        }
        else {
            print "No new source files for rule '$rule':\n";
        }
        my @first_read_after_write = sort keys %first_read_after_write;
        if ( $#first_read_after_write >= 0 ) {
            print "The following files were only read after being written:\n";
            foreach (@first_read_after_write) {
                print "   '$_'\n";
            }
        }
    }
    my @files_not_needed = ();
    foreach ( keys %$PHsource ) {
        if ( !exists $dependents{$_} ) {
            print "Removing no-longer-needed dependent '$_' from rule '$rule'\n"
              if $diagnostics;
            push @files_not_needed, $_;
        }
    }
    rdb_remove_files( $rule, @files_not_needed );

}    # END rdb_set_latex_deps

#************************************************************

sub test_gen_file {

    # Usage: test_gen_file( filename )
    # Tests whether the file was generated during a run of (pdf)latex.
    # Used by rdb_set_latex_deps.
    # Assumes context for primary rule, and that %generated_log is set.
    # The generated_log test works with TeXLive's tex, because it puts
    #   \openout lines in log file.
    # But it doesn't work with MikTeX, which does NOT put \openout lines
    #   in log file.
    # So we have a back up test: bcf file exists and is at least as new as
    #   the run time (so it should have been generated on the current run).
    my $file = shift;
    return exists $generated_log{$file}
      || ( -e $file && ( get_mtime($file) >= $$Prun_time ) );
}

#************************************************************

sub rdb_find_new_files {

    # Call: rdb_find_new_files
    # Assumes rule context for primary rule.
    # Deal with files which were missing and for which a method
    # of finding them has become available:
    #   (a) A newly available source file for a custom dependency.
    #   (b) When there was no extension, a file with appropriate
    #       extension
    #   (c) When there was no extension, and a newly available source
    #       file for a custom dependency can make it.

    my %new_includes = ();

  MISSING_FILE:
    foreach my $missing ( keys %$PHsource ) {
        next if ( $$PHsource{$missing} != 0 );
        my ( $base, $path, $ext ) = fileparseA($missing);
        $ext =~ s/^\.//;
        if ( -e "$missing.tex" ) {
            $new_includes{"$missing.tex"} = 1;
        }
        if ( -e $missing ) {
            $new_includes{$missing} = 1;
        }
        if ( $ext ne "" ) {
            foreach my $dep (@cus_dep_list) {
                my ( $fromext, $toext ) = split( ' ', $dep );
                if (   ( "$ext" eq "$toext" )
                    && ( -e "$path$base.$fromext" ) )
                {
                    # Source file for the missing file exists
                    # So we have a real include file, and it will be made
                    # next time by rdb_set_dependents
                    $new_includes{$missing} = 1;
                }
                else {
                    # no point testing the $toext if the file doesn't exist.
                }
                next MISSING_FILE;
            }
        }
        else {
            # $_ doesn't exist, $_.tex doesn't exist,
            # and $_ doesn't have an extension
            foreach my $dep (@cus_dep_list) {
                my ( $fromext, $toext ) = split( ' ', $dep );
                if ( -e "$path$base.$fromext" ) {

                    # Source file for the missing file exists
                    # So we have a real include file, and it will be made
                    # next time by &rdb__dependents
                    $new_includes{"$path$base.$toext"} = 1;

                    #                  next MISSING_FILE;
                }
                if ( -e "$path$base.$toext" ) {

                    # We've found the extension for the missing file,
                    # and the file exists
                    $new_includes{"$path$base.$toext"} = 1;

                    #                  next MISSING_FILE;
                }
            }
        }
    }    # end MISSING_FILES

# Sometimes bad line-breaks in log file (etc) create the
# impression of a missing file e.g., ./file, but with an incorrect
# extension.  The above tests find the file with an extension,
# e.g., ./file.tex, but it is already in the list.  So now I will
# remove files in the new_include list that are already in the
# include list.  Also handle aliasing of file.tex and ./file.tex.
# For example, I once found:
# (./qcdbook.aux (./to-do.aux) (./ideas.aux) (./intro.aux) (./why.aux) (./basics
#.aux) (./classics.aux)

    my $found = 0;
    foreach my $file ( keys %new_includes ) {
        my $stripped = $file;
        $stripped =~ s{^\./}{};
        if ( exists $PHsource{$file} ) {
            delete $new_includes{$file};
        }
        else {
            $found++;
            rdb_ensure_file( $rule, $file );
        }
    }

    if ( $diagnostics && ( $found > 0 ) ) {
        warn "$My_name: Detected previously missing files:\n";
        foreach ( sort keys %new_includes ) {
            warn "   '$_'\n";
        }
    }
    return $found;
}    # END rdb_find_new_files

#************************************************************

sub rdb_set_dependents {

    # Call rdb_set_dependents( rules ...)
    # Returns array (sorted), of new source files.
    local @new_sources = ();
    local @deletions   = ();

    # Shouldn't recurse.  The definite rules to be examined are given.
    rdb_for_some( [@_], 0, \&rdb_one_dep );

    # OLD    rdb_recurse( [@_],  0, \&rdb_one_dep );
    foreach (@deletions) {
        my ( $rule, $file ) = @$_;
        rdb_remove_files( $rule, $file );
    }
    &rdb_make_links;
    return uniqs(@new_sources);
}    #END rdb_set_dependents

#************************************************************

sub rdb_one_dep {

    # Helper for finding dependencies.  One case, $rule and $file given
    # Assume file (and rule) context for DESTINATION file.

    # Only look for dependency if $rule is primary rule (i.e., latex
    # or pdflatex) or is a custom dependency:
    if ( ( !exists $possible_primaries{$rule} ) && ( $rule !~ /^cusdep/ ) ) {
        return;
    }

    #print "=============ONE_DEP: '$rule' '$file'\n";
    local $new_dest = $file;
    my ( $base_name, $path, $toext ) = fileparseA($new_dest);
    $base_name = $path . $base_name;
    $toext =~ s/^\.//;
    my $Pinput_extensions = $input_extensions{$rule};
  DEP:
    foreach my $dep (@cus_dep_list) {
        my ( $fromext, $proptoext, $must, $func_name ) = split( ' ', $dep );
        if ( $toext eq $proptoext ) {
            my $source = "$base_name.$fromext";

            # Found match of rule
            if ($diagnostics) {
                print "Found cusdep:  $source to make $rule:$new_dest ====\n";
            }
            if ( -e $source ) {
                $$Pfrom_rule = "cusdep $fromext $toext $base_name";

                #??		print "?? Ensuring rule for '$$Pfrom_rule'\n";
                local @PAnew_cmd = ( 'do_cusdep', $func_name );
                if ( !-e $new_dest ) {
                    push @new_sources, $new_dest;
                }
                if ( !rdb_rule_exists($$Pfrom_rule) ) {
                    print "=== Creating rule for '$$Pfrom_rule'\n";
                    rdb_create_rule(
                        $$Pfrom_rule, 'cusdep', '',        \@PAnew_cmd,
                        3,            $source,  $new_dest, $base_name,
                        0
                    );
                }
                else {
                    rdb_one_rule( $$Pfrom_rule,
                        sub { @$PAint_cmd = @PAnew_cmd; $$Pdest = $new_dest; }
                    );
                }
                return;
            }
            else {
                # Source file does not exist
                if ( !$force_mode && ( $must != 0 ) ) {

                    # But it is required that the source exist ($must !=0)
                    $failure     = 1;
                    $failure_msg = "File '$base_name.$fromext' does not exist "
                      . "to build '$base_name.$toext'";
                    return;
                }
                elsif ( $$Pfrom_rule =~ /^cusdep $fromext $toext / ) {

                    # Source file does not exist, destination has the rule set.
                    # So turn the from_rule off
                    $$Pfrom_rule = '';
                }
                else {
                }
            }
        }
        elsif (( $toext eq '' )
            && ( !-e $file )
            && ( !-e "$base_name.$proptoext" )
            && exists $$Pinput_extensions{$proptoext} )
        {
            # Empty extension and non-existent destination
            #   This normally results from  \includegraphics{A}
            #    without graphics extension for file, when file does
            #    not exist.  So we will try to find something to make it.
            my $source = "$base_name.$fromext";
            if ( -e $source ) {
                $new_dest = "$base_name.$proptoext";
                my $from_rule = "cusdep $fromext $proptoext $base_name";
                push @new_sources, $new_dest;
                print "Ensuring rule for '$from_rule', to make '$new_dest'\n"
                  if $diagnostics > -1;
                local @PAnew_cmd = ( 'do_cusdep', $func_name );
                if ( !rdb_rule_exists($from_rule) ) {
                    rdb_create_rule(
                        $from_rule, 'cusdep', '',        \@PAnew_cmd,
                        3,          $source,  $new_dest, $base_name,
                        0
                    );
                }
                else {
                    rdb_one_rule( $$Pfrom_rule,
                        sub { @$PAint_cmd = @PAnew_cmd; $$Pdest = $new_dest; }
                    );
                }
                rdb_ensure_file( $rule, $new_dest, $from_rule );

                # We've now got a spurious file in our rule.  But don't mess
                # with deleting an item we are in the middle of!
                push @deletions, [ $rule, $file ];
                return;
            }
        }    # End of Rule found
    }    # End DEP
    if ( ( !-e $file ) && $use_make_for_missing_files ) {

        # Try to make the missing file
        #Set character to surround filenames in commands:
        my $q = $quote_filenames ? '"' : '';
        if ( $toext ne '' ) {
            print
"$My_name: '$rule': source file '$file' doesn't exist. I'll try making it...\n";
            &Run_subst("$make $q$file$q");
            if ( -e $file ) {
                return;
            }
        }
        else {
            print "$My_name: '$rule': source '$file' doesn't exist.\n",
              "   I'll try making it with allowed extensions \n";
            foreach my $try_ext ( keys %$Pinput_extensions ) {
                my $new_dest = "$file.$try_ext";
                &Run_subst("$make $q$new_dest$q");
                if ( -e $new_dest ) {
                    print "SUCCESS in making '$new_dest'\n";

                    # Put file in rule, without a from_rule, but
                    # set its state as non-existent, to correspond
                    # to file's state before the file was made
                    # This ensures a rerun of (pdf)latex is provoked.
                    rdb_ensure_file( $rule, $new_dest, undef, 1 );
                    push @new_sources, $new_dest;
                    push @deletions, [ $rule, $file ];

                    # Flag need for a new run of (pdf)latex despite
                    # the error due to a missing file.
                    $$Pout_of_date_user = 1;
                    return;
                }
            }
        }
    }
}    #END rdb_one_dep

#************************************************************

sub rdb_list {

    # Call: rdb_list()
    # List rules and their source files
    print "===Rules:\n";
    local $count_rules = 0;
    my @accessible_all = rdb_accessible( keys %requested_filerules );
    rdb_for_some(
        \@accessible_all,
        sub {
            $count_rules++;
            print "Rule '$rule' depends on:\n";
        },
        sub { print "    '$file'\n"; },
        sub {
            print "  and generates:\n";
            foreach ( keys %$PHdest ) { print "    '$_'\n"; }

            #             print "  default_extra_generated:\n";
            #             foreach (@$PA_extra_generated) { print "    '$_'\n"; }
        },
    );
    if ( $count_rules <= 0 ) {
        print "   ---No rules defined\n";
    }
}    #END rdb_list

#************************************************************

sub deps_list {

    # Call: deps_list(fh)
    # List dependent files to file open on fh
    my $fh = $_[0];
    print $fh "#===Dependents for $filename:\n";
    my @dest = ();
    if ($pdf_mode)        { push @dest, '.pdf'; }
    if ($dvi_mode)        { push @dest, '.dvi'; }
    if ($postscript_mode) { push @dest, '.ps'; }
    my %source         = ( $texfile_name => 1 );
    my @generated      = ();
    my @accessible_all = rdb_accessible( keys %requested_filerules );
    rdb_for_some(
        \@accessible_all,
        sub {
            #             foreach (keys %$PHdest) { print "-----   $_\n"; }
            push @generated, keys %$PHdest;
        },
        sub { $source{$file} = 1; }
    );
    foreach ( keys %generated_exts_all ) {
        ( my $name = /%R/ ? $_ : "%R.$_" ) =~ s/%R/$root_filename/;
        push @generated, $name;
    }
    foreach (@generated) {
        delete $source{$_};
    }
    foreach my $dest (@dest) {
        if ( $deps_file eq '-' ) {
            print $fh "$root_filename$dest :";
        }
        else {
            print $fh "$root_filename$dest $deps_file :";
        }
        foreach ( sort keys %source ) {
            print $fh "\\\n    $_";
        }
        print $fh "\n";
    }
    print $fh "#===End dependents for $filename:\n";
    if ($dependents_phony) {
        print $fh "\n#===Phony rules for $filename:\n\n";
        foreach ( sort keys %source ) {
            print $fh "$_ :\n\n";
        }
        print $fh "#===End phony rules for $filename:\n";
    }
}    #END deps_list

#************************************************************

sub rdb_show {

    # Call: rdb_show()
    # Displays contents of rule data base.
    # Side effect: Exercises access routines!
    print "===Rules:\n";
    local $count_rules = 0;
    rdb_for_all(
        sub {
            $count_rules++;
            my @int_cmd = @$PAint_cmd;
            foreach (@int_cmd) {
                if ( !defined($_) ) { $_ = 'undef'; }
            }
            print
              "  [$rule]: '$$Pcmd_type' '$$Pext_cmd' '@int_cmd' $$Ptest_kind ",
"'$$Psource' '$$Pdest' '$$Pbase' $$Pout_of_date $$Pout_of_date_user\n";
        },
        sub { print "    '$file': $$Ptime $$Psize $$Pmd5 '$$Pfrom_rule'\n"; }
    );
    if ( $count_rules <= 0 ) {
        print "   ---No rules defined\n";
    }
}    #END rdb_show

#************************************************************

sub rdb_accessible {

    # Call: rdb_accessible( rule, ...)
    # Returns array of rules accessible from the given rules
    local @accessible = ();
    rdb_recurse( [@_], sub { push @accessible, $rule; } );
    return @accessible;
}    #END rdb_accessible

#************************************************************
#************************************************************
#************************************************************

sub rdb_make {

    # Call: rdb_make( target, ... )
    # Makes the targets and prerequisites.
    # Leaves one-time rules to last.
    # Does appropriate repeated makes to resolve dependency loops

    # Returns 0 on success, nonzero on failure.

    # General method: Find all accessible rules, then repeatedly make
    # them until all accessible rules are up-to-date and the source
    # files are unchanged between runs.  On termination, all
    # accessible rules have stable source files.
    #
    # One-time rules are view and print rules that should not be
    # repeated in an algorithm that repeats rules until the source
    # files are stable.  It is the calling routine's responsibility to
    # arrange to call them, or to use them here with caution.
    #
    # Note that an update-viewer rule need not be considered
    # one-time.  It can be legitimately applied everytime the viewed
    # file changes.
    #
    # Note also that the criterion of stability is to be applied to
    # source files, not to output files.  Repeated application of a
    # rule to IDENTICALLY CONSTANT source files may produce different
    # output files.  This may be for a trivial reason (e.g., the
    # output file contains a time stamp, as in the header comments for
    # a typical postscript file), or for a non-trivial reason (e.g., a
    # stochastic algorithm, as in abcm2ps).
    #
    # This caused me some actual trouble.  In general, circular
    # dependencies produce non-termination, and the the following
    # situation is an example of a generic situation where certain
    # rules must be obeyed in order to obtain proper results:
    #    1.  A/the latex source file contains specifications for
    #        certain postprocessing operations.  Standard (pdf)latex
    #        already has this, for indexing and bibliography.
    #    2.  In the case in point that caused me trouble, the
    #        specification was for musical tunes that were contained
    #        in external source files not directly input to
    #        (pdf)latex.  But in the original version, there was a
    #        style file (abc.sty) that caused latex itself to call
    #        abcm2ps to make .eps files for each tune that were to be
    #        read in on the next run of latex.
    #    3.  Thus the specification can cause a non-terminating loop
    #        for latexmk, because the output files of abcm2ps changed
    #        even with identical input.
    #    4.  The solution was to
    #        a. Use a style file abc_get.sty that simply wrote the
    #           specification on the tunes to the .aux file in a
    #           completely deterministic fashion.
    #        b. Instead of latex, use a script abclatex.pl that runs
    #           latex and then extracts the abc contents for each tune
    #           from the source abc file.  This is also
    #           deterministic.
    #        c. Use a cusdep rule in latexmk to convert the tune abc
    #           files to eps.  This is non-deterministic, but only
    #           gets called when the (deterministic) source file
    #           changes.
    #        This solves the problem.  Latexmk works.  Also, it is no
    #        longer necessary to enable write18 in latex, and multiple
    #        unnecessary runs of abcm2ps are no longer used.
    #
    # The order of testing and applying rules is chosen by the
    # following heuristics:
    #    1.  Both latex and pdflatex may be used, but the resulting
    #        aux files etc may not be completely identical.  Define
    #        latex and pdflatex as primary rules.  Apply the general
    #        method of repeated circulating through all rules until
    #        the source files are stable for each primary rule
    #        separately.  Naturally the rules are all accessible
    #        rules, but excluding primary rules except for the current
    #        primary.
    #    2.  Assume that the primary rules are relatively
    #        time-consuming, so that unnecessary passes through them
    #        to check stability of the source files should be avoided.
    #    3.  Assume that although circular dependencies exist, the
    #        rules can nevertheless be thought of as basically
    #        non-circular, and that many rules are strictly or
    #        normally non-circular.  In particular cusdep rules are
    #        typically non-circular (e.g., fig2eps), as are normal
    #        output processing rules like dvi2ps.
    #    4.  The order for the non-circular approximation is
    #        determined by applying the assumption that an output file
    #        from one rule that is read in for an earlier stage is
    #        unchanged.
    #    HOWEVER, at a first attempt, the ordering is not needed.  It
    #    only gives an optimization
    #    5.  (Note that these assumptions could be violated, e.g., if
    #        $dvips is arranged not only to do the basic dvips
    #        command, but also to extract information from the ps file
    #        and feed it back to an input file for (pdf)latex.)
    #    6.  Nevertheless, the overall algorithm should allow
    #        circularities.  Then the general criterion of stability
    #        of source files covers the general case, and also
    #        robustly handles the case that the USER changes source
    #        files during a run.  This is particularly important in
    #        -pvc mode, given that a full make on a large document can
    #        be quite lengthy in time, and moreover that a user
    #        naturally wishes to make corrections in response to
    #        errors, particularly latex errors, and have them apply
    #        right away.
    # This leads to the following approach:
    #    1.  Classify accessible rules as: primary, pre-primary
    #        (typically cusdep, bibtex, makeindex, etc), post-primary
    #        (typically dvips, etc), and one-time
    #    2.  Then stratify the rules into an order of application that
    #        corresponds to the basic feedforward structure, with the
    #        exclusion of one-time rules.
    #    3.  Always require that one-time rules are among the
    #        explicitly requested rules, i.e., the last to be applied,
    #        were we to apply them.  Anything else would not match the
    #        idea of a one-time rule.
    #    4.  Then work as follows:
    #        a. Loop over primaries
    #        b. For each primary, examine each pre-primary rule and
    #           apply if needed, then the primary rule and then each
    #           post-primary rule.  The ordering of the pre-primary
    #           and post-primary rules was found in step 2.
    #      BUT applying the ordering is not essential
    #        c. Any time that a pre-primary or primary rule is
    #           applied, loop back to the beginning of step b.  This
    #           ensures that bibtex etc are applied before rerunning
    #           (pdf)latex, and also covers changing source files, and
    #           gives priority to quick pre-primary rules for changing
    #           source files against slow reruns of latex.
    #        d. Then apply post-primary rules in order, but not
    #           looping back after each rule.  This non-looping back
    #           is because the rules are normally feed-forward only.
    #      BUT applying the ordering is not essential
    #        e. But after completing post-primary rules do loop back
    #           to b if any rules were applied.  This covers exotic
    #           circular dependence (and as a byproduct, changing
    #           source files).
    #        f. On each case of looping back to b, re-evaluate the
    #           dependence setup to allow for the effect of changing
    #           source files.
    #

    local @requested_targets = @_;
    local %current_primaries = ();    # Hash whose keys are primary rules
         # needed, i.e., known latex-like rules which trigger
         # circular dependencies
    local @pre_primary  = ();    # Array of rules
    local @post_primary = ();    # Array of rules
    local @one_time     = ();    # Array of rules

    # For diagnostics on changed files, etc:
    local @changed         = ();
    local @disappeared     = ();
    local @no_dest         = ();    # Non-existent destination files
    local @rules_never_run = ();
    local @rules_to_apply  = ();

    &rdb_classify_rules( \%possible_primaries, @requested_targets );

    local %pass            = ();
    local $failure         = 0;  # General accumulated error flag
    local $missing_dvi_pdf = ''; # Did primary run fail to make its output file?
    local $runs            = 0;
    local $too_many_passes = 0;
    local %rules_applied   = ();
    my $retry_msg = 0;           # Did I earlier say I was going to attempt
                                 # another pass after a failure?
  PRIMARY:

    foreach my $primary ( keys %current_primaries ) {
        foreach my $rule ( keys %rule_db ) {
            $pass{$rule} = 0;
        }
      PASS:
        while ( 1 == 1 ) {

            # Exit condition at end of body of loop.
            $runs = 0;
            my $previous_failure = $failure;
            $failure = 0;
            local $newrule_nofile = 0;    # Flags whether rule created for
                 # making currently non-existent file, which
                 # could become a needed source file for a run
                 # and therefore undo an error condition
            if ($diagnostics) {
                print "MakeB: doing pre_primary and primary...\n";
            }

            # Do the primary run if it is needed. On return $runs == 0
            #       signals that nothing was run (and hence no output
            #       files changed), either because no input files
            #       changed and no run was needed, or because the
            #       number of passes through the rule exceeded the
            #       limit.  In the second case $too_many_runs is set.
            rdb_for_some( [ @pre_primary, $primary ], \&rdb_make1 );
            if ( ( $runs > 0 ) && !$too_many_passes ) {
                next PASS;
            }
            if ( $runs == 0 ) {

               # $failure not set on this pass, so use value from previous pass:
                $failure = $previous_failure;
                if ( $failure && !$force_mode ) { last PASS; }
            }
            if ($missing_dvi_pdf) {

                # No output from primary, after completing circular dependence
                warn "Failure to make '$missing_dvi_pdf'\n";
                $failure = 1;
                last PASS;
            }
            if ($diagnostics) {
                print "MakeB: doing post_primary...\n";
            }
            rdb_for_some( [@post_primary], \&rdb_make1 );
            if ( ( $runs == 0 ) || $too_many_passes ) {

                # If $too_many_passes is set, it should also be that
                # $runs == 0; but for safety, I also checked
                # $too_many_passes.
                last PASS;
            }
        }
        continue {
            # Re-evaluate rule classification and accessibility,
            # but do not change primaries.
            # Problem is that %current_primaries gets altered
            my %old_curr_prim = %current_primaries;
            &rdb_classify_rules( \%possible_primaries, @requested_targets );
            %current_primaries = %old_curr_prim;
            &rdb_make_links;
        }
    }
    rdb_for_some( [@one_time], \&rdb_make1 );
    rdb_write($fdb_name);

    if ( !$silent ) {
        if ( $failure && $force_mode ) {
            print
              "$My_name: Errors, in force_mode: so I tried finishing targets\n";
        }
        elsif ($failure) {
            print "$My_name: Errors, so I did not complete making targets\n";
        }
        else {
            local @dests = ();
            rdb_for_some( [@_], sub { push @dests, $$Pdest if ($$Pdest); } );
            print "$My_name: All targets ("
              . join( " ", @dests )
              . ") are up-to-date\n";
        }
    }
    return $failure;
}    #END rdb_make

#-------------------

sub rdb_show_rule_errors {
    local @errors   = ();
    local @warnings = ();
    rdb_for_all(
        sub {
            if ( $$Plast_message ne '' ) {
                if ( $$Plast_result == 200 ) {
                    push @warnings, "$rule: $$Plast_message";
                }
                else {
                    push @errors, "$rule: $$Plast_message";
                }
            }
            elsif ( $$Plast_result == 1 ) {
                push @errors, "$rule: failed to create output file";
            }
            elsif ( $$Plast_result == 2 ) {
                push @errors, "$rule: gave an error";
            }
            elsif ( $$Prun_time == 0 ) {

                #  This can have innocuous causes.  So don't report
            }
        }
    );
    if ( $#warnings > -1 ) {
        warn "Collected warning summary (may duplicate other messages):\n";
        foreach (@warnings) {
            warn "  $_\n";
        }
    }
    if ( $#errors > -1 ) {
        warn "Collected error summary (may duplicate other messages):\n";
        foreach (@errors) {
            warn "  $_\n";
        }
    }
    return $#errors + 1;
}

#-------------------

sub rdb_make1 {

    # Call: rdb_make1
    # Helper routine for rdb_make.
    # Carries out make at level of given rule (all data available).
    # Assumes contexts for recursion, make, and rule, and
    # assumes that source files for the rule are to be considered
    # up-to-date.
    if ($diagnostics) { print "  MakeB1 $rule\n"; }
    if ( $failure & !$force_mode ) { return; }
    if ( !defined $pass{$rule} ) { $pass{$rule} = 0; }
    &rdb_clear_change_record;

    # Special fix up for bibtex:
    my $bibtex_not_run = -1;    # Flags status as to whether this is a
         # bibtex rule and if it is, whether out-of-date condition is to
         # be ignored.
         #  -1 => not a bibtex rule
         #   0 => no special treatment
         #   1 => don't run bibtex because of non-existent bibfiles
         #           (and setting to do this test)
         #   2 => don't run bibtex because of setting
    my @missing_bib_files = ();

    if ( $rule =~ /^(bibtex|biber)/ ) {
        $bibtex_not_run = 0;
        if ( $bibtex_use == 0 ) {
            $bibtex_not_run = 2;
        }
        elsif ( $bibtex_use == 1 ) {
            foreach ( keys %$PHsource ) {
                if ( (/\.bib$/) && ( !-e $_ ) ) {
                    push @missing_bib_files, $_;
                    $bibtex_not_run = 1;
                }
            }
        }
    }

    if ( ( $$Prun_time == 0 ) && exists( $possible_primaries{$rule} ) ) {
        push @rules_never_run, $rule;
        $$Pout_of_date = 1;
        $$Plast_result = -1;
    }
    else {
        if ( $$Pdest && ( !-e $$Pdest ) ) {

            # With a non-existent destination, if we haven't made any passes
            #   through a rule, rerunning the rule is good, because the file
            #   may fail to exist because of being deleted by the user (for ex.)
            #   rather than because of a failure on a previous run.
            # (We could do better with a flag in fdb file.)
            # But after the first pass, the situation is different.
            #   For a primary rule (pdf)latex, the lack of a destination file
            #      could result from there being zero content due to a missing
            #      essential input file.  The input file could be generated
            #      by a program to be run later (e.g., a cusdep or bibtex),
            #      so we should wait until all passes are completed before
            #      deciding a non-existent destination file is an error.
            #   For a custom dependency, the rule may be obsolete, and
            #      if the source file does not exist also, we should simply
            #      not run the rule, but not set an error condition.
            #      Any error will arise at the (pdf)latex level due to a
            #      missing source file at that level.
            if (
                $$Psource
                && ( !-e $$Psource )

                # OLD                && ( ( $$Pcmd_type eq 'cusdep') )
                # NEW
                && ( ( $$Pcmd_type ne 'primary' ) )
              )
            {
                # Main source file doesn't exist, and rule is NOT primary.
                # No action, since a run is pointless.  Primary is different:
                # file might be found elsewhere (by kpsearch from (pdf)latex),
                # while non-existence of main source file is a clear error.
            }
            elsif ( $$Pcmd_type eq 'delegated' ) {

                # Delegate to destination rule
            }
            elsif ( $pass{$rule} == 0 ) {
                push @no_dest, $$Pdest;
                $$Pout_of_date = 1;
            }
            if ( $$Pcmd_type eq 'primary' ) {
                $missing_dvi_pdf = $$Pdest;
            }
        }
    }

    &rdb_flag_changes_here(0);

    if ( !$$Pout_of_date ) {

        #??	if ( ($$Pcmd_type eq 'primary') && (! $silent) ) {
        #            print "Rule '$rule' up to date\n";
        #        }
        return;
    }
    if ($diagnostics) { print "     remake\n"; }
    if ( !$silent ) {
        print "$My_name: applying rule '$rule'...\n";
        &rdb_diagnose_changes("Rule '$rule': ");
    }

    # We are applying the rule, so its source file state for when it
    # was last made is as of now:
    # ??IS IT CORRECT TO DO NOTHING IN CURRENT VERSION?

    # The actual run
    my $return = 0;    # Return code from called routine
                       # Rule may have been created since last run:
    if ( !defined $pass{$rule} ) { $pass{$rule} = 0; }
    if ( $pass{$rule} ge $max_repeat ) {

        # Avoid infinite loop by having a maximum repeat count
        # Getting here represents some kind of weird error.
        warn "$My_name: Maximum runs of $rule reached ",
          "without getting stable files\n";
        $too_many_passes = 1;

        # Treat rule as completed, else in -pvc mode get infinite reruns:
        $$Pout_of_date = 0;
        $failure       = 1;
        $failure_msg   = "'$rule' needed too many passes";
        return;
    }

    $rules_applied{$rule} = 1;
    $runs++;

    $pass{$rule}++;
    if ( $bibtex_not_run > 0 ) {
        if ( $bibtex_not_run == 1 ) {
            show_array(
"$My_name: I WON'T RUN '$rule' because I don't find the following files:",
                @missing_bib_files
            );
        }
        elsif ( $bibtex_not_run == 2 ) {
            warn "$My_name: I AM CONFIGURED/INVOKED NOT TO RUN '$rule'\n";
        }
        $return = &rdb_dummy_run1;
    }
    else {
        warn_running("Run number $pass{$rule} of rule '$rule'");
        if ( $$Pcmd_type eq 'primary' ) {
            $return = &rdb_primary_run;
        }
        else { $return = &rdb_run1; }
    }
    if ($$Pchanged) {
        $newrule_nofile = 1;
        $return         = 0;
    }
    elsif ( $$Pdest && ( !-e $$Pdest ) && ( !$failure ) ) {

        # If there is a destination to make, but for some reason
        #    it did not get made, and no other error was reported,
        #    then a priori there appears to be an error condition:
        #    the run failed.   But there are two important cases in
        #    which this is a wrong diagnosis.
        if ( ( $$Pcmd_type eq 'cusdep' ) && $$Psource && ( !-e $$Psource ) ) {

            # However, if the rule is a custom dependency, this is not by
            #  itself an error, if also the source file does not exist.  In
            #  that case, we may have the situation that (1) the dest file is no
            #  longer needed by the tex file, and (2) therefore the user
            #  has deleted the source and dest files.  After the next
            #  latex run and the consequent analysis of the log file, the
            #  cusdep rule will no longer be needed, and will be removed.

            # So in this case, do NOT report an error
            $$Pout_of_date = 0;
        }
        elsif ( $$Pcmd_type eq 'primary' ) {

            # For a primary rule, i.e., (pdf)latex, not to produce the
            #    expected output file may not be an error condition.
            # Diagnostics were handled in parsing the log file.
            # Special action in main loop in rdb_make
            $missing_dvi_pdf = $$Pdest;
        }
        elsif ( $return == -2 ) {

            # Missing output file was reported to be NOT an error
            $$Pout_of_date = 0;
        }
        else {
            $failure = 1;
        }
    }
    if ( ( $return != 0 ) && ( $return != -2 ) ) {
        $failure       = 1;
        $$Plast_result = 2;
        if ( !$$Plast_message ) {
            $$Plast_message = "Run of rule '$rule' gave a non-zero error code";
        }

        # !!??        $failure_msg = $$Plast_message;

    }
}    #END rdb_make1

#************************************************************

#??sub rdb_submake {
#??    # Call: rdb_submake
#??    # Makes all the source files for a given rule.
#??    # Assumes contexts for recursion, for make, and rule.
#??    %visited = %visited_at_rule_start;
#??    local $failure = 0;  # Error flag
#??    my @v = keys %visited;
#??    rdb_do_files( sub{ rdb_recurse_rule( $$Pfrom_rule, 0,0,0, \&rdb_make1 ) } );
#??    return $failure;
#??}  #END rdb_submake

#************************************************************

sub rdb_classify_rules {

    # Usage: rdb_classify_rules( \%allowed_primaries, requested targets )
    # Assume the following variables are available (global or local):
    # Input:
    #    @requested_targets    # Set to target rules

    # Output:
    #    %current_primaries    # Keys are actual primaries
    #    @pre_primary          # Array of rules
    #    @post_primary         # Array of rules
    #    @one_time             # Array of rules
    # @pre_primary and @post_primary are in natural order of application.

    local $P_allowed_primaries = shift;
    local @requested_targets   = @_;
    local $state               = 0;       # Post-primary
    local @classify_stack      = ();

    %current_primaries = ();
    my @pre_primary  = ();
    my @post_primary = ();
    my @one_time     = ();

    rdb_recurse( \@requested_targets, \&rdb_classify1, 0, 0, \&rdb_classify2 );

    # Reverse, as tendency is to find last rules first.
    @pre_primary  = reverse @pre_primary;
    @post_primary = reverse @post_primary;

    if ($diagnostics) {
        print "Rule classification: \n";
        if ( $#requested_targets < 0 ) {
            print "  No requested rules\n";
        }
        else {
            print "  Requested rules:\n";
            foreach (@requested_targets) { print "    $_\n"; }
        }
        if ( $#pre_primary < 0 ) {
            print "  No pre-primaries\n";
        }
        else {
            print "  Pre-primaries:\n";
            foreach (@pre_primary) { print "    $_\n"; }
        }
        print "  Primaries:\n";
        foreach ( keys %current_primaries ) { print "    $_\n"; }
        if ( $#post_primary < 0 ) {
            print "  No post-primaries\n";
        }
        else {
            print "  Post-primaries:\n";
            foreach (@post_primary) { print "    $_\n"; }
        }
        if ( $#one_time < 0 ) {
            print "  No one_time rules\n";
        }
        else {
            print "  One_time rules:\n";
            foreach (@one_time) { print "    $_\n"; }
        }
    }    #end diagnostics

}    #END rdb_classify_rules

#-------------------

sub rdb_classify1 {

    # Helper routine for rdb_classify_rules
    # Applied as rule_act1 in recursion over rules
    # Assumes rule context, and local variables from rdb_classify_rules
    push @classify_stack, [$state];
    if ( exists $possible_one_time{$rule} ) {

        # Normally, we will have already extracted the one_time rules,
        # and they will never be accessed here.  But just in case of
        # problems or generalizations, we will cover all possibilities:
        if ( $depth > 1 ) {
            warn "ONE TIME rule not at outer level '$rule'\n";
        }
        push @one_time, $rule;
    }
    elsif ( $state == 0 ) {
        if ( exists ${$P_allowed_primaries}{$rule} ) {
            $state = 1;                      # In primary rule
            $current_primaries{$rule} = 1;
        }
        else {
            push @post_primary, $rule;
        }
    }
    else {
        $state = 2;                          # in post-primary rule
        push @pre_primary, $rule;
    }
}    #END rdb_classify1

#-------------------

sub rdb_classify2 {

    # Helper routine for rdb_classify_rules
    # Applied as rule_act2 in recursion over rules
    # Assumes rule context
    ($state) = @{ pop @classify_stack };
}    #END rdb_classify2

#************************************************************

sub rdb_run1 {

    # Assumes contexts for: rule.
    # Unconditionally apply the rule
    # Returns return code from applying the rule.
    # Otherwise: 0 on other kind of success,
    #            -1 on error,
    #            -2 when missing dest_file is to be ignored

    # Source file data, by definition, correspond to the file state just
    # before the latest run, and the run_time to the time just before the run:
    &rdb_update_files;
    $$Prun_time     = time;
    $$Pchanged      = 0;      # No special changes in files
    $$Plast_result  = 0;
    $$Plast_message = '';

    # Return values for external command:
    my $return = 0;

    # Find any internal command
    my @int_args              = @$PAint_cmd;
    my $int_cmd               = shift @int_args;
    my @int_args_for_printing = @int_args;
    foreach (@int_args_for_printing) {
        if ( !defined $_ ) { $_ = 'undef'; }
    }
    if ($int_cmd) {
        print
"For rule '$rule', running '\&$int_cmd( @int_args_for_printing )' ...\n";
        $return = &$int_cmd(@int_args);
    }
    elsif ($$Pext_cmd) {
        $return = &Run_subst();
    }
    else {
        warn "$My_name: Either a bug OR a configuration error:\n",
          "    Need to implement the command for '$rule'\n";
        &traceback();
        $return         = -1;
        $$Plast_result  = 2;
        $$Plast_message = "Bug or configuration error; incorrect command type";
    }
    if ( $rule =~ /^biber/ ) {
        my @biber_source = ();
        my $retcode = check_biber_log( $$Pbase, \@biber_source );
        foreach my $source (@biber_source) {
            print "  === Source file '$source' for '$rule'\n"
              if ($diagnostics);
            rdb_ensure_file( $rule, $source );
        }
        if ( $retcode == 5 ) {

            # Special treatment if sole missing file is bib file
            # I don't want to treat that as an error
            $return         = 0;
            $$Plast_result  = 200;
            $$Plast_message = "Could not find bib file for '$$Pbase'";
            push @warnings, "Bib file not found for '$$Pbase'";
        }
        elsif ( $retcode == 6 ) {

            # Missing control file.  Need to remake it (if possible)
            # Don't treat missing bbl file as error.
            warn "$My_name: bibtex control file missing.  Since that can\n",
              "   be recreated, I'll try to do so.\n";
            $return = -2;
            rdb_for_some( [ keys %current_primaries ],
                sub { $$Pout_of_date = 1; } );
        }
        elsif ( $retcode == 4 ) {
            $$Plast_result = 2;
            $$Plast_message =
              "Could not find all biber source files for '$$Pbase'";
            push @warnings, "Not all biber source files found for '$$Pbase'";
        }
        elsif ( $retcode == 3 ) {
            $$Plast_result  = 2;
            $$Plast_message = "Could not open biber log file for '$$Pbase'";
            push @warnings, $$Plast_message;
        }
        elsif ( $retcode == 2 ) {
            $$Plast_message = "Biber errors: See file '$$Pbase.blg'";
            push @warnings, $$Plast_message;
        }
        elsif ( $retcode == 1 ) {
            push @warnings, "Biber warnings for '$$Pbase'";
        }
        elsif ( $retcode == 10 ) {
            push @warnings, "Biber found no citations for '$$Pbase'";

            # Biber doesn't generate a bbl file in this situation.
            $return = -2;
        }
    }
    if ( $rule =~ /^bibtex/ ) {
        my $retcode = check_bibtex_log($$Pbase);
        if ( !-e $$Psource ) {
            $retcode = 10;
            rdb_for_some( [ keys %current_primaries ],
                sub { $$Pout_of_date = 1; } );
        }
        if ( $retcode == 3 ) {
            $$Plast_result  = 2;
            $$Plast_message = "Could not open bibtex log file for '$$Pbase'";
            push @warnings, $$Plast_message;
        }
        elsif ( $retcode == 2 ) {
            $$Plast_message = "Bibtex errors: See file '$$Pbase.blg'";
            $failure        = 1;
            push @warnings, $$Plast_message;
        }
        elsif ( $retcode == 1 ) {
            push @warnings, "Bibtex warnings for '$$Pbase'";
        }
        elsif ( $retcode == 10 ) {
            push @warnings, "Bibtex found no citations for '$$Pbase',\n",
              "    or bibtex found a missing aux file\n";
            if ( !-e $$Pdest ) {
                warn "$My_name: Bibtex did not produce '$$Pdest'.  But that\n",
                  "     was because of missing files, so I will continue.\n";
                $return = -2;
            }
            else {
                $return = 0;
            }
        }
    }

    $updated = 1;
    if ( $$Ptest_kind == 3 ) {

        # We are time-criterion first time only.  Now switch to
        # file-change criterion
        $$Ptest_kind = 1;
    }
    $$Pout_of_date = $$Pout_of_date_user = 0;

    if ( ( $$Plast_result == 0 ) && ( $return != 0 ) && ( $return != -2 ) ) {
        $$Plast_result = 2;
        if ( $$Plast_message eq '' ) {
            $$Plast_message = "Command for '$rule' gave return code $return";
        }
    }
    elsif ( $$Pdest && ( !-e $$Pdest ) && ( $return != -2 ) ) {
        $$Plast_result = 1;
    }
    return $return;
}    # END rdb_run1

#-----------------

sub rdb_dummy_run1 {

    # Assumes contexts for: rule.
    # Update rule state as if the rule ran successfully,
    #    but don't run the rule.
    # Returns 0 (success code)

    # Source file data, by definition, correspond to the file state just before
    # the latest run, and the run_time to the time just before the run:
    &rdb_update_files;
    $$Prun_time     = time;
    $$Pchanged      = 0;      # No special changes in files
    $$Plast_result  = 0;
    $$Plast_message = '';

    if ( $$Ptest_kind == 3 ) {

        # We are time-criterion first time only.  Now switch to
        # file-change criterion
        $$Ptest_kind = 1;
    }
    $$Pout_of_date = $$Pout_of_date_user = 0;

    return 0;
}    # END rdb_dummy_run1

#-----------------

sub Run_subst {

    # Call: Run_subst( cmd, msg, options, source, dest, base )
    # Runs command with substitutions.
    # If an argument is omitted or undefined, it is replaced by a default:
    #    cmd is the command to execute
    #    msg is whether to print a message:
    #           0 for not, 1 according to $silent setting, 2 always
    #    options, source, dest, base: correspond to placeholders.
    # Substitutions:
    #    %S=source, %D=dest, %B=base, %R=root=base for latex, %O=options,
    #    %T=texfile, %Y=$aux_dir1, %Z=$out_dir1
    # This is a globally usable subroutine, and works in a rule context,
    #    and outside.
    # Defaults:
    #     cmd: $PPext_cmd if defined, else '';
    #     msg: 1
    #     options: ''
    #     source:  $$Psource if defined, else $texfile_name;
    #     dest:    $$Pdest if defined, else $view_file, else '';
    #     base:    $$Pbase if defined, else $root_filename;

    my ( $ext_cmd, $msg, $options, $source, $dest, $base ) = @_;

    $ext_cmd ||= ( $Pext_cmd ? $$Pext_cmd : '' );
    $msg = ( defined $msg ? $msg : 1 );
    $options ||= '';
    $source  ||= ( $Psource ? $$Psource : $texfile_name );
    $dest    ||= ( $Pdest ? $$Pdest : ( $view_file || '' ) );
    $base ||= ( $Pbase ? $$Pbase : $root_filename );

    if ( $ext_cmd eq '' ) {
        return 0;
    }

    #Set character to surround filenames:
    my $q = $quote_filenames ? '"' : '';

    my %subst = (
        '%O' => $options,
        '%R' => $q . $root_filename . $q,
        '%B' => $q . $base . $q,
        '%T' => $q . $texfile_name . $q,
        '%S' => $q . $source . $q,
        '%D' => $q . $dest . $q,
        '%Y' => $q . $aux_dir1 . $q,
        '%Z' => $q . $out_dir1 . $q,
        '%%' => '%'                      # To allow literal %B, %R, etc, by %%B.
    );
    if ( ( $^O eq "MSWin32" ) && $MSWin_back_slash ) {
        foreach ( '%R', '%B', '%T', '%S', '%D', '%Y', '%Z' ) {
            $subst{$_} =~ s(/)(\\)g;
        }
    }

    my @tokens = split /(%.)/, $ext_cmd;
    foreach (@tokens) {
        if ( exists( $subst{$_} ) ) { $_ = $subst{$_}; }
    }
    $ext_cmd = join '', @tokens;

    my ( $pid, $return ) =
      ( ( $msg == 0 ) || ( ( $msg == 1 ) && $silent ) )
      ? &Run($ext_cmd)
      : &Run_msg($ext_cmd);
    return $return;
}    #END Run_subst

#-----------------

sub rdb_primary_run {

    #?? See multipass_run in previous version Aug 2007 for issues
    # Call: rdb_primary_run
    # Assumes contexts for: recursion, make, & rule.
    # Assumes (a) the rule is a primary,
    #         (b) a run has to be made,
    #         (c) source files have been made.
    # This routine carries out the run of the rule unconditionally,
    # and then parses log file etc.
    my $return = 0;

    my $return_latex = &rdb_run1;
    if ( -e $$Pdest ) { $missing_dvi_pdf = ''; }

    ######### Analyze results of run:
    if ( !-e $log_name ) {
        $failure        = 1;
        $$Plast_result  = 2;
        $$Plast_message = $failure_msg =
          "(Pdf)LaTeX failed to generate the expected log file '$log_name'";
        return -1;
    }

    if ($recorder) {

        # Handle problem that some version of (pdf)latex give fls files
        #    of name latex.fls or pdflatex.fls instead of $root_filename.fls.
        # Also that setting of -output-directory -aux-directory is not
        #    respected by (pdf)latex, at least in some versions.
        my $std_fls_file    = "$aux_dir1$root_filename.fls";
        my @other_fls_names = ();
        if ( $rule =~ /^pdflatex/ ) {
            push @other_fls_names, "pdflatex.fls";
        }
        else {
            push @other_fls_names, "latex.fls";
        }
        if ( $aux_dir1 ne '' ) {
            push @other_fls_names, "$root_filename.fls";
        }
        my $have_fls = 0;
        if ( test_gen_file($std_fls_file) ) {
            $have_fls = 1;
        }
        else {
            foreach my $cand (@other_fls_names) {
                if ( test_gen_file($cand) ) {
                    copy $cand, $std_fls_file;
                    $have_fls = 1;
                    last;
                }
            }
        }
        if ( !$have_fls ) {
            warn "$My_name: fls file doesn't appear to have been made\n";
        }
    }

    # Find current set of source files:
    &rdb_set_latex_deps;

    # For each file of the kind made by epstopdf.sty during a run,
    #   if the file has changed during a run, then the new version of
    #   the file will have been read during the run.  Unlike the usual
    #   case, we will NOT need to redo the primary run because of the
    #   change of this file during the run.  Therefore set the file as
    #   up-to-date:
    rdb_do_files(
        sub {
            if ($$Pcorrect_after_primary) { &rdb_update1; }
        }
    );

    #??    # There may be new source files, and the run may have caused
    #??    # circular-dependency files to be changed.  And the regular
    #??    # source files may have been updated during a lengthy run of
    #??    # latex.  So redo the makes for sources of the current rule:
    #??    my $submake_return = &rdb_submake;
    #??    &rdb_clear_change_record;
    #??    &rdb_flag_changes_here(0);
    #??    if ($$Pout_of_date && !$silent) {
    #??        &rdb_diagnose_changes( "Rule '$rule': " );
    #??    }

    $updated = 1;    # Flag that some dependent file has been remade

    #??    # Fix the state of the files as of now: this will solve the
    #??    # problem of latex and pdflatex interfering with each other,
    #??    # at the expense of some non-optimality
    #??    #??  Check this is correct:
    #??    &rdb_update_files;

    if ($diagnostics) {
        print "$My_name: Rules after run: \n";
        rdb_show();
    }

    $return = $return_latex;

    # ???? Is the following needed?
    if ( $return_latex && $$Pout_of_date_user ) {
        print "Error in (pdf)LaTeX, but change of user file(s), ",
          "so ignore error & provoke rerun\n"
          if ( !$silent );
        $return = 0;
    }

    # Summarize issues that may have escaped notice:
    my @warnings = ();
    if ($bad_reference) {
        push @warnings, "Latex failed to resolve $bad_reference reference(s)";
    }
    if ($bad_citation) {
        push @warnings, "Latex failed to resolve $bad_citation citation(s)";
    }
    if ( $#warnings > -1 ) {
        show_array( "$My_name: Summary of warnings:", @warnings );
    }
    return $return;
}    #END rdb_primary_run

#************************************************************

sub rdb_clear_change_record {

    # Initialize diagnostics for reasons for running rule.
    @changed         = ();
    @disappeared     = ();
    @no_dest         = ();    # We are not now using this
    @rules_never_run = ();
    @rules_to_apply  = ();    # This is used in recursive application
                              # of rdb_flag_changes_here, to list
                              # rules that were out-of-date for some reason.
}    #END rdb_clear_change_record

#************************************************************

sub rdb_flag_changes_here {

    # Flag changes in current rule.
    # Assumes rule context.
    # Usage: rdb_flag_changes_here( ignore_run_time )
    # Argument: if true then fdb_get shouldn't do runtime test
    #             for recalculation of md5

    local $ignore_run_time = $_[0];
    if ( !defined $ignore_run_time ) { $ignore_run_time = 0; }

    $$Pcheck_time = time;

    local $dest_mtime = 0;
    $dest_mtime = get_mtime($$Pdest) if ($$Pdest);
    rdb_do_files( \&rdb_file_change1 );
    if ($$Pout_of_date) {
        push @rules_to_apply, $rule;
    }

    #??	print "======== flag: $rule $$Pout_of_date ==========\n";
}    #END rdb_flag_changes_here

#************************************************************

sub rdb_file_change1 {

    # Call: &rdb_file_change1
    # Assumes rule and file context.  Assumes $dest_mtime set.
    # Flag whether $file in $rule has changed or disappeared.
    # Set rule's make flag if there's a change.

    my $check_time_argument = 0;
    if ( !$ignore_run_time ) {
        $check_time_argument = max( $$Pcheck_time, $$Prun_time );
    }
    my ( $new_time, $new_size, $new_md5 ) =
      fdb_get( $file, $check_time_argument );

    #??    print "FC1 '$rule':$file $$Pout_of_date TK=$$Ptest_kind\n";
    #??    print "    OLD $$Ptime, $$Psize, $$Pmd5\n",
    #??          "    New $new_time, $new_size, $new_md5\n";
    my $ext_no_period = ext_no_period($file);
    if ( ( $new_size < 0 ) && ( $$Psize >= 0 ) ) {

        # print "Disappeared '$file' in '$rule'\n";
        push @disappeared, $file;

        # No reaction is good.
        #$$Pout_of_date = 1;
        # ??? 1 Sep. 2008: I do NOT think so, for cusdep no-file-exists issue
        # ??? 30 Sep 2008: I think I have this fixed.  There were other changes
        #  needed.  No-change-flagged is correct.  The array @disappeared flags
        #  files that have disappeared, if I need to know.  But having a source
        #  file disappear is not a reason for a remake unless I know how to
        #  make the file.  If the file is a destination of a rule, that rule
        #  will be rerun.  It may be that the user is changing another source
        #  in such a way that the disappeared file won't be needed.  Before the
        #  change is applied we get a superfluous infinite loop.
        return;
    }
    if ( ( $new_size < 0 ) && ( $$Psize < 0 ) ) {
        return;
    }
    if ( ( $new_size != $$Psize ) || ( $new_md5 ne $$Pmd5 ) ) {

#??        print "FC1: changed $file: ($new_size != $$Psize) $new_md5 ne $$Pmd5)\n";
        push @changed, $file;
        $$Pout_of_date = 1;
        if ( !exists $generated_exts_all{$ext_no_period} ) {
            $$Pout_of_date_user = 1;
        }
    }
    elsif ( $new_time != $$Ptime ) {

       #warn "--==-- Unchanged $file, changed time, update filetime in $rule\n";
        $$Ptime = $new_time;
    }
    if (   ( ( $$Ptest_kind == 2 ) || ( $$Ptest_kind == 3 ) )
        && ( !exists $generated_exts_all{$ext_no_period} )
        && ( $new_time > $dest_mtime ) )
    {
        #??        print "FC1: changed $file: ($new_time > $dest_mtime)\n";
        push @changed, $file;
        $$Pout_of_date = $$Pout_of_date_user = 1;
    }
}    #END rdb_file_change1

#************************************************************

sub rdb_new_changes {
    &rdb_clear_change_record;
    rdb_recurse( [@_], sub { &rdb_flag_changes_here(1); } );
    return
         ( $#changed >= 0 )
      || ( $#no_dest >= 0 )
      || ( $#rules_to_apply >= 0 );
}    #END rdb_new_changes

#************************************************************

sub rdb_diagnose_changes {

    # Call: rdb_diagnose_changes or rdb_diagnose_changes( heading )
    # List changes on STDERR
    # Precede the message by the optional heading, else by "$My_name: "
    my $heading = defined( $_[0] ) ? $_[0] : "$My_name: ";

    if ( $#rules_never_run >= 0 ) {
        warn "${heading}Rules & subrules not known to be previously run:\n";
        foreach (@rules_never_run) { warn "   $_\n"; }
    }
    if ( ( $#changed >= 0 ) || ( $#disappeared >= 0 ) || ( $#no_dest >= 0 ) ) {
        warn "${heading}File changes, etc:\n";
        if ( $#changed >= 0 ) {
            warn "   Changed files, or newly in use since previous run(s):\n";
            foreach ( uniqs(@changed) ) { warn "      '$_'\n"; }
        }
        if ( $#disappeared >= 0 ) {
            warn "   No-longer-existing files:\n";
            foreach ( uniqs(@disappeared) ) { warn "      '$_'\n"; }
        }
        if ( $#no_dest >= 0 ) {
            warn "   Non-existent destination files:\n";
            foreach ( uniqs(@no_dest) ) { warn "      '$_'\n"; }
        }
    }
    elsif ( $#rules_to_apply >= 0 ) {
        warn "${heading}The following rules & subrules became out-of-date:\n";
        foreach (@rules_to_apply) { warn "      '$_'\n"; }
    }
    else {
        warn "${heading}No file changes\n";
    }
}    #END rdb_diagnose_changes

#************************************************************
#************************************************************
#************************************************************
#************************************************************

#************************************************************
#************************************************************
#************************************************************
#************************************************************

# Routines for convenient looping and recursion through rule database
# ================= NEW VERSION ================

# There are several places where we need to loop through or recurse
# through rules and files.  This tends to involve repeated, tedious
# and error-prone coding of much book-keeping detail.  In particular,
# working on files and rules needs access to the variables involved,
# which either involves direct access to the elements of the database,
# and consequent fragility against changes and upgrades in the
# database structure, or involves lots of routines for reading and
# writing data in the database, then with lots of repetitious
# house-keeping code.
#
# The routines below provide a solution.  Looping and recursion
# through the database are provided by a set of basic routines where
# each necessary kind of looping and iteration is coded once.  The
# actual actions are provided as references to action subroutines.
# (These can be either actual references, as in \&routine, or
# anonymous subroutines, as in sub{...}, or aas a zero value 0 or an
# omitted argument, to indicate that no action is to be performed.)
#
# When the action subroutine(s) are actually called, a context for the
# rule and/or file (as appropriate) is given by setting named
## NEW ??
# variables to REFERENCES to the relevant data values.  These can be
# used to retrieve and set the data values.  As a convention,
# references to scalars are given by variables named start with "$P",
# as in "$Pdest", while references to arrays start with "$PA", as in
# "$PAint_cmd", and references to hashes with "$PH", as in "$PHsource".
# After the action subroutine has finished, checks for data
# consistency may be made.
## ??? OLD
# variables to the relevant data values.  After the action subroutine
# has finished, the database is updated with the values of these named
# variables, with any necessary consistency checks.  Thus the action
# subroutines can act on sensibly named variables without needed to
# know the database structure.
#
# The only routines that actually use the database structure and need
# to be changed if that is changed are:  (a) the routines rdb_one_rule
# and rdb_one_file that implement the calling of the action subroutines,
# (b) routines for creation of single rules and file items, and (c) to
# a lesser extent, the routine for destroying a file item.
#
# Note that no routine is provided for destroying a rule.  During a
# run, a rule, with its source files, may become inaccessible or
# unused.  This happens dynamically, depending on the dependencies
# caused by changes in the source file or by error conditions that
# cause the computation of dependencies, particular of latex files, to
# become wrong.  In that situation the files certainly come and go in
# the database, but subsidiary rules, with their content information
# on their source files, need to be retained so that their use can be
# reinstated later depending on dynamic changes in other files.
#
# However, there is a potential memory leak unless some pruning is
# done in what is written to the fdb file.  (Probably only accessible
# rules and those for which source files exist.  Other cases have no
# relevant information that needs to be preserved between runs.)

#
#

#************************************************************

# First the top level routines for recursion and iteration

#************************************************************

sub rdb_recurse {

    # Call: rdb_recurse( rule | [ rules],
    #                    \&rule_act1, \&file_act1, \&file_act2,
    #                    \&rule_act2 )
    # The actions are pointers to subroutines, and may be null (0, or
    # undefined) to indicate no action to be applied.
    # Recursively acts on the given rules and all ancestors:
    #   foreach rule found:
    #       apply rule_act1
    #       loop through its files:
    #          apply file_act1
    #          act on its ancestor rule, if any
    #          apply file_act2
    #       apply rule_act2
    # Guards against loops.
    # Access to the rule and file data by local variables, only
    #   for getting and setting.

    # This routine sets a context for anything recursive, with @heads,
    # %visited  and $depth being set as local variables.

    local @heads = ();
    my $rules = shift;

    # Distinguish between single rule (a string) and a reference to an
    # array of rules:
    if   ( ref $rules eq 'ARRAY' ) { @heads = @$rules; }
    else                           { @heads = ($rules); }

    # Keep a list of visited rules, used to block loops in recursion:
    local %visited = ();
    local $depth   = 0;

    foreach $rule (@heads) { rdb_recurse_rule( $rule, @_ ); }

}    #END rdb_recurse

#************************************************************

sub rdb_for_all {

    # Call: rdb_for_all( \&rule_act1, \&file_act, \&rule_act2 )
    # Loops through all rules and their source files, using the
    #   specified set of actions, which are pointers to subroutines.
    # Sorts rules alphabetically.
    # See rdb_for_some for details.
    rdb_for_some( [ sort keys %rule_db ], @_ );
}    #END rdb_for_all

#************************************************************

sub rdb_for_some {

    # Call: rdb_for_some( rule | [ rules],
    #                    \&rule_act1, \&file_act, \&rule_act2)
    # Actions can be zero, and rules at tail of argument list can be
    # omitted.  E.g. rdb_for_some( rule, 0, \&file_act ).
    # Anonymous subroutines can be used, e.g., rdb_for_some( rule, sub{...} ).
    #
    # Loops through rules and their source files, using the
    # specified set of rules:
    #   foreach rule:
    #       apply rule_act1
    #       loop through its files:
    #          apply file_act
    #       apply rule_act2
    #
    # Rule data and file data are made available in local variables
    # for access by the subroutines.

    local @heads = ();
    my $rules = shift;

    # Distinguish between single rule (a string) and a reference to an
    # array of rules:
    if   ( ref $rules eq 'ARRAY' ) { @heads = @$rules; }
    else                           { @heads = ($rules); }

    foreach $rule (@heads) {

        # $rule is implicitly local
        &rdb_one_rule( $rule, @_ );
    }
}    #END rdb_for_some

#************************************************************

sub rdb_for_one_file {
    my $rule = shift;

    # Avoid name collisions with general recursion and iteraction routines:
    local $file1   = shift;
    local $action1 = shift;
    rdb_for_some( $rule, sub { rdb_one_file( $file1, $action1 ) } );
}    #END rdb_for_one_file

#************************************************************

#   Routines for inner part of recursion and iterations

#************************************************************

sub rdb_recurse_rule {

    # Call: rdb_recurse_rule($rule, \&rule_act1, \&file_act1, \&file_act2,
    #                    \&rule_act2 )
    # to do the work for one rule, recurisvely called from_rules for
    # the sources of the rules.
    # Assumes recursion context, i.e. that %visited, @heads, $depth.
    # We are overriding actions:
    my ( $rule, $rule_act1, $new_file_act1, $new_file_act2, $rule_act2 ) = @_;

    # and must propagate the file actions:
    local $file_act1 = $new_file_act1;
    local $file_act2 = $new_file_act2;

    # Prevent loops:
    if ( ( !$rule ) || exists $visited{$rule} ) { return; }
    $visited{$rule} = 1;

    # Recursion depth
    $depth++;

    # We may need to repeat actions on dependent rules, without being
    # blocked by the test on visited files.  So save %visited:
    # NOT CURRENTLY USED!!    local %visited_at_rule_start = %visited;
    # At end, the last value set for %visited wins.
    rdb_one_rule( $rule, $rule_act1, \&rdb_recurse_file, $rule_act2 );
    $depth--;
}    #END rdb_recurse_rule

#************************************************************

sub rdb_recurse_file {

    # Call: rdb_recurse_file to do the work for one file.
    # This has no arguments, since it is used as an action subroutine,
    # passed as a reference in calls in higher-level subroutine.
    # Assumes contexts set for: Recursion, rule, and file
    &$file_act1 if $file_act1;
    rdb_recurse_rule( $$Pfrom_rule, $rule_act1, $file_act1, $file_act2,
        $rule_act2 )
      if $$Pfrom_rule;
    &$file_act2 if $file_act2;
}    #END rdb_recurse_file

#************************************************************

sub rdb_do_files {

    # Assumes rule context, including $PHsource.
    # Applies an action to all the source files of the rule.
    local $file_act = shift;
    my @file_list = sort keys %$PHsource;
    foreach my $file (@file_list) {
        rdb_one_file( $file, $file_act );
    }
}    #END rdb_do_files

#************************************************************

# Routines for action on one rule and one file.  These are the main
# places (in addition to creation and destruction routines for rules
# and files) where the database structure is accessed.

#************************************************************

sub rdb_one_rule {

    # Call: rdb_one_rule( $rule, $rule_act1, $file_act, $rule_act2 )
    # Sets context for rule and carries out the actions.
    #===== Accesses rule part of database structure =======

    local ( $rule, $rule_act1, $file_act, $rule_act2 ) = @_;

    #??    &R1;
    if ( ( !$rule ) || !rdb_rule_exists($rule) ) { return; }

    local ( $PArule_data, $PHsource, $PHdest ) = @{ $rule_db{$rule} };
    local (
        $Pcmd_type,    $Pext_cmd,      $PAint_cmd,
        $Ptest_kind,   $Psource,       $Pdest,
        $Pbase,        $Pout_of_date,  $Pout_of_date_user,
        $Prun_time,    $Pcheck_time,   $Pchanged,
        $Plast_result, $Plast_message, $PA_extra_generated
    ) = Parray($PArule_data);

    &$rule_act1              if $rule_act1;
    &rdb_do_files($file_act) if $file_act;
    &$rule_act2              if $rule_act2;

    #??    &R2;
}    #END rdb_one_rule

#************************************************************

sub rdb_one_file {

    # Call: rdb_one_file($file, $file_act)
    # Sets context for file and carries out the action.
    # Assumes $rule context set.
    #===== Accesses file part of database structure =======
    local ( $file, $file_act ) = @_;

    #??    &F1;
    if ( ( !$file ) || ( !exists ${$PHsource}{$file} ) ) { return; }
    local $PAfile_data = ${$PHsource}{$file};
    local ( $Ptime, $Psize, $Pmd5, $Pfrom_rule, $Pcorrect_after_primary ) =
      Parray($PAfile_data);
    &$file_act() if $file_act;
    if ( !rdb_rule_exists($$Pfrom_rule) ) {
        $$Pfrom_rule = '';
    }

    #??    &F2;
}    #END rdb_one_file

#************************************************************

# Routines for creation of rules and file items, and for removing file
# items.

#************************************************************

sub rdb_remove_rule {

    # rdb_remove_rule( rule, ...  )
    foreach my $key (@_) {
        delete $rule_db{$key};
    }
}

#************************************************************

sub rdb_create_rule {

    # rdb_create_rule( rule, command_type, ext_cmd, int_cmd, test_kind,
    #                  source, dest, base,
    #                  needs_making, run_time, check_time, set_file_not_exists,
    #                  ref_to_array_of_specs_of_extra_generated_files )
    # int_cmd is either a string naming a perl subroutine or it is a
    # reference to an array containing the subroutine name and its
    # arguments.
    # Makes rule.  Error if it already exists.
    # Omitted arguments: replaced by 0 or '' as needed.
    # ==== Sets rule data ====
    my (
        $rule,      $cmd_type,   $int_cmd,
        $PAext_cmd, $test_kind,  $source,
        $dest,      $base,       $needs_making,
        $run_time,  $check_time, $set_file_not_exists,
        $extra_gen
    ) = @_;
    my $changed = 0;

    # Set defaults, and normalize parameters:
    foreach ( $cmd_type, $int_cmd, $PAext_cmd, $source, $dest, $base,
        $set_file_not_exists )
    {
        if ( !defined $_ ) { $_ = ''; }
    }
    foreach ( $needs_making, $run_time, $check_time, $test_kind ) {
        if ( !defined $_ ) { $_ = 0; }
    }
    if ( !defined $test_kind ) {

        # Default to test on file change
        $test_kind = 1;
    }
    if ( ref($PAext_cmd) eq '' ) {

        #  It is a single command.  Convert to array reference:
        $PAext_cmd = [$PAext_cmd];
    }
    else {
        # COPY the referenced array:
        $PAext_cmd = [@$PAext_cmd];
    }
    my $PA_extra_gen = [];
    if ($extra_gen) {
        @$PA_extra_gen = @$extra_gen;
    }
    $rule_db{$rule} = [
        [
            $cmd_type, $int_cmd,  $PAext_cmd,  $test_kind,
            $source,   $dest,     $base,       $needs_making,
            0,         $run_time, $check_time, $changed,
            -1,        '',        $PA_extra_gen
        ],
        {},
        {}
    ];
    if ($source) {
        rdb_ensure_file( $rule, $source, undef, $set_file_not_exists );
    }
    rdb_one_rule( $rule, \&rdb_initialize_generated );
}    #END rdb_create_rule

#************************************************************

sub rdb_initialize_generated {

    # Assume rule context.
    # Initialize hash of generated files
    %$PHdest = ();
    if ($$Pdest) { rdb_add_generated($$Pdest); }
    foreach (@$PA_extra_generated) {
        rdb_add_generated($_);
    }
}    #END rdb_initialize_generated

#************************************************************

sub rdb_add_generated {

    # Assume rule context.
    # Add arguments to hash of generated files
    foreach (@_) {
        $$PHdest{$_} = 1;
    }
}    #END rdb_add_generated

#************************************************************

sub rdb_ensure_file {

# rdb_ensure_file( rule, file[, fromrule[, set_not_exists]] )
# Ensures the source file item exists in the given rule.
# Then if the fromrule is specified, set it for the file item.
# If the item is created, then:
#    (a) by default initialize it to current file state.
#    (b) but if the fourth argument, set_not_exists, is true,
#        initialize the item as if the file does not exist.
#        This case is typically used when the log file for a run
#        of latex/pdflatex claims that the file was non-existent
#        at the beginning of a run.
#============ rule and file data set here ======================================
    my $rule = shift;
    local ( $new_file, $new_from_rule, $set_not_exists ) = @_;
    if ( !rdb_rule_exists($rule) ) {
        die_trace(
            "$My_name: BUG in rdb_ensure_file: non-existent rule '$rule'");
    }
    if ( !defined $new_file ) {
        die_trace(
            "$My_name: BUG in rdb_ensure_file: undefined file for '$rule'");
    }
    if ( !defined $set_not_exists ) { $set_not_exists = 0; }
    rdb_one_rule(
        $rule,
        sub {
            if ( !exists ${$PHsource}{$new_file} ) {
                if ($set_not_exists) {
                    ${$PHsource}{$new_file} = [ 0, -1, 0, '', 0 ];
                }
                else {
                    ${$PHsource}{$new_file} =
                      [ fdb_get( $new_file, $$Prun_time ), '', 0 ];
                }
            }
        }
    );
    if ( defined $new_from_rule ) {
        rdb_for_one_file( $rule, $new_file,
            sub { $$Pfrom_rule = $new_from_rule; } );
    }
}    #END rdb_ensure_file

#************************************************************

sub rdb_remove_files {

    # rdb_remove_file( rule, file,... )
    # Removes file(s) for the rule.
    my $rule = shift;
    if ( !$rule ) { return; }
    local @files = @_;
    rdb_one_rule(
        $rule,
        sub {
            foreach (@files) { delete ${$PHsource}{$_}; }
        }
    );
}    #END rdb_remove_files

#************************************************************

sub rdb_rule_exists {

    # Call rdb_rule_exists($rule): Returns whether rule exists.
    my $rule = shift;
    if ( !$rule ) { return 0; }
    return exists $rule_db{$rule};
}    #END rdb_rule_exists

#************************************************************

sub rdb_file_exists {

    # Call rdb_file_exists($rule, $file):
    # Returns whether source file item in rule exists.
    local ( $rule, $file ) = @_;
    local $exists = 0;
    rdb_one_rule( $rule,
        sub { $exists = exists( ${$PHsource}{$file} ) ? 1 : 0; } );
    return $exists;
}    #END rdb_file_exists

#************************************************************

sub rdb_update_gen_files {

    # Assumes rule context.  Update source files of rule to current state.
    rdb_do_files(
        sub {
            if ( exists $generated_exts_all{ ext_no_period($file) } ) {
                &rdb_update1;
            }
        }
    );
}    #END rdb_update_gen_files

#************************************************************

sub rdb_update_files {

    # Call: rdb_update_files
    # Assumes rule context.  Update source files of rule to current state.
    rdb_do_files( \&rdb_update1 );
}

#************************************************************

sub rdb_update1 {

    # Call: rdb_update1.
    # Assumes file context.  Updates file data to correspond to
    # current file state on disk
    ( $$Ptime, $$Psize, $$Pmd5 ) = fdb_get($file);
}

#************************************************************

sub rdb_set_file1 {

    # Call: fdb_file1(rule, file, new_time, new_size, new_md5)
    # Sets file time, size and md5.
    my $rule = shift;
    my $file = shift;

    my @new_file_data = @_;
    rdb_for_one_file( $rule, $file,
        sub { ( $$Ptime, $$Psize, $$Pmd5 ) = @new_file_data; } );
}

#************************************************************

sub rdb_dummy_file {

    # Returns file data for non-existent file
    # ==== Uses rule_db structure ====
    return ( 0, -1, 0, '' );
}

#************************************************************
#************************************************************

# Predefined subroutines for custom dependency

sub cus_dep_delete_dest {

    # This subroutine is used for situations like epstopdf.sty, when
    #   the destination (target) of the custom dependency invoking
    #   this subroutine will be made by the primary run provided the
    #   file (destination of the custom dependency, source of the
    #   primary run) doesn't exist.
    # It is assumed that the resulting file will be read by the
    #   primary run.

    # Remove the destination file, to indicate it needs to be remade:
    unlink_or_move($$Pdest);

    # Arrange that the non-existent destination file is not treated as
    #   an error.  The variable changed here is a bit misnamed.
    $$Pchanged = 1;

    # Ensure a primary run is done
    &cus_dep_require_primary_run;

    # Return success:
    return 0;
}

#************************************************************

sub cus_dep_require_primary_run {

    # This subroutine is used for situations like epstopdf.sty, when
    #   the destination (target) of the custom dependency invoking
    #   this subroutine will be made by the primary run provided the
    #   file (destination of the custom dependency, source of the
    #   primary run) doesn't exist.
    # It is assumed that the resulting file will be read by the
    #   primary run.

    local $cus_dep_target = $$Pdest;

    # Loop over all rules and source files:
    rdb_for_all(
        0,
        sub {
            if ( $file eq $cus_dep_target ) {
                $$Pout_of_date           = 1;
                $$Pcorrect_after_primary = 1;
            }
        }
    );

    # Return success:
    return 0;
}

#************************************************************
#************************************************************
#************************************************************
#
#      UTILITIES:
#

#************************************************************
# Miscellaneous

sub show_array {

    # For use in diagnostics and debugging.
    #  On stderr, print line with $_[0] = label.
    #  Then print rest of @_, one item per line preceeded by some space
    warn "$_[0]\n";
    shift;
    if ( $#_ >= 0 ) {
        foreach (@_) { warn "  $_\n"; }
    }
    else { warn "  NONE\n"; }
}

#************************************************************

sub Parray {

    # Call: Parray( \@A )
    # Returns array of references to the elements of @A
    # But if an element of @A is already a reference, the
    # reference will be returned in the output array, not a
    # reference to the reference.
    my $PA = shift;
    my @P = (undef) x ( 1 + $#$PA );
    foreach my $i ( 0 .. $#$PA ) {
        $P[$i] = ( ref $$PA[$i] ) ? ( $$PA[$i] ) : ( \$$PA[$i] );
    }
    return @P;
}

#************************************************************

sub glob_list {

    # Glob a collection of filenames.  Sort and eliminate duplicates
    # Usage: e.g., @globbed = glob_list(string, ...);
    my @globbed = ();
    foreach (@_) {
        push @globbed, glob;
    }
    return uniqs(@globbed);
}

#==================================================

sub glob_list1 {

  # Glob a collection of filenames.
  # But no sorting or elimination of duplicates
  # Usage: e.g., @globbed = glob_list1(string, ...);
  # Since perl's glob appears to use space as separator, I'll do a special check
  # for existence of non-globbed file (assumed to be tex like)

    my @globbed = ();
    foreach my $file_spec (@_) {

# Problem, when the PATTERN contains spaces, the space(s) are
# treated as pattern separaters (in MSWin at least).
# MSWin: I can quote the pattern (is that MSWin native, or also
#        cygwin?)
# Linux: Quotes in a pattern are treated as part of the filename!
#        So quoting a pattern is definitively wrong.
# The following hack solves this partly, for the cases that there is no wildcarding
#    and the specified file exists possibly space-containing, and that there is wildcarding,
#    but spaces are prohibited.
        if ( -e $file_spec || -e "$file_spec.tex" ) {

     # Non-globbed file exists, return the file_spec.
     # Return $file_spec only because this is not a file-finding subroutine, but
     #   only a globber
            push @globbed, $file_spec;
        }
        else {
           # This glob fails to work as desired, if the pattern contains spaces.
            push @globbed, glob("$file_spec");
        }
    }
    return @globbed;
}    #END glob_list1

#************************************************************
# Miscellaneous

sub prefix {

    #Usage: prefix( string, prefix );
    #Return string with prefix inserted at the front of each line
    my @line = split( /\n/, $_[0] );
    my $prefix = $_[1];
    for ( my $i = 0 ; $i <= $#line ; $i++ ) {
        $line[$i] = $prefix . $line[$i] . "\n";
    }
    return join( "", @line );
}    #END prefix

#===============================

sub parse_quotes {

    # Split string into words.
    # Words are delimited by space, except that strings
    # quoted all stay inside a word.  E.g.,
    #   'asdf B" df "d "jkl"'
    # is split to ( 'asdf', 'B df d', 'jkl').
    # An array is returned.
    my @results = ();
    my $item    = '';
    local $_ = shift;
    pos($_) = 0;
  ITEM:
    while () {
        /\G\s*/gc;
        if (/\G$/) {
            last ITEM;
        }

        # Now pos (and \G) is at start of item:
      PART:
        while () {
            if (/\G([^\s\"]*)/gc) {
                $item .= $1;
            }
            if (/\G\"([^\"]*)\"/gc) {

                # Match balanced quotes
                $item .= $1;
                next PART;
            }
            elsif (/\G\"(.*)$/gc) {

                # Match unbalanced quote
                $item .= $1;
                warn "====Non-matching quotes in\n    '$_'\n";
            }
            push @results, $item;
            $item = '';
            last PART;
        }
    }
    return @results;
}    #END parse_quotes

#************************************************************
#************************************************************
#      File handling utilities:

#************************************************************

sub get_latest_mtime

  # - arguments: each is a filename.
  # - returns most recent modify time.
{
    my $return_mtime = 0;
    foreach my $include (@_) {
        my $include_mtime = &get_mtime($include);

        # The file $include may not exist.  If so ignore it, otherwise
        # we'll get an undefined variable warning.
        if ( ($include_mtime) && ( $include_mtime > $return_mtime ) ) {
            $return_mtime = $include_mtime;
        }
    }
    return $return_mtime;
}

#************************************************************

sub get_mtime_raw {
    my $mtime = ( stat( $_[0] ) )[9];
    return $mtime;
}

#************************************************************

sub get_mtime {
    return get_mtime0( $_[0] );
}

#************************************************************

sub get_mtime0 {

    # Return time of file named in argument
    # If file does not exist, return 0;
    if ( -e $_[0] ) {
        return get_mtime_raw( $_[0] );
    }
    else {
        return 0;
    }
}

#************************************************************

sub get_size {

    # Return time of file named in argument
    # If file does not exist, return 0;
    if ( -e $_[0] ) {
        return get_size_raw( $_[0] );
    }
    else {
        return 0;
    }
}

#************************************************************

sub get_size_raw {
    my $size = ( stat( $_[0] ) )[7];
    return $size;
}

#************************************************************

sub get_time_size {

    # Return time and size of file named in argument
    # If file does not exist, return (0,-1);
    if ( -e $_[0] ) {
        return get_time_size_raw( $_[0] );
    }
    else {
        return ( 0, -1 );
    }
}

#************************************************************

sub get_time_size_raw {
    my $mtime = ( stat( $_[0] ) )[9];
    my $size  = ( stat( $_[0] ) )[7];
    return ( $mtime, $size );
}

#************************************************************

sub processing_time {
    my ( $user, $system, $cuser, $csystem ) = times();
    return $user + $system + $cuser + $csystem;
}

#************************************************************

sub get_checksum_md5 {
    my $source         = shift;
    my $input          = new FileHandle;
    my $md5            = Digest::MD5->new;
    my $ignore_pattern = '';

    #&traceback;
    #warn "======= GETTING MD5: $source\n";
    if ( $source eq "" ) {

        # STDIN:
        open( $input, '-' );
    }
    elsif ( -d $source ) {

        # We won't use checksum for directory
        return 0;
    }
    else {
        open( $input, '<', $source )
          or return 0;
        my ( $base, $path, $ext ) = fileparseA($source);
        $ext =~ s/^\.//;
        if ( exists $hash_calc_ignore_pattern{$ext} ) {
            $ignore_pattern = $hash_calc_ignore_pattern{$ext};
        }
    }

    if ($ignore_pattern) {
        while (<$input>) {
            if (/$ignore_pattern/) {
                $_ = '';
            }
            $md5->add($_);
        }
    }
    else {
        $md5->addfile($input);
    }
    close $input;
    return $md5->hexdigest();
}

#************************************************************
#************************************************************

sub find_file1 {

    #?? Need to use kpsewhich, if possible

    # Usage: find_file1(name, ref_to_array_search_path)
    # Modified find_file, which doesn't die.
    # Given filename and path, return array of:
    #             full name
    #             retcode
    # On success: full_name = full name with path, retcode = 0
    # On failure: full_name = given name, retcode = 1

    my $name = $_[0];

    # Make local copy of path, since we may rewrite it!
    my @path = ();
    if ( $_[1] ) {
        @path = @{ $_[1] };
    }
    if ( $name =~ /^\// ) {

        # Absolute path (if under UNIX)
        # This needs fixing, in general
        if   ( -e $name ) { return ( $name, 0 ); }
        else              { return ( $name, 1 ); }
    }
    foreach my $dir (@path) {

        #??print "-------------dir='$dir',  ";
        # Make $dir concatenatable, and empty for current dir:
        if ( $dir eq '.' ) {
            $dir = '';
        }
        elsif ( $dir =~ /[\/\\:]$/ ) {

            #OK if dir ends in / or \ or :
        }
        elsif ( $dir ne '' ) {

            #Append directory separator only to non-empty dir
            $dir = "$dir/";
        }

        #?? print " newdir='$dir'\n";
        if ( -e "$dir$name" ) {
            return ( "$dir$name", 0 );
        }
    }
    my @kpse_result = kpsewhich($name);
    if ( $#kpse_result > -1 ) {
        return ( $kpse_result[0], 0 );
    }
    return ( "$name", 1 );
}    #END find_file1

#************************************************************

sub find_file_list1 {

    # Modified version of find_file_list that doesn't die.
    # Given output and input arrays of filenames, a file suffix, and a path,
    # fill the output array with full filenames
    # Return array of not-found files.
    # Usage: find_file_list1( ref_to_output_file_array,
    #                         ref_to_input_file_array,
    #                         suffix,
    #                         ref_to_array_search_path
    #                       )

    my $ref_output = $_[0];
    my $ref_input  = $_[1];
    my $suffix     = $_[2];
    my $ref_search = $_[3];
    my @not_found  = ();

#??  show_array( "=====find_file_list1.  Suffix: '$suffix'\n Source:",  @$ref_input );
#??  show_array( " Bibinputs:",  @$ref_search );

    my @return_list = ();    # Generate list in local array, since input
                             # and output arrays may be same
    my $retcode     = 0;
    foreach my $file (@$ref_input) {
        my ( $tmp_file, $find_retcode ) =
          &find_file1( "$file$suffix", $ref_search );
        if ($tmp_file) {
            push @return_list, $tmp_file;
        }
        if ( $find_retcode != 0 ) {
            push @not_found, $file . $suffix;
        }
    }
    @$ref_output = @return_list;

#??  show_array( " Output", @$ref_output );
#??  foreach (@$ref_output) { if ( /\/\// ) {  print " ====== double slash in  '$_'\n"; }  }
    return @not_found;
}    #END find_file_list1

#************************************************************

sub unlink_or_move {
    if ( $del_dir eq '' ) {
        unlink @_;
    }
    else {
        foreach (@_) {
            if ( -e $_ && !rename $_, "$del_dir/$_" ) {
                warn "$My_name:Cannot move '$_' to '$del_dir/$_'\n";
            }
        }
    }
}

#************************************************************

sub kpsewhich {

    # Usage: kpsewhich( filespec, ...)
    # Returns array of files with paths as found by kpsewhich
    #    kpsewhich( 'try.sty', 'jcc.bib' );
    # Can also do, e.g.,
    #    kpsewhich( '-format=bib', 'trial.bib', 'file with spaces');
    my $cmd  = $kpsewhich;
    my @args = @_;
    foreach (@args) {
        if ( !/^-/ ) {
            $_ = "\"$_\"";
        }
    }
    foreach ($cmd) {
        s/%[RBTDO]//g;
    }
    $cmd =~ s/%S/@args/g;
    my @found = ();
    local $fh;
    open $fh, "$cmd|"
      or die "Cannot open pipe for \"$cmd\"\n";
    while (<$fh>) {
        s/^\s*//;
        s/\s*$//;
        push @found, $_;
    }
    close $fh;

    #    show_array( "Kpsewhich: '$cmd', '$file_list' ==>", @found );
    return @found;
}

####################################################

sub add_cus_dep {

    # Usage: add_cus_dep( from_ext, to_ext, flag, sub_name )
    # Add cus_dep after removing old versions
    my ( $from_ext, $to_ext, $must, $sub_name ) = @_;
    remove_cus_dep( $from_ext, $to_ext );
    push @cus_dep_list, "$from_ext $to_ext $must $sub_name";
}

####################################################

sub remove_cus_dep {

    # Usage: remove_cus_dep( from_ext, to_ext )
    my ( $from_ext, $to_ext ) = @_;
    my $i = 0;
    while ( $i <= $#cus_dep_list ) {
        if ( $cus_dep_list[$i] =~ /^$from_ext $to_ext / ) {
            splice @cus_dep_list, $i, 1;
        }
        else {
            $i++;
        }
    }
}

####################################################

sub show_cus_dep {
    show_array( "Custom dependency list:", @cus_dep_list );
}

####################################################

sub add_input_ext {

    # Usage: add_input_ext( rule, ext, ... )
    # Add extension(s) (specified without a leading period) to the
    # list of input extensions for the given rule.  The rule should be
    # 'latex' or 'pdflatex'.  These extensions are used when an input
    # file without an extension is found by (pdf)latex, as in
    # \input{file} or \includegraphics{figure}.  When latexmk searches
    # custom dependencies to make the missing file, it will assume that
    # the file has one of the specified extensions.
    my $rule = shift;
    if ( !exists $input_extensions{$rule} ) {
        $input_extensions{$rule} = {};
    }
    my $Prule = $input_extensions{$rule};
    foreach (@_) { $$Prule{$_} = 1; }
}

####################################################

sub remove_input_ext {

    # Usage: remove_input_ext( rule, ext, ... )
    # Remove extension(s) (specified without a leading period) to the
    # list of input extensions for the given rule.  The rule should be
    # 'latex' or 'pdflatex'.  See sub add_input_ext for the use.
    my $rule = shift;
    if ( !exists $input_extensions{$rule} ) { return; }
    my $Prule = $input_extensions{$rule};
    foreach (@_) { delete $$Prule{$_}; }
}

####################################################

sub show_input_ext {

    # Usage: show_input_ext( rule )
    my $rule = shift;
    show_array(
        "Input extensions for rule '$rule': ",
        keys %{ $input_extensions{$rule} }
    );
}

####################################################

sub find_dirs1 {

    # Same as find_dirs, but argument is single string with directories
    # separated by $search_path_separator
    find_dirs( &split_search_path( $search_path_separator, ".", $_[0] ) );
}

#************************************************************

sub find_dirs {

    # @_ is list of directories
    # return: same list of directories, except that for each directory
    #         name ending in //, a list of all subdirectories (recursive)
    #         is added to the list.
    #   Non-existent directories and non-directories are removed from the list
    #   Trailing "/"s and "\"s are removed
    local @result = ();
    my $find_action = sub {    ## Subroutine for use in File::find
        ## Check to see if we have a directory
        if (-d) { push @result, $File::Find::name; }
    };
    foreach my $directory (@_) {
        my $recurse = ( $directory =~ m[//$] );

        # Remove all trailing /s, since directory name with trailing /
        #   is not always allowed:
        $directory =~ s[/+$][];

        # Similarly for MSWin reverse slash
        $directory =~ s[\\+$][];
        if ( !-e $directory ) {
            next;
        }
        elsif ($recurse) {

            # Recursively search directory
            find( $find_action, $directory );
        }
        else {
            push @result, $directory;
        }
    }
    return @result;
}

#************************************************************

sub uniq

  # Read arguments, delete neighboring items that are identical,
  # return array of results
{
    my @sort = ();
    my ( $current, $prev );
    my $first = 1;
    while (@_) {
        $current = shift;
        if ( $first || ( $current ne $prev ) ) {
            push @sort, $current;
            $prev  = $current;
            $first = 0;
        }
    }
    return @sort;
}

#==================================================

sub uniq1 {

    # Usage: uniq1( strings )
    # Returns array of strings with duplicates later in list than
    # first occurence deleted.  Otherwise preserves order.

    my @strings     = ();
    my %string_hash = ();

    foreach my $string (@_) {
        if ( !exists( $string_hash{$string} ) ) {
            $string_hash{$string} = 1;
            push @strings, $string;
        }
    }
    return @strings;
}

#************************************************************

sub uniqs {

    # Usage: uniq2( strings )
    # Returns array of strings sorted and with duplicates deleted
    return uniq( sort @_ );
}

#************************************************************

sub ext {

    # Return extension of filename.  Extension includes the period
    my $file_name = $_[0];
    my ( $base_name, $path, $ext ) = fileparseA($file_name);
    return $ext;
}

#************************************************************

sub ext_no_period {

    # Return extension of filename.  Extension excludes the period
    my $file_name = $_[0];
    my ( $base_name, $path, $ext ) = fileparseA($file_name);
    $ext =~ s/^\.//;
    return $ext;
}

#************************************************************

sub fileparseA {

    # Like fileparse but replace $path for current dir ('./' or '.\') by ''
    # Also default second argument to get normal extension.
    my $given   = $_[0];
    my $pattern = '\.[^\.]*';
    if ( $#_ > 0 ) { $pattern = $_[1]; }
    my ( $base_name, $path, $ext ) = fileparse( $given, $pattern );
    if ( ( $path eq './' ) || ( $path eq '.\\' ) ) {
        $path = '';
    }
    return ( $base_name, $path, $ext );
}

#************************************************************

sub fileparseB {

    # Like fileparse but with default second argument for normal extension
    my $given   = $_[0];
    my $pattern = '\.[^\.]*';
    if ( $#_ > 0 ) { $pattern = $_[1]; }
    my ( $base_name, $path, $ext ) = fileparse( $given, $pattern );
    return ( $base_name, $path, $ext );
}

#************************************************************

sub split_search_path {

    # Usage: &split_search_path( separator, default, string )
    # Splits string by separator and returns array of the elements
    # Allow empty last component.
    # Replace empty terms by the default.
    my $separator   = $_[0];
    my $default     = $_[1];
    my $search_path = $_[2];
    my @list        = split( /$separator/, $search_path );
    if ( $search_path =~ /$separator$/ ) {

        # If search path ends in a blank item, the split subroutine
        #    won't have picked it up.
        # So add it to the list by hand:
        push @list, "";
    }

    # Replace each blank argument (default) by current directory:
    for ( $i = 0 ; $i <= $#list ; $i++ ) {
        if ( $list[$i] eq "" ) { $list[$i] = $default; }
    }
    return @list;
}

#################################

sub tempfile1 {

    # Makes a temporary file of a unique name.  I could use file::temp,
    # but it is not present in all versions of perl
    # Filename is of form $tmpdir/$_[0]nnn$suffix, where nnn is an integer
    my $tmp_file_count = 0;
    my $prefix         = $_[0];
    my $suffix         = $_[1];
    while ( 1 == 1 ) {

        # Find a new temporary file, and make it.
        $tmp_file_count++;
        my $tmp_file = "${tmpdir}/${prefix}${tmp_file_count}${suffix}";
        if ( !-e $tmp_file ) {
            open( TMP, ">$tmp_file" )
              or next;
            close(TMP);
            return $tmp_file;
        }
    }
    die "$My_name.tempfile1: BUG TO ARRIVE HERE\n";
}

#################################

#************************************************************
#************************************************************
#      Process/subprocess routines

sub Run_msg {

    # Same as Run, but give message about my running
    warn_running("Running '$_[0]'");
    my $time1 = processing_time();
    my ( $pid, $return ) = Run( $_[0] );
    my $time = processing_time() - $time1;
    push @timings, "'$_[0]': time = $time\n";
    return ( $pid, $return );
}    #END Run_msg

#==================

sub Run {

 # Usage: Run ("command string");
 #    or  Run ("one-or-more keywords command string");
 # Possible keywords: internal, NONE, start, nostart.
 #
 # A command string not started by keywords just gives a call to system with
 #   the specified string, I return after that has finished executing.
 # Exceptions to this behavior are triggered by keywords.
 # The general form of the string is
 #    Zero or more occurences of the start keyword,
 #    followed by at most one of the other key words (internal, nostart, NONE),
 #    followed by (a) a command string to be executed by the systerm
 #             or (b) if the command string is specified to be internal, then
 #                    it is of the form
 #
 #                       routine arguments
 #
 #                    which implies invocation of the named Perl subroutine
 #                    with the given arguments, which are obtained by splitting
 #                    the string into words, delimited by spaces, but with
 #                    allowance for double quotes.
 #
 # The meaning of the keywords is:
 #
 #    start: The command line is to be running detached, as appropriate for
 #             a previewer.  The method is appropriate for the operating system
 #             (and the keyword is inspired by the action of the start command
 #             that implements in under MSWin).
 #           HOWEVER: the start keyword is countermanded by the nostart,
 #             internal, and NONE keywords.  This allows rules that do
 #             previewing to insert a start keyword to create a presumption
 #             of detached running unless otherwise.
 #   nostart: Countermands a previous start keyword; the following command
 #             string is then to be obeyed by the system, and any necessary
 #             detaching (as of a previewer) is done by the executed command(s).
 #   internal: The following command string, of the form 'routine arguments'
 #             specifies a call to the named Perl subroutine.
 #   NONE:   This does not run anything, but causes an error message to be
 #             printed.  This is provided to allow program names defined in the
 #             configuration to flag themselves as unimplemented.
 # Note that if the word "start" is duplicated at the beginning, that is
 #   equivalent to a single "start".
 #
 # Return value is a list (pid, exitcode):
 #   If a process is spawned sucessfully, and I know the PID,
 #       return (pid, 0),
 #   else if process is spawned sucessfully, but I do not know the PID,
 #       return (0, 0),
 #   else if process is run,
 #       return (0, exitcode of process)
 #   else if I fail to run the requested process
 #       return (0, suitable return code)
 #   where return code is 1 if cmdline is null or begins with "NONE" (for
 #       an unimplemented command)
 #       or the return value of the Perl subroutine.
    my $cmd_line = $_[0];
    if ( $cmd_line eq '' ) {
        traceback( "$My_name: Bug OR configuration error\n"
              . "   In run of '$rule', attempt to run a null program" );
        return ( 0, 1 );
    }

    # Deal with latexmk-defined pseudocommands 'start' and 'NONE'
    # at front of command line:
    my $detach = 0;
    while ( $cmd_line =~ s/^start +// ) {

        # But first remove extra starts (which may have been inserted
        # to force a command to be run detached, when the command
        # already contained a "start").
        $detach = 1;
    }
    if ( $cmd_line =~ s/^nostart +// ) {
        $detach = 0;
    }
    if ( $cmd_line =~ /^internal\s+([a-zA-Z_]\w*)\s+(.*)$/ ) {
        my $routine = $1;
        my @args    = parse_quotes($2);
        warn "$My_name: calling $routine( @args )\n";
        return ( 0, &$routine(@args) );
    }
    elsif ( $cmd_line =~ /^NONE/ ) {
        warn "$My_name: ",
          "Program not implemented for this version.  Command line:\n";
        warn "   '$cmd_line'\n";
        return ( 0, 1 );
    }
    elsif ($detach) {

        # Run detached.  How to do this depends on the OS
        return &Run_Detached($cmd_line);
    }
    else {
        # The command is given to system as a single argument, to force shell
        # metacharacters to be interpreted:
        return ( 0, system($cmd_line ) );
    }
}    #END Run

#************************************************************

sub Run_Detached {

    # Usage: Run_Detached ("program arguments ");
    # Runs program detached.  Returns 0 on success, 1 on failure.
    # Under UNIX use a trick to avoid the program being killed when the
    #    parent process, i.e., me, gets a ctrl/C, which is undesirable for pvc
    #    mode.  (The simplest method, system ("program arguments &"), makes the
    #    child process respond to the ctrl/C.)
    # Return value is a list (pid, exitcode):
    #   If process is spawned sucessfully, and I know the PID,
    #       return (pid, 0),
    #   else if process is spawned sucessfully, but I do not know the PID,
    #       return (0, 0),
    #   else if I fail to spawn a process
    #       return (0, 1)

    my $cmd_line = $_[0];

##    warn "Running '$cmd_line' detached...\n";
    if ( $cmd_line =~ /^NONE / ) {
        warn "$My_name: ",
          "Program not implemented for this version.  Command line:\n";
        warn "   '$cmd_line'\n";
        return ( 0, 1 );
    }

    if ( "$^O" eq "MSWin32" ) {

        # Win95, WinNT, etc: Use MS's start command:
        # Need extra double quotes to deal with quoted filenames:
        #    MSWin start takes first quoted argument to be a Window title.
        return ( 0, system("start \"\" $cmd_line") );
    }
    else {
        # Assume anything else is UNIX or clone
        # For this purpose cygwin behaves like UNIX.
        ## warn "Run_Detached.UNIX: A\n";
        my $pid = fork();
        ## warn "Run_Detached.UNIX: B pid=$pid\n";
        if ( !defined $pid ) {
            ## warn "Run_Detached.UNIX: C\n";
            warn "$My_name: Could not fork to run the following command:\n";
            warn "   '$cmd_line'\n";
            return ( 0, 1 );
        }
        elsif ( $pid == 0 ) {
            ## warn "Run_Detached.UNIX: D\n";
            # Forked child process arrives here
            # Insulate child process from interruption by ctrl/C to kill parent:
            #     setpgrp(0,0);
            # Perhaps this works if setpgrp doesn't exist
            #    (and therefore gives fatal error):
            eval { setpgrp( 0, 0 ); };
            exec($cmd_line );

            # Exec never returns; it replaces current process by new process
            die "$My_name forked process: could not run the command\n",
              "  '$cmd_line'\n";
        }
        ##warn "Run_Detached.UNIX: E\n";
        # Original process arrives here
        return ( $pid, 0 );
    }

    # NEVER GET HERE.
    ##warn "Run_Detached.UNIX: F\n";
}    #END Run_Detached

#************************************************************

sub find_process_id {

    # find_process_id(string) finds id of process containing string and
    # being run by the present user.  Typically the string will be the
    # name of the process or part of its command line.
    # On success, this subroutine returns the process ID.
    # On failure, it returns 0.
    # This subroutine only works on UNIX systems at the moment.

    if ( $pid_position < 0 ) {

        # I cannot do a ps on this system
        return (0);
    }

    my $looking_for = $_[0];
    my @ps_output   = `$pscmd`;

    # There may be multiple processes.  Find only latest,
    #   almost surely the one with the highest process number
    # This will deal with cases like xdvi where a script is used to
    #   run the viewer and both the script and the actual viewer binary
    #   have running processes.
    my @found = ();

    shift(@ps_output);    # Discard the header line from ps
    foreach (@ps_output) {
        next unless (/$looking_for/);
        my @ps_line = split(' ');

        # OLD       return($ps_line[$pid_position]);
        push @found, $ps_line[$pid_position];
    }

    if ( $#found < 0 ) {

        # No luck in finding the specified process.
        return (0);
    }
    @found = reverse sort @found;
    if ($diagnostics) {
        print "Found the following processes concerning '$looking_for'\n",
          "   @found\n",
          "   I will use $found[0]\n";
    }
    return $found[0];
}

#************************************************************
#************************************************************
#************************************************************

#============================================

sub cache_good_cwd {

    # Set cached value of cwd to current cwd.
    # Under cygwin, the cwd is converted to a native MSWin path so
    # that the result can be used for input to MSWin programs as well
    # as cygwin programs.
    my $cwd = cwd();
    if ( $^O eq "cygwin" ) {
        my $cmd     = "cygpath -w \"$cwd\"";
        my $Win_cwd = `$cmd`;
        chomp $Win_cwd;
        if ($Win_cwd) {
            $cwd = $Win_cwd;
        }
        else {
            warn "$My_name: Could not correctly run command\n",
              "      '$cmd'\n",
              "  to get MSWin version of cygwin path\n",
              "     '$cwd'\n",
              "  The result was\n",
              "     'Win_cwd'\n";
        }
    }
    $cache{cwd} = $cwd;
}    # END cache_good_cwd

#============================================

sub good_cwd {

    # Return cwd, but under cygwin, convert to MSWin path.
    # Use cached result
    return $cache{cwd};
}    # END good_cwd

#============================================

#   Directory stack routines

sub pushd {
    push @dir_stack, [ cwd(), $cache{cwd} ];
    if ( $#_ > -1 ) {
        chdir $_[0];
        &cache_good_cwd;
    }
}

#************************************************************

sub popd {
    if ( $#dir_stack > -1 ) {
        my $Parr = pop @dir_stack;
        chdir $$Parr[0];
        $cache{cwd} = $$Parr[1];
    }
}

#************************************************************

sub ifcd_popd {
    if ($do_cd) {
        warn "$My_name: Undoing directory change\n";
        &popd;
    }
}

#************************************************************

sub finish_dir_stack {
    while ( $#dir_stack > -1 ) { &popd; }
}

#************************************************************
#************************************************************
# Break handling routines (for wait-loop in preview continuous)

sub end_wait {

    #  Handler for break: Set global variable $have_break to 1.
    # Some systems (e.g., MSWin reset) appear to reset the handler.
    # So I'll re-enable it
    &catch_break;
    $have_break = 1;
}

#========================

sub catch_break {

    # Capture ctrl/C and ctrl/break.
    # $SIG{INT} corresponds to ctrl/C on LINUX/?UNIX and MSWin
    # $SIG{BREAK} corresponds to ctrl/break on MSWin, doesn't exist on LINUX
    $SIG{INT} = \&end_wait;
    if ( exists $SIG{BREAK} ) {
        $SIG{BREAK} = \&end_wait;
    }
}

#========================

sub default_break {

    # Arrange for ctrl/C and ctrl/break to give default behavior
    $SIG{INT} = 'DEFAULT';
    if ( exists $SIG{BREAK} ) {
        $SIG{BREAK} = 'DEFAULT';
    }
}

#************************************************************
#************************************************************
##our $a="$b + $c + ___werewr";
#our @b=qw(a b c);
#our %c=(a  => 1);

# N.B. !!!!!!!!!!!  See 17 July 2012 comments !!!!!!!!!!!!!!!!!!

# On a UNIX-like system, the above enables latexmk to run independently
#   of the location of the perl executable.  This line relies on the
#   existence of the program /usr/bin/env
# If there is a problem for any reason, you can replace the first line of
#   this file by:

# with the path of the perl executable adjusted for your system.

# Delete #??!! when working

# See ?? <===============================

## ?? Issues with clean-up
## List of aux files deleted is those read, not those generated.
## Other files are generated by (pdf)latex; should they be deleted?
## (I have hooks for this).

#=======================================

#??  Force mode doesn't appear to do force (if error in latex file)
#??? Get banner back in.
#??  CORRECT DIAGNOSTICS ON CHANGED FILES IF THEY DIDN'T EXIST BEFORE
#??  Further corrections to deal with disappeared source files for custom dependencies.
#       Message repeatedly appears about remake when source file of cusdep doesn't exist.
#??  logfile w/o fdb file: don't set changed file, perhaps for generated exts.
#    Reconsider
#??  Do proper run-stuff for bibtex, makeindex, cus-deps.  OK I think
#    Parse and correctly find ist files

# ATTEMPT TO ALLOW FILENAMES WITH SPACES:
#    (as of 1 Apr 2006, and then 14 Sep. 2007)

# Problems:
# A.  Quoting filenames will not always work.
#        a.  Under UNIX, quotes are legal in filenames, so when PERL
#            directly runs a binary, a quoted filename will be treated as
#            as a filename containing a quote character.  But when it calls
#            a shell, the quotes are handled by the shell as quotes.
#        b.  Under MSWin32, quotes are illegal filename characters, and tend
#            to be handled correctly.
#        c.  But under cygwin, results are not so clear (there are many
#            combinations: native v. cygwin perl, native v cygwin programs
#            NT v. unix scripts, which shell is called.
# B.  TeX doesn't always handle filenames with spaces gracefully.
#        a.  UNIX/LINUX: The version on gluon2 Mar 31, 2006 to Sep. 2007)
#            doesn't handle them at all.  (TeX treats space as separator.)
#        b.  At least some later versions actually do (Brad Miller e-mail,
#            Sep. 2007).
#        c.  fptex [[e-TeXk, Version 3.141592-2.1 (Web2c 7.5.2)] does, on
#            my MSWin at home.  In \input the filename must be in quotes.
#        d.  Bibtex [BibTeX (Web2c 7.5.2) 0.99c on my MSWin system at home,
#            Sep. 2007] does not allow names of bibfiles to have spaces.
# C.  =====> Using the shell for command lines is not safe, since special
#     characters can cause lots of mayhem.
#     It will therefore be a good idea to sanitize filenames.
#
# I've sanitized all calls out:
#     a. system and exec use a single argument, which forces
#        use of shell, under all circumstances
#        Thus I can safely use quotes on filenames:  They will be handled by
#        the shell under UNIX, and simply passed on to the program under MSWin32.
#     b. I reorganized Run, Run_Detached to use single command line
#     c. All calls to Run and Run_Detached have quoted filenames.
#     d. So if a space-free filename with wildcards is given on latexmk's
#        command line, and it globs to space-containing filename(s), that
#        works (fptex on home computer, native NT tex)
#     e. ====> But globbing fails: the glob function takes space as filename
#        separator.   ====================

#================= TO DO ================
#
# 1.  See ??  ESPECIALLY $MSWin_fudge_break
# 2.  Check fudged conditions in looping and make_files
# 3.  Should not completely abort after a run that ends in failure from latex
#     Missing input files (including via custom dependency) should be checked for
#     a change in status
#         If sources for missing files from custom dependency
#             are available, then do a rerun
#         If sources of any kind become available rerun (esp. for pvc)
#             rerun
#         Must parse log_file after unsuccessful run of latex: it may give
#             information about missing files.
# 4.  Check file of bug reports and requests
# 5.  Rationalize bibtex warnings and errors.  Two almost identical routines.
#         Should 1. Use single routine
#                2. Convert errors to failure only in calling routine
#                3. Save first warning/error.

# ?? Use of generated_exts arrays and hashes needs rationalization

# To do:
#   Rationalize again handling of include files.
#     Now I use kpsewhich to do searches, if file not found
#        (How do I avoid getting slowed down too much?)
#   Document the assumptions at each stage of processing algorithm.
#   Option to restart previewer automatically, if it dies under -pvc
#   Test for already running previewer gets wrong answer if another
#     process has the viewed file in its command line

## Copyright John Collins 1998-2012
##           (username collins at node phys.psu.edu)
##      (and thanks to David Coppit (username david at node coppit.org)
##           for suggestions)
## Copyright Evan McLean
##         (modifications up to version 2)
## Copyright 1992 by David J. Musliner and The University of Michigan.
##         (original version)
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
##
##
##
##   NEW FEATURES, since v. 2.0:
##     1.  Correct algorithm for deciding how many times to run latex:
##         based on whether source file(s) change between runs
##     2.  Continuous preview works, and can be of ps file or dvi file
##     3.  pdf creation by pdflatex possible
##     4.  Defaults for commands are OS dependent.
##     5.  Parsing of log file instead of source file is used to
##         obtain dependencies, by default.
##
##   Modification log from 9 Dec 2011 onwards in detail
##
##   12 Jan 2012 STILL NEED TO DOCUMENT some items below
##     11 Nov 2012  John Collins  V. 4.35
##                                Correct bug that under some combinations of
##                                   MS-Windows, cygwin and distributions of
##                                   TeX, line endings in fls file (CRLF v. LF)
##                                   were misparsed, resulting in source
##                                   filenames that incorrectly contained CR
##                                   characters.
##                                Correct bug that when --gg mode is on, the
##                                   rule database contained items from the OLD
##                                   fdb file.  Using --gg mode implies that
##                                   the rules in the OLD fdb file must be
##                                   ignored (since they may be wrong).
##      1 Oct 2012  John Collins  V. 4.34
##                                Correct problem that if a file is read by
##                                   latex only after being written, it is
##                                   not a true source file.
##     19 Aug 2012  John Collins  V. 4.33c
##                                Correct infinite loop when maximum passes
##                                   exceeded.
##                                Improve error messages
##     12 Aug 2012  John Collins  V. 4.33b
##                                Improve text displayed by -showextraoptions
##      8 Aug 2012  John Collins  V. 4.33a
##                                Fix problem that with Cygwin,
##                                   latexmk runs very slowly, because
##                                   subroutine good_cwd() runs the
##                                   program cygpath on every
##                                   invocation.  Solution: cach cwd.
##      6 Aug 2012  John Collins  Version number to 4.33
##      4 Aug 2012  John Collins  Further fixes of filename treatment:
##                                   normalize_filename routine to remove
##                                   string for current directory, and
##                                   convert '\' directory separator to '/'
##                                   (Note MiKTeX uses BOTH, see e.g., its
##                                   log file, so MSWin systems are NOT
##                                   guaranteed to be consistent.  But latexmk
##                                   needs to treat filenames differing by
##                                   change of directory separator as equivalent.
##                                   Warning: SOME MWWin programs, e.g., current
##                                   cmd.exe (as tested yesterday on PSU computer
##                                   in library) do not accept '/' as directory
##                                   separator, so it may be worth allowing conversion
##                                   to '\' in executed files.)
##                                Also improve running when $silent is on:
##                                   don't print warnings about undefined references
##                                   and citations, but simply display a summary, whose
##                                   criterion for being shown had to be fixed.
##      3 Aug 2012  John Collins  Fix finding of files in aux-dir
##      1 Aug 2012  John Collins  Handle aliasing of cwd in output file
##                                to avoid unnecessary warnings about
##                                actual o/p file .ne. expected with MiKTeX
##                                Clean up subroutine names:
##                       parse_logB to parse_log
##                       make_preview_continuousB to make_preview_continuous
##                       rdb_find_new_filesB to rdb_find_new_files
##                       rdb_set_dependentsA to rdb_set_dependents
##                       rdb_makeB to rdb_make
##                       rdb_makeB1 to rdb_make1
##                       rdb_one_depA to rdb_one_dep
##                       rdb_recurseA to rdb_recurse
##                       rdb_update_filesA to rdb_update_files
##     28, 29, 30 Jul 2012  John Collins  Try better file-name normalization in reading fls file.
##     18 Jul 2012  John Collins  Change ver. to 4.32d.
##                                Merge changes from 29 June 2012:
##                                Add $dvipdf_silent_switch
##     17 Jul 2012  John Collins  Try better fix for error/rerun and retest issue.
##                                Now rdb_primary_run doesn't have so many complications
##                                rdb_makeB's PASS loop is simpler
##                                rdb_submakeB is unneeded.
##                                See the lines starting #??
##                                See comments nearby
##                                Compare w/ v. 4.32a
##                                V. 4.32b
##     17 Jul 2012  John Collins  Fix problem that after finding error in a run
##                                  of (pdf)latex, latexmk didn't check for
##                                  changed files before giving up.
##                                  To do that, I reverted some changes in
##                                  rdb_primary_run to pre v. 4.31
##                                Remove unused code
##                                v. 4.32a
##      8 May 2012  John Collins  Possibility to substitute backslashes for
##                                  forward slashes in file and directory
##                                  names in executed command line,
##                                  for MSWin
##      5 May 2012  John Collins  Comment on ctrl/C handling in WAIT loop
##
##   1998-2010, John Collins.  Many improvements and fixes.
##       See CHANGE-log.txt for full list, and CHANGES for summary
##
##   Modified by Evan McLean (no longer available for support)
##   Original script (RCS version 2.3) called "go" written by David J. Musliner
##
## 2.0 - Final release, no enhancements.  LatexMk is no longer supported
##       by the author.
## 1.9 - Fixed bug that was introduced in 1.8 with path name fix.
##     - Fixed buglet in man page.
## 1.8 - Add not about announcement mailling list above.
##     - Added texput.dvi and texput.aux to files deleted with -c and/or
##       the -C options.
##     - Added landscape mode (-l option and a bunch of RC variables).
##     - Added sensing of "\epsfig{file=...}" forms in dependency generation.
##     - Fixed path names when specified tex file is not in the current
##       directory.
##     - Fixed combined use of -pvc and -s options.
##     - Fixed a bunch of speling errors in the source. :-)
##     - Fixed bugs in xdvi patches in contrib directory.
## 1.7 - Fixed -pvc continuous viewing to reattach to pre-existing
##       process correctly.
##     - Added $pscmd to allow changing process grepping for different
##       systems.
## 1.6 - Fixed buglet in help message
##     - Fixed bugs in detection of input and include files.
## 1.5 - Removed test message I accidentally left in version 1.4
##     - Made dvips use -o option instead of stdout redirection as some
##       people had problems with dvips not going to stdout by default.
##     - Fixed bug in input and include file detection
##     - Fixed dependency resolution process so it detects new .toc file
##       and makeindex files properly.
##     - Added dvi and postscript filtering options -dF and -pF.
##     - Added -v version commmand.
## 1.4 - Fixed bug in -pvc option.
##     - Made "-F" option include non-existant file in the dependency list.
##       (RC variable: $force_include_mode)
##     - Added .lot and .lof files to clean up list of extensions.
##     - Added file "texput.log" to list of files to clean for -c.
##     - LatexMk now handles file names in a similar fashion to latex.
##       The ".tex" extension is no longer enforced.
##     - Added $texfile_search RC variable to look for default files.
##     - Fixed \input and \include so they add ".tex" extension if necessary.
##     - Allow intermixing of file names and options.
##     - Added "-d" and banner options (-bm, -bs, and -bi).
##       (RC variables: $banner, $banner_message, $banner_scale,
##       $banner_intensity, $tmpdir)
##     - Fixed "-r" option to detect an command line syntax errors better.
## 1.3 - Added "-F" option, patch supplied by Patrick van der Smagt.
## 1.2 - Added "-C" option.
##     - Added $clean_ext and $clean_full_ext variables for RC files.
##     - Added custom dependency generation capabilities.
##     - Added command line and variable to specify custom RC file.
##     - Added reading of rc file in current directly.
## 1.1 - Fixed bug where Dependency file generation header is printed
##       rependatively.
##     - Fixed bug where TEXINPUTS path is searched for file that was
##       specified with absolute an pathname.
## 1.0 - Ripped from script by David J. Musliner (RCS version 2.3) called "go"
##     - Fixed a couple of file naming bugs
##        e.g. when calling latex, left the ".tex" extension off the end
##             of the file name which could do some interesting things
##             with some file names.
##     - Redirected output of dvips.  My version of dvips was a filter.
##     - Cleaned up the rc file mumbo jumbo and created a dependency file
##       instead.  Include dependencies are always searched for if a
##       dependency file doesn't exist.  The -i option regenerates the
##       dependency file.
##       Getting rid of the rc file stuff also gave the advantage of
##       not being restricted to one tex file per directory.
##     - Can specify multiple files on the command line or no files
##       on the command line.
##     - Removed lpr options stuff.  I would guess that generally,
##       you always use the same options in which case they can
##       be set up from an rc file with the $lpr variable.
##     - Removed the dviselect stuff.  If I ever get time (or money :-) )
##       I might put it back in if I find myself needing it or people
##       express interest in it.
##     - Made it possible to view dvi or postscript file automatically
##       depending on if -ps option selected.
##     - Made specification of dvi file viewer seperate for -pv and -pvc
##       options.
##-----------------------------------------------------------------------

## Explicit exit codes:
##             10 = bad command line arguments
##             11 = file specified on command line not found
##                  or other file not found
##             12 = failure in some part of making files
##             13 = error in initialization file
##             20 = probable bug
##             or retcode from called program.

1;
