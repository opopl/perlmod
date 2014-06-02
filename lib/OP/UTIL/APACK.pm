package OP::UTIL::APACK;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 
)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

if (${^UTF8LOCALE}) {
  use Encode qw(decode_utf8);
  binmode($_, ':encoding(UTF-8)') for \*STDIN, \*STDOUT, \*STDERR;
  $_ = decode_utf8($_) for @ARGV, values %ENV;
}

use File::Basename;
use File::Spec;
use Getopt::Long;
use POSIX;
use locale;
use strict;

# Subroutine prototypes (needed for perl 5.6)
sub runcmds($$$;@);
sub getmode();
sub multiarchivecmd($$$$@);
sub singlearchivecmd($$$$$@);
sub maketarcmd($$$$@);
sub cmdexec($@);
sub parsefmt($$);
sub makeoutdir();
sub makeoutfile($);
sub explain($);
sub extract(@);
sub shquotemeta($);
sub tailslash($);
sub de($);
sub makespec(@);
sub backticks(@);
sub readconfig($$);
sub formatext($);
sub stripext($);
sub findformat($$);
sub unlink_directory($);
sub find_comparable_file($);
sub makeabsolute($);
sub quote($);
sub shell_execute(@);
sub save_outdir($);
sub handle_empty_add(@);
sub issingleformat($);
sub repack_archive($$$$);
sub set_config_option($$$);

$::SYSCONFDIR = '/etc'; # This line is automatically updated by make
$::PACKAGE = 'atool'; # This line is automatically updated by make
$::VERSION = '0.39.0'; # This line is automatically updated by make
$::BUG_EMAIL = 'oskar@osk.mine.nu'; # This line is automatically updated by make
$::PROGRAM = $::PACKAGE;

# Configuration options and their built-in defaults
$::cfg_args_diff            = '-ru';              # arguments to pass to diff program
$::cfg_decompress_to_cwd    = 1;                  # decompress to current directory
$::cfg_default_verbosity    = 1;                  # default verbosity level
$::cfg_extract_deb_control  = 1;                  # extract DEBIAN control dir from .deb packages?
$::cfg_keep_compressed      = 1;                  # keep compressed file after pack/unpack
$::cfg_path_7z              = '7z';               # 7z program
$::cfg_path_ar              = 'ar';               # ar program
$::cfg_path_arc             = 'arc';              # arc program
$::cfg_path_arj             = 'arj';              # arj program
$::cfg_path_bzip            = 'bzip';             # bzip program
$::cfg_path_bzip2           = 'bzip2';            # bzip2 program
$::cfg_path_cabextract      = 'cabextract';       # cabextract program
$::cfg_path_cat             = 'cat';              # cat program
$::cfg_path_compress        = 'compress';         # compress program
$::cfg_path_cpio            = 'cpio';             # cpio program
$::cfg_path_diff            = 'diff';             # diff program
$::cfg_path_dpkg_deb        = 'dpkg-deb';         # dpkg-deb program
$::cfg_path_file            = 'file';             # file program
$::cfg_path_find            = 'find';             # find program
$::cfg_path_gzip            = 'gzip';             # gzip program
$::cfg_path_jar             = 'jar';              # jar program
$::cfg_path_lbzip2          = 'lbzip2';           # lbzip2 program
$::cfg_path_lha             = 'lha';              # lha program
$::cfg_path_lrzip           = 'lrzip';            # lrzip program
$::cfg_path_lzip            = 'lzip';             # lzip program
$::cfg_path_lzma            = 'lzma';             # lzma program
$::cfg_path_lzop            = 'lzop';             # lzop program
$::cfg_path_nomarch         = 'nomarch';          # nomarch program
$::cfg_path_pager           = 'pager';            # pager program
$::cfg_path_pbzip2          = 'pbzip2';           # pbzip2 program
$::cfg_path_pigz            = 'pigz';             # pigz program
$::cfg_path_plzip           = 'plzip';            # plzip program
$::cfg_path_rar             = 'rar';              # rar program
$::cfg_path_rpm             = 'rpm';              # rpm program
$::cfg_path_rpm2cpio        = 'rpm2cpio';         # rpm2cpio program
$::cfg_path_rzip            = 'rzip';             # rzip program
$::cfg_path_syscfg          = File::Spec->catfile($::SYSCONFDIR, $::PROGRAM.'.conf');  # system-wide configuration file
$::cfg_path_tar             = 'tar';              # tar program
$::cfg_path_unace           = 'unace';            # unace program
$::cfg_path_unalz           = 'unalz';            # unalz program
$::cfg_path_unarj           = 'unarj';            # unarj program
$::cfg_path_unrar           = 'unrar';            # unrar program
$::cfg_path_unzip           = 'unzip';            # unzip program
$::cfg_path_usercfg         = '.'.$::PROGRAM.'rc';  # user configuration file
$::cfg_path_xargs           = 'xargs';            # xargs program
$::cfg_path_xz              = 'xz';               # xz program
$::cfg_path_zip             = 'zip';              # zip program
$::cfg_show_extracted       = 1;                  # always show extracted file/directory
$::cfg_strip_unknown_ext    = 1;                  # strip unknown extensions
$::cfg_tmpdir_name          = 'Unpack-%04d';      # extraction directory name
$::cfg_tmpfile_name         = 'Pack-%04d';        # temporary file used during packing
$::cfg_use_arc_for_unpack   = 0;                  # use arc to unpack arc files?
$::cfg_use_arj_for_unpack   = 0;                  # use arj to unpack arj files?
$::cfg_use_file             = 1;                  # use file(1) for unknown extensions?
$::cfg_use_file_always      = 0;                  # always use file to identify archives (ignore extension)
$::cfg_use_find_cpio_print0 = 1;                  # use -print0/-0 find/cpio options?
$::cfg_use_gzip_for_z       = 1;                  # use gzip to decompress .Z files?
$::cfg_use_jar              = 0;                  # use jar or zip for .jar archives?
$::cfg_use_lbzip2           = 0;                  # use lbzip2 instead of bzip2
$::cfg_use_pbzip2           = 0;                  # use pbzip2 instead of bzip2
$::cfg_use_pigz             = 0;                  # use pigz instead of gzip
$::cfg_use_plzip            = 0;                  # use plzip instead of lzip
$::cfg_use_rar_for_unpack   = 0;                  # use rar to unpack rar files?
$::cfg_use_tar_bzip2_option = 1;                  # does tar support --bzip2?
$::cfg_use_tar_lzma_option  = 1;                  # does tar support --lzma?
$::cfg_use_tar_lzip_option  = 0;                  # does tar support --lzip?
$::cfg_use_tar_lzop_option  = 0;                  # does tar support --lzop?
$::cfg_use_tar_xz_option    = 0;                  # does tar support --xz?
$::cfg_use_tar_z_option     = 1;                  # does tar support -z?

# Global variables
$::basename = quote(File::Basename::basename($0));
@::rmdirs = ();
$::up = File::Spec->updir();
$::cur = File::Spec->curdir();
@::opt_options = ();
@::opt_format_options = ();

# Parse arguments
Getopt::Long::config('bundling');
Getopt::Long::GetOptions(
  'l|list'         => \$::opt_cmd_list,
  'x|extract'      => \$::opt_cmd_extract,
  'X|extract-to=s' => \$::opt_cmd_extract_to,
  'a|add'          => \$::opt_cmd_add,
  'c|cat'          => \$::opt_cmd_cat,
  'd|diff'         => \$::opt_cmd_diff,
  'r|repack'       => \$::opt_cmd_repack,
  'q|quiet'        => sub { $::opt_verbosity--; },
  'v|verbose'      => sub { $::opt_verbosity++; },
  'V|verbosity=i'  => \$::opt_verbosity,
  'config=s'       => \$::opt_config,
  'o|option=s'     => sub { push @::opt_options, $_[1] },
  'help'           => \$::opt_cmd_help,
  'version'        => \$::opt_cmd_version,
  'F|format=s'     => \$::opt_format,
  'O|format-option=s' => sub { push @::opt_format_options, $_[1] },
  'f|force'        => \$::opt_force,
  'p|page'         => \$::opt_use_pager,
  'e|each'         => \$::opt_each,
  'E|explain'      => \$::opt_explain,
  'S|simulate'     => \$::opt_simulate,
  'save-outdir=s'  => \$::opt_save_outdir,
  'D|subdir'       => \$::opt_extract_subdir,
  '0|null'         => \$::opt_null,
) or exit 1;

# Display --version
if ($::opt_cmd_version) {
  print $::PACKAGE.' '.$::VERSION."\
Copyright (C) 2011 Oskar Liljeblad\
This is free software.  You may redistribute copies of it under the terms of
the GNU General Public License <http://www.gnu.org/licenses/gpl.html>.
There is NO WARRANTY, to the extent permitted by law.

Written by Oskar Liljeblad.\n";
  exit;
}

# Display --help
if ($::opt_cmd_help) {
  print <<_END_;
Usage: $::PROGRAM [OPTION]... ARCHIVE [FILE]...
       $::PROGRAM -e [OPTION]... [ARCHIVE]...
Manage file archives of various types.

Commands:
  -l, --list               list files in archive (als)
  -x, --extract            extract files from archive (aunpack)
  -X, --extract-to=PATH    extract archive to specified directory
  -a, --add                create archive (apack)
  -c, --cat                extract file to standard out (acat)
  -d, --diff               generate a diff between two archives (adiff)
  -r, --repack             repack archives to a different format (arepack)
      --help               display this help and exit
      --version            output version information and exit

Options:
  -e, --each               execute command above for each file specified
  -F, --format=EXT         override archive format (see below)
  -O, --format-option=OPT  give specific options to the archiver
  -D, --subdir             always create subdirectory when extracting
  -f, --force              allow overwriting of local files
  -q, --quiet              decrease verbosity level by one
  -v, --verbose            increase verbosity level by one
  -V, --verbosity=LEVEL    specify verbosity (0, 1 or 2)
  -p, --page               send output through pager
  -0, --null               filenames from standard in are null-byte separated
  -E, --explain            explain what is being done by $::PROGRAM
  -S, --simulate           simulation mode - no filesystem changes are made
  -o, --option=KEY=VALUE   override a configuration option
      --config=FILE        load configuration defaults from file

Archive format (for --format) may be specified either as a
file extension ("tar.gz") or as "tar+gzip".

Report bugs to Oskar Liljeblad <$::BUG_EMAIL>.
_END_
  exit;
}

# Read configuration files
if (defined $::opt_config) {
  readconfig($::opt_config, 0);
} else {
  readconfig($::cfg_path_syscfg, 1);
  if ($::cfg_path_usercfg !~ /^\//) {
    readconfig(File::Spec->catfile($ENV{HOME}, $::cfg_path_usercfg), 1);
  } else {
    readconfig($::cfg_path_usercfg, 1);
  }
}
foreach my $opt (@::opt_options) {
  my ($var,$val) = ($opt =~ /^([^=]+)=(.*)$/);
  die "$::basename: invalid value for --option: $opt\n" if !defined $val;
  set_config_option($var, $val, '');
}

# Verify option integrity
$::opt_verbosity += $::cfg_default_verbosity;
if ($::opt_explain && $::opt_simulate) {
  die "$::basename: --explain and --simulate options are mutually exclusive\n"; #OK
}

my $mode = getmode();

if (defined $::opt_save_outdir && $mode eq 'extract-to') {
  die "$::basename: --save-outdir cannot be used in extract-to mode\n";
}
if ($::opt_extract_subdir && $mode ne 'extract') {
  die "$::basename: --subdir can only be used in extract mode\n";
}

if ($mode eq 'diff') {
  die "$::basename: missing archive argument\n" if (@ARGV < 2); #OK
  my $use_pager = $::opt_use_pager;
  $::opt_verbosity--;
  $::opt_use_pager = 0;

  my $outfile1 = makeoutdir() || exit 1;
  my $outfile2 = makeoutdir() || exit 1;
  $::opt_cmd_extract_to = $outfile1;
  $::opt_cmd_extract_to_type = 'f';
  exit 1 if (!runcmds('extract-to', undef, $ARGV[0]));
  $::opt_cmd_extract_to = $outfile2;
  $::opt_cmd_extract_to_type = 'f';
  exit 1 if (!runcmds('extract-to', undef, $ARGV[1]));

  my $match1 = find_comparable_file($outfile1);
  my $match2 = find_comparable_file($outfile2);

  my @cmd = ($::cfg_path_diff, split(/ /, $::cfg_args_diff), $match1, $match2);
  push @cmd, ['|'], get_pager_program() if $use_pager;
  my $allok = cmdexec(1, @cmd);

  foreach my $file ($outfile1,$outfile2) {
    warn 'rm -r ',quote($file),"\n" if $::opt_simulate;
    if (-e $file && -d $file) {
    #if (-e $file) {
      #print "$::basename: remove `$file'? ";
      #select((select(STDOUT), $| = 1)[0]);
      #my $line = <STDIN>;
      #if (defined $line && $line =~ /^y/) {
        #if (-d $file) {
          warn 'rm -r ',quote($file),"\n" if $::opt_explain;
          unlink_directory($file) if !$::opt_simulate;
        #} else {
          #unlink $file;
        #}
      #}
    }
  }

  exit ($allok ? 0 : 1);
}
elsif ($mode eq 'repack') {
  if ($::opt_each) {
    my $totaldiff = 0;
    if (!defined $::opt_format) {
      die "$::basename: specify a format with -F when using --each in repack mode\n";
    }
    my $fmt2 = findformat($::opt_format, 1);
    exit 1 if !defined $fmt2; # OK
    for (my $c = 0; $c < @ARGV; $c++) {
      my $fmt1 = findformat($ARGV[$c], 0);
      next if !defined $fmt1;
      if (!issingleformat($fmt1) && issingleformat($fmt2)) {
        warn "$::basename: format $fmt1 is cannot be repacked into format $fmt2\n";
        warn "skipping ", quote($ARGV[$c]), "\n";
        next;
      }
      if ($fmt1 eq $fmt2) {
        warn "$::basename: will not repack to same archive type\n";
        warn "skipping ", quote($ARGV[$c]), "\n";
        next;
      }
      my $newname = stripext($ARGV[$c]).formatext($fmt2);
      if (-e $newname) {
        warn "$::basename: ".quote($newname).": destination file exists\n";
        warn "skipping ", quote($ARGV[$c]), "\n";
        next;
      }
      repack_archive($ARGV[$c], $newname, $fmt1, $fmt2);
      my $diff = $::opt_simulate ? 0 : (-s $ARGV[$c]) - (-s $newname);
      $totaldiff += $diff;
      if ($::opt_verbosity >= 1) {
        print quote($newname), ': ',
            ($diff >= 0 ? 'saved '.$diff : 'grew '.-$diff),' ',
            ($diff == 1 ? 'byte':'bytes'), "\n";
      }
    }
    if ($::opt_verbosity >= 1) {
      print $totaldiff >= 0 ? 'saved '.$totaldiff : 'grew '.-$totaldiff, ' ',
          $totaldiff == 1 ? 'byte':'bytes', " in total\n";
    }
  } else {
    die "$::basename: missing archive arguments\n" if @ARGV < 1; #OK
    die "$::basename: missing archive argument\n" if @ARGV < 2; #OK
    die "$::basename: will not repack to same archive file\n"
      if ($ARGV[0] eq $ARGV[1] || File::Spec->canonpath($ARGV[0]) eq File::Spec->canonpath($ARGV[1]));
    die "$::basename: ".quote($ARGV[1]).": destination file exists\n" if -e $ARGV[1];
    my $fmt1 = findformat($ARGV[0], 0);
    my $fmt2 = findformat($ARGV[1], 0);
    exit 1 if !defined $fmt1 || !defined $fmt2; # OK
    die "$::basename: format $fmt1 is cannot be repacked into format $fmt1\n"
      if (!issingleformat($fmt1) && issingleformat($fmt2));
    die "$::basename: will not repack to same archive type\n" if $fmt1 eq $fmt2;
    repack_archive($ARGV[0], $ARGV[1], $fmt1, $fmt2);
    my $diff = ($::opt_simulate ? 0 : (-s $ARGV[0]) - (-s $ARGV[1]));
    if ($::opt_verbosity >= 1) {
      print quote($ARGV[1]), ': ',
          ($diff >= 0 ? 'saved '.$diff : 'grew '.-$diff),' ',
          ($diff == 1 ? 'byte':'bytes'), "\n";
    }
  }
}
elsif ($::opt_each) {
  my $allok = 1;
  if ($mode eq 'cat') {
    die "$::basename: --each can not be used with cat or add command\n";  #OK
  }
  if ($mode eq 'add') {
    if (!defined $::opt_format) {
      die "$::basename: specify a format with -F when using --each in add mode\n";
    }
    my $format = findformat($::opt_format, 1);
    exit 1 if !defined $format;
    for (my $c = 0; $c < @ARGV; $c++) {
      my $archive = File::Spec->canonpath($ARGV[$c]) . formatext($format);
      warn quote($archive).":\n" if $::opt_verbosity > 1;
      runcmds('add', $format, $archive, $ARGV[$c]) or $allok = 0;
    }
  } else {
    for (my $c = 0; $c < @ARGV; $c++) {
      warn quote($ARGV[$c]).":\n" if $::opt_verbosity > 1;
      runcmds($mode, undef, $ARGV[$c]) or $allok = 0;
    }
  }
  exit ($allok ? 0 : 1);
}
else {
  die "$::basename: missing archive argument\n" if (@ARGV == 0);  #OK
  runcmds($mode, undef, shift @ARGV, @ARGV) || exit 1;
}

# runcmds(mode, format, archive, args)
# Execute an atool command. This is where it all happens.
# If mode is 'extract', returns the directory (or only file)
# which was extracted.
# If forceformat is undef, the format will be detected from 
# $::opt_format or the filename.
sub runcmds($$$;@) {
  my ($mode, $format, $archive, @args) = @_;

  if (!defined $format) {
    if (defined $::opt_format) {
      $format = findformat($::opt_format, 1);
    } else {
      $format = findformat($archive, 0);
    }
    return undef if !defined $format;
  }

  my @cmd;
  my $outdir;
  if ($format eq 'tar+bzip2') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_tar_bzip2_option) {
      push @cmd, maketarcmd($archive, $outdir, $mode, 'f', '--bzip2'), @args;
    } elsif ($::cfg_use_pbzip2) {
      push @cmd, $::cfg_path_pbzip2, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_pbzip2, '-c', ['>'], $archive if $mode eq 'add';
      #if ($mode eq 'add') {
        # Unfortunately pbzip2 cannot read from standard in
        # 2012-03-15: It seems now it does.
      #  my $tmpname = makeoutfile($::cfg_tmpfile_name);
      #  push @cmd, maketarcmd($tmpname, $outdir, $mode, 'f'), @args;
      #  push @cmd, [';'], $::cfg_path_pbzip2, '-c', $tmpname, ['>'], $archive;
      #  push @cmd, [';'], 'rm', $tmpname;
      #} else {
      #  push @cmd, $::cfg_path_pbzip2, '-cd', $archive, ['|'];
      #  push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      #}
    } elsif ($::cfg_use_lbzip2) {
      push @cmd, $::cfg_path_lbzip2, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_lbzip2, '-c', ['>'], $archive if $mode eq 'add';
    } else {
      push @cmd, $::cfg_path_bzip2, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_bzip2, '-c', ['>'], $archive if $mode eq 'add';
    }
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+gzip') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_tar_z_option) {
      push @cmd, maketarcmd($archive, $outdir, $mode, 'zf'), @args;
    } elsif ($::cfg_use_pigz) {
      push @cmd, $::cfg_path_pigz, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_pigz, '-c', ['>'], $archive if $mode eq 'add';
    } else {
      push @cmd, $::cfg_path_gzip, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_gzip, '-c', ['>'], $archive if $mode eq 'add';
    }
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+bzip') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    push @cmd, $::cfg_path_bzip, '-cd', $archive, ['|'] if $mode ne 'add';
    push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
    push @cmd, ['|'], $::cfg_path_bzip, '-c', ['>'], $archive if $mode eq 'add';
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+compress') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_gzip_for_z) {
      push @cmd, $::cfg_path_gzip, '-cd', $archive, ['|'] if $mode ne 'add';
    } else {
      push @cmd, $::cfg_path_compress, '-cd', $archive, ['|'] if $mode ne 'add';
    }
    push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
    push @cmd, ['|'], $::cfg_path_compress, '-c', ['>'], $archive if $mode eq 'add';
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+lzop') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_tar_lzop_option) {
      push @cmd, maketarcmd($archive, $outdir, $mode, 'f', '--lzop'), @args;
    } else {
      push @cmd, $::cfg_path_lzop, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_lzop, '-c', ['>'], $archive if $mode eq 'add';
    }
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+lzip') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_tar_lzip_option) {
      push @cmd, maketarcmd($archive, $outdir, $mode, 'f', '--lzip'), @args;
    } elsif ($::cfg_use_plzip) {
      push @cmd, $::cfg_path_plzip, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_plzip, '-c', ['>'], $archive if $mode eq 'add';
    } else {
      push @cmd, $::cfg_path_lzip, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_lzip, '-c', ['>'], $archive if $mode eq 'add';
    }
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+xz') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_tar_xz_option) {
      push @cmd, maketarcmd($archive, $outdir, $mode, 'f', '--xz'), @args;
    } else {
      push @cmd, $::cfg_path_xz, '-cd', $archive, ['|'] if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_xz, '-c', ['>'], $archive if $mode eq 'add';
    }
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+7z') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    push @cmd, $::cfg_path_7z, 'x', '-so', $archive, ['|']  if $mode ne 'add';
    push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
    push @cmd, ['|'], $::cfg_path_7z, 'a', '-si', $archive if $mode eq 'add';
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar+lzma') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($::cfg_use_tar_lzma_option) {
      push @cmd, maketarcmd($archive, $outdir, $mode, 'f', '--lzma'), @args;
    } else {
      push @cmd, $::cfg_path_lzma, '-cd', $archive, ['|']     if $mode ne 'add';
      push @cmd, maketarcmd('-', $outdir, $mode, 'f'), @args;
      push @cmd, ['|'], $::cfg_path_lzma, '-c', ['>'], $archive if $mode eq 'add';
    }
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'tar') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    push @cmd, maketarcmd($archive, $outdir, $mode, 'f'), @args;
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'jar' && $::cfg_use_jar) {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    my $opts = '';
    if ($mode eq 'add') {
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
    $opts .= 'v' if $::opt_verbosity >= 1;
    push @cmd, $::cfg_path_jar;
    push @cmd, "x$opts", '-C', $outdir if $mode eq 'extract';
    push @cmd, "x$opts", '-C', $::opt_cmd_extract_to if $mode eq 'extract-to';
    push @cmd, "t$opts" if $mode eq 'list';
    push @cmd, "c$opts" if $mode eq 'add';
    push @cmd, $archive, @args;
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'jar' || $format eq 'zip') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'add') {
      push @cmd, $::cfg_path_zip, '-r';
    } else {
      push @cmd, $::cfg_path_unzip;
      push @cmd, '-p' if $mode eq 'cat';
      push @cmd, '-l' if $mode eq 'list';
      push @cmd, '-d', $outdir if $mode eq 'extract';
      push @cmd, '-d', $::opt_cmd_extract_to if $mode eq 'extract-to';
    }
    push @cmd, '-v' if $::opt_verbosity > 1;
    push @cmd, '-qq' if $::opt_verbosity < 0;
    push @cmd, '-q' if $::opt_verbosity == 0;
    push @cmd, $archive, @args;
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq 'rar') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'add' || $::cfg_use_rar_for_unpack) {
      push @cmd, $::cfg_path_rar;
    } else {
      push @cmd, $::cfg_path_unrar;
    }
    push @cmd, 'a' if $mode eq 'add';
    push @cmd, 'vt' if $mode eq 'list' && $::opt_verbosity >= 3;
    push @cmd, 'v' if $mode eq 'list' && $::opt_verbosity == 2;
    push @cmd, 'l' if $mode eq 'list' && $::opt_verbosity <= 1;
    push @cmd, 'x' if ($mode eq 'extract' || $mode eq 'extract-to');
    push @cmd, '-ierr', 'p' if $mode eq 'cat';
    push @cmd, '-r0' if ($mode eq 'add');
    push @cmd, $archive, @args;
    push @cmd, tailslash($outdir) if $mode eq 'extract';
    push @cmd, tailslash($::opt_cmd_extract_to) if $mode eq 'extract-to';
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq '7z') {
    # 7z has the -so option for writing data to stdout, but it doesn't
    # write data to terminal even if the file is designed to be
    # read in a terminal...
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    #if ($mode eq 'cat') {
    #  warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
    #  return undef;
    #}
    push @cmd, $::cfg_path_7z;
    push @cmd, 'a' if $mode eq 'add';
    push @cmd, 'l' if $mode eq 'list';
    push @cmd, 'x', '-so' if $mode eq 'cat';
    push @cmd, 'x', '-o'.$outdir if $mode eq 'extract';
    push @cmd, 'x', '-o'.$::opt_cmd_extract_to if $mode eq 'extract-to';
    push @cmd, @::opt_format_options, $archive, @args;
    return multiarchivecmd($archive, $outdir, $mode, 1, 0, \@args, @cmd);
  }
  elsif ($format eq 'cab') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'add') {
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
    push @cmd, $::cfg_path_cabextract;
    push @cmd, '--single';
    push @cmd, '--directory', $outdir if $mode eq 'extract';
    push @cmd, '--directory', $::opt_cmd_extract_to if $mode eq 'extract-to';
    push @cmd, '--pipe' if $mode eq 'cat';
    push @cmd, '--list' if $mode eq 'list';
    push @cmd, $archive;
    push @cmd, '--filter';
    push @cmd, @args;
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq 'alzip') {
    if ($mode eq 'cat' || $mode eq 'add' || $mode eq 'list') {
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    push @cmd, $::cfg_path_unalz;
    push @cmd, $archive;
    push @cmd, $outdir if $mode eq 'extract';
    push @cmd, $::opt_cmd_extract_to if $mode eq 'extract-to';
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq 'lha') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    push @cmd, $::cfg_path_lha;
    push @cmd, 'a' if $mode eq 'add';
    push @cmd, 'v' if $mode eq 'list' && $::opt_verbosity >= 3;
    push @cmd, 'l' if $mode eq 'list' && $::opt_verbosity == 2;
    push @cmd, 'lq' if $mode eq 'list' && $::opt_verbosity <= 1;
    push @cmd, 'xw='.tailslash($outdir) if $mode eq 'extract';
    push @cmd, 'xw='.tailslash($::opt_cmd_extract_to) if $mode eq 'extract-to';
    push @cmd, 'p' if $mode eq 'cat';
    push @cmd, $archive, @args;
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq 'ace') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    push @cmd, $::cfg_path_unace;
    if ($mode eq 'add' || $mode eq 'cat') {
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
    push @cmd, 'v', '-c' if $mode eq 'list' && $::opt_verbosity >= 3;
    push @cmd, 'v' if $mode eq 'list' && $::opt_verbosity == 2;
    push @cmd, 'l' if $mode eq 'list' && $::opt_verbosity <= 1;
    push @cmd, 'x' if ($mode eq 'extract' || $mode eq 'extract-to');
    push @cmd, $archive, @args;
    push @cmd, tailslash($outdir) if $mode eq 'extract';
    push @cmd, tailslash($::opt_cmd_extract_to) if $mode eq 'extract-to';
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq 'arj') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'cat') {
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
    if ($mode eq 'add' || $::cfg_use_arj_for_unpack) {
      push @cmd, $::cfg_path_arj;
      push @cmd, 'a' if $mode eq 'add';
      push @cmd, 'v' if $mode eq 'list' && $::opt_verbosity == 2;
      push @cmd, 'l' if $mode eq 'list' && $::opt_verbosity <= 1;
      push @cmd, 'x' if ($mode eq 'extract' || $mode eq 'extract-to');
      push @cmd, $archive, @args;
      push @cmd, tailslash($outdir) if $mode eq 'extract';
      push @cmd, tailslash($::opt_cmd_extract_to) if $mode eq 'extract-to';
      @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
      return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
    } else {
      push @cmd, $::cfg_path_unarj;
      # XXX: cat mode might work for arj archives, but it extract to stderr!
      push @cmd, 'v' if $mode eq 'list' && $::opt_verbosity == 2;
      push @cmd, 'l' if $mode eq 'list' && $::opt_verbosity <= 1;
      push @cmd, 'x' if ($mode eq 'extract' || $mode eq 'extract-to');
      push @cmd, $archive if ($mode ne 'extract' && $mode ne 'extract-to');;
      # we call makeabsolute here because needcwd=1 to the multiarchivecmd call
      push @cmd, makeabsolute($archive) if ($mode eq 'extract' || $mode eq 'extract-to');
      push @cmd, @args;
      @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
      return multiarchivecmd($archive, $outdir, $mode, 0, 1, \@args, @cmd);
    }
  }
  elsif ($format eq 'arc') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'add' || $::cfg_use_arc_for_unpack) {
      push @cmd, $::cfg_path_arc;
      push @cmd, 'a' if $mode eq 'add';
      push @cmd, 'v' if $mode eq 'list' && $::opt_verbosity >= 3;
      push @cmd, 'l' if $mode eq 'list' && $::opt_verbosity == 2;
      push @cmd, 'ln' if $mode eq 'list' && $::opt_verbosity <= 1;
      push @cmd, 'x' if ($mode eq 'extract' || $mode eq 'extract-to');
      push @cmd, 'p' if $mode eq 'cat';
    } else {
      push @cmd, $::cfg_path_nomarch;
      push @cmd, '-lvU' if $mode eq 'list' && $::opt_verbosity >= 2;
      push @cmd, '-lU' if $mode eq 'list' && $::opt_verbosity <= 1;
      push @cmd, '-p' if $mode eq 'cat';
    }
    push @cmd, $archive if ($mode ne 'extract' && $mode ne 'extract-to');
    # we call makeabsolute here because needcwd=1 to the multiarchivecmd call
    push @cmd, makeabsolute($archive) if ($mode eq 'extract' || $mode eq 'extract-to');
    push @cmd, @args;
    @cmd = handle_empty_add(@cmd) if ($mode eq 'add' && @args == 0);
    return multiarchivecmd($archive, $outdir, $mode, 0, 1, \@args, @cmd);
  }
  elsif ($format eq 'rpm') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'list') {
      push @cmd, $::cfg_path_rpm;
      push @cmd, '-qlp';
      push @cmd, '-v' if $::opt_verbosity >= 1;
      push @cmd, $archive, @args;
      return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
    }
    elsif ($mode eq 'extract' || $mode eq 'extract-to') {
      push @cmd, $::cfg_path_rpm2cpio;
      push @cmd, makeabsolute($archive);
      push @cmd, ['|'];
      push @cmd, $::cfg_path_cpio, '-imd', '--quiet', @args;
      return multiarchivecmd($archive, $outdir, $mode, 0, 1, \@args, @cmd);
    }
    else { # add and cat
      # FIXME: I guess cat could work too, but it would require that we
      # extracted to a temporary dir, read and printed it, then removed it.
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
  }
  elsif ($format eq 'deb') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'cat') {
      push @cmd, $::cfg_path_dpkg_deb, '--fsys-tarfile', makeabsolute($archive), ['|'];
      push @cmd, $::cfg_path_tar, '-xO', @args;
    } elsif ($mode eq 'list' || $mode eq 'extract' || $mode eq 'extract-to') {
      push @cmd, $::cfg_path_dpkg_deb;
      push @cmd, '--contents' if $mode eq 'list';
      if ($mode eq 'extract' || $mode eq 'extract-to') {
        push @cmd, '--extract' if $::opt_verbosity <= 0;
        push @cmd, '--vextract' if $::opt_verbosity > 0;
      }
      push @cmd, $archive;
      push @cmd, $outdir if $mode eq 'extract';
      push @cmd, $::opt_cmd_extract_to if $mode eq 'extract-to';
      push @cmd, @args;
      if ($::cfg_extract_deb_control && ($mode eq 'extract' || $mode eq 'extract-to')) {
        push @cmd, [';'];
        push @cmd, $::cfg_path_dpkg_deb;
        push @cmd, '--control';
        push @cmd, $archive;
        push @cmd, File::Spec->catdir($outdir, 'DEBIAN') if $mode eq 'extract';
        push @cmd, File::Spec->catdir($::opt_cmd_extract_to, 'DEBIAN') if $mode eq 'extract-to';
      }
    }
    return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
  }
  elsif ($format eq 'ar') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    my $v = ($::opt_verbosity >= 1 ? 'v' : '');
    push @cmd, $::cfg_path_ar;
    push @cmd, 'rc'.$v if $mode eq 'add';
    push @cmd, 'x'.$v if ($mode eq 'extract' || $mode eq 'extract-to');
    push @cmd, 't'.$v if $mode eq 'list';
    # Don't use v(erbose) with cat command because ar would add "\n<member data>\n\n" to output
    push @cmd, 'p' if $mode eq 'cat';
    push @cmd, makeabsolute($archive), @args;
    return multiarchivecmd($archive, $outdir, $mode, 1, 1, \@args, @cmd);
  }
  elsif ($format eq 'cpio') {
    return undef if ($mode eq 'extract' && !defined ($outdir = makeoutdir()));
    if ($mode eq 'list') {
      push @cmd, $::cfg_path_cat, $archive, ['|'];
      push @cmd, $::cfg_path_cpio, '-t';
      push @cmd, '-v' if $::opt_verbosity >= 1;
      return multiarchivecmd($archive, $outdir, $mode, 0, 0, \@args, @cmd);
    }
    elsif ($mode eq 'extract' || $mode eq 'extract-to') {
      push @cmd, $::cfg_path_cat, makeabsolute($archive), ['|'];
      push @cmd, $::cfg_path_cpio, '-i';
      push @cmd, '-v' if $::opt_verbosity >= 1;
      return multiarchivecmd($archive, $outdir, $mode, 0, 1, \@args, @cmd);
    }
    elsif ($mode eq 'add') {
      if (@args == 0) {
        push @cmd, $::cfg_path_cpio;
        push @cmd, '-0' if $::opt_null;
        push @cmd, '-o';
        push @cmd, '-v' if $::opt_verbosity >= 1;
        push @cmd, ['>'], $archive;
      } else {
        push @cmd, $::cfg_path_find, @args;
        push @cmd, '-print0' if $::cfg_use_find_cpio_print0;
        push @cmd, ['|'], $::cfg_path_cpio;
        push @cmd, '-0' if $::cfg_use_find_cpio_print0;
        push @cmd, '-o';
        push @cmd, '-v' if $::opt_verbosity >= 1;
        push @cmd, ['>'], $archive;
      }
      return multiarchivecmd($archive, $outdir, $mode, 1, 1, \@args, @cmd);
    }
    else { # cat
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
  }
  elsif ($format eq 'bzip2') {
    return singlearchivecmd($archive, $::cfg_path_pbzip2, $format, $mode, 1, @args) if $::cfg_use_pbzip2;
    return singlearchivecmd($archive, $::cfg_path_lbzip2, $format, $mode, 1, @args) if $::cfg_use_lbzip2;
    return singlearchivecmd($archive, $::cfg_path_bzip2, $format, $mode, 1, @args);
  }
  elsif ($format eq 'bzip') {
    return singlearchivecmd($archive, $::cfg_path_bzip, $format, $mode, 1, @args);
  }
  elsif ($format eq 'gzip') {
    return singlearchivecmd($archive, $::cfg_use_pigz ? $::cfg_path_pigz : $::cfg_path_gzip, $format, $mode, 1, @args);
  }
  elsif ($format eq 'compress') {
    if ($::cfg_use_gzip_for_z && $mode ne 'add') {
      return singlearchivecmd($archive, $::cfg_path_gzip, $format, $mode, 1, @args);
    } else {
      return singlearchivecmd($archive, $::cfg_path_compress, $format, $mode, 1, @args);
    }
  }
  elsif ($format eq 'lzma') {
    return singlearchivecmd($archive, $::cfg_path_lzma, $format, $mode, 1, @args);
  }
  elsif ($format eq 'lzop') {
    return singlearchivecmd($archive, $::cfg_path_lzop, $format, $mode, 0, @args);
  }
  elsif ($format eq 'lzip') {
    return singlearchivecmd($archive, $::cfg_use_plzip ? $::cfg_path_plzip : $::cfg_path_lzip, $format, $mode, 1, @args);
  }
  elsif ($format eq 'xz') {
    return singlearchivecmd($archive, $::cfg_path_xz, $format, $mode, 1, @args);
  }
  elsif ($format eq 'rzip') {
    return singlearchivecmd($archive, $::cfg_path_rzip, $format, $mode, 0, @args);
  }
  elsif ($format eq 'lrzip') {
    return singlearchivecmd($archive, $::cfg_path_lrzip, $format, $mode, 0, @args);
  }

  return undef;
}

# de(value):
# Return 1 if value defined and is non-zero, 0 otherwise.
sub de($) {
  my ($value) = @_;
  return defined $value && $value ? 1 : 0;
}

# getmode()
# Identify the execution mode, and return it.
# Possible modes are 'cat', 'extract', 'list', 'add' or 'extract-to'.
sub getmode() {
  my $mode;
  if (de($::opt_cmd_list)
      + de($::opt_cmd_cat)
      + de($::opt_cmd_extract)
      + de($::opt_cmd_add) 
      + de($::opt_cmd_extract_to)
      + de($::opt_cmd_diff)
      + de($::opt_cmd_repack) > 1) {
    die "$::basename: only one command may be specified\n"; #OK
  }
  $mode = 'cat'           if ($::basename eq 'acat');
  $mode = 'extract'       if ($::basename eq 'aunpack');
  $mode = 'list'          if ($::basename eq 'als');
  $mode = 'add'           if ($::basename eq 'apack');
  $mode = 'diff'          if ($::basename eq 'adiff');
  $mode = 'repack'        if ($::basename eq 'arepack');
  $mode = 'add'           if ($::opt_cmd_add);
  $mode = 'cat'           if ($::opt_cmd_cat);
  $mode = 'list'          if ($::opt_cmd_list);
  $mode = 'extract'       if ($::opt_cmd_extract);
  $mode = 'extract-to'    if ($::opt_cmd_extract_to);
  $mode = 'diff'          if ($::opt_cmd_diff);
  $mode = 'repack'        if ($::opt_cmd_repack);
  if (!defined $mode) {
    die "$::basename: no command specified\nTry `$::basename --help' for more information.\n"; #OK
  }
  return $mode;
}

# singlearchivecmd(archive, command, format, mode, args)
# Execute a command for single-file archives.
# The command parameter specifies what command to execute.
# If mode is 'extract-to', returns the directory (or only file)
# which was extracted.
sub singlearchivecmd($$$$$@) {
  my ($archive, $cmd, $format, $mode, $can_do_c, @args) = @_;
  my $outfile;
  my $reason;
  my @cmd;
  push @cmd, $cmd;
  push @cmd, '-v' if $::opt_verbosity > 1;

  if ($mode eq 'list') {
    warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
    return undef;
  }
  elsif ($mode eq 'cat') {
    if (!$can_do_c) {
      warn "$::basename: ".quote($archive).": $mode command not supported for $format archives\n";
      return undef;
    }
    push @cmd, '-c', '-d', $archive, @args;
    $outfile = $archive; # Just so that we don't return undef
  }
  elsif ($mode eq 'add') {
    if (@args > 1) {
      warn "$::basename: cannot add more than one file with this format\n";
      return undef;
    }
    if (!$::opt_force && (-e $archive || -l $archive)) {
      warn "$::basename: ".quote($archive).": refusing to overwrite existing file\n";
      return undef;
    }
    #if (!$::cfg_keep_compressed && stripext($archive) ne $args[0]) {
    # warn "$::basename: ".quote($archive).": cannot create a $format archive with this name (use -X)\n";
    # return;
    #}
    if ($can_do_c) {
      push @cmd, '-c', @args, ['>'], $archive;
    } else {
      push @cmd, '-o', $archive, @args;
    }
    $outfile = $archive; # Just so that we don't return undef
  }
  elsif ($mode eq 'extract') {
    $outfile = stripext($archive);
    if ($::cfg_decompress_to_cwd) {
      $outfile = basename($outfile);
    }
    if (-e $outfile) {
      $outfile = makeoutfile($::cfg_tmpdir_name);
      $reason = 'local file exists';
    }
    if ($can_do_c) {
      push @cmd, '-c', '-d', $archive, @args, ['>'], $outfile;
    } else {
      push @cmd, '-o', $outfile, '-d', $archive, @args;
    }
  }
  elsif ($mode eq 'extract-to') {
    $outfile = $::opt_cmd_extract_to;
    if ($::opt_simulate ? $::opt_cmd_extract_to_type eq 'd' : -d $outfile) {
      my $base = File::Basename::basename($archive);
      $outfile = File::Spec->catfile($outfile, stripext($base));
    }
    if ($can_do_c) {
      push @cmd, '-c', '-d', $archive, @args, ['>'], $outfile;
    } else {
      push @cmd, '-o', $outfile, '-d', $archive, @args;
    }
  }

  push @cmd, ['|'], get_pager_program() if $::opt_use_pager;
  cmdexec(0, @cmd) || return undef;

  if ($mode eq 'extract' || $mode eq 'extract-to') {
    if ($::cfg_show_extracted && !$::opt_simulate) {
      my $archivebase = File::Basename::basename($archive);
      my $rmsg = defined $reason ? " ($reason)" : '';
      warn quote($archivebase).": extracted to `".quote($outfile)."'$rmsg\n";
    }
  }

  if (!$::cfg_keep_compressed) {
    if ($mode eq 'extract') {
      warn 'unlink ', quote($archive), "\n" if ($::opt_explain || $::opt_simulate);
      if (!$::opt_simulate) {
        unlink($archive) || warn "$::basename: ".quote($archive).": cannot remove - $!\n";
      }
    }
    elsif ($mode eq 'add') {
      warn 'unlink ', quote($args[0]), "\n" if ($::opt_explain || $::opt_simulate);
      if (!$::opt_simulate) {
        unlink($args[0]) || warn "$::basename: ".quote($args[0]).": cannot remove - $!\n";
      }
    }
  }

  return $outfile;
}

# maketarcmd(opts):
# Create (partial) command line arguments for a tar command.
# The parameter opts specifies additional arguments to add.
sub maketarcmd($$$$@) {
  my ($archive, $outdir, $mode, $opts, @rest) = @_;
  $opts = 'v'.$opts if $::opt_verbosity >= 1;
  my @cmd = ($::cfg_path_tar);
  push @cmd, "xO$opts" if $mode eq 'cat';
  push @cmd, "x$opts" if ($mode eq 'extract' || $mode eq 'extract-to');
  push @cmd, "t$opts" if $mode eq 'list';
  push @cmd, "c$opts" if $mode eq 'add';
  push @cmd, $archive if defined $archive;
  push @cmd, '-C', $outdir if $mode eq 'extract';
  push @cmd, '-C', $::opt_cmd_extract_to if $mode eq 'extract-to';
  push @cmd, @rest;
  return @cmd;
}

# cmdexec(ignore_return, cmdspec)
# Execute a command specification.
# The cmdspec parameter is a list of string arguments building
# the command line. If there's a list reference instead of a
# string, it is a shell meta character/string which shouldn't
# be quoted.
sub cmdexec($@) {
  my ($ignret, @cmd) = @_;
  
  if ($::opt_explain || $::opt_simulate) {
    my $spec = join(' ', map { ref $_ ? @{$_} : shquotemeta $_ } @cmd);
    explain quote($spec)."\n";
    return 1 if ($::opt_simulate);
  }

  my $cmds = makespec(@cmd);
  if (!shell_execute(@cmd)) {
    warn "$::basename: ".quote($cmds).": cannot execute - $::errmsg\n";
    return 0;
  }

  if ($? & 0xFF != 0) {
    warn "$::basename: ".quote($cmds).": abnormal exit (exit code $?)\n";
    return 0;
  }
  
  if (!$ignret && $? >> 8 != 0) {
    warn "$::basename: ".quote($cmds).": non-zero return-code\n";
    return 0;
  }

  return 1;
}

# makespec(@)
# Make a command specification when printing errors.
sub makespec(@) {
  my (@cmd) = @_;
  my $spec = $cmd[0].' ...';
  my $lastref = 0;
  foreach (@cmd, '') {
    if ($lastref) {
      $spec .= " | $_ ...";
      $lastref = 0;
    }
    $lastref = 1 if (ref);
  }
  return $spec;
}

# makeoutfile(template)
# Make a unique output file for extraction command.
sub makeoutfile($) {
  my ($template) = @_;
  my $file;
  do {
    $file = sprintf $template, int rand 10000;
  } while (-e $file);
  return $file;
}

# makeoutdir()
# Make a temporary (unique) output directory for extraction command.
sub makeoutdir() {
  my $dir;
  do {
    $dir = sprintf $::cfg_tmpdir_name, int rand 10000;
  } while (-e $dir);

  warn 'mkdir ', $dir, "\n" if $::opt_simulate || $::opt_explain;
  if (!$::opt_simulate) {
    if (!mkdir($dir, 0700)) {
      warn "$::basename: ".quote($dir).": cannot create directory - $!\n";
      return undef;
    }
    push @::rmdirs, $dir;
  }
  return $dir;
}

# explain($)
# Print on screen if $::opt_explain is true.
sub explain($) {
  my ($msg) = @_;
  print STDERR $msg if ($::opt_explain || $::opt_simulate);
}

# tailslash($)
# If specified filename does not end with a slash,
# add one and return the new filename.
sub tailslash($) {
  my ($file) = @_;
  return ($file =~ /\/$/ ? $file : "$file/");
}

# shquotemeta($)
# A more sophisticated quotemeta for bourne shells.
# (This should be used for printing only.)
sub shquotemeta($) {
  my ($str) = @_;
  $str =~ s/([^A-Za-z0-9_.+,\/:=@%^-])/\\$1/g;
  return $str;
}

# multiarchivecmd(archive, outdir, mode, create, needcwd, argref, cmdspec)
# Execute a command for multi-file archives.
# The `create' argument controls whether the archive
# will be created (1) or just added to (0) if mode is "add".
# If mode is 'extract', returns the directory (or only file)
# which was extracted.
# If needcwd is true, the outdir must be changed to.
sub multiarchivecmd($$$$@) {
  my ($archive, $outdir, $mode, $create, $needcwd, $argref, @cmd) = @_;
  my @args = @{$argref};

  if ($mode eq 'cat' && @args == 0) {
    die "$::basename: missing file argument\n"; #OK
  }

  if ($mode eq 'add' && $create && !$::opt_force && (-e $archive || -l $archive)) {
    warn "$::basename: ".quote($archive).": refusing to overwrite existing file\n";
    return undef;
  }

  push @cmd, ['|'], get_pager_program() if $::opt_use_pager;

  my $olddir = undef;
  if ($needcwd) {
    $olddir = getcwd();
    if ($mode eq 'extract') {
      warn "cd ", quote($outdir), "\n" if $::opt_explain || $::opt_simulate;
      if (!$::opt_simulate && !chdir($outdir)) {
        warn "$::basename: ".quote($outdir).": cannot change to - $!\n";
        return undef;
      }
    }
    if ($mode eq 'extract-to') {
      warn "cd ", quote($::opt_cmd_extract_to), "\n" if $::opt_explain || $::opt_simulate;
      if (!$::opt_simulate && !chdir($::opt_cmd_extract_to)) {
        warn "$::basename: ".quote($::opt_cmd_extract_to).": cannot change to - $!\n";
        return undef;
      }
    }
  }

  if ($mode ne 'extract') {
    cmdexec(0, @cmd) || return undef;
    if (defined $olddir) {
      warn "cd ", quote($olddir), "\n" if $::opt_explain || $::opt_simulate;
      if (!$::opt_simulate && !chdir($olddir)) {
        warn "$::basename: ".quote($olddir).": cannot change to - $!\n";
        return undef;
      }
    }
    # XXX: can't save outdir with extract-to.
    return 1;
  }

  if (!cmdexec(0, @cmd)) {
    if (defined $olddir) {
      warn "cd ", quote($olddir), "\n" if $::opt_explain || $::opt_simulate;
      if (!$::opt_simulate && !chdir($olddir)) {
        warn "$::basename: ".quote($olddir).": cannot change to - $!\n";
      }
    }
    return undef;
  }

  if (defined $olddir) {
    warn "cd ", quote($olddir), "\n" if $::opt_explain || $::opt_simulate;
    if (!$::opt_simulate && !chdir($olddir)) {
      warn "$::basename: ".quote($olddir).": cannot change to - $!\n";
      return undef;
    }
  }

  return undef if $::opt_simulate;

  if (!opendir(DIR, $outdir)) {
    warn "$::basename: ".quote($outdir).": cannot list - $!\n";
    return undef;
  }
  my @files = grep !/^\.\.?$/, readdir DIR;
  closedir DIR;

  my $archivebase = File::Basename::basename($archive);
  my $reason;
  my $adddir = 0;
  if (@files == 0) {
    warn quote($archivebase).": archive is empty\n";
    rmdir $outdir;
    return undef;
  } elsif ($::opt_extract_subdir) {
    $reason = 'forced';
  } elsif (@files == 1) {
    my $fromfile = File::Spec->catfile($outdir, $files[0]);
    if ($::opt_force || (!-l $files[0] && !-e $files[0])) {

      # If the file is a directory, it can only be moved if writable
      my $oldmode = undef;
      if (!-l $fromfile && -d $fromfile) {
        my @statinfo = stat($fromfile);
        if (!@statinfo) {
          warn quote($fromfile).": cannot get file info - $!\n";
          return undef;
        }
        $oldmode = $statinfo[2];
        if (!chmod(0700, $fromfile)) {
          warn quote($fromfile).": cannot change mode - $!\n";
          return undef;
        }
      }

      if (!rename $fromfile, $files[0]) {
        warn quote($fromfile).": cannot rename - $!\n";
        return undef;
      }
      rmdir $outdir;

      # If we changed mode previously, restore that mode now
      if (defined $oldmode) {
        if (!chmod($oldmode, $files[0])) {
          warn quote($files[0]).": cannot change mode - $!\n";
          return undef;
        }
      }

      if ($::cfg_show_extracted) {
        my $file = ($files[0] =~ /\// ? dirname($files[0]) : $files[0]);
        warn quote($archivebase).": extracted to `".quote($file)."'\n" ;
      }

      save_outdir($files[0]);
      return $files[0];
    }
    $reason = 'local file exists';
    $adddir = 1 if (!-l $files[0] && -d $files[0]);
  } else {
    $reason = 'multiple files in root';
  }

  my $localoutdir = stripext($archivebase);
  if (!-e $localoutdir) {
    if (!rename $outdir, $localoutdir) {
      warn quote($outdir).": cannot rename - $!\n";
      return undef;
    }
    $outdir = $localoutdir;
  }

  warn quote($archivebase).": extracted to `".quote($outdir)."' ($reason)\n";
  save_outdir($adddir ? File::Spec->catfile($outdir, $files[0]) : $outdir);
  return $outdir;
}

# stripext(file)
# Strip extension from the specified file.
sub stripext($) {
  my ($file) = @_;
  return $file if ($file =~ s/(\.tar\.bz2|\.tbz2)$//);
  return $file if ($file =~ s/(\.tar\.bz|\.tbz)$//);
  return $file if ($file =~ s/(\.tar\.gz|\.tgz)$//);
  return $file if ($file =~ s/(\.tar\.Z|\.tZ)$//);
  return $file if ($file =~ s/(\.tar\.7z|\.t7z)$//);
  return $file if ($file =~ s/(\.tar\.lzma|\.tlzma)$//);
  return $file if ($file =~ s/(\.tar\.lzo|\.lzo)$//);
  return $file if ($file =~ s/(\.tar\.lz|\.lz)$//);
  return $file if ($file =~ s/\.tar$//);
  return $file if ($file =~ s/\.bz2$//);
  return $file if ($file =~ s/\.bz$//);
  return $file if ($file =~ s/\.lz$//);
  return $file if ($file =~ s/\.gz$//);
  return $file if ($file =~ s/\.zip$//);
  return $file if ($file =~ s/\.7z$//);
  return $file if ($file =~ s/\.alz$//);
  return $file if ($file =~ s/\.jar$//);
  return $file if ($file =~ s/\.war$//);
  return $file if ($file =~ s/\.Z$//);
  return $file if ($file =~ s/\.rar$//);
  return $file if ($file =~ s/\.(lha|lzh)$//);
  return $file if ($file =~ s/\.ace$//);
  return $file if ($file =~ s/\.arj$//);
  return $file if ($file =~ s/\.a$//);
  return $file if ($file =~ s/\.lzma$//);
  return $file if ($file =~ s/\.rpm$//);
  return $file if ($file =~ s/\.deb$//);
  return $file if ($file =~ s/\.cpio$//);
  return $file if ($file =~ s/\.cab$//);
  return $file if ($::cfg_strip_unknown_ext && $file =~ s/\.[^.]+$//);
  return $file;
}

# formatext(format)
# Return the usual extension for the specified file format
sub formatext($) {
  my ($format) = @_;
  return '.tar.bz2'  if $format eq 'tar+bzip2';
  return '.tar.gz'   if $format eq 'tar+gzip';
  return '.tar.bz'   if $format eq 'tar+bzip';
  return '.tar.7z'   if $format eq 'tar+7z';
  return '.tar.lzo'  if $format eq 'tar+lzop';
  return '.tar.lzma' if $format eq 'tar+lzma';
  return '.tar.lz'   if $format eq 'tar+lzip';
  return '.tar.xz'   if $format eq 'tar+xz';
  return '.tar.Z'    if $format eq 'tar+compress';
  return '.tar'      if $format eq 'tar';
  return '.bz2'      if $format eq 'bzip2';
  return '.lzma'     if $format eq 'lzma';
  return '.7z'       if $format eq '7z';
  return '.alz'      if $format eq 'alzip';
  return '.bz'       if $format eq 'bzip';
  return '.gz'       if $format eq 'gzip';
  return '.lzo'      if $format eq 'lzop';
  return '.lz'       if $format eq 'lzip';
  return '.xz'       if $format eq 'xzip';
  return '.rz'       if $format eq 'rzip';
  return '.lrz'      if $format eq 'lrzip';
  return '.zip'      if $format eq 'zip';
  return '.jar'      if $format eq 'jar';
  return '.Z'        if $format eq 'compress';
  return '.rar'      if $format eq 'rar';
  return '.ace'      if $format eq 'ace';
  return '.a'        if $format eq 'ar';
  return '.arj'      if $format eq 'arj';
  return '.lha'      if $format eq 'lha';
  return '.rpm'      if $format eq 'rpm';
  return '.deb'      if $format eq 'deb';
  return '.cpio'     if $format eq 'cpio';
  return '.cab'      if $format eq 'cab';
  die "$::basename: ".quote($format).": don't know file extension for format\n";
}

# issingleformat(fmt)
# fmt is a file specification as returned by findformat.
# This function returns true if fmt is a single file archive (gzip etc)
# for certain. This means that 7zip is not a single file archive format,
# although it can be used in this way.
sub issingleformat($) {
  my ($fmt) = @_;
  return 1 if $fmt eq 'bzip2';
  return 1 if $fmt eq 'gzip';
  return 1 if $fmt eq 'bzip';
  return 1 if $fmt eq 'compress';
  return 1 if $fmt eq 'lzma';
  return 1 if $fmt eq 'lzop';
  return 1 if $fmt eq 'lzip';
  return 1 if $fmt eq 'xz';
  return 1 if $fmt eq 'rzip';
  return 1 if $fmt eq 'lrzip';
  return 0;
}

# findformat(spec, manual)
# Figure out format from specified file/string.
# If manual is 0, spec is a filename, otherwise
# it is a format description string.
sub findformat($$) {
  my ($file, $manual) = @_;
  my $spec = lc $file;
  my @fileoutput = (
    ['tar+bzip2',      qr/^(GNU|POSIX) tar archive \(bzip2 compressed data(\W|$)/],
    ['tar+gzip',       qr/^(GNU|POSIX) tar archive \(gzip compressed data(\W|$)/],
    ['tar+bzip',       qr/^(GNU|POSIX) tar archive \(bzip compressed data(\W|$)/],
    ['tar+compress',   qr/^(GNU|POSIX) tar archive \(compress'd data(\W|$)/],
    ['tar',            qr/^(GNU|POSIX) tar archive(\W|$)/],
    ['zip',            qr/ \(Zip archive data[^)]*\)$/],
    ['zip',            qr/^Zip archive data(\W|$)/],
    ['zip',            qr/^MS-DOS executable (.*), ZIP self-extracting archive(\W|$)/],
    ['rar',            qr/^RAR archive data(\W|$)/],
    ['lha',            qr/^LHa \(2\.x\) archive data /],
    ['lha',            qr/^LHa 2\.x\? archive data /],
    ['lha',            qr/^LHarc 1\.x archive data /],
    ['lha',            qr/^MS-DOS executable .*, LHA's SFX$/],
    ['7z',             qr/^7(z|-zip) archive data, version .*$/],
    ['ar',             qr/^current ar archive(\W|$)/],
    ['arj',            qr/^ARJ archive data(\W|$)/],
    ['arc',            qr/^ARC archive data(\W|$)/],
    ['cpio',           qr/^cpio archive$/],
    ['cpio',           qr/^ASCII cpio archive /],
    ['rpm',            qr/^RPM v/],
    ['cab',            qr/^Microsoft Cabinet archive data\W/],
    ['cab',            qr/^PE executable for MS Windows /],
    ['deb',            qr/^Debian binary package(\W|$)/],
    ['bzip2',          qr/ \(bzip2 compressed data(\W|$)/],
    ['bzip',           qr/ \(bzip compressed data(\W|$)/],
    ['gzip',           qr/ \(gzip compressed data(\W|$)/],
    ['compress',       qr/ \(compress'd data(\W|$)/],
    ['lzma',           qr/^lzma compressed data /], # Not in my magic
    ['lzop',           qr/^lzop compressed data /],
    ['lzip',           qr/^lzip compressed data /], # Not in my magic
    ['xz',             qr/^xz compressed data /], # Not in my magic
    ['rzip',           qr/^rzip compressed data /],
    ['lrzip',          qr/^lrzip compressed data /], # Not in my magic
    ['bzip2',          qr/^bzip2 compressed data(\W|$)/],
    ['bzip',           qr/^bzip compressed data(\W|$)/],
    ['gzip',           qr/^gzip compressed data(\W|$)/],
    ['compress',       qr/^compress'd data(\W|$)/],
  );
  my @fileextensions = (
    ['tar+7z',         qr/(\.tar\.7z|\.t7z)$/],
    ['tar+bzip',       qr/(\.tar\.bz|\.tbz)$/],
    ['tar+bzip2',      qr/(\.tar\.bz2|\.tbz2)$/],
    ['tar+compress',   qr/(\.tar\.[zZ]|\.t[zZ])$/],
    ['tar+gzip',       qr/(\.tar\.gz|\.tgz)$/],
    ['tar+lzip',       qr/(\.tar\.lz|\.tlz)$/],
    ['tar+lzma',       qr/(\.tar\.lzma|\.tlzma)$/],
    ['tar+lzop',       qr/(\.tar\.lzo|\.tzo)$/],
    ['tar+xz',         qr/(\.tar\.xz|\.txz)$/],

    ['7z',             qr/\.7z$/],
    ['ace',            qr/\.ace$/],
    ['alzip',          qr/\.alz$/],
    ['ar',             qr/\.a$/],
    ['arc',            qr/\.arc$/],
    ['arj',            qr/\.arj$/],
    ['bzip',           qr/\.bz$/],
    ['bzip2',          qr/\.bz2$/],
    ['cab',            qr/\.cab$/],
    ['compress',       qr/\.[zZ]$/],
    ['cpio',           qr/\.cpio$/],
    ['deb',            qr/\.deb$/],
    ['gzip',           qr/\.gz$/],
    ['jar',            qr/\.(jar|war)$/],
    ['lha',            qr/\.(lha|lzh)$/],
    ['lrzip',          qr/\.lrz$/],
    ['lzip',           qr/\.lz$/],
    ['lzma',           qr/\.lzma$/],
    ['lzop',           qr/\.lzo$/],
    ['rar',            qr/\.rar$/],
    ['rpm',            qr/\.rpm$/],
    ['rzip',           qr/\.rz$/],
    ['tar',            qr/\.tar$/],
    ['xz',             qr/\.xz$/],
    ['zip',            qr/\.zip$/],
  );

  if ($manual) {
    $spec =~ tr/+/./;
    $spec =~ s/^\.*/\./;
    $spec =~ s/lzop/lzo/;
    $spec =~ s/lzip/lz/;
    $spec =~ s/rzip/rz/;
    $spec =~ s/lrzip/lrz/;
    $spec =~ s/bzip2/bz2/;
    $spec =~ s/bzip/bz/;
    $spec =~ s/gzip/gz/;
    $spec =~ s/7zip/7z/;
    $spec =~ s/alzip/alz/;
    $spec =~ s/compress/Z/;
    $spec =~ s/^ar$/a/;
  }
  if (!$::cfg_use_file_always) {
    foreach my $formatinfo (@fileextensions) {
      my ($format, $regex) = @{$formatinfo};
      return $format if ($spec =~ $regex);
    }
  }
  if (!$manual && $::cfg_use_file) {
    if (!-e $file) {
      warn "$::basename: ".quote($file).": no such file and cannot identify format from extension\n";
      return;
    }
    if (!sysopen(TMP, $file, O_RDONLY)) {
      warn "$::basename: ".quote($file).": cannot open - $!\n";
      return;
    }
    close TMP;
    if (!-f $file) {
      warn "$::basename: ".quote($file).": not a regular file\n";
      return;
    }
    if ($::opt_verbosity >= 1) {
            if ($::cfg_use_file_always) {
        warn "$::basename: ".quote($file).": identifying format using file\n";
            } else {
        warn "$::basename: ".quote($file).": format not known, identifying using file\n";
                        }
    }
    my @cmd = ($::cfg_path_file, '-b', '-L', '-z', '--', $file);
    $spec = backticks(@cmd);
    if (!defined $spec) {
      warn "$::basename: $::errmsg\n";
      return;
    }
    if ($? & 0xFF != 0) {
      warn "$::basename: ".quote($::cfg_path_file).": abnormal exit\n";
      return;
    }
    if ($? >> 8 != 0) {
      warn "$::basename: ".quote($file).": unknown file format\n";
      return;
    }
    chomp $spec;
    foreach my $formatinfo (@fileoutput) {
      my ($format, $regex) = @{$formatinfo};
      if ($spec =~ $regex) {
        warn "$::basename: ".quote($file).": format is `$format'\n" if $::opt_verbosity >= 1;
        return $format;
      }
    }
    warn "$::basename: ".quote($file).": unsupported file format `$spec'\n";
    return;
  }
  warn "$::basename: ".quote($file).": unrecognized file format\n";
  return;
}

# backticks(cmdargs, ..)
# An implementation of the backtick (qx//) operator.
# The difference is that command STDERR output will still
# be printed on STDERR, and the shell isn't used to parse
# the command line.
sub backticks(@) {
  if (!pipe(IN,OUT)) {
    $::errmsg = "pipe failed - $!";
    return;
  }
  my $child = fork;
  if (!defined $child) {
    $::errmsg = "fork failed - $!";
    return;
  }
  if ($child == 0) {
    close IN || exit 1;
    close STDOUT || exit 1;
    open(STDOUT, '>&OUT') || exit 1;
    close OUT || exit 1;
    $SIG{__WARN__} = sub {};
    exec(@_) || exit 1;
  }
  close OUT;
  my $text = join('', <IN>);
  close IN;
  if (waitpid($child,0) != $child && $^O ne 'MSWin32') {
    $::errmsg = "waitpid failed - $!";
    return;
  }
  return $text;
}

# set_config_option(variable, value)
# Set a configuration option.
sub set_config_option($$$) {
  my ($var, $val, $context) = @_;
  my %optionmap = (
    'args_diff'               => [ 'option', \$::cfg_args_diff, qr/.*/ ],
    'decompress_to_cwd'       => [ 'option', \$::cfg_decompress_to_cwd, qr/^(0|1)$/ ],
    'default_verbosity'       => [ 'option', \$::cfg_default_verbosity, qr/^\d+$/ ],
    'extract_deb_control'     => [ 'option', \$::cfg_extract_deb_control, qr/^(0|1)$/ ],
    'keep_compressed'         => [ 'option', \$::cfg_keep_compressed, qr/^(0|1)$/ ],
    'path_7z'                 => [ 'option', \$::cfg_path_7z, qr/.*/ ],
    'path_ar'                 => [ 'option', \$::cfg_path_ar, qr/.*/ ],
    'path_arc'                => [ 'option', \$::cfg_path_arc, qr/.*/ ],
    'path_arj'                => [ 'option', \$::cfg_path_arj, qr/.*/ ],
    'path_bzip'               => [ 'option', \$::cfg_path_bzip, qr/.*/ ],
    'path_bzip2'              => [ 'option', \$::cfg_path_bzip2, qr/.*/ ],
    'path_cabextract'         => [ 'option', \$::cfg_path_cabextract, qr/.*/ ],
    'path_cat'                => [ 'option', \$::cfg_path_cat, qr/.*/ ],
    'path_compress'           => [ 'option', \$::cfg_path_compress, qr/.*/ ],
    'path_cpio'               => [ 'option', \$::cfg_path_cpio, qr/.*/ ],
    'path_diff'               => [ 'option', \$::cfg_path_diff, qr/.*/ ],
    'path_dpkg_deb'           => [ 'option', \$::cfg_path_dpkg_deb, qr/.*/ ],
    'path_file'               => [ 'option', \$::cfg_path_file, qr/.*/ ],
    'path_find'               => [ 'option', \$::cfg_path_find, qr/.*/ ],
    'path_gzip'               => [ 'option', \$::cfg_path_gzip, qr/.*/ ],
    'path_jar'                => [ 'option', \$::cfg_path_jar, qr/.*/ ],
    'path_lbzip2'             => [ 'option', \$::cfg_path_lbzip2, qr/.*/ ],
    'path_lha'                => [ 'option', \$::cfg_path_lha, qr/.*/ ],
    'path_lrzip'              => [ 'option', \$::cfg_path_lrzip, qr/.*/ ],
    'path_lzip'               => [ 'option', \$::cfg_path_lzip, qr/.*/ ],
    'path_lzma'               => [ 'option', \$::cfg_path_lzma, qr/.*/ ],
    'path_lzop'               => [ 'option', \$::cfg_path_lzop, qr/.*/ ],
    'path_nomarch'            => [ 'option', \$::cfg_path_nomarch, qr/.*/ ],
    'path_pager'              => [ 'option', \$::cfg_path_pager, qr/.*/ ],
    'path_pbzip2'             => [ 'option', \$::cfg_path_pbzip2, qr/.*/ ],
    'path_pigz'               => [ 'option', \$::cfg_path_pigz, qr/.*/ ],
    'path_plzip'              => [ 'option', \$::cfg_path_plzip, qr/.*/ ],
    'path_rar'                => [ 'option', \$::cfg_path_rar, qr/.*/ ],
    'path_rpm'                => [ 'option', \$::cfg_path_rpm, qr/.*/ ],
    'path_rpm2cpio'           => [ 'option', \$::cfg_path_rpm2cpio, qr/.*/ ],
    'path_rzip'               => [ 'option', \$::cfg_path_rzip, qr/.*/ ],
    'path_tar'                => [ 'option', \$::cfg_path_tar, qr/.*/ ],
    'path_unace'              => [ 'option', \$::cfg_path_unace, qr/.*/ ],
    'path_unalz'              => [ 'option', \$::cfg_path_unalz, qr/.*/ ],
    'path_unarj'              => [ 'option', \$::cfg_path_unarj, qr/.*/ ],
    'path_unrar'              => [ 'option', \$::cfg_path_unrar, qr/.*/ ],
    'path_unzip'              => [ 'option', \$::cfg_path_unzip, qr/.*/ ],
    'path_usercfg'            => [ 'option', \$::cfg_path_usercfg, qr/.*/ ],
    'path_xargs'              => [ 'option', \$::cfg_path_xargs, qr/.*/ ],
    'path_xz'                 => [ 'option', \$::cfg_path_xz, qr/.*/ ],
    'path_zip'                => [ 'option', \$::cfg_path_zip, qr/.*/ ],
    'show_extracted'          => [ 'option', \$::cfg_show_extracted, qr/^(0|1)$/ ],
    'strip_unknown_ext'       => [ 'option', \$::cfg_strip_unknown_ext, qr/^(0|1)$/ ],
    'tmpdir_name'             => [ 'option', \$::cfg_tmpdir_name, qr/.*/ ],
    'tmpfile_name'            => [ 'option', \$::cfg_tmpfile_name, qr/.*/ ],
    'use_arc_for_unpack'      => [ 'option', \$::cfg_use_arc_for_unpack, qr/^(0|1)$/ ],
    'use_arj_for_unpack'      => [ 'option', \$::cfg_use_arj_for_unpack, qr/^(0|1)$/ ],
    'use_file'                => [ 'option', \$::cfg_use_file, qr/^(0|1)$/ ],
    'use_file_always'         => [ 'option', \$::cfg_use_file_always, qr/^(0|1)$/ ],
    'use_find_cpio_print0'    => [ 'option', \$::cfg_use_find_cpio_print0, qr/^(0|1)$/ ],
    'use_gzip_for_z'          => [ 'option', \$::cfg_use_gzip_for_z, qr/^(0|1)$/ ],
    'use_lbzip2'              => [ 'option', \$::cfg_use_lbzip2, qr/^(0|1)$/ ],
    'use_jar'                 => [ 'option', \$::cfg_use_jar, qr/^(0|1)$/ ],
    'use_pbzip2'              => [ 'option', \$::cfg_use_pbzip2, qr/^(0|1)$/ ],
    'use_pigz'                => [ 'option', \$::cfg_use_pigz, qr/^(0|1)$/ ],
    'use_plzip'               => [ 'option', \$::cfg_use_plzip, qr/^(0|1)$/ ],
    'use_rar_for_unpack'      => [ 'option', \$::cfg_use_rar_for_unpack, qr/^(0|1)$/ ],
    'use_rar_for_unrar'       => [ 'obsolete', 'use_rar_for_unpack' ],
    'use_tar_bzip2_option'    => [ 'option', \$::cfg_use_tar_bzip2_option, qr/^(0|1)$/ ],
    'use_tar_lzma_option'     => [ 'option', \$::cfg_use_tar_lzma_option, qr/^(0|1)$/ ],
    'use_tar_lzop_option'     => [ 'option', \$::cfg_use_tar_lzop_option, qr/^(0|1)$/ ],
    'use_tar_xz_option'       => [ 'option', \$::cfg_use_tar_xz_option, qr/^(0|1)$/ ],
    'use_tar_j_option'        => [ 'obsolete', 'use_tar_bzip2_option' ],
    'use_tar_z_option'        => [ 'option', \$::cfg_use_tar_z_option, qr/^(0|1)$/ ],
  );
  die $::basename,': ',$context,'unrecognized directive `',$var,"'\n" if !exists $optionmap{$var};
  return 0 if !exists $optionmap{$var};
  my ($type) = @{$optionmap{$var}};
  if ($type eq 'obsolete') {
    warn $context.$var.' is obsolete - use '.$optionmap{$var}->[1].')'."\n";
    $var = $optionmap{$var}->[1];
  }
  my ($varref,$check) = @{$optionmap{$var}}[1,2];
  die $::basename,': ',$context,'invalid value for `',$var,"'\n" if $val !~ $check;
  ${$varref} = $val;
  return 1;
}

# readconfig(file)
# Read and parse the specified configuration file.
# If the file does not exist, just return.
# If there is an error in the configuration file,
# the program will be terminated. This could be a
# problem when there are errors in the system-wide
# configuration file.
sub readconfig($$) {
  my ($file, $failok) = @_;
  return if ($failok && !-e $file);
  sysopen(FILE, $file, O_RDONLY) || die "$::basename: ".quote($file).": cannot open for reading - $!\n";  #OK
  while (<FILE>) {
    chomp;
    next if /^\s*(#(.*))?$/;
    my ($var,$val) = /^(.*?)\s+([^\s].*)$/; # joe markup bug -> ]]
    set_config_option($var, $val, quote($file).':'.$..': ');
  }
  close(FILE);
}

# Remove a directory recursively. This function used to change
# the mode on the directories is traverses, but I now consider
# that to be unsafe (what if there's a bug in atool and it
# removes a file it shouldn't?).
sub unlink_directory($) {
  my ($dir) = @_;
  die "$::basename: internal error 1 - please report this bug\n"
    if ($dir eq '/' || $dir eq $ENV{HOME});
# chmod 0700, $dir || die "$::basename: cannot chmod `".quote($dir)."': $!\n";
  chdir $dir || die "$::basename: ".quote($dir).": cannot change to - $!\n";
  opendir(DIR, $::cur) || die "$::basename: ".quote($dir).": cannot list - $!\n";
  my @files = readdir(DIR);
  closedir(DIR);
  foreach my $file (@files) {
    next if $file eq $::cur || $file eq $::up;
    if (-d $file && !-l $file) {
      unlink_directory($file);
    } else {
      unlink $file || die "$::basename: ".quote($file).": cannot remove - $!\n";
    }
  }
  chdir $::up || die "$::basename: $::up: cannot change to - $!\n";
  rmdir $dir || die "$::basename: ".quote($dir).": cannot remove - $!\n";
}

# find_comparable_file(dir)
# Assuming that the contents of some archive has been extracted to dir,
# this function will determine the main file or directory in this
# archive - the file or directory which will be compared when this
# archive is compared to some other.
sub find_comparable_file($) {
  my ($dir) = @_;
  my $result = $dir;
  if (opendir(my $dh, $dir)) {
    my @files;
    for (0..3) {
      my $file = readdir($dh);
      last if !defined $file;
      next if $file eq '.' || $file eq '..';
      push @files, $file;
    }
    closedir($dh);
    $result = File::Spec->catfile($dir, $files[0]) if @files == 1;
  }
  return $result;
}

# makeabsolute(file)
# Return the absolute version of file.
sub makeabsolute($) {
  my ($file) = @_;
  return $file if (substr($file, 0, 1) eq '/');
  return File::Spec->catfile(getcwd(), $file);
}

# quote(string)
# Quote a style like the GNU fileutils would do (`locale'
# quoting style).
sub quote($) {
  my ($in) = @_;
  my $out = '';
  for (my $c = 0; $c < length($in); $c++) {
    my $ch = substr($in, $c, 1);
    if ($ch eq "\b") {
      $out .= "\\b";
    } elsif ($ch eq "\f") {
      $out .= "\\f";
    } elsif ($ch eq "\n") {
      $out .= "\\n";
    } elsif ($ch eq "\r") {
      $out .= "\\r";
    } elsif ($ch eq "\t") {
      $out .= "\\t";
    } elsif (ord($ch) == 11) {      # Vertical Tab, \v
      $out .= "\\v";
    } elsif ($ch eq "\\") {
      $out .= "\\\\";
    } elsif ($ch eq "'") {
      $out .= "\\'";
    } elsif ($ch !~ /[[:print:]]/) {
      $out .= sprintf('\\%03o', ord($ch));
    } else {
      $out .= $ch;
    }
  }
  return $out;
}

# shell_execute(@)
# Execute a command with pipes and output redirection like the
# shell does. Only difference is we do it without the shell.
# This reason for this is because we don't have to quote
# meta-characters - some meta-characters like LF and DEL are
# unquotable!
sub shell_execute(@) {
  my @cmdspec = @_;
  my $start = 0;
  my $c;
  for ($c = 0; $c < @cmdspec; $c++) {
    if (ref $cmdspec[$c] && ${$cmdspec[$c]}[0] eq ';') {
      return 0 if !shell_execute_single_statement(@cmdspec[$start..$c-1]);
      $start = $c+1;
    }
  }
  if ($start != $c) {
    return 0 if !shell_execute_single_statement(@cmdspec[$start..$c-1]);
  }
  return 1;
}

sub shell_execute_single_statement(@) {
  my (@cmdspec) = @_;

  while (@cmdspec > 0) {
    my @cmds = ();
    my $start = 0;
    my $redir_out = undef;
    #my $more_cmds = 0;
    my $c;
    for ($c = 0; $c < @cmdspec; $c++) {
      if (ref $cmdspec[$c]) {
        push @cmds, [ @cmdspec[$start..$c-1] ];
        if (${$cmdspec[$c]}[0] eq '>') {
          $redir_out = $cmdspec[$c+1];
          $start = $c+2;
          $c++;
        #} elsif (${$cmdspec[$c]}[0] eq ';') {
          #$more_cmds = 1;
        #  $start = $c+1;
        #  $c++;
        #  last;
        } elsif (${$cmdspec[$c]}[0] eq '|') {
          $start = $c+1;
        }
      }
    }
    push @cmds, [ @cmdspec[$start..$c-1] ] if $start < $c;
    #for (my $x = 0; $x < @cmds; $x++) {
    #  print $x, ': ', join(':',@{$cmds[$x]}), "\n";
    #}
    splice @cmdspec,0,$c;

    $SIG{INT} = 'IGNORE';

    my @ip = ();
    my @op = ();
    my @children = ();
    for (my $c = 0; $c <= $#cmds; $c++) {
      if ($c != $#cmds) {
        @op = reverse POSIX::pipe();
        if (!@op || !defined $op[0] || !defined $op[1]) {
          $::errmsg = "pipe failed - $!";
          return 0;
        }
      }
      if ($c == $#cmds && defined $redir_out) {
        @_ = (); # XXX: necessary to overcome POSIX autoload bug!
        @op = (POSIX::open($redir_out, &POSIX::O_WRONLY | &POSIX::O_CREAT));
        if (!@op || !defined $op[0]) {
          $::errmsg = quote($redir_out).": cannot open for writing - $!";
          return 0;
        }
      }
      my $pid = fork();
      die "fork failed - $!\n" if !defined $pid;
      if ($pid == 0) {
        $SIG{INT} = '';
        if (@ip) {
          die "dup2 failed - $!\n" if POSIX::dup2($ip[1], 0) < 0;
          POSIX::close($_) foreach (@ip);
        }
        if (@op) {
          die "dup2 failed - $!\n" if POSIX::dup2($op[0], 1) < 0;
          POSIX::close($_) foreach (@op);
        }
        exec(@{$cmds[$c]}) || die ${$cmds[$c]}[0].": cannot execute - $!\n";
      }
      POSIX::close($op[0]) if ($c == $#cmds && defined $redir_out);
      POSIX::close($_) foreach (@ip);
      @ip = @op;
      @op = ();
      push @children, $pid;
    }

    foreach (@children) {
      if (waitpid($_,0) < 0 && $^O ne 'MSWin32') {
        $::errmsg = "waitpid failed - $!";
        return 0;
      }
    }
    $SIG{INT} = '';
  }

  return 1;
}

# Write dir to file indicated by $::opt_save_outdir.
#
sub save_outdir($) {
  my ($dir) = @_;
  if (defined $::opt_save_outdir && !-l $dir && -d $dir) {
    if (!sysopen(TMP, $::opt_save_outdir, O_WRONLY)) {
      warn die "$::basename: ".quote($::opt_save_outdir).": cannot open for writing - $!\n";
    } else {
      print TMP $dir, "\n";
      close(TMP);
    }
  }
}

# Somewhat stupid subroutine to add xargs to the command line.
#
sub handle_empty_add(@) {
  my @cmd = @_;
  unshift @cmd, '--';
  unshift @cmd, '-0' if ($::opt_null);
  unshift @cmd, $::cfg_path_xargs;
  return @cmd;
}

# Return a suitable pager command
#
sub get_pager_program {
  return $ENV{PAGER} if (exists $ENV{PAGER});
  return $::cfg_path_pager;
}

# repack_archive(srcfile,dstfile,srcfmt,dstfmt)
# Repack an archive from a file to another (that shouldn't exist).
sub repack_archive($$$$) {
  my ($file1,$file2,$fmt1,$fmt2) = @_;

  # Special cases for tar-based archives (single file archives).
  if ($fmt1 =~ /^tar\+/ && $fmt2 =~ /^tar$/) {
    $fmt1 =~ s/^tar\+//;
    $::opt_cmd_extract_to = $file2; # XXX: would like to get rid of these
    $::opt_cmd_extract_to_type = 'f'; # XXX: would like to get rid of these
    exit 1 if (!runcmds('extract-to', $fmt1, $file1));
    return;
  } elsif ($fmt1 =~ /^tar$/ && $fmt2 =~ /^tar\+/) {
    $fmt2 =~ s/^tar\+//;
    exit 1 if (!runcmds('add', $fmt2, $file2, $file1));
    return;
  }

  if ($fmt1 =~ /^tar\+/ && $fmt2 =~ /^tar\+/) {
    $fmt1 =~ s/^tar\+//;
    $fmt2 =~ s/^tar\+//;
  }

  my $newarchive;
  if (File::Spec->file_name_is_absolute($file2)) {
    $newarchive = $file2;
  } else {
    $newarchive = File::Spec->catdir($::up, $file2);
  }

  my $outdir;
  $outdir = makeoutdir() || exit 1;
  $::opt_cmd_extract_to = $outdir;
  $::opt_cmd_extract_to_type = 'd';
  exit 1 if !runcmds('extract-to', $fmt1, $file1);
  warn 'cd ',quote($outdir),"\n" if $::opt_explain || $::opt_simulate;
  if (!$::opt_simulate) {
    chdir($outdir) || die "$::basename: ".quote($outdir).": cannot change to - $!\n";
  }
  if (issingleformat($fmt2)) {
    # Preferrably we would like to find out what file it was
    # extracted to from the above execute-to command.
    #my $oldfile = stripext_exactly(basename($file1), $fmt1);
    my $oldfile = find_comparable_file($::cur); # FIXME: won't work in simulate mode
    exit 1 if !runcmds('add', $fmt2, $newarchive, $oldfile);
  } else {
    exit 1 if !runcmds('add', $fmt2, $newarchive, $::cur);
  }
  warn 'cd ',quote($::up),"\n" if $::opt_explain || $::opt_simulate;
  if (!$::opt_simulate) {
    chdir($::up) || die "$::basename: ".$::up.": cannot change to - $!\n"; #OK?????
  }
  warn 'rm -r ',quote($outdir),"\n" if $::opt_explain || $::opt_simulate;
  if (!$::opt_simulate) {
    unlink_directory($outdir);
  }
}

sub END {
  map (rmdir, @::rmdirs) if !$::opt_simulate; # Errors are ignored
}

1;
#
# atool - A script for managing file archives of various types.
#
# Copyright (C) 2001, 2002, 2003, 2004, 2005, 2007, 2008,
# 2009, 2011, 2012 Oskar Liljeblad
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# See the atool(1) manual page for usage details.
#
# This file uses tab stops with a length of two.
#

# XXX: We could use -CLSDA but 5.10.0 has a bug which prevents us from
# specifying this with shebang. Thanks to some helpful dude on #perl
# FreeNode.