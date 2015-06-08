
package OP::PROJSHELL::CGI;

use strict;
use warnings;

sub _cgi_error {
	my $self=shift;

	my $text=shift || '';

	$self->cgi->b({ -style => 'Color: red;' },"$text");
	
}
sub _cgi_pdfview_perldoc {
	my $self=shift;

	my $q=$self->cgi;

	my $topic=$q->param('pdfperldoc');

    print 
		$q->b("PDF perldoc topic: $topic"),
		$q->p, 
		$q->a(
			{
				href => 'http://localhost/pdfperldoc/' . $topic . '.pdf' 
			},$topic . '.pdf'),
		$q->end_html;

}


sub _cgi_pdfview {
	my $self=shift;

	my $q=$self->cgi;

	unless ($q->param) {
	    print "<b>No query submitted yet.</b>";
    	return;
	}

	my $proj=$q->param('pdfproj');

	unless (defined $proj) {
		return;
	}

    print 
		$q->b("PDF project: $proj"),
		$q->p;

	$self->_proj_reset($proj);

	unless (defined $self->PDFFILE) {
	    print $self->_cgi_error("PDFFILE is not defined");
		return;
	}
	
	unless (-e $self->PDFFILE) {
	    print $self->_cgi_error("PDF output file does not exist");
		return;
	}

	print $q->a(
		{
			href => 'http://localhost/pdfout/' . $self->PDFFILENAME
		},$self->PDFFILENAME);

	print $q->end_html;

   # print "Content-Type:application/x-download\n";
	#print "Content-Disposition: attachment; filename=" 
			#. $self->PDFFILENAME . "\n\n";

	#open FILE, "<", $self->PDFFILE or die "can't open : $!";
	#binmode FILE;
	#local $/ = \10240;
	#while (<FILE>){
		#print $_;
	#}
	
    #close FILE;
	#
}

sub _cgi_htmlview {
	my $self=shift;

	my $q= $self->cgi;

	my $proj=$q->param('htmlproj');

	$self->_proj_reset($proj);

	my $nfiles=$self->HTMLFILES_count;

	my $HTMLDIR=$self->HTMLDIR;
	my $h=OP::HTML->new;

	print $q->header;

	unless($nfiles){

		print 
			$q->p({ -style => 'Color: blue;' },
					'HTML project: ' . $proj ),
	    	$self->_cgi_error("No HTML files found");

	} elsif ($nfiles == 1) {
		my $file=$self->HTMLFILES_shift;
		my $projuri='http://localhost/htmlprojs/' 
				 . $self->PROJ . '/' . $file;

		#print $q->redirect({ uri => $projuri });

		print $q->a({ href => $projuri },$file);

	}

	print $q->end_html;

}

sub _cgi_makepdf {
	my $self=shift;

	my $q= $self->cgi;

	my $proj=$q->param('proj');

	$self->_proj_reset($proj);

	$self->make;

}

sub _cgi_makehtml {
	my $self=shift;

	my $q= $self->cgi;

	my $proj=$q->param('proj');

	$self->_proj_reset($proj);

	$self->make('_html');

}

sub _cgi_printenv {
	my $self=shift;

	my $q=$self->cgi;

	#print $q->header
	print $q->start_html;

	my @vars=sort keys %ENV;
	my (%varlett,@letters);

	foreach my $var (@vars) {
		my ($lett) = ( $var =~ /^(\w)/ );
		$lett=uc $lett;

		push(@{$varlett{$lett}},$var);
		push(@letters,$lett);
	}
	@letters=uniq(@letters);

	print $q->a({ name => "up" });

	print $q->hr . "\n";
	foreach my $lett (@letters) {
		print $q->a({ href => "#$lett" },$lett) . "\n";
	}
	print 	$q->hr . "\n";

	foreach my $lett (('A'..'Z')) {
		next unless defined $varlett{$lett};

		print $q->h3("$lett"),
			$q->a({ name => "$lett" }),
			'	',
			$q->a({ href => "#up" },'up'),
			'	',
			$q->a({ href => "#down" },'down'),
			$q->br;

		foreach my $var (@{$varlett{$lett}}) {
			my $val=$ENV{$var};
				if(grep { /^$var$/ } qw(PATH PERLLIB)){
					print $q->br,"$var = ";
					foreach my $dir (split(':',$val)) {
						print $q->br,"   $dir" . "\n";
					}
					
				}else{
					print $q->br,"$var = $val";
				}
		}
	}

	print $q->a({ name => "down" }) . "\n";

	print $q->end_html . "\n";

	exit 0;
}

sub _cgi_perldoc {
	my $self=shift;

	OP::cgi::perldoc->new->main;

}

sub _cgi_tex4ht {
	my $self=shift;

	OP::cgi::tex4ht->new->main;

}

sub _cgi_www {
	my $self=shift;

	$self->cgi( CGI->new );
	my $pinfo=$self->cgi->path_info;

	$self->_cgi_www_header($pinfo);

	$pinfo =~ s{^\/(\w+)\/.*$}{$1}g;

	for($pinfo){
		/^$/ && do {
			$self->_cgi_www_frameset;
			next;
		};
		/^query$/ && do {
			$self->_cgi_www_frame_query;
			next;
		};
		/^response$/ && do {
			$self->_cgi_www_frame_response;
			next;
		};
		/^perldoc$/ && do {
			$self->_cgi_www_perldoc;
			next;
		};
	}

	print $self->cgi->end_html . "\n";

    exit 0;
}

sub _cgi_www_frameset {
	my $self=shift;

	my $q=$self->cgi;

	my $sname=$q->script_name;

	my $h=OP::HTML->new;

    print <<EOF;
<html><head><title>Root Projs Page</title></head>
	<frameset 
		rows="30,70" 
		frameborder='yes' 
		border=2
		scrolling='yes'>
	<frame 
		src="$sname/query" 
		name="query"
		marginwidth="10" marginheight="15">
	<frame src="$sname/response" name="response">
</frameset>
EOF

}

sub _cgi_www_frame_query {
	my $self=shift;

	my $q=$self->cgi;

	my $sname=$q->script_name;

	my $lines=[
		$q->start_html('ProjsQuery'), 
		$q->start_form(
			-action => "$sname/response",
			-target => "response",
		),
		"<table border=1>",
			"<tr>",
			   "<td>",
					"PDF projects", $q->br,
					$q->popup_menu(
						-name		=> 'pdfproj',
						-values		=>	[ $self->PDFPROJS ],
						-default 	=> 'KantCPR'
					),
			   "</td>",
			   "<td>",
					"HTML projects",$q->br,
					$q->popup_menu(
						-name		=> 'htmlproj',
						-values		=>	[ $self->HTMLPROJS ],
						-default 	=> 'KantCPR'
					),
			   "</td>",
			   "<td>",
					"All projects",$q->br,
					$q->popup_menu(
						-name		=> 'proj',
						-values		=>	[ $self->PROJS ],
						-default 	=> 'programmingperl'
					),
			   "</td>",
			   "<td>",
					"PDF perldoc",$q->br,
					$q->popup_menu(
						-name		=> 'pdfperldoc',
						-values		=>	[ $self->PDFPERLDOC ],
						-default 	=> 'CGI',
					),
			   "</td>",
			"</tr>",
			"<tr>",
			   "<td>",
					$q->submit('submit_pdfview'  , 'View PDF'),
			   "</td>",
			   "<td>",
					$q->submit('submit_htmlview' , 'View HTML'),
			   "</td>",
			   "<td>",
					$q->submit('submit_makepdf'  , 'Generate PDF'),
			   "</td>",
			   "<td>",
					$q->submit('submit_pdfview_perldoc'  , 'View PDF (perldoc)'),
			   "</td>",
			"</tr>",
			"<tr>",
			   "<td>",
			   "</td>",
			   "<td>",
			   "</td>",
			   "<td>",
					$q->submit('submit_makehtml' , 'Generate HTML'),
			   "</td>",
			"</tr>",
		"</table>",
		$q->submit('submit_printenv' , 'Environment'),
		$q->submit('submit_perldoc' , 'Perldoc'),
		$q->submit('submit_tex4ht' , 'TeX4HT'),
		# -------------- View/Generate HTML 
		$q->end_form,
	];

	print join("\n",@$lines) . "\n";

}

sub _cgi_www_header {
	my $self=shift;

	my $pinfo=shift;

   # given($pinfo){
		#when(/pdfview/) { 
		#}
		#default { 
		#}
	#}

	print $self->cgi->header;

}


sub _cgi_www_frame_response {
	my $self=shift;

	my $q=$self->cgi;

	$self->submits(qw(
				pdfview htmlview
				pdfview_perldoc
				makepdf makehtml
				printenv perldoc tex4ht
			)
		);

	foreach my $id (@{$self->submits}) {
		if ($q->param('submit_' . $id )){
			eval '$self->_cgi_' . $id;

			if($@){
				print $q->header,
					$q->start_html;

				print $self->_cgi_error($_) for(split(' ',$@));

				print $q->end_html;

				exit 1;
			}
		}
	}

	exit 0;

}

sub usecgi {
	my $self=shift;

	my $usecgi = $self->_opt_true("cgi" ) ? 1 : 0;

	print $usecgi . "\n";

	return $usecgi;


}


1;
 

