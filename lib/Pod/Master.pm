
=head1 NAME

Pod::Master - I am the master of HTML Pod.

=head1 DESCRIPTION

This module uses L<Pod::Html|Pod::Html> to generate HTML versions of
all the documentation it finds using L<Pod::Find|Pod::Find>.

It also creates a neat-o table of contents.
Look at B<L<this|"Modules">> to see if you like it.

=head1 SYNOPSIS

C<perl -MPod::Master -e Update()>
C<perl -MPod::Master -e " Update()->MiniTOC() ">

    #!/usr/bin/perl -w
    
    use Pod::Master;
    use strict;
    
    my $pM = new Pod::Master( { verbose => 1 } );
       $pM->UpdatePOD();
       $pM->UpdateTOC(1);

=head1 EXPORTS

L<C<Update>|"Update"> is the only exported function, and the only
one you need to call, to have a this module do what it does
and have the results end up in C<perl -V:installhtmldir>

=cut

package Pod::Master;

require  5.005; # let's be reasonable now ;)(cause File* and Pod* are)

use Config;
use File::Path qw( mkpath );
use File::Spec::Functions qw( canonpath abs2rel splitpath splitdir catdir );
use Pod::Html qw( 1.04 ); 
use Pod::Find qw( pod_find );

# now it's my problem
use strict;
BEGIN{eval q{use warnings};} # where available only (i wan't em)

use vars qw(
    @EXPORT @ISA $VERSION
    $MasterCSS 
    $ScriptDir $PrivLib  $SiteLib  $InstallPrefix  $InstallHtmlDir
);

$VERSION = 0.014;
@ISA = qw( Exporter );
@EXPORT = qw( Update );


$ScriptDir = canonpath $Config{scriptdir}; # must be canonical!!!!
$PrivLib = canonpath $Config{privlib};
$SiteLib  = canonpath $Config{sitelib};
$InstallPrefix = canonpath $Config{installprefix};
$InstallHtmlDir = canonpath $Config{installhtmldir};


=head1 Methods

Most of these  return C<$self> if they're not supposed to return anything.

=head2 C<new>

The constructor (a class method).

Takes an optional hashref of C<$options>, which are:

=over 4

=item boiler

I<See L<Header|"Header">>.

=item outdir

A path (which must exist) where 

  podmaster.frame.html
  podmaster.toc.html
  lib/strict.html
  ...

will reside.

=item overwrite

A boolean.  Default is 0. It's the default argument to L<"UpdatePOD">.

=item verbose

A boolean.  If true, prints out messages (it's all or none).

=item path

An array reference of additional directories to search for pod files.

C<perl -V:privlib -V:sitelib -V:scriptdir> are in there by default.

=item pod2html

A hashref, with options to pass to L<Pod::Html|Pod::Html>.

Only the following L<Pod::Html|Pod::Html> options are allowed
(the rest are either automagically generated or not available):

    $self->{pod2html}{backlink}
    $self->{pod2html}{css}
    $self->{pod2html}{quiet}
    $self->{pod2html}{header}
    $self->{pod2html}{verbose}
    $self->{pod2html}{flush}   # valid only on 1st run only
                               # good idea after uninstalling

B<BEWARE> the css option.
Any filename you pass to css should reside in $self->{outdir},
otherwise the css link won't be generated correctly.

It has to be a relative link, meaning you can't do

    my $pM = new Pod::Master({
        pod2html {
            css => 'F:/foo/bar.css',
        },
        outdir => 'G:/baz',
    });

and expect it to work.


=back

=cut

sub new {
    my( $class, $options ) = @_;
    my $self = ref $options eq 'HASH' ? $options : {};
    $self->{boiler}    ||= 0;
    $self->{verbose}   ||= 0;
    $self->{overwrite} ||= 0;
    $self->{outdir}    ||= $InstallHtmlDir || catdir($InstallPrefix,"html");
    $self->{outdir} = canonpath $self->{outdir};
    $self->{pod2html}  ||= {
        css => 'podmaster.css',
        backlink => '__top',
        quiet => 1,
        verbose => 0,
        header =>1,
        flush =>0,
    };

    $self->{path} = [
        grep{'.' ne $_ }
        $PrivLib, $SiteLib, $ScriptDir,
        exists $self->{path} ? @{$self->{path}} : ()
    ];

    return bless $self, $class;
}

=head2 C<Update>

The only exported function.

Takes a single optional argument, which it passes to L<new|"new">.

Unless invoked as a method, creates a new Pod::Master object.

Subsequently invokes L<"UpdatePOD"> and L<"UpdateTOC">.

If you have ActivePerl::DocTools, you may wish to invoke it as
C<Update({outdir=E<gt>'C:/PodMasterHtmlPod/'})>


=cut

sub Update {
    my( $self ) = @_;

    $self = __PACKAGE__->new($self)
      if not defined $self
         or not UNIVERSAL::isa($self,__PACKAGE__);

    $self->UpdatePOD();
    $self->UpdateTOC();
    return $self;
}


=head2 C<UpdatePOD>

Runs pod2html for every pod file found whose .html
equivalent is missing, or outdated (modify time).

Takes a single optional argument, a true value (1),
which forces pod2html to be run on all pod files.

Default agrument is taken from C<$$self{overwrite}>

=cut

sub UpdatePOD {
    my($self, $overwrite ) = @_;
    $overwrite = $self->{overwrite} unless defined $overwrite;

    $self->_FindEmPods() unless exists $self->{Modules};

    chdir $InstallPrefix or die "can't chdir to $InstallPrefix $!";

    print "chdir'ed to $InstallPrefix\n" if $self->{verbose};

    my $libPods = 'perlfunc:perlguts:perlvar:perlrun:perlopt:perlapi:perlxs';
    my $BackLink = $self->{pod2html}{backlink};
    my $css = $self->{pod2html}{css} || "podmaster.css";
    my $p2quiet = $self->{pod2html}{quiet};
    my $p2header = $self->{pod2html}{header};
    my $p2verbose = $self->{pod2html}{verbose};
    my $p2flush = $self->{pod2html}{flush};

    $self->{pod2html}{flush}=0 if $self->{pod2html}{flush};

    my $PodPath = join ':',
            map{
                s{\Q$InstallPrefix\E}{};
                canonpath("./$_");
            }
            @{$self->{path}};
            #($ScriptDir,$PrivLib,$SiteLib); 

    print "podpath = $PodPath\n" if $self->{verbose};

    my $OutDir = $self->{outdir};

    for my $What (qw( PerlDoc Pragmas Scripts Modules )) {
        print "processing $What \n" if $self->{verbose};

        while( my( $name, $InFile ) = each %{$self->{$What}}) {

#            my $RelPath = abs2rel( catdir( (splitpath$InFile)[1,2] ), $InstallPrefix );
            my $RelPath = $self->_RelPath( $InFile, $InstallPrefix );
            my $HtmlRoot = catdir map { $_ ? '..' : $_ } splitdir((splitpath$RelPath)[1]);
            my $OutFile = catdir $OutDir, $RelPath;
               $OutFile =~ s{\.([^\.]+)$}{.html};

            my $HtmlDir = catdir( ( splitpath($OutFile) )[0,1] );

            my @args = (
                "--htmldir=$HtmlDir",
                "--htmlroot=$HtmlRoot",
                "--podroot=.",
                "--podpath=$PodPath",
                "--infile=$InFile", 
                "--outfile=$OutFile",
                "--libpods=$libPods",
                "--css=".catdir($HtmlRoot, $css),
                "--cachedir=$OutDir",
                $p2header ? "--header" : (), 
                $BackLink ? "--backlink=$BackLink" : (),

                ( $p2quiet ? "--quiet" : () ),
                ( $p2verbose ? "--verbose" : () ),
                ( $p2flush ? "--flush" : () ),
            );
            $p2flush = 0 if $p2flush; # first run only

            if( $overwrite ) {

                print "forced overwrite" if $self->{verbose};
                mkpath($HtmlDir);
                $self->pod2html( @args );

            }elsif($self->_AmIOlderThanYou($InFile,$OutFile)){
                print "out of sync" if $self->{verbose};
                mkpath($HtmlDir);
                $self->pod2html( @args );
            }
        }
    }
    return $self;
}


=begin ForInternalUseOnly =head1 C<_AmIOlderThanYou>

Takes 2 filenames ( C<$in,$out>). Returns 1 if $in is older than $out,
or $in doesn't exist.  Returns 0 otherwise.

=end ForInternalUseOnly

=cut

sub _AmIOlderThanYou {
    my($self, $in, $out ) = @_;
    return 1 if not -e $in or (stat $in)[9] > (stat $out)[9] ;
    return 0;
}


=head2 C<UpdateTOC>

Refreshes the MasterTOC (podmaster.toc.html).

Takes 1 argument, C<$ret>, a boolean, and if it's true,
returns the MasterTOC as string.

Re-Creates podmaster.frame.html and podmaster.css if they're missing,
but only if C<$ret> is false.

The standard css is contained in C<$MasterCSS>,
and it is printed if C<$$self{css}> isn't defined.

C<$self->_Frame> contains the frameset to be printed.

=cut

sub UpdateTOC {
#    eval q[use ActivePerl::DocTools::TOC::HTML::Podmaster; ActivePerl::DocTools::TOC::HTML::Podmaster::WriteTOC() ];

    my($self, $ret ) = @_;
    $ret ||=0;

    $self->_FindEmPods() unless exists $self->{Modules};

    my $OutDir = $self->{outdir};

    chdir $OutDir or die "can't chdir to $OutDir $!";

    print "chdir'ed to $OutDir\n" if $self->{verbose};

    my $MasterTOC =  'podmaster.toc.html';
    my $MasterFrame =  'podmaster.frame.html';

    unless($ret){
        open(OUT,">$MasterTOC") or die "Couldn't clobber $MasterTOC $!";
        print "outputting html to $MasterTOC\n" if $self->{verbose};
        print OUT $self->_TOC();
        close OUT;
        print "done\n" if $self->{verbose};
    }else{
        return $self->_TOC();
    }

    my $MasterCss = $self->{pod2html}{css};
    if(not -e $MasterCss and $MasterCss =~ /podmaster\.css/){
        $MasterCss = catdir $OutDir, $MasterCss;
        open(OUT,">$MasterCss") or die "Couldn't refresh $MasterCss $!";
        print "Refreshing $MasterCss " if $self->{verbose};
        print OUT $MasterCSS; ## Oouh, case sensitivity ;^)
        close(OUT);
    }

    open(OUT,">$MasterFrame") or die "Couldn't refresh $MasterFrame $!";
    print "Refreshing $MasterFrame " if $self->{verbose};
    print OUT $self->_Frame($MasterTOC);
    close(OUT);

    return ($self);
}


sub _TOC {
    my( $self ) = @_;
    return join '',
        $self->Header(),
        $self->PerlDoc(),
        $self->Pragmas(),
        $self->Scripts(),
        $self->Modules(),
        $self->Footer();
}


=head2 C<MiniTOC>

Like C<UpdateTOC> except it writes to C<podmaster.minitoc.html>. 

=cut

sub MiniTOC {
    my( $self ) = @_;
    my $OutDir = $self->{outdir};
    $self->_FindEmPods() unless exists $self->{Modules};
    chdir $OutDir or die " can't chdir to $OutDir $!";
    open(OUT,">podmaster.minitoc.html") or die "oops podmaster.minitoc.html $!";
    print OUT $self->Header();
    print OUT q[
<div class="likepre">
<form method=get action="http://search.cpan.org/search" name=f>
<input type="text" name="query" value="" size=36 >
<input type="submit" value="CPAN Search"> in
<select name="mode"><option value="all">All</option>
 <option value="module" >Modules</option>
 <option value="dist" >Distributions</option>
 <option value="author" >Authors</option>
</select>
</form>
<hr>
    <a TARGET="_self" href="podmaster.perldoc.html">Perl Core Documentation</a><br>
    <a TARGET="_self" href="podmaster.pragmas.html">Pragmas</a><br>
    <a TARGET="_self" href="podmaster.scripts.html">Perl Programs</a><br>
    <a TARGET="_self" href="podmaster.modules.html">Installed Modules</a><br>
<hr>
go to <a target=_self href='podmaster.toc.html'>toc</a>(the big one)
</div>
];
    print OUT $self->Footer();
    close OUT;

    open(OUT,'>podmaster.miniframe.html') or die "oops podmaster.miniframe.html $!";
    print OUT $self->_Frame('podmaster.minitoc.html');
    close OUT;

    my $MasterCss = $self->{pod2html}{css};
       $MasterCss = catdir $OutDir, $MasterCss;
    if(not -e $MasterCss and $MasterCss eq 'podmaster.css'){
        open(OUT,">$MasterCss") or die "Couldn't refresh $MasterCss $!";
        print "Refreshing $MasterCss " if $self->{verbose};
        print OUT $MasterCSS; ## Oouh, case sensitivity ;^)
        close(OUT);
    }

    for my $f (qw( PerlDoc Pragmas Scripts Modules ) ) {
        open(OUT,">podmaster.\L$f.html") or die "oops podmaster.\L$_.html $!";
        print OUT $self->Header();
        print OUT "back to <a TARGET=_self href='podmaster.minitoc.html'>minitoc</a> <br>";
        print OUT $self->$f();
        print OUT $self->Footer();
        close OUT;
    }

    return $self;
}

=begin ForInternalUseOnly =head1 C<_FindEmPods>

Invokes C<Pod::Find::pod_find()> and stores the results as

    $self->{PerlDoc} = \%Perldoc;
    $self->{Pragmas} = \%Pragmas;
    $self->{Modules} = \%Modules;
    $self->{Scripts} = \%Scripts;

=end ForInternalUseOnly

=cut

sub _FindEmPods {
    my( $self ) = @_;
    my( %Perldoc, %Pragmas, %Scripts, %Modules);

    my @BINC = map { canonpath($_) } @{$self->{path}}; # Must be canonical!!!

    print "BINC= @BINC \n" if $self->{verbose};

    my @PodList = pod_find( {
            -verbose => 0,
            -perl => 0,
            -inc => 0,  # both -inc and -script automatically turn on -perl
            -script =>0,# this is NOT ****ING DOCUMENTED and cost me an HOUR
        },              # must complain to perl5porters to  document or remove
        @BINC,
    );

    for( my $ix = 0; $ix < $#PodList; $ix+=2 ) {
        my( $filename, $modulename ) = @PodList[$ix,$ix+1];
        $filename = canonpath( $filename );

        print "$filename\n" if $self->{verbose};
# perl pragmas are named all lowercase
# and as of Mon Nov 4 2002, no pragma has a  matching .pod file
# Characters such as the following are not pragmas:
#    cgi_to_mod_perl
#    lwpcook
#    mod_perl
#    mod_perl_cvs
#    mod_perl_method_handlers
#    mod_perl_traps
#    mod_perl_tuning
#    perlfilter

        if( $modulename =~ /^[Pp]od::(perl[a-z\d]*)/ ) {
            $Perldoc{$1} = $filename;
        }elsif( $filename =~ /^\Q$ScriptDir/i) {
            $Scripts{$modulename} = $filename;
        }elsif($modulename =~ /^([a-z:\d]+)$/
               and ( substr($filename,-4) ne '.pod'
                     or $1 eq 'perllocal'
                   )
              ){
            $Pragmas{$1} = $filename;
        }else{
            $Modules{$modulename} = $filename;
        }
    }

    $self->{PerlDoc} = \%Perldoc;
    $self->{Pragmas} = \%Pragmas;
    $self->{Modules} = \%Modules;
    $self->{Scripts} = \%Scripts;

    return $self;
}



=begin ForInternalUseOnly =head1 C<_RelPath>

Takes 2 absolute paths ( C<$file,$base>).
Returns a absolutely relative path from C<$base> to C<$file>

=end ForInternalUseOnly

=cut


sub _RelPath {
    goto &_RelPathForNewerFileSpec if File::Spec->VERSION >= 0.84;
    goto &_RelPathForOlderFileSpec ;
}

sub _RelPathForNewerFileSpec {
    my($self, $file, $base ) = @_;
    return abs2rel($file,$base);
}

sub _RelPathForOlderFileSpec {
    my($self, $file, $base ) = @_;
    return abs2rel(
        catdir( (splitpath $file )[1,2] ),
        $base
    );
}


# idea care of ActivePerl::DocTools::TOC
# this crap be maintained manually (i'll fix this);
use vars qw( @PodOrdering );
@PodOrdering = qw(
            perl perlintro perlfaq perltoc perlbook
                    __
            perlsyn perldata perlop perlsub perlfunc perlreftut perldsc
            perlrequick perlpod perlpodspec perlstyle perltrap
                    __
            perlrun perldiag perllexwarn perldebtut perldebug
                    __
            perlvar perllol perlopentut perlretut perlpacktut
                    __
            perlre perlref
                    __
            perlform 
                    __
            perlboot perltoot perltootc perlobj perlbot perltie
                    __
            perlipc perlfork perlnumber perlthrtut perlothrtut
                    __
            perlport  perllocale perluniintro perlunicode perlebcdic
                    __
            perlsec
                    __
            perlmod perlmodlib perlmodinstall perlmodstyle perlnewmod
                    __
            perlfaq1 perlfaq2 perlfaq3 perlfaq4 perlfaq5
            perlfaq6 perlfaq7 perlfaq8 perlfaq9
                    __
            perlcompile
                    __
            perlembed perldebguts perlxstut perlxs perlclib
            perlguts perlcall perlutil perlfilter
            perldbmfilter perlapi perlintern perlapio perliol
            perltodo perlhack
		    __
            perlhist perldelta 
            perl572delta perl571delta perl570delta perl561delta
            perl56delta  perl5005delta perl5004delta
    		__
            perlapollo perlaix perlamiga perlbeos perlbs2000
            perlce perlcygwin perldos perlepoc perlfreebsd
            perlhpux perlhurd perlirix perlmachten perlmacos
            perlmint perlmpeix perlnetware perlplan9 perlos2
            perlos390 perlqnx perlsolaris perltru64 perluts
            perlvmesa perlvms perlvos perlwin32 
		);


=head1 Subclassing

If you wish to change the way the MasterTOC looks,
subclass C<Pod::Master> and override the following  methods.

=head3 C<Header>

B<Returns> a header ( in this case html).

Takes 1 argument, which defaults to L<C<$$self{boiler}>|"new">.
If it's true, and you are using ActivePerl
( C<$Config{cf_by} eq 'ActiveState'> ),
then the standard boiler from the ActivePerl documentation
will be printed as well (links to the ActivePerl FAQ and stuff).

This is all asuming you have C<ActivePerl::DocTools> installed.

=cut

sub Header {
    my( $self, $boiler) = @_;
    $boiler ||= $self->{boiler};

    my $ret = q[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Perl User Guide - Table of Contents (according to Pod::Master)</title>
<link rel="STYLESHEET" href="podmaster.css" type="text/css">
</head>

<body>
<h1>Table of Contents</h1>
<base target="PerlDoc">
];
    $ret.= "<!-- generated ".scalar(gmtime())." by Pod::Master -->\n";

    if( $boiler
        and
        $Config{cf_by} eq 'ActiveState'
        and eval q{require ActivePerl::DocTools::TOC::HTML} ){
        $ret.= ActivePerl::DocTools::TOC::HTML->boiler_links()."</div>";
    }

    return $ret;
}


=head3 C<PerlDoc>

B<Returns> the "Perl Core Documentation" part of the toc.

Uses C<@Pod::Master::PodOrdering> to do the neato topicalization
of the core pod (inspired by ActivePerl::DocTools).
Accounts for all the Pod::perl files released up to perl-5.8.0.


=cut

sub PerlDoc {
    my $self = shift;
    my $OutDir = $self->{outdir};

    $self->_FindEmPods() unless exists $self->{PerlDoc};
    my %PerlDoc = %{$self->{PerlDoc}};
    my $ret = "<h4>Perl Core Documentation</h4>";

    for my $item(@PodOrdering) {
        if($item eq "__") {
            $ret .= "<br>";
        }elsif( exists $PerlDoc{$item} ) {
            my $OutFile = $self->_RelPath($PerlDoc{$item}, $InstallPrefix );
            delete  $PerlDoc{$item};
            $OutFile =~ s{\.([^\.]+)$}{.html};
            $OutFile =~ y[\\][/];
            $ret .= qq[<A href="$OutFile">$item</a><br>];
        }
    }

    $ret .= "<br>"; # In case we have unknown docs, but we shouldn't

    for my $item(keys %PerlDoc) {
        my $OutFile = $self->_RelPath($PerlDoc{$item}, $InstallPrefix );
        delete  $PerlDoc{$item};
        $OutFile =~ s{\.([^\.]+)$}{.html};
        $OutFile =~ y[\\][/];
        $ret .= qq[<A href="$OutFile">$item</a><br>];
    }

    return $ret;
}

=head3 C<Scripts>

B<Returns> the "Perl Programs" part of the toc.

=cut

sub Scripts {
    my $self = shift;
    my $OutDir = $self->{outdir};

    $self->_FindEmPods() unless exists $self->{Scripts};

    my $ret = "<h4>Perl Programs</h4>";

    for my $item(sort{lc($a)cmp lc($b)}keys %{$self->{Scripts}}) {
        my $OutFile = $self->_RelPath( $self->{Scripts}->{$item}, $InstallPrefix);
        $OutFile =~ s{\.([^\.]+)$}{.html};
        $OutFile =~ y[\\][/]; # fsck MOZILLA HAS ISSUES WITH THIS (MORONS)
        $ret .= qq[<A href="$OutFile">$item</a><br>];
    }

    return $ret;
}

=head3 C<Pragmas>

B<Returns> the "Pragmas" part of the toc.

=cut

sub Pragmas {
    my $self = shift;
    my $OutDir = $self->{outdir};

    my $ret = "<h4>Pragmas</h4>";
    for my $item(sort{lc($a)cmp lc($b)}keys %{$self->{Pragmas}}) {
        my $OutFile = $self->_RelPath( $self->{Pragmas}->{$item}, $InstallPrefix);
        $OutFile =~ s{\.([^\.]+)$}{.html};
        $OutFile =~ y[\\][/];
        $ret .= qq[<A href="$OutFile">$item</a><br>];
    }

    return $ret;
}

sub pod2html {
    my($self, @args ) = @_;
    print join"\n","\n",@args,"\n" if $self->{verbose};
    Pod::Html::pod2html(@args);    
}

=head3 C<Modules>

B<Returns> the I<oh-so-pretty> "Installed Modules" part of the toc,
that looks something like
(note the links won't work, and you'll need a css capable browser):

=begin html

<blockquote> <!-- blockquote not really here -->
<style type="text/css">

.blend {
    color: #FFFFFF;
    text-decoration: underline;
}

</style>

<h4>Installed Modules</h4>
&nbsp;<A href="site/lib/Apache.html">Apache</a><br>
&nbsp;<span class="blend">Apache</span><a href="site/lib/Apache/AuthDBI.html">::AuthDBI</a><br>
&nbsp;<span class="blend">Apache</span><a href="site/lib/Apache/Build.html">::Build</a><br>
&nbsp;<span class="blend">Apache</span><a href="site/lib/Apache/Constants.html">::Constants</a><br>
&nbsp;<span class="blend">Apache</span><a href="site/lib/Apache/CVS.html">::CVS</a><br>

&nbsp;<A href="site/lib/Bundle/Apache.html">Bundle::Apache</a><br>
&nbsp;<span class="blend">Bundle</span><a href="site/lib/Bundle/ApacheTest.html">::ApacheTest</a><br>&nbsp;<A href="site/lib/Bundle/DBD/mysql.html">Bundle::DBD::mysql</a><br>
&nbsp;<span class="blend">Bundle</span><a href="site/lib/Bundle/DBI.html">::DBI</a><br>
&nbsp;<span class="blend">Bundle</span><a href="site/lib/Bundle/LWP.html">::LWP</a><br>
&nbsp;<span class="blend">DBD</span><a href="site/lib/DBD/Proxy.html">::Proxy</a><br>&nbsp;<A href="site/lib/DBI.html">DBI</a><br>
&nbsp;<span class="blend">DBI</span><a href="site/lib/DBI/Changes.html">::Changes</a><br>
&nbsp;<A href="site/lib/DBI/Const/GetInfo/ANSI.html">DBI::Const::GetInfo::ANSI</a><br>
&nbsp;<span class="blend">DBI::Const::GetInfo</span><a href="site/lib/DBI/Const/GetInfo/ODBC.html">::ODBC</a><br>
&nbsp;<A href="site/lib/DBI/Const/GetInfoReturn.html">DBI::Const::GetInfoReturn</a><br>
&nbsp;<span class="blend">DBI::Const</span><a href="site/lib/DBI/Const/GetInfoType.html">::GetInfoType</a><br>
&nbsp;<span class="blend">DBI</span><a href="site/lib/DBI/DBD.html">::DBD</a><br>
&nbsp;<span class="blend">DBI</span><a href="site/lib/DBI/FAQ.html">::FAQ</a><br>

</blockquote>

=end html

In the above example,
you can now search for 'Bundle::DBI' and find it.

You can also search for 'E<32>DBI' (note the space prefix) and find it.

If you only search for 'DBI', you'll find
'Apache::AuthDBI' followed by
'Bundle::DBI' until you get to DBI.

Don't you just love Pod::Master ?

=cut


sub Modules {
    my $self = shift;
    my $ret = "<h4>Installed Modules</h4>";
    my %seen = ();
    $self->_FindEmPods() unless exists $self->{Modules};
    my %Modules = %{$self->{Modules}};

    for my $key(keys %Modules) {
        my @chunks = split /::/, $key;
        my $chunk = shift@chunks;
        $seen{$chunk}=1;
        while(@chunks){
            $chunk.= '::'.shift @chunks;
            $seen{$chunk}=1;
        }
        $seen{$key}=1;
    }

    for my $key(keys %seen) {
        unless(exists $Modules{$key} ) {
            $Modules{$key} = undef;
        }
    }

#    printf("%-70.70s = %-5.5s\n",$_,$Modules{$_}) for(sort{lc($a)cmp lc($b)} keys %Modules);die;

    my($oldLetter, $newLetter ) = ('a','a');
    my($oldD,$newD) = (0,0);

    for my $modulename(sort{lc($a)cmp lc($b)}keys %seen) {
        my $OutFile = $self->_RelPath( $Modules{$modulename}, $InstallPrefix);
        $OutFile =~ s{\.([^\.]+)$}{.html};
        $OutFile =~ y[\\][/];

        $oldLetter = $newLetter;
        $newLetter = lc substr $modulename, 0, 1;
        if($oldLetter ne $newLetter ) {
            $ret.=qq[\n&nbsp;<hr>\n];
        }

=for NoUse
        $oldD = $newD;
        $newD = () = $modulename =~ /::/g;
        $ret.='&nbsp;<br>' if $newD == 0 and 0 != $oldD;

=cut

        if( not defined $Modules{$modulename}) {
            if( $modulename =~ /^(.*?)::([^:]+)$/ ) {
                $ret .= qq[
&nbsp;<span class="blend">$1</span>::$2<br>
];
            } else {
                $ret .= qq[
&nbsp;$modulename<br>
];   
            }
        }elsif( $modulename =~ /^(.*?)::([^:]+)$/ ) {
            $ret .= qq[
&nbsp;<span class="blend">$1</span><a href="$OutFile">::$2</a><br>
];
        } else {
            $ret .= qq[
&nbsp;<A href="$OutFile">$modulename</a><br>
];
        }
    }

    return $ret;
}


sub ModulesOriginal {
    my $self = shift;
    my $ret = "<h4>Installed Modules</h4>";
    my %seen = ();
    for my $modulename(sort{lc($a)cmp lc($b)}keys %{$self->{Modules}}) {
        my $OutFile = $self->_RelPath( $self->{Modules}->{$modulename}, $InstallPrefix);
        $OutFile =~ s{\.([^\.]+)$}{.html};
        $OutFile =~ y[\\][/];

        if( $modulename =~ /^(.*?)::([^:]+)$/ and $seen{$1}) { # $modulename =~ /::/ and
            $ret .= qq[
&nbsp;<span class="blend">$1</span><a href="$OutFile">::$2</a><br>
];
        } else {
            $seen{$1}++ if $1; # wasn't seen, so we sees it now
            $ret .= qq[
&nbsp;<A href="$OutFile">$modulename</a><br>
];
        }
        $seen{$modulename}++; # of course we gots to see the module
    }

    return $ret;
}


=head3 C<Footer>

B<Returns> a footer ( in this case, closing body and html tags ) 

=cut

sub Footer {q[
</body></html>
];
}


=head1 BUGS

C<Pod::Find> version 0.22 is buggy.
It will not find files in C<perl -V:scriptdir>.
I've sent in a patch, but maybe I ought to distribute a copy.

If you run L<Pod::Checker|Pod::Checker> on this document,
you may get a few warnings like:

    *** WARNING: line containing nothing but whitespace

The L<SYNOPSIS|"SYNOPSIS"> generates these, but don't it look pretty
(I think a single code block is better than 3, for a single example).

=head1 AUTHOR

D.H. <podmaster@cpan.org>

=head1 LICENSE

copyright (c) D.H. 2002
All rights reserved.

This program is released under the same terms as perl itself.
If you don't know what that means, visit http://perl.com
or execute C<perl -v> at a commandline (assuming you have perl installed).

=cut


$MasterCSS = <<'MASTERCSS';

/* for the MasterTOC modules list */
.blend {
    color: #FFFFFF;
    text-decoration: underline;
}


/* standard elements */
body {
    background: #FFFFFF;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
    font-size: 70%;
}
	
td {
    font-size: 70%;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
    text-decoration: none;
}

input {
	font-size: 12px;
}

select {
	font-size: 12px;
}

p {
    color: #000000;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
    padding-left: 1em;
}

p.code {
    padding-left: .1em;
}


.likepre {
    font-size: 120%;
    border: 1px groove #006000;
    background: #EEFFCC;
    padding-top: 1em;
    padding-bottom: 1em;
    white-space: pre;
}


blockquote {
    color: #000000;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
}

dl {
    color: #000000;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
}

dt {
    color: #000000;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
    padding-left: 2em;
}

ul {
    color: #000000;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
}

li {
    font-size: 110%;
}


ol {
    color: #000000;
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-weight: normal;
}

h1 { 
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 18px;
    font-weight: bold;
    color: #006000;
/*
    color: #19881D;
*/
}

h2 {
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 13px;
    font-weight: bold;
    color: #006000;
/*
    background-color: #EAE2BB;
*/
    background-color: #D9FFAA;
}

h3 { 
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 12px;
    font-weight: bold;
    color: #006000;
    border-left: 0.2em solid darkGreen;
    padding-left: 0.5em;
}        

h4 { 
    font-family: Verdana, Arial, Helvetica, sans-serif;
    font-size: 11px;
    font-weight: bold;
    color: #006000;
    background: #ffffff;
    border: 1px groove black;
    padding: 2px, 0px, 2px, 1em;
} 	

pre {
    font-size: 120%;
/*    background: #EEFFCC;
    background: #CCFFD9;
*/
    border: 1px groove #006000;
    background: #EEFFCC;
    padding-top: 1em;
    padding-bottom: 1em;
    white-space: pre;
}

hr {
    border: 1px solid #006000;
}

tt {
    font-size: 120%;
}

code {
    font-size: 120%;
    background: #EEFFEE;
    border: 0px solid black;
    padding: 0px, 4px, 0px, 4px;
}

kbd {
    font-size: 120%;
}
   
/* default links */

a:link { 
/*
	color: #B82619;
*/
    color: #00525C;
    text-decoration: underline;
}

a:visited {
/*
    color: #80764F;
*/
    color: #80764F;
    text-decoration: underline;
}

a:hover {
	color: #000000;
    text-decoration: underline;
}

a:active { 
/*
	color: #B82619;
*/
    color: #00525C;
    text-decoration: underline;
    font-weight: bold; 
}


 
/* crap */
td.block {
    font-size: 10pt;
/*
    background: #EAE2BB;
    background: #4EBF51;
    background: #97EB97;
    background: #D3FF8C;
    background: #AED9B1;
    background: #AEFFB1;
    background: #BBEAC8;
    background: #94B819;
*/
    background: #D9FFAA;
    color: #006000;
    border: 1px dotted #006000;
    font-weight: bold;
}   

MASTERCSS


sub _Frame {
    my($self, $toc ) = @_;
    $toc ||= 'podmaster.toc.html';

    my $Initial = $self->{PerlDoc}{perl};
#    my $Initial = catdir $self->{outdir},  $self->_RelPath( $Initial, $InstallPrefix );
       $Initial = $self->_RelPath( $Initial, $InstallPrefix );
       $Initial =~ s{\.([^\.]+)$}{.html};
       $Initial =~ y[\\][/];

    return qq[
<HTML>

<HEAD>
<title>Perl User Guide (according to Pod::Master)</title>
</HEAD>

<FRAMESET cols="320,*">
  <FRAME name="TOC" src="$toc" target="PerlDoc">
  <FRAME name="PerlDoc" src="$Initial">
  <NOFRAMES>
  <H1>Sorry!</H1>
  <H3>This page must be viewed by a browser that is capable of viewing frames.</H3>
  </NOFRAMES>
</FRAMESET>
<FRAMESET>
</FRAMESET>

</HTML>];

}

1; # just in case i screwed up


