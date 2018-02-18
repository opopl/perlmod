;

#!/usr/bin/perl -l

#http://www.perlmonks.org/?displaytype=displaycode;node_id=361260
package TempOut;

use overload '""' => 'as_string', fallback => 1;

sub new { 
	my $opt = shift;
	my $content = '';
	open my $t, '>', \$content or die "Unable to open temp stdout: $!";
	my $orig = select $t;
	undef $\ if $opt;
	return bless [ $orig, \$content];
}

sub DESTROY {
	my $self = shift;
	return unless $self->[0];
	select $self->[0];
	undef $self->[0];
	$\ = $/;
}

*release = \&DESTROY;

sub as_string {
	return ${shift->[1]};
}


package main;

use Win32::Clipboard;
use IPC::Run 'run';
use File::Temp;
use File::Spec::Functions 'rel2abs';
use Text::ParseWords 'shellwords';
use Data::Dumper;
use B::Deparse;
use strict;
use vars '$c';

$/ = "\r\n";
my $v = shift;
$v = $v && $v eq '-v' ? 1 : 0;

$main::c = Win32::Clipboard->new();

my $last = "";
my $count = 0;

my %macros;
my %subs = (
	reload => \&reload,
	list => \&list,
	def_macro => \&def_macro,
	rem_macro => \&rem_macro,
	exit => sub { $c->Set("Good bye ;-)");exit },
	restart => \&restart,
	codefor => \&codefor,
	fullcodefor => \&fullcodefor,
	justrestart => sub { restart([1]) },
	promote_macro => \&promote_macro
);

my %commands;
my %scripts;

# find available commands in commands directory
reload();


while ($c->WaitForChange) {
	next unless $c->IsText && $count++;
	my $t = $c->GetText or next;
	next if  $t eq $last || $t !~ /^'?-+\s*([\w-]+)([ \t]+[^\r\n]+)?[\r\n]*(.*)$/s;
	$last = $t;
	my ($command,$params,$in) = ($1,$2,$3);
	# do this afterwards so we have our variables set before using the regex engine again
	$command = lc $command;
	$params =~ s/^\s+//g; 
	next unless exists $commands{$command};
	if (ref $commands{$command}) {
		print "Executing macro $command";
		eval { $commands{$command}->(parse($params),$in) };
		print "Finished execution";
		print $c->GetText if $v;
		next;
	}
	my $out;
	$c->Set('** EXECUTING **');
	(my $stupid_win = $^X) =~ s/\\/\\\\/g;
	if ($v) {
		print qq{Executing: [$^X "$commands{$command}" $params]};
		print "Parses as: ",Dumper(parse(qq["$stupid_win" "$commands{$command}" $params]));
	}
	eval {
		run(parse(qq["$stupid_win" "$commands{$command}" $params]), \$in, \$out);
	};
	$out = "***** ERROR *****:\n$@" if $@;
	$out =~ s~(?<!\r)\n~$/~g;
	$c->Set($out);
	print $c->GetText if $v;
	$last = $out;
}

sub parse {
   my $line = shift ;
   $line =~ s{(\\[\w\s])}{\\$1}g ;
   return [ shellwords $line ];
   
}

sub reload {
	undef %commands;
	for (<commands/*.pl>) {
		next unless -f;
		my ($check) = m!([\w-]+)\.pl$!g or next;
		$commands{lc $check} = rel2abs($_);
		$commands{lc $check} =~ s/\\/\\\\/g;
	}
	%scripts = %commands;
	%commands = (%commands,%subs,%macros);
	my $out = "Commands available: \r\n";
	$out .= join "\r\n", map qq[ -- $_], sort keys %commands;
	print $out;
	$c->Set(($count ? "Reload successful!\r\n":'').$out);
	print Dumper(\%commands) if $v;
}

sub list {
	my $out = "Commands available: $/";
	$out .= join $/, map qq[ -- $_], sort keys %commands;
	print $out;
	$c->Set($out);	
}

sub def_macro {
	my ($args,$in) = @_;
	my ($name,$opt) = @$args;
	$c->Set("No body for the macro '$name' detected") unless $in;
	my $exec = eval { 'sub { my $temporary_out = TempOut->new("' . ($opt || '') . '"); local $_;local *ARGV;local $\\ = $/;local $/ = $/;local ${"} = ${"};local ${,} = ${,};{ my($XYZARGS,$INPUT) = @_;*_ = $XYZARGS;*ARGV = \\@_;open ARGV, \'<\', \\$INPUT or die "Wrapper failed"; };' . $in . '; close ARGV; $main::c->Set($temporary_out->as_string); }' } or warn "Error! $@" and return;
	my $sub = eval { eval $exec or die $@ } or $c->Set("Error creating macro '$name': $@") and print "Body: $/$exec" and return;
	$macros{lc $name} = $commands{lc $name} = $sub;
	local $, = $/;
	print "Built code as: ",B::Deparse->new->coderef2text($sub),"Macro $name successfully created", if $v;
	$c->Set("Macro $name successfully created");
}

sub rem_macro {
	my ($args,$in) = @_;
	my ($name) = @$args;
	$c->Set("Macro $name not found") and return unless exists $commands{$name};
	delete $commands{lc $name};
	delete $macros{lc $name};
	$c->Set("Macro $name successfully removed");
}

sub restart {
	my $args = shift;
	$c->Set("You will lose all macros. Please pass 1 as the first parameter if you wish to continue.") and return unless @$args && $args->[0] eq "1";
	$c->Set("** RESTARTING **");
	print "$/$/Please stay tuned for the following messages.$/$/****** RESTARTING ******$/";
	undef $c;
	exec("$^X $0");
}

sub codefor {
	my $args = lc shift->[0];
	my $out;
	if (exists $macros{$args} && ref $macros{$args}) {
		my @x = map { s/^ {4}//;$_ } split m!\n!,B::Deparse->new->coderef2text($macros{$args});
		$out = join($/, " -- def_macro $args", @x[15..($#x - 3)],"","# End of macro");
	} else {
		$out = "$args is not a macro"
	}
	$c->Set($out);
}

sub fullcodefor {
	my $args = lc shift->[0];
	my $out;
	if (exists $macros{$args}) {
		$out = join $/, split m!\n!,B::Deparse->new->coderef2text($macros{$args});
	} else {
		$out = "$args is not a macro"
	}
	$c->Set($out);
}

sub promote_macro {
	my $args = lc shift->[0];
	my $out;
	if (! exists $macros{$args}) {
		$out = "Macro $args doesn't exist";
	} else {
		$out = eval {
			my @x = map { s/^ {4}//;$_ } split m!\n!,B::Deparse->new->coderef2text($macros{$args});
			mkdir "commands" unless -d "commands";
			open my $f, '>', rel2abs("commands/$args.pl") or die $@;
			print $f $_ for "#!/usr/bin/perl -l","",@x[15..($#x - 3)];
			close $f or die $@;
			delete $macros{$args};
			$commands{$args} = $scripts{$args} = rel2abs("commands/$args.pl");
			"Macro $args successfully promoted!";
		} || "Error promoting macro $args: $@";
	}
	$c->Set($out);
}


__END__

##</code><code>##

#!/usr/bin/perl -l

package Tom;

sub out {
    print "Reached out";
}

package main;

use Safe;

my $t = Safe->new->reval('bless {},"Tom"');

print $t;

print $t->out;

__END__
Tom=HASH(0x18d0b48)
Can't locate object method "out" via package "Tom" at safetest.pl line 17.

##</code><code>##

perl -le'print 2**38'

##</code><code>##

perl -le'$_="@ARGV";tr/a-z/c-zab/;print' "text"

##</code><code>##

perl -pe's/[\W_]//g' file

##</code><code>##

perl -ne'print $1 while /(?<![A-Z])[A-Z]{3}([a-z])[A-Z]{3}(?![A-Z])/g' file

##</code><code>##

#!/usr/bin/perl -wl

use LWP::Simple;

$_ = shift;

while ($_) {
   $_ = get "http://www.pythonchallenge.com/pc/def/linkedlist.php?nothing=$_";
   print;
   ($_)= /(\d+)$/g
}

##</code><code>##

import pickle

print pickle.load(open('banner.p','r'))

##</code><code>##

python script.py | perl -e'$_=eval <STDIN>;for (@$_) { while(($a,$b
)=splice(@$_,0,2)) {print $a x $b}print $/}'

##</code><code>##

#!/usr/bin/perl -wl

use Archive::Zip;

my $z = Archive::Zip->new("channel.zip");

my $seed = shift;
my $comment = "";

while ($seed) {
   my $mem = $z->memberNamed("$seed.txt");
   $comment .= $mem->fileComment();
   ($seed) = $mem->contents =~ /(\d+)$/g;
}

print $comment

##</code><code>##

#!/usr/bin/perl -w

use GD;

my $i = GD::Image->newFromPng("oxygen.png",1);

for (my $x=0;(($r,$g,$b)=$i->rgb($i->getPixel($x,47))) && $r == $g && $g == $b; $x+=7) {
  print chr($r)
}

print $/;

##</code><code>##

perl -le'print map chr, @ARGV' numbers

##</code><code>##

#!/usr/bin/perl

use GD::Simple;

my $i = GD::Simple->new(640,480);

$i->bgcolor('white');
$i->fgcolor('black');

my @a = (
... first values ...
);
my @b = (
... second values ...
);

for (\@a,\@b) {
    while (@$_) {
        my @x = splice @$_,0,2;
        next unless @$_;
        $i->moveTo(@x);
        $i->lineTo(@{$_}[0,1]);
    }
}
open $x, ">","out.jpg";
binmode $x;
print $x $i->jpeg();
close $x;

##</code><code>##

perl -le'$_=1; s/((.)\2*)/length($1).$2/ge while $a++ < 30; print length $_'

##</code><code>##

#!/usr/bin/perl

use GD;

my $i = GD::Image->newFromJpeg("cave.jpg",1);

my $b = $i->colorAllocate(255,255,255);

for my $x (0..639) {
    for my $y (0..479) {
        $i->setPixel($x,$y,$b) if ($y % 2 ? $x+1:$x) % 2
    }
}

open $x, ">", "out2.jpg";
binmode $x;
print $x $i->jpeg();
close $x;

##</code><code>##

perl -ne'BEGIN{undef$/;$a=shift;@ARGV=q[evil2.gfx];binmode(STDOUT)}for(;defined($x=substr($_,$a,1));$a+=5){print$x}' number > out.type

##</code><code>##

perl -MRPC::XML::Client -le'print RPC::XML::Client->new(q[http://www.pythonchallenge.com/pc/phonebook.php])->send_request(qw[phone Bert])->value'

##</code><code>##

#!/usr/bin/perl

use GD;

$i = GD::Image->newFromPng("wire.png",1);

$n = GD::Image->newTrueColor(100,100);

my ($x,$y) = (-1,0);
my @go = ([1,0],[0,1],[-1,0],[0,-1]);
my $c = 0;
my $direct = 0;

for ( map { $_ % 100 != 0 ? ($_) x 2 : $_ } reverse 0..100 ) {
    for (1..$_) {
        $x += $go[$direct][0];
        $y += $go[$direct][1];
        $n->setPixel($x,$y, $n->colorAllocate($i->rgb($i->getPixel($c,0))));
        $c++
    }
    $direct++;
    $direct %= 4;
}

open $w, ">", "out3.jpg";
binmode $w;
print $w $n->jpeg(100);
close $w;

##</code><code>##

perl -MDateTime -le'print for grep { $a=DateTime->new(year=>$_,month=>1,day=>26);$a->day_of_week == 1 and $a->is_leap_year } map { sprintf q[1%02d6], reverse 0..99 }'

##</code><code>##


##</code><code>##

Table Items:
itemid | name
-------+--------
 1     | Teddies
 2     | Bobsleds
 3     | Pogo sticks
 4     | Trampolines

Table ShoppingCart:
cartid | name_on_cart
-------+--------------
 1     | Bob Smith
 2     | Jane Dover
 3     | Will Simpson

Table ShoppingCartItems:
cartitemid | cartid | itemid
-----------+--------+---------
 1         | 1      | 2
 2         | 3      | 4
 3         | 2      | 1
 4         | 2      | 4
Foreign key cartid -> ShoppingCart.cartid
Foreign key itemid -> Items.itemid



##</code><code>##

my $iter = ( 
    DBSchema::ShoppingCart->only_fields("name_on_cart")
  + DBSchema::Items->where(name => [ qw(Teddies Trampolines) ]
)->execute;

##</code><code>##

SELECT ShoppingCart.name_on_cart from ShoppingCart where ShoppingCart.cartid IN (SELECT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid = Items.itemid where Items.name in ('Teddies','Trampolines'))

##</code><code>##

my $iter =  ( 
    DBSchema::ShoppingCart->only_fields("name_on_cart") 
  + DBSchema::Items->where(name => "Teddies") 
  + DBSchema::Items->where(name => "Trampolines") 
  - DBSchema::Items->where(name => ["!=", [ qw(Teddies Trampolines) ] ] )
)->execute();

##</code><code>##

SELECT ShoppingCart.name_on_cart from ShoppingCart where ShoppingCart.cartid IN (SELECT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid=Items.itemid where Items.name = 'Teddies') AND ShoppingCart.cartid IN (SELECT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid=Items.itemid where Items.name = 'Trampolines') AND ShoppingCart.cartid NOT IN (SELECT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid=Items.itemid where Items.name NOT IN ('Teddies','Trampolines'))

##</code><code>##

SELECT DISTINCT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid=Items.itemid where Items.name='Teddies';

- collects results -

SELECT DISTINCT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid=Items.itemid where Items.name='Trampolines';

- collects results -

SELECT DISTINCT ShoppingCartItems.cartid from ShoppingCartItems inner join Items on ShoppingCartItems.itemid=Items.itemid where Items.name NOT IN ('Teddies','Trampolines');

- collects results, calculates the intersection from first two and then the difference of the intersection and the third query -

SELECT ShoppingCart.name_on_cart from ShoppingCart where ShoppingCart.cartid=2;

##</code><code>##

package Attribute::Scary;

use Attribute::Handlers;

our %lookup;

sub import {
    # put $self into the calling package
    my $caller = caller() . "::self";
    *{$caller} = \$$caller;
    # well this is somewhat pointless
    $caller = caller();
    *{"$caller\::spacey 0"} = sub { "Bob" };
    *{"$caller\::spacey 1"} = sub { "Hello, Bob!\n" };
}

sub UNIVERSAL::Method :ATTR(CODE) {
    my ($package, $symbol, $referent) = @_;
    my $name = "$package\::" . *{$symbol}{NAME};
    $lookup{$name} = $referent;
    eval "
        no warnings 'redefine';
        *$name = sub {
            package $package;
            local \$self = shift;
            &{\$Attribute::Scary::lookup{'$name'}};
        }
    ";
}

1;

##</code><code>##

#!/usr/bin/perl -l

BEGIN { $INC{"b.pm"}=$0 }

package b;

use attributes;
use Devel::Peek;

our $last;

sub MODIFY_CODE_ATTRIBUTES {
    if ($last) {
	    print "$/-- LAST CODEREF -----";
        Dump($last);
        print "---------------------";
    }
    $last = $_[1];
    print "$/-- Current is $_[1]";
    Dump($_[1]);
}

package a;

use base "b";

sub x :att {}
sub y :att {}

__END__

-- Current is CODE(0x8145670)

SV = RV(0x813f850) at 0x813f2e8
  REFCNT = 1
  FLAGS = (PADBUSY,PADMY,ROK)
  RV = 0x8145670
  SV = PVCV(0x812d950) at 0x8145670
    REFCNT = 5
    FLAGS = ()
    IV = 0
    NV = 0
    COMP_STASH = 0x0
    ROOT = 0x0
    XSUB = 0x0
    XSUBANY = 0
    GVGV::GV = 0x0
    FILE = "(null)"
    DEPTH = 0
    FLAGS = 0x0
    PADLIST = 0x812d790
    OUTSIDE = 0x811b2ac (MAIN)
    
-- LAST CODEREF -----
SV = RV(0x813f854) at 0x8126a7c
  REFCNT = 1
  FLAGS = (ROK)
  RV = 0x8145670
  SV = PVCV(0x812d950) at 0x8145670
    REFCNT = 2
    FLAGS = ()
    IV = 0
    NV = 0
    COMP_STASH = 0x812d6b8      "a"
    START = 0x8130040 ===> 3717
    ROOT = 0x81478c0
    XSUB = 0x0
    XSUBANY = 0
    GVGV::GV = 0x812d7d8        "a" :: "x"
    FILE = "-"
    DEPTH = 0
    FLAGS = 0x0
    PADLIST = 0x812d790
    OUTSIDE = 0x811b2ac (MAIN)
---------------------

-- Current is CODE(0x8148024)
SV = RV(0x813f850) at 0x813f2e8
  REFCNT = 1
  FLAGS = (PADBUSY,PADMY,ROK)
  RV = 0x8148024
  SV = PVCV(0x8167a4c) at 0x8148024
    REFCNT = 5
    FLAGS = ()
    IV = 0
    NV = 0
    COMP_STASH = 0x0
    ROOT = 0x0
    XSUB = 0x0
    XSUBANY = 0
    GVGV::GV = 0x0
    FILE = "(null)"
    DEPTH = 0
    FLAGS = 0x0
    PADLIST = 0x816724c
    OUTSIDE = 0x811b2ac (MAIN)

##</code><code>##

sub randChar {
    my ($chars,$len,$inc,$exl) = split /-/, shift;
    $chars ||= "1";
    $len ||= 1;
    my %map;
    my $temp = 0;
    undef @map{
                "bob",
                map { $temp++; $chars =~ /$temp/ ? @$_ : () } 
                    [0..9],
                    ["a".."z"],
                    ["A".."Z"],
                    [map chr,34..47,58..64,92..96,123..126]
              };
    undef @map{
                "bob", 
                map { /^\d+$/ && $_ < 127 ? chr : () } split/\|/, $inc || ""
              };
    delete @map{
                "bob", 
                map { /^\d+$/ && $_ < 127 ? chr : () } split /\|/, $exl || "" 
               };
    my @map = keys %map or return;
    join "",map $map[rand @map],1..$len
}

##</code><code>##

use Scalar::Util "weaken";
use vars qw(%STORE);


sub new {
   my ($class,$key) = @_;
   return $STORE{$key} if exists $STORE{$key} && defined $STORE{$key};
   my $obj = $class->retrieve($key);
   weaken $obj;
   $STORE{$key} = $obj;
   return $obj;
}

...

##</code><code>##

my $var = 1;
$_string = $var;
$var = 2;
print $_string; # prints 1

$var = 1;
MatchVars->string($var);
$var = 2;
print $_string; # prints 2

##</code><code>##

package MatchVars;

use vars qw($string $match $prematch $postmatch $_internal $_init);
$_internal = "";
$_init = 0;

sub string {
  shift if ref($_[0]) eq "MatchVars" || (@_ > 1 && $_[0] eq "MatchVars");
  return $_internal unless @_;
  $_internal = \ $_[0]
}


sub import {
  no strict;
  my $caller = caller();
  unless ($_init) {
    tie $string, "MatchVars::string", \$_internal;
    tie $match, "MatchVars::Match", \$_internal;
    tie $prematch, "MatchVars::Prematch", \$_internal;
    tie $postmatch, "MatchVars::Postmatch", \$_internal;
    $_init = 1;
  }
  *{"$caller\::_string"} = \$string;
  *{"$caller\::_match"} = \$match;
  *{"$caller\::_prematch"} = \$prematch;
  *{"$caller\::_postmatch"} = \$postmatch;
}

package MatchVars::string;

sub TIESCALAR {
    my ( $class, $r_string ) = @_; 
    bless \do{my $o = $r_string},$class;
}

sub STORE { 
  my $self = shift;
  $$$self = \ $_[0];
}

sub FETCH {
  my $self = shift;
  return $$$$self;
}

sub UNTIE { }

sub DESTROY { }

package MatchVars::base;

sub TIESCALAR {
    my ( $class, $r_string ) = @_; 
    bless \do{my $o = $r_string},$class;
}

sub STORE { }

sub UNTIE { }

sub DESTROY { }

package MatchVars::Match;

use base "MatchVars::base";

sub FETCH { 
    my $self = shift;
    no warnings;
    my $return = substr($$$$self, $-[0], $+[0] - $-[0] );
    return defined $return?$return:"";
}

package MatchVars::Prematch;

use base "MatchVars::base";

sub FETCH {
    my $self = shift;
    no warnings;
    my $return = substr($$$$self,0, $-[0] );
    return defined $return?$return:"";
}

package MatchVars::Postmatch;

use base "MatchVars::base";

sub FETCH { 
    my $self = shift;
    no warnings;
    my $return = substr($$$$self, $+[0]);
    return defined $return?$return:"";
}

1;

# END OF MatchVars.pm
__END__
#!/usr/bin/perl -wl
use strict;
use MatchVars;

# Let's try it out
my $var1 = "pre=match=post";
$_string = $var1;

print "1: $_prematch | $_match | $_postmatch" if $var1 =~ /=\w+=/;

# 1: pre | =match= | post

# But this doesn't work properly if you change $var
my $var2 = "pre=match=post";
$_string = $var2;
$var2 = "this=is_not=right";

print "2: $_prematch | $_match | $_postmatch" if $var2 =~ /=\w+=/;
# 2: pre= | match=po | st

# But this is a workaround
my $var3 = "pre=match=post";
MatchVars->string($var3);
$var3 = "this=shows=up";

print "3: $_prematch | $_match | $_postmatch" if $var3 =~ /=\w+=/;
# this | =shows= | up



