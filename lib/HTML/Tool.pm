
package HTML::Tool;

use strict;
use warnings;
use utf8;

use Data::Dumper qw(Dumper);

use base qw(
	HTML::Tool::Tabs
);

use JSON::XS;

use HTML::Work;
use HTML::Work::PHP qw(
	$php_net_subs
);
use File::Find qw(find);

use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use XML::LibXML;
use XML::LibXML::Simple;

use HTML::Strip;
use HTML::TreeBuilder;
use HTML::FormatText;

use File::Spec::Functions qw(catfile);
use File::Path qw(make_path remove_tree mkpath rmtree);
use File::Temp qw(tempfile tempdir);
use URI;

use File::Slurp qw(
  append_file
  edit_file
  edit_file_lines
  read_file
  write_file
  prepend_file
);

use Tk;
use Tk::widgets qw(
	DialogBox
	DirTree
	HistEntry
	LabEntry
	NoteBook
	Tree
	HyperText
	ClickText
);

our $htw=HTML::Work->new();

sub log {
	my $self=shift;

	$self->tk_console_write(@_);
	
}

sub config_get_xml {
	my $self  = shift;
	my $xpath = shift;

	my $dom=$self->{dom_config};
	my @nodes=$dom->findnodes($xpath);

	my @values;
	foreach my $n (@nodes) {
		push @values,$n->toString;
	}
	my $xml=join("\n",@values);

	return $xml;
}

sub config_dump {
	my $self=shift;
	my $xpath=shift;

	my $xml=$self->config_get_xml($xpath);

	print Dumper($xml);

}

sub config_get_hash {
	my $self=shift;

	my $xpath=shift;
	my %opts=@_;

	my $hash = {};
	my $order = [];

	my $dom   = $self->{dom_config};
	my @nodes = $dom->findnodes($xpath);

	my $xml = $self->config_get_xml($xpath);

	my $cb_key=$opts{cb_key} || undef;
	foreach my $n (@nodes) {
		my @sn=$n->findnodes('./*');
		foreach my $sn (@sn) {
			my $value = $sn->textContent;
			my $key   = $sn->nodeName;

			push @$order,$key;

			if ($cb_key && ref $cb_key eq 'CODE') {
				$key = $cb_key->($key);
			}
			
			$hash->{$key}=$value;
		}

	}

	return ($hash,$order);
}

sub config_get_nodes {
	my $self=shift;

	my $xpath=shift;

	my $dom   = $self->{dom_config};
	my @nodes = $dom->findnodes($xpath);

	wantarray ? @nodes : \@nodes;

}

sub config_get_text_split {
	my $self=shift;

	my $xpath=shift;
	my $delim=shift || ",";

	my $dom=$self->{dom_config};
	my @nodes=$dom->findnodes($xpath);

	my @values;
	foreach my $n (@nodes) {
		push @values,split($delim,$n->textContent);
	}
	wantarray ? @values : \@values;

}

sub config_get_text {
	my $self=shift;

	my $xpath=shift;

	my $dom=$self->{dom_config};
	my @nodes=$dom->findnodes($xpath);

	my @values;
	foreach my $n (@nodes) {
		push @values,$n->textContent;
		#push @values,$n->toString;
	}
	wantarray ? @values : \@values;

}

sub init_config {
	my $self=shift;

	my $bname = basename($Script);
	my $root  = $bname;

	$root=~s/\.(\w)$//g;

	my $file_xml = catfile($Bin,'config.xml');


	unless(-e $file_xml){ return; }

	my @out;
	open(F,"<$file_xml") || die $!;
	while(<F>){
		chomp;
		my $line=$_;
		push @out,$line;
	}
	close(F);
	my $xml=join("\n",@out);

	
    my $doc = XML::LibXML->load_xml(string => $xml);

	my @nodes   = $doc->findnodes('/root/php_net_pl/*');
	my @l;
	foreach my $n (@nodes) {
		push @l,$n->toString;
	}
	my $xml_conf = join("\n",@l);

    my $dom_conf = XML::LibXML->load_xml(string => $xml_conf);

	my $xs       = XML::LibXML::Simple->new;

	my $data = $xs->XMLin($xml_conf);

	$self->{config}     = $data;
	$self->{dom_config} = $dom_conf;

	return $self;		

}





sub read_idat {
	my $self = shift;
	my $ref=shift;
	my $idat = $ref->{'idat'};

	my $f=catfile($Bin,qw(data),$idat .'.i.dat');
	unless (-e $f) { $self->log('File not readable: '.$f); }
	my @tt=map { chomp; /^\s*#/ ? () : $_ } read_file $f;
	
	wantarray ? @tt : \@tt ;
}


sub tk_init_mw {
	my $self=shift;	

	my $mw = MainWindow->new;
	$mw->geometry("500x800");

	$self->{tk_mw}=$mw;

	push @{$self->{tk_objects}},'mw';

}

sub tk_init_tab {
	my $self     = shift;

	my $tab_name = shift;

	for($tab_name){
		my $sub = 'tk_init_'.$tab_name;
		if ($self->can($sub)) {
			$self->$sub;
		}
		last;
	}
}

###tab_test
sub tk_init_tab_test {
	my $self=shift;

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_test};

	my $htw=$self->{htw};

	my $fr_left= $tab->Frame(
		-height => '50',
		-width  => 30,
	)->pack(
		-side   => 'top',
		-expand => 0,
	);

	my $dt=$fr_left->DirTree(
		-directory => catfile(qw(c: saved)),
	)->pack(
		-side   => 'top',
		-fill   => 'both',
		-expand => 1,
	);
}


###tab_options
sub tk_init_tab_options {
	my $self=shift;

	my $mw=$self->{tk_mw};

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_options};

	my ($paths,$path_order)=$self->config_get_hash('/tk/tab_options/paths');

	my $fr=$tab->Frame->pack(-side => 'top',-fill => 'x');

	$self->{paths}=$paths;

	foreach my $pathname (@$path_order) {
		$self->log($pathname);

		my $val = $paths->{$pathname} || '';
		next unless $val;

		$self->log($val);

		#$self->log(Dumper($val));

		my $lb = $fr->Label(
			-text => $pathname,
		)->pack(qw/-side top/);

		my $e= $fr->Entry(
		     -textvariable => \$val,
		     -width        => 20,
		)->pack(qw/-side top -fill x -expand 1/)
	}
 
}

sub env { 
	my $self=shift;

	my $var = shift;

	return $ENV{$var} || '';
}

sub path {
	my $self=shift;

	my $pathname = shift;

	my $paths = $self->{paths};
	my $val   = $paths->{$pathname} || '';

	$val =~ s/\$(\w)/$self->env($1)/g;

	return $val;

}

###tab_xpath
sub tk_init_tab_xpath {
	my $self=shift;

	my $mw=$self->{tk_mw};

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_xpath};

	my $htw=$self->{htw};

	my $urls;
	$urls=$self->config_get_text('/tk/tab_xpath/urls/url');
	
	my $urlref;
	${$urlref}=$urls->[0] || '';

	my $fileref;
	my $files;
	$files=$self->config_get_text('/tk/tab_xpath/localfiles/file');
	${$fileref}=$files->[0] || '';
	
	my $xpaths;
	$xpaths=$self->config_get_text('/tk/tab_xpath/xpaths/xpath');
	my $xpath  = $xpaths->[0] || '';

	my $text_output;
	my $entry_url;

	my $method_load_html;
	my $reload;

	my $entry_local_html;


	my ($headings,$entry_headings);

###sub_update_headings
	my $sub_update_headings = sub {
		$self->log('start: sub_update_headings');

		$headings=[ $htw->list_heads ];

		my $size=$entry_headings->Subwidget('slistbox')->size;
		$entry_headings->delete(0,'end');

		for(@$headings){
			$entry_headings->insert('end',$_);
		}
	};


###sub_load_html
	my $sub_load_html=sub {
		$self->log('start: sub_load_html',
					'	$method_load_html = ' . '"' . $method_load_html .'"',
					'	$reload           = ' . $reload,
					'	${$urlref}        = ' . ${$urlref},
					'	${$fileref}       = ' . ${$fileref},
				);

		for($method_load_html){
			/^use_url$/ && do {
				$htw->load_html_from_url({ 
					url    => ${$urlref},
					reload => $reload,
				});
				next;
			};

			/^use_file$/ && do {
				$htw->load_html_from_file({ 
					file   => ${$fileref},
					reload => $reload,
				});
				next;

			};
			last;
		}

		$sub_update_headings->();

		$self->log('end: sub_load_html');
	};

###sub_reload_url
	my $sub_reload_url = sub {
		$entry_url->invoke;

		$method_load_html='use_url';
		$reload=1;

		$sub_load_html->();
		
	};

###sub_reload_local_file
	my $sub_reload_local_file = sub {
		$method_load_html='use_file';
		$reload=1;

		$sub_load_html->();
	};

###sub_run_xpath
	my $sub_run_xpath = sub {
		$reload=0;
		$sub_load_html->();

		my $c = $htw->htmlstr({xpath => $xpath});
		$text_output->set_content({ 
			items => [$c] 
		});

	};
###sub_print_headings
	my $sub_print_headings=sub{
		$reload=0;
		$sub_load_html->();

		my @h = $htw->list_heads;
		$text_output->set_content(
			items => [join("\n",@h)]
		);
	};

###sub_select_tag_script
	my $sub_select_tag_script=sub{
		$reload=0;
		$sub_load_html->();

		my $c = $htw->htmlstr({xpath => '//script'});
		$text_output->set_content($c);

	};

###sub_select_tag_script_src
	my $sub_select_tag_script_src=sub{
		$reload=0;
		$sub_load_html->();

		#my $nodes = $htw->nodes({xpath => '//script]'});
		#my $c;
		#$text_output->set_content($c);

		my @src=();
		my @attr = $htw->list_attr({
			xpath => '//script[@src]',
			attr  => 'src',
		});
		my $c=join("\n",@attr);
		$text_output->set_content($c);

	};

###sub_select_tag_link
	my $sub_select_tag_link=sub{
		$reload=0;
		$sub_load_html->();

		my $c = $htw->htmlstr({xpath => '//link'});
		$text_output->set_content($c);

	};

###sub_select_tag_link_css
	my $sub_select_tag_link_css=sub{
		$reload=0;
		$sub_load_html->();

		my $c = $htw->htmlstr({
				xpath => ' //link[@type="text/css"] '
			});
		$text_output->set_content($c);

	};

###sub_select_tag_link_css_src
	my $sub_select_tag_link_css_src=sub{
		$reload=0;
		$sub_load_html->();

		my @attr = $htw->list_attr({
				xpath => '//link[@type="text/css"]',
				attr => 'href'
			});
		my $c=join("\n",@attr);
		$text_output->set_content($c);

	};


	my $sub_print_links=sub{
		$reload=0;
		$sub_load_html->();

		my @a = map { defined $_ ? $_ : () } $htw->list_href;
		$text_output->set_content({ 
			items => \@a,
		});
	};
	my $sub_print_forms=sub{
		$reload=0;
		$sub_load_html->();

		#my @forms = map { defined $_ ? $_ : () } $htw->list_forms;
		#$text_output->set_content(join("\n",@forms));
	};

###sub_show_html
	my $sub_show_html = sub {
		$reload=0;
		$sub_load_html->();

		my $db = $self->{tk_mw}->DialogBox(
			-title          => 'HTML View',
			-buttons        => ['Close'],
			-default_button => 'Close',
		);

     	my $ht = $db->Scrolled('HyperText',
	        -scrollbars => 'ose',
	        -wrap       => 'word',
      	)->pack (-fill => 'both', -expand => 1);
		my $html = $htw->htmlstr;
		$ht->loadString($html);

		$db->Show();

	};

###sub_goto_heading
	my $sub_goto_heading = sub {
		$reload=0;
		$sub_load_html->();
	};

###sub_url_to_vh
	my $sub_url_to_vh=sub{
		$reload=0;
		$sub_load_html->();

###dialogbox_Convert_VimHelp
		my $db = $self->{tk_mw}->DialogBox(
			-title          => 'HTML => VimHelp Conversion',
			-buttons        => ['Ok', 'Cancel'],
			-default_button => 'Ok',
		);
		my $url='';

		my $out_vh;
		my $le_out_vh = $db->LabEntry(
		     -label        => 'VH File:',
		     -labelPack    => [qw/-side left -anchor w/],
		     -labelFont    => '9x15bold',
			 #-relief       => 'flat',
			 #-state        => 'disabled',
		     -textvariable => \$out_vh,
		     -width        => 35,
		);
		$le_out_vh->pack(qw/-fill x -expand 1/);

		my $lb_actions = $db->Label(-text=>'actions:')->pack(-side => 'top');

		my $text_actions = $db->Scrolled(
			'Text',
			-height => 5,
			-width  => 80,
		)->pack(qw/-fill x -side top/);
		my @actions=$self->config_get_text_split('/tk/url_to_vh/actions');
		$text_actions->Contents(join("\n",@actions));

		my $lb_xpath_rm = $db->Label(-text=>'xpath_rm')->pack(-side => 'top');

		my $text_xpath_rm = $db->Scrolled(
			'Text',
			-height => 10,
			-width  => 80,
		)->pack(qw/-fill x -side top/);

		my @xpath_rm=$self->config_get_text('/tk/url_to_vh/xpath_rm/xpath');
		$text_xpath_rm->Contents(join("\n",@xpath_rm));
	
		my $ans=$db->Show();
	
		if ($ans eq "Ok") {
		   # $htw->load_html_from_url({ 
				#url    => ${$urlref},
				#reload => 0,
			#});
			my $in_html_text = $htw->htmlstr;

			my $tag ='';
			my $vhref={
				# input HTML text
				in_html_text => $in_html_text,
				# output VimHelp file
				out_vh  => $out_vh,
				# head Vim tag (to be enclosed as *TAG* at the top of the outcome VimHelp file )
				tag 	=> $tag,
				# possible additional actions, may include
				# 	replace_a - replace all links with text
				actions => \@actions || [],
				# xpath to select elements to be removed
				xpath_rm => \@xpath_rm || [],
				# xpath callbacks
				xpath_cb => [],
			};
				
				$htw->save_to_vh($vhref);
		}

	};

###tab_xpath_frame_input
###frame_input
	my $frame_input=$tab->Frame->pack(-side => 'top',-fill => 'x');

###lb_url
	my $lb_url = $frame_input->Label(-text => 'URL:')->pack('-side' =>'top',-padx => '50');
	$entry_url = $frame_input->HistEntry(
		-textvariable => $urlref,
		-command      => sub {
			push @$urls,${$urlref};
		},
	);
	foreach my $url (@$urls) {
		$entry_url->addhistory($url);
	}
	my ($po)=$self->config_get_hash(
		'/tk/tab_xpath/entry_url/pack',
		cb_key => sub { my $k=shift; return '-'.$k },
	);
	
###entry_url
	$entry_url->pack(%$po);

	$po = {
		-side   => 'top',
		-fill   => 'x',
		-expand => 1,
	};

	my $lb_local_html=$frame_input->Label(
			-text => 'Local File:'
		)->pack( 
			'-side' => 'top',
			-padx   => '50',
		);
	my $frame_local_file=$frame_input->Frame->pack(
		-side   => 'top',
		-expand => 1,
		-fill   => 'x',
	);

###btn_loadfile

	my $btn_loadfile=$frame_local_file->Button(
		-text => 'Load File',
		-command => sub {
			 my $types = [];

			 my $nodes_db = $self->config_get_nodes('/tk/tab_xpath/dialog_loadfile');
			 my $nodes_ft = $self->config_get_nodes('/tk/tab_xpath/dialog_loadfile/filetypes/ft');

			 foreach my $node (@$nodes_ft) {
				 push @$types,[ 
					 $node->getAttribute('description'),
					 $node->getAttribute('extensions'),
				 ];
			 }

			 my $initdir  = catfile(qw(c: saved html ));
 			 my $filename = $mw->getOpenFile(
				 -filetypes  => $types,
				 -initialdir => $initdir,
			 );

 			 if ($filename ne "") {
				 ${$fileref}=$filename;
				 my $e=$entry_local_html;
				 $e->historyAdd($filename);
				 my $s=$e->get;
				 $e->delete(0,length($s));
				 $e->insert(0,$filename);
			 }
			 $reload=1;
			 $sub_load_html->();
		},
	)->pack(
		-side => 'left', 
		#-fill => 'x'
	);
###entry_local_html
	
	$entry_local_html = $frame_local_file->HistEntry(
		-textvariable => $fileref,
		-command      => sub {
			push @$files,${$fileref};
		},
	);
	foreach my $file (@$files) {
		$entry_local_html->addhistory($file);
	}
	$entry_local_html->pack(
		-side     => 'left',
		'-fill'   => 'x',
		'-expand' => 1
	);

###rb_use_url
###fr_rb
	my $fr_rb=$frame_input->Frame()->pack(-side => 'top', -fill => 'x');

	my $rb_use_url  = $fr_rb
		->Radiobutton(
			-command  => sub { },
			-text     => 'Use URL',
			-value    => 'use_url',
			-variable => \$method_load_html,
		)
		->pack(-side => 'left', -fill => 'x');
	#$rb_use_url->bind('<ButtonPress>' => [sub { $rb_use_url->deselect }, ]);

	my $rb_use_file  = $fr_rb
		->Radiobutton(
			-command  => sub {},
			-text     => 'Use local file',
			-value    => 'use_file',
			-variable => \$method_load_html,
		)
		->pack(-side => 'left', -fill => 'x');
		$rb_use_file->select;
   # my $chb  = $fr_rb
		#->Checkbutton(
			#-command => sub {},
			#-text => 'Use local file',
			#-indicatoron => 1,
		#)
		#->pack(-side => 'left', -fill => 'x');
		#
	my $lb_xpath=$frame_input
		->Label(-text => 'XPATH:')
		->pack('-side'=>'top',-padx => '50');

	my $entry_xpath = $frame_input->HistEntry(
		-textvariable => \$xpath,
		-command      => sub {
			push @$xpaths,$xpath;
			$sub_run_xpath->();
		},
	);
###entry_xpath
	$entry_xpath->pack(-side => 'top','-fill' => 'x');

	my $frame_control=$tab->Frame->pack(-side => 'top',-fill => 'x');

###fr_control
	my $btn_reload_url=$frame_control->Button(
		-text    => 'Reload URL',
		-command => $sub_reload_url,
	)->pack(-side => 'left');

###btn_reload_local_file
	my $btn_reload_local_file=$frame_control->Button(
		-text    => 'Reload local file',
		-command => $sub_reload_local_file,
	)->pack(-side => 'left');

	my $btn_run_xpath=$frame_control->Button(
		-text    => 'Run XPATH',
		-command => $sub_run_xpath,
	)->pack(-side => 'left');

###btn_headings
	my $btn_headings=$frame_control->Button(
		-text    => 'Headings',
		-command => $sub_print_headings,
	)->pack(-side => 'left');

###btn_links
	my $btn_links=$frame_control->Button(
		-text    => 'Links',
		-command => $sub_print_links,
	)->pack(-side => 'left');

###btn_forms
	my $btn_forms=$frame_control->Button(
		-text    => 'Forms',
		-command => $sub_print_forms,
	)->pack(-side => 'left');

###btn_to_vh
	my $btn_to_vh=$frame_control->Button(
		-text    => '=> VimHelp',
		-command => $sub_url_to_vh,
	)->pack(-side => 'left');

###btn_goto_heading


###frame_control_2
	my $frame_control_2=$tab->Frame->pack(-side => 'top',-fill => 'x');

	my $btn_goto_heading=$frame_control_2->Button(
		-text    => 'Goto heading: ',
		-command => $sub_goto_heading,
	)->pack(
		-side  => 'left',
		-ipadx => 30,
	);

	my $heading;
	$entry_headings = $frame_control_2->BrowseEntry(
		-label=> '', 
		-variable=> \$heading)->pack(-side => 'left');
	#my $lb = $entry_headings->Subwidget('slistbox');

###btn_show_html
   # my $btn_show_html=$frame_control->Button(
		#-text    => 'Show HTML',
		#-command => $sub_show_html,
	#)->pack(-side => 'left');
	#
###frame_tags
	my $frame_tags=$tab->Frame->pack(-side => 'top',-fill => 'x');

###btn_tag_script
	my $btn_tag_script=$frame_tags->Button(
		-text    => '<script>',
		-command => $sub_select_tag_script,
	)->pack(-side => 'left');

###btn_tag_script_src
	my $btn_tag_script_src=$frame_tags->Button(
		-text    => '<script src="...">',
		-command => $sub_select_tag_script_src,
	)->pack(-side => 'left');

	my $btn_tag_link=$frame_tags->Button(
		-text    => '<link>',
		-command => $sub_select_tag_link,
	)->pack(-side => 'left');

	my $btn_tag_link_css=$frame_tags->Button(
		-text    => '<link ...> (CSS)',
		-command => $sub_select_tag_link_css,
	)->pack(-side => 'left');

	my $btn_tag_link_css_src=$frame_tags->Button(
		-text    => '<link ...> (CSS, src)',
		-command => $sub_select_tag_link_css_src,
	)->pack(-side => 'left');

###frame_output
	my $frame_output=$tab->Frame->pack(-side => 'top',-fill => 'x');
	my $lb_output=$frame_output->Label(-text => 'Output')->pack(-side =>'top',-fill => 'x');

	$text_output=$frame_output->Scrolled(
		'ClickText',
		-height          => 50,
		-width           => 80,
		-exportselection => 1,
	)->pack(-side => 'top',-fill => 'x');


	push @{$self->{tk_objects}},'tk_tab_xpath';
}

sub tk_init_tab_links {
	my $self=shift;

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_links};

	my $links = $tab->Text(
		-exportselection => 1,
		-height          => 50,
		-width           => 80,
	);
	$links->pack;

	$self->{tk_text_links}=$links;

	push @{$self->{tk_objects}},'tk_text_links';
}

sub tk_init_tab_url {
	my $self=shift;
	
	my $htw=$self->{htw} || undef;

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_url};


	my $fr1=$tab->Frame()->pack(-side => 'top',-fill => 'x');

	$fr1->Label(
		-text => 'List of URLs',
	)->pack(-side => 'top');

	my $urls = $fr1->Text(
		-exportselection => 1,
		-height          => 10,
		-width           => 80,
	);
	$urls->pack(-side => 'top');

	my $fr2=$tab->Frame()->pack(-side => 'top',-fill => 'x');

	my $sub_get_links;
	my $text_links;
	$sub_get_links = sub {
		my $c    = $urls->Contents;
		my @urls = split("\n",$c);
		
		my @links;
		foreach my $url (@urls) {
			$htw->load_html_from_url({ url => $url });
			my @href=$htw->list_href;
			push @links,@href;
		}
		for(@links){$text_links->insert('end',$_."\n");}
	};
	my $bts={
		'GetLinks' => $fr2->Button(
			-text    => 'Get Links',
			-command => $sub_get_links,
		)->pack(-side => 'left'),
	};

	my $fr3=$tab->Frame()->pack(-side => 'top',-fill => 'x');

	$fr3->Label(
		-text => 'List of Links',
	)->pack(-side => 'top');

	$text_links = $fr3->Text(
		-exportselection => 1,
		-height          => 10,
		-width           => 80,
	)->pack(-side => 'top');



	$self->{tk_text_urls}=$urls;
	my @urls=@{$self->{config}->{tk}->{text_urls}->{url}||[]};
	for(@urls){
		$urls->insert('end',$_."\n");
	}

	push @{$self->{tk_objects}},'tk_text_urls';
}

sub tk_init_tabs {
	my $self=shift;

	my $cnf=$self->{config}||{};

	my @tab_names = map { 'tab_'.$_} $self->config_get_text('/tk/tabs/tab');

	$self->{tk_tab_names}=[@tab_names];

	my $w = $self->{tk_mw}->NoteBook()->pack(
		-expand => 1,
		-fill   => 'both',
	);

	my $tabs={};
	foreach my $tab_name (@tab_names) {
		my $tab = $w->add($tab_name,-label => $tab_name);

		$tabs->{$tab_name}=$tab;
		$self->{tk_tabs}=$tabs;

		$self->tk_init_tab($tab_name);
	}

	push @{$self->{tk_objects}},'tabs';
	
}

sub tk_run {
	my $self=shift;

	$self->tk_init;

	MainLoop;
}

sub tk_init_console {
	my $self=shift;

	my $tabs = $self->{tk_tabs};
	my $tab  = $tabs->{tab_console};


	my $console = $tab->Scrolled(
		'Text',
		-exportselection => 1,
		-height => 50,
		-width => 80,
	);
	$console->pack(
		-expand => 1,
		-fill   => 'both'
	);

	$self->{tk_console}=$console;



}


sub tk_init {
	my $self=shift;

	$self->init_config;

	$self->{htw}=HTML::Work->new(
		sub_log => sub { $self->tk_console_write(@_); }
	);

	$self->tk_init_mw;
	$self->tk_init_tabs;
	$self->tk_init_console;
	$self->tk_init_buttons;

}

sub tk_links_print {
	my $self=shift;

	my @links=@_;

	my $text =$self->{tk_text_links};
	for(@links){
		$text->insert('end',$_."\n");
	}
}

sub tk_console_write {
	my $self=shift;

	my $console = $self->{tk_console};
	unless ($console) {
		print 'console object undefined!' . "\n";
		for(@_){	
			print $_ . "\n";
		}
		return;
	}

	my $time = localtime();
	for(@_){	
		next unless defined $_;
		$console->insert('end',$time . ' ' . $_ . "\n");
	}
}

sub tk_button_url_get_links {
	my $self=shift;

	my $mw  = $self->{tk_mw};

	my %opts_htw = (sub_log => sub { $self->tk_console_write(@_); } );
	my $htw = $self->{htw} || HTML::Work->new(%opts_htw);

	my $db = $mw->DialogBox(
		-title          => 'URL input',
		-buttons        => ['Ok', 'Cancel'],
		-default_button => 'Ok',
	);
	my $url='';
	my $le = $db->LabEntry(
	     -label        => 'URL:',
	     -labelPack    => [qw/-side left -anchor w/],
	     -labelFont    => '9x15bold',
	     -relief       => 'flat',
		 #-state        => 'disabled',
	     -textvariable => \$url,
	     -width        => 35,
	);
	$le->pack(qw/-fill x -expand 1/);

	my $ans=$db->Show();

	if ($ans eq "Ok") {
		my @href = $htw->load_html_from_url({ 
			url => $url,
		})->list_href;

		$self->tk_links_print(@href);

	}
}

sub tk_init_buttons {
	my $self=shift;

	my $mw=$self->{tk_mw};


	my @buttons;
	my $button_data={
		'tab_main' => [
			{ 
				'-text' => 'save_help_topic',
			},
			{ 
				'-text' => 'url_get_links',
				'-command' => sub { $self->tk_button_url_get_links },  
			},
		],
	};
	
	$self->{tk_buttons}=[@buttons];

	my @tab_names = @{$self->{tk_tab_names}||[]};
	my $tabs=$self->{tk_tabs} || {};

	push @{$self->{tk_objects}},'buttons';

	foreach my $tab_name (@tab_names) {
		my $tab=$tabs->{$tab_name} || undef;
		next unless $tab;

		my $bdata = $button_data->{$tab_name} || [];

		foreach my $b (@$bdata) {
			my $btn   = $tab->Button(%$b);
	
			$btn->pack();
			push @buttons, $btn;
		}
	
	}
	
}

sub new
{
	my ($class, %opts) = @_;
	my $self = bless (\%opts, ref ($class) || $class);

	$self->init if $self->can('init');

	return $self;
}

sub init {
	my $self=shift;

	my $h={
		#sub_log => sub  { print $_ . "\n" for(@_); }
		sub_log => sub { $self->tk_console_write(@_); }
	};
		
	my @k=keys %$h;

	for(@k){
		$self->{$_} = $h->{$_} unless defined $self->{$_};
	}
}

sub init_subs {
	my $self=shift;

	my $subs={
		tab_xpath => {},
	};
}

1;
