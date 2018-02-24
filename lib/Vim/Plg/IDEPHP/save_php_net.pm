package Vim::Plg::IDEPHP::save_php_net;

use strict;
use warnings;
use utf8;

use HTML::Work;
use Vim::Plg::IDEPHP::vars qw(
	$php_net_subs
);
use File::Basename qw(basename dirname);
use FindBin qw($Bin $Script);
use File::Spec::Functions qw(catfile);

our $htw=HTML::Work->new();

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={};
		
	my @k=keys %$h;

	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }
}

sub run {
	my $self=shift;

	my @actions = ();

###actions
	push @actions,
		'get_remote_url',
		'find_htm',
		'htm_to_txt',
		;
	my $ref={ 
		'cutoff'  => -1,
		'actions' => \@actions,
		#'topic'   => 'html_mdn',
		'topic'   => 'mysql_refman',
	};

	$self->save_help_topic($ref);

}

sub save_help_exec {
	my $self=shift;
	my @tt=qw( book.exec );

	foreach my $t (@tt) {
		my $url = 'http://php.net/manual/en/'.lc $t.'.php';
	
		my $savedir = $self->{savedir}=catfile(qw(c: saved html php_net exec ));
		my $file    = $t.'.htm';
	
		$htw->url_saveas({ 
				url     => $url,
				file 	=> $file,
				savedir => $savedir,
		});

	}
}

sub save_help_dom {
	my $self=shift;

	my @tt=qw(
		dom.examples

		class.domdocument
		class.domelement
		class.domattr
		class.domnode
		class.domnodelist
		class.domtext
		class.domxpath

		domelement.construct
		domelement.getattribute
		domelement.getattributenode
		domelement.getattributenodens
		domelement.getattributens
		domelement.getelementsbytagname
		domelement.getelementsbytagnamens
		domelement.hasattribute
		domelement.hasattributens
		domelement.removeattribute
		domelement.removeattributenode
		domelement.removeattributens
		domelement.setattribute
		domelement.setattributenode
		domelement.setattributenodens
		domelement.setattributens
		domelement.setidattribute
		domelement.setidattributenode
		domelement.setidattributens
		
		class.domentity
		class.domexception
		class.domcdatasection

		domtext.iswhitespaceinelementcontent
		domtext.splittext

	);
	foreach my $t (@tt) {
		my $url = 'http://php.net/manual/en/'.lc $t.'.php';
	
		my $savedir = $self->{savedir} = catfile(qw(c: saved html php_net dom ));
		my $file    = $t.'.htm';
	
		$htw->url_saveas({ 
			url     => $url,
			file 	=> $file,
			savedir => $savedir,
		});

	}
}


sub save_local_htm {
	my ($self,$ref)=@_;

	my $topic  = $ref->{topic} || '';
	my $cutoff = $ref->{cutoff} || $self->{cutoff} || 0;

	my $subs  = $php_net_subs->{$topic} || [];

	my $i=0;

	my $savedir=$self->{savedir};
	foreach my $sub (@$subs) {
		if ($cutoff && ($i==$cutoff)) { last }
	
		(my $fsub = $sub ) =~ s/_/-/g; 
		my $url  = $self->url_php_net_remote($fsub);

		my $file = $sub . '.htm';
		$htw->url_saveas({ 
				url     => $url,
				file 	=> $file,
				savedir => $savedir,
		});

		$i++;
	}
	
}

sub savedir_for_topic {
	my $self=shift;
	my $topic=shift;

	catfile(qw(c: saved html php_net ),$topic);
}

###html_mdn
###mdn
sub save_help_html_mdn {
	my $self=shift;

	my $dir = 'C:/web/MDN_HTML_elements_reference/developer.mozilla.org/en-US/docs/Web/HTML/Element';
	my @htm;
	File::Find::find({ 
			wanted => sub { 
					if (/^(\w+)(\.htm|\.html)$/) {
						my $elem=$1;
						push @htm, { 
							elem     => $elem,
							basename => $_,
							fullpath => $File::Find::name,
						};
					}
			} 
	},$dir
	);

	my $i=0;
	foreach my $htm (@htm) {
		#last if $i==1;

		my $elem=$htm->{elem} || '';

		my $fpath = $htm->{fullpath} || '';

		my $sec=$elem;

		my $vhdir = catfile($ENV{VRT},qw(plg idephp help html mdn));
		mkpath($vhdir) unless -d $vhdir;

		my $vh    = catfile($vhdir,$sec . '.txt');
	
		my $tmpdir = catfile(qw(C: tmp html mdn));
		mkpath($tmpdir) unless -d $tmpdir;

		$self->log("Saving to vh: ",$vh);
		$htw->save_to_vh({
					insert_vh => [
						' '                             ,
						' *mdn_'.$sec.'*'               ,
						' *<'.$sec.'>*'                 ,
						'vim:ft=help:foldmethod=indent' ,
						' '                             ,
					],
					in_html => $fpath,
					out_vh  => $vh,
					tag     => $sec,
					tmphtml => catfile($tmpdir,$sec.'.htm'),
					xpath_rm => [
						'//link',
						'//nav',
						'//meta',
						'//script',
						'//footer',
						'//header',
						'//ul[@id="nav-access"]',
						'//div[@id="languages-menu-submenu"]',
						'//*[@id="languages-menu"]',
						'//div[@id="toc"]',
						'//div[@id="wiki-document-head"]//div[@class="document-actions"]',
						#'//div[@class="page-tools"]',
						#'//div[@class="headsup"]',
						#'//div[@id="goto"]',
						#'//div[@id="breadcrumbs"]',
						],
					actions => [qw(
						replace_a
					)],
				});

		$i++;
	}

}


###mysql
sub save_help_mysql {
	my $self=shift;

	my $dir = 'C:/doc/programming/mysql/refman-5.7-en.html-chapter/';
	my (@htm,@elems);
	File::Find::find({ 
			wanted => sub { 
					if (/^(\w+)(\.htm|\.html)$/) {
						my $elem=$1;
						push @elems,$elem;
						push @htm, { 
							elem     => $elem,
							basename => $_,
							fullpath => $File::Find::name,
						};
					}
			} 
	},$dir
	);

	my $i=0;
	my $elem;
	my @use;
	push @use,qw(tutorial);
	foreach my $htm (@htm) {
		#last if $i==1;
		$elem=$htm->{elem} || '';

		#next unless grep { /^$elem$/ ? 1 : 0 } @use;


		my $fpath = $htm->{fullpath} || '';

		my $sec=$elem;

		my $vhdir = catfile($ENV{VRT},qw(plg idephp help mysql refman));
		mkpath($vhdir) unless -d $vhdir;

		my $vh    = catfile($vhdir,$sec . '.txt');
	
		my $tmpdir = catfile(qw(C: tmp html mysql_refman));
		mkpath($tmpdir) unless -d $tmpdir;

		$self->log("Saving to vh: ",$vh);
		$htw->save_to_vh({
					insert_vh => [
						' '                             ,
						' 	*mysql_refman_'.$sec.'*'    ,
						'vim:ft=help:foldmethod=indent' ,
						' '                             ,
					],
					in_html => $fpath,
					out_vh  => $vh,
					tag     => $sec,
					tmphtml => catfile($tmpdir,$sec.'.htm'),
					xpath_cb => [
						{ xpath => '', cb => sub {} },
					],
					xpath_rm => [
						'//link',
						'//nav',
						'//meta',
						'//script',
						'//footer',
						'//header',
						'//ul[@id="nav-access"]',
						'//div[@id="languages-menu-submenu"]',
						'//*[@id="languages-menu"]',
						'//div[@id="toc"]',
						'//div[@id="wiki-document-head"]//div[@class="document-actions"]',
						'//div[@class="navheader"]',
						'//div[@class="navfooter"]',
						#'//div[@class="page-tools"]',
						#'//div[@class="headsup"]',
						#'//div[@id="goto"]',
						#'//div[@id="breadcrumbs"]',
						],
					actions => [qw(
						replace_a
					)],
				});

		$i++;
	}

}

sub save_help_pcre {
	my $self=shift;

	my @tt=qw(
		ref.pcre
	);
	foreach my $t (@tt) {
		my $url = 'http://php.net/manual/en/'.lc $t.'.php';
	
		my $savedir = $self->{savedir}=catfile(qw(c: saved html php_net pcre ));
		my $file    = $t.'.htm';
	
		$htw->url_saveas({ 
			url     => $url,
			file 	=> $file,
			savedir => $savedir,
		});

	}
}


sub save_help_mysqli {
	my $self=shift;

	my $topic = 'mysqli';
	my $tt    = $self->read_idat({ 'idat' => 'php_files_'.$topic });
	$self->save_files_to_htm($topic,$tt);

}

###pdo
sub save_help_topic {
	my $self = shift;
	my $ref  = shift;

	my $actions = $ref->{actions} || [];

	my $topic = $ref->{topic} || '';

	my @htm;
	my $savedir = $self->{savedir} = catfile(qw(c: saved html php_net),$topic);

	for($topic){
		/^html_mdn$/ && do {
			$self->save_help_html_mdn;
			return;
			next;
		};
		/^mysql_refman$/ && do {
			$self->save_help_mysql;
			return;
			next;
		};
		/^datetime$/ && do {
			next; 

			my $bf=catfile($savedir,'ref.datetime.htm');

			$htw->load_html_from_file({file=>$bf});

			my @href = $htw->list_href({ 
				sub => sub { 
					/\.php$/ && !/\// && 
						!/index.php/ &&
						!/funcref/ 
					? 1 : 0;
				}
			});

			my @lines = map { s/\.php$//g; $_ } @href;
			my $idat  = catfile($Bin,'data','php_files_'.$topic.'.i.dat');

			write_file($idat,join("\n",@lines) . "\n");

			next; 
			
		};
		#last;
	}
	#return;


	foreach my $act (@$actions) {
		local $_=$act;
###pdo_get_url
		/^get_remote_url$/ && do{
				my $tt    = $self->read_idat({ 'idat' => 'php_files_'.$topic });
				$self->save_files_to_htm($topic,$tt);
			
		};
###pdo_find_htm
		/^find_htm$/ && do {
			$self->log("STAGE: $_");

				File::Find::find({ 
					wanted => sub { 
						if (/\.htm$/) {
							push @htm, { 
								basename => $_, 
								fullpath => $File::Find::name,
							};
						}
					} 
				},$savedir	
				);
		};
###pdo_to_txt
		/^htm_to_txt$/ && do {

			$self->log("STAGE: $_");

			my $cutoff = $ref->{cutoff} || 1;
			my $i=0;

			foreach my $htm (@htm) {
				my $bn    = $htm->{basename};
				my $fpath = $htm->{fullpath};

				my $dirname = dirname($fpath);

				my $sec=$bn;
				$sec =~ s/\.(\w*)$//g;

				if ($cutoff && ($i==$cutoff)) { last }

				$self->log("Processing: $bn");

				$sec=~s/^function\.//g;
				$sec=~s/-/_/g;

				for($topic){
					/^control_structures/ && do {
						$sec=~s/^control_structures\.//g;
						next;
					};
				}

			
				my $vhdir = catfile($ENV{VRT},qw(plg idephp help php),$topic);
				my $vh    = catfile($vhdir,$sec . '.txt');
		
				$i++;

				my $tmpdir = catfile($vhdir,'tmp');
				#if (-d $tmpdir) {rmtree($tmpdir);}
				mkpath($tmpdir) unless -d $tmpdir;

				$self->log("Saving to vh: ",$vh);
				$htw->save_to_vh({
					in_html => $fpath,
					out_vh  => $vh,
					tag     => $sec,
					tmphtml => catfile($tmpdir,$sec.'.htm'),
					xpath_rm => [
						'//link',
						'//nav',
						'//footer',
						'//div[@class="page-tools"]',
						'//div[@class="headsup"]',
						'//div[@id="goto"]',
						'//div[@id="breadcrumbs"]',
						],
					actions => [qw(
						replace_a
					)],
				});
			}
		}
	}

}


sub save_files_to_htm {
	my $self = shift;

	my $topic= shift;
	my $tt   = shift || [];

	foreach my $t (@$tt) {
		my $url = 'http://php.net/manual/en/'.lc($t).'.php';
	
		my $savedir = $self->{savedir}=catfile(qw(c: saved html php_net),$topic);
		my $file    = $t.'.htm';
		print $url . "\n";
	
		$htw->url_saveas({ 
				url     => $url,
				file 	=> $file,
				savedir => $savedir,
		});
	}

}


sub run_topics {
	my $self = shift;
	my $ref  = shift;

	my $do   = $ref->{do} || [qw(save_htm save_txt)];

	my $topics=$self->{topics} || [];
	for my $topic (@$topics){	
		my $savedir = $self->{savedir} = $self->savedir_for_topic($topic);
		make_path($savedir) unless -d $savedir;

		for(@$do){
			/^save_htm$/ && do {
					$self->save_local_htm({ 
						'topic'  => $topic,
						'cutoff' => -1,
					});
			};
			/^save_txt$/ && do {
					$self->save_to_txt({ 
						topic  => $topic,
						cutoff => -1,
					});
			};
		}

	}

}


sub save_to_txt  {
	my ($self,$ref)=@_;

	my $topic  = $ref->{topic} || '';
	my $cutoff = $ref->{cutoff} || $self->{cutoff} || 0;

	my $subs        = $php_net_subs->{$topic} || [];
	my $savedir_htm = $self->savedir_for_topic($topic);

	my $savedir_xpath = catfile($savedir_htm,'..','xpath');
	mkpath($savedir_xpath) unless -d $savedir_xpath;
	
	my $i=0;
	foreach my $sub (@$subs) {
		$self->log("Processing: $sub");

		(my $fsub = $sub ) =~ s/_/-/g; 

		if ($cutoff && ($i==$cutoff)) { last }
	
		my $fpath  = $self->url_php_net_local($sub,$topic);
	
		$htw->load_html_from_file({ file => $fpath });
		$htw->dom_replace_a;

		my $dom=$htw->{dom};
		$self->{dom}=$dom;

		my @ascii_refnamediv;
		{
			my $xpath		='//div [@class="refnamediv"]';
			my $nodelist 	= $dom->findnodes($xpath);
			my @nodes    	= $nodelist->get_nodelist;

			foreach my $node (@nodes) {
				my $html   = $node->toString;
				my $parent = $node->parentNode;
	
				$htw->node2text($dom,$node);
	
				my @br=$parent->findnodes('./br');
				foreach my $a (@br) {
					push @ascii_refnamediv,$a->textContent;
				}
			}
		}
		
		my $xpath='//div [@id="function.'.$fsub.'" and @class="refentry"]';
	
		my $nodelist = $dom->findnodes($xpath);
		my @nodes    = $nodelist->get_nodelist;

		my @nodes_code=();
		my @ascii_code=();

		foreach my $n (@nodes) {
			my ($ascii,$nodes) = $htw->node_getascii({
				xpath => './/code',
				node  => $n,
			});
			push @ascii_code,@$ascii;
			push @nodes_code,@$nodes;
			
		}
###save_txt_code
		{
			my $f=catfile($savedir_xpath,$sub . '_code.txt');
			open(F,">$f") || die $!;
				
			foreach my $c (@ascii_code) {
				print F $c . "\n";
			}
			close(F);
		}

###save_refnamediv
		{
			my $f=catfile($savedir_xpath,$sub . '_refnamediv.txt');
			open(F,">$f") || die $!;
				
			foreach my $c (@ascii_refnamediv) {
				print F $c . "\n";
			}
			close(F);
		}

###save_htm
		{
			my $f=catfile($savedir_xpath,$sub . '.htm');
			open(F,">$f") || die $!;
				
			foreach my $n (@nodes) {
				$htw->node_pretty($n);
				print F $n->toString . "\n";
			}
			close(F);
		}

###save_htm_code
		{
			my $f=catfile($savedir_xpath,$sub . '_code.htm');
			open(F,">$f") || die $!;
				
			foreach my $n (@nodes_code) {
				print F $n->toString . "\n";
			}
			close(F);
		}
###save_vimhelp
		{
			my $vhdir = catfile($ENV{VRT},qw(plg idephp help php),$topic);
			my $vh    = catfile($vhdir,$sub . '.txt');
			my $do;

			$do = (!-e $vh) ? 1 : 0;
			$do = 1;

			if ($do) {
				my $f     = catfile($savedir_xpath,$sub . '.htm');

				$htw->save_to_vh({ 
					in_html => $f,
					out_vh  => $vh,
					tag     => $sub,
				});
			}
			
		}

		$i++;
	}

}

sub url_php_net_remote {
	my $self=shift;
	my $fsub=shift;

	my $url  = 'http://php.net/manual/en/function.'.$fsub.'.php';
	return $url;
}

sub url_php_net_local {
	my $self=shift;

	my ($sub,$topic)=@_;

	my $savedir = $self->savedir_for_topic($topic);
	my $fpath   = catfile($savedir,$sub . '.htm');

	return $fpath;
}

1;
 

