# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use PDL;
use PDL::Config;
use PDL::Graphics::PLplot;
use Test::More;
use File::Spec;

# These tests are taken from the plplot distribution.  The reference results
# are also from the plplot distribution--they are the results of running
# the C language test suite.  D. Hunt May 6, 2011

# Determine if we are running these tests from the build directory
# or the 't' directory.
my $cwd = '.';
my @scripts = glob ("./x??.pl");
unless (@scripts) {
  @scripts = glob ("./t/x??.pl");
  $cwd = 't';
}

my $maindir = '..' if (-s "../OPTIONS!");
   $maindir = '.'  if (-s "./OPTIONS!");
my $plversion = do "$maindir/OPTIONS!";

if ($plversion->{'c_pllegend'}) {
  plan qw(no_plan);
} else {
  plan skip_all => 'pllegend not found--plplot version not recent enough';
}

foreach my $plplot_test_script (@scripts) {
  my ($num) = ($plplot_test_script =~ /x(\d\d)\.pl/);
  (my $c_code = $plplot_test_script) =~ s/\.pl/c\.c/;

  # Compile C version
  unlink ("a.out");
  
  #my $C_COMPILE='gcc -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -I/home/op/include/plplot -I/home/op/include -L/home/op/lib -lplplotd -lX11';

  ####################################
  # Compile PLplot examples

  	my $C_COMPILE='/usr/bin/gcc -pipe -lX11';

  	my $PLPLOT_LIB='/home/op/lib';

  	my $flags=`pkg-config --cflags --libs plplotd`;
	my $rpath=" -Wl,-rpath -Wl,/home/op/lib:/usr/lib/i386-linux-gnu ";
	#$flags.=$rpath;

  $ENV{LD_RUN_PATH}=$PLPLOT_LIB;

  my $cmd="$C_COMPILE $c_code -lm -o a.out $flags";
  system("$cmd");
  ok ((($? == 0) && -s "a.out"), "$c_code compiled successfully");

  ####################################

  # Run C version
  my $devnull = File::Spec->devnull();
  my $dot_slash = $^O =~ /MSWin32/i ? '' : './';
  system "${dot_slash}a.out -dev svg -o x${num}c.svg -fam > $devnull 2>&1";
  ok ($? == 0, "C code $c_code ran successfully");

  # Run perl version
  my $perlrun = $^O =~ /MSWin32/i ? 'perl -Mblib' : '';
  system "$perlrun $plplot_test_script -dev svg -o x${num}p.svg -fam > $devnull 2>&1";
  ok ($? == 0, "Script $plplot_test_script ran successfully");
  my @output = glob ("x${num}p.svg*");
  foreach my $outfile (@output) {
    (my $reffile = $outfile) =~ s/x(\d\d)p/x${1}c/;
    my $perldata = do { local( @ARGV, $/ ) = $outfile; <> } ; # slurp!
    my $refdata  = do { local( @ARGV, $/ ) = $reffile; <> } ; # slurp!
    ok ($perldata eq $refdata, "Output file $outfile matches C output");
  }
}


# comment this out for testing!!!
unlink glob ("$cwd/x???.svg.*");
unlink "$cwd/a.out";

# Local Variables:
# mode: cperl
# End:
