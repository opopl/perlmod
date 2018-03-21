#!/usr/bin/env perl
	
package MyParser;

use strict;
use warnings;

use base qw(Pod::Simple::PullParser);

use DBI;
use File::Find;
use Pod::Simple::Text;
use Pod::Simple::HTML;

# Variables to hold the text and HTML produced by POD parsers
my ($text, $html);
# Create parser objects and tell them where their output will go
(my $parser_text = Pod::Simple::Text->new)->output_string(\$text);
(my $parser_html = Pod::Simple::HTML->new)->output_string(\$html);

my $dbname="docs_sphinx";

# Initialize database connection
my $dbh = DBI->connect("dbi:mysql:dbname=$dbname;host=localhost", "root","")
	or die $!;
	
sub run {
    my $self = shift;
	my (@tokens, $title);
	
	while (my $token = $self->get_token) {
	        push @tokens, $token;
	
	        # We're looking for a "=head1 NAME" section
	        if (@tokens > 5) {
	            if ($tokens[0]->is_start && $tokens[0]->tagname eq 'head1' &&
	                $tokens[1]->is_text && $tokens[1]->text =~ /^name$/i &&
	                $tokens[4]->is_text)
	            {
	                $title = $tokens[4]->text;
	                # We have the title, so we can ignore the remaining tokens
	                last;
	            }
	
	            shift @tokens;
	        }
	    }
	
	    # No title means no POD -- we're done with this file
	    return if !$title;
	
	    print "Adding: $title\n";
	
	    $parser_text->parse_file($self->source_filename);
	    $parser_html->parse_file($self->source_filename);
	
	    # Add the new document to the database
        my $q=qq{
            INSERT INTO documents (
                title, contents_text, contents_html
            ) values(?,?,?)
        };
	    my $sth = $dbh->prepare($q);
        my @e   = ($title, $text, $html);
        $sth->execute(@e);
	
	    # Clear the content variables and reinitialize parsers
	    $text = $html = "";
	    $parser_text->reinit;
	    $parser_html->reinit;
}

package main;
	
	
#C:\Users\apoplavskiy\repos\git\perlmod\apps\dancer2\sphinx_search\bin
my @dirs;

push @dirs,@INC,
    #(shift @ARGV || '.'),
    ;

use File::Find qw(find);

find({ wanted => sub {
    if (-f and /\.pm$|\.pod$/) {
        my $parser = MyParser->new;
        $parser->parse_file($File::Find::name);
        #$parser->reinit;
    }
}, no_chdir => 1 }, @dirs);

