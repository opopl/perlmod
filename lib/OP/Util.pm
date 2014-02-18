
package OP::Util;

use strict;
use warnings;

use parent qw( Class::Accessor::Complex );

use IPC::Cmd ();
use Data::Dumper;

###__ACCESSORS_SCALAR
my @scalar_accessors=qw(
);

###__ACCESSORS_HASH
my @hash_accessors=qw(
	runstat
);

###__ACCESSORS_ARRAY
my @array_accessors=qw();

__PACKAGE__
	->mk_scalar_accessors(@scalar_accessors)
	->mk_array_accessors(@array_accessors)
	->mk_hash_accessors(@hash_accessors);

sub run {
	my $self=shift;

	my $command=shift;
	my $opts=shift // {};

	my %res;

	$self->runstat('command' => $command);

	#my($ok,$errormessage,$fullbuf,$stdoutbuf,$stderrbuf)=
	@res{qw( ok errormessage fullbuf stdoutbuf stderrbuf )}=
		IPC::Cmd::run( command => $command, verbose => 0 );

	#@res{qw( ok errormessage fullbuf stdoutbuf stderrbuf )}=
		#($ok,$errormessage,$fullbuf,$stdoutbuf,$stderrbuf);

	foreach my $id (qw( stdoutbuf fullbuf stderrbuf )) {
		$res{$id}= [ split("\n",join("",@{$res{$id}})) ];
	}


	unless($res{ok}){
    	@res{qw(exitstatus)} = ( $res{errormessage} =~ /exited with value\s+(\d+)$/ );
	}else{
    	@res{qw(exitstatus)} = 0;
	}

	$self->runstat(%res);

}

1;
