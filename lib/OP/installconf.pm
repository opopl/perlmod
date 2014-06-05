
package OP::installconf;
 
use strict;
use warnings;
 
use FindBin qw($Bin $Script);
use Env qw($hm $USER $EMAIL);
use File::Slurp qw( append_file);
use File::Spec::Functions qw(catfile);
use File::Copy qw( copy );
use File::Slurp qw( write_file );
use OP::Script::Simple qw( _say );

our %files;
our $id;
our @ids;
our $mkfile;

sub get_opt;
sub process_id;
sub main;
sub init_vars;
sub generate_mk;

sub init_vars {
    @ids=qw(
		ctags
		directfbrc
		fbtermrc
		gitconfig
		minicpanrc
		pinerc
		screenrc
        zshrc
		ttreerc
		my.cnf
		poddisplaypdf.topics.yaml
    );
}

sub generate_mk {

    $mkfile=catfile($hm,qw( scripts mk installconf.mk ));

    my $text=<<'EOF';

cpandir:=$(hm)/.cpan/CPAN/

cpanconf:=$(cpandir)/MyConfig.pm
scripts:=$(hm)/scripts/installconf.pl

# definitions

EOF

    foreach my $id (@ids) {
        $text .= $id . ':=$(hm)/.' . $id . "\n"; 
    }

    $text.="\n" . '# targets' . "\n\n" ; 

    $text.='all: ' . join(' ',@ids) . "\n\n"; 
    $text.='.PHONY: ' . join(' ',@ids) . "\n\n"; 

    foreach my $id (@ids) {
        $text .= $id . ': ' . '$(' . $id . ')' . "\n" ;
    }
    $text .= "\n" ;

    foreach my $id (@ids) {
        for($id){
            /^cpanconf$/ && do {
                $text.=      '$(cpanconf): $(hm)/config/cpan_config.pm'
	                . "\n" . 'mkdir -p $(cpandir)'
	                . "\n" . 'cp $< $@' 
                    . "\n";
                next;
            };

            $text .= '$(' . $id . '): ' 
                . '$(hm)/config/' . $id . ' $(scripts)' . "\n" ;
            $text .= "\t" . $Script . ' ' . $id . "\n\n";
        };
    }

    write_file($mkfile,$text);

}

sub get_opt { 

	unless (@ARGV) {
	    chdir $Bin;
	    system("make -f $mkfile");
	    exit 0;
	}

    $id=shift @ARGV;
}

sub main {
    init_vars;
    generate_mk;
    get_opt;
    process_id;
}

sub process_id { 

    _say "Processing id: $id";

	$files{$id}=catfile($hm, '.' .  $id);
	
	copy(
	    catfile($hm, qw(config), "$id"),
	    catfile( $files{$id} )
	);
	
	for($id){
	    /^gitconfig$/ && do { 
			my @userinfo;
			push(@userinfo,'[user]');
			push(@userinfo,"\t" . 'name=' . $EMAIL);
			push(@userinfo,"\t" . 'email=' . $EMAIL);
			append_file($files{gitconfig},join("\n",@userinfo) . "\n" );
	
	        next;
	    };
	}

}

1; 
