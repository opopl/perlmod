package OP::Parse::BL;

# POD, new() {{{

# POD: Header, info about the module {{{

=head1 NAME

Parse::BooleanLogic - parser of boolean expressions

=head1 SYNOPSIS

    use Parse::BL;
    use Data::Dumper;

    my $parser = Parse::BooleanLogic->new( operators => ['', 'OR'] );
    my $tree = $parser->as_array( 'label:parser subject:"boolean logic"' );
    print Dumper($tree);

    $parser = new Parse::BooleanLogic;
    $tree = $parser->as_array( 'x = 10' );
    print Dumper($tree);

    $tree = $parser->as_array( 'x = 10 OR (x > 20 AND x < 30)' );
    print Dumper($tree);

    # custom parsing using callbacks
    $parser->parse(
        string   => 'x = 10 OR (x > 20 AND x < 30)',
        callback => {
            open_paren   => sub { ... },
            operator     => sub { ... },
            operand      => sub { ... },
            close_paren  => sub { ... },
            error        => sub { ... },
        },
    );

=head1 DESCRIPTION

This module is quite fast parser for boolean expressions. Originally it's been writen for
Request Tracker to parse SQL like expressions and it's still capable, but
it can be used to parse other boolean logic sentences with OPERANDs joined using
binary OPERATORs and grouped and nested using parentheses (OPEN_PAREN and CLOSE_PAREN).

Operand is not qualified strictly what makes parser flexible enough to parse different
things, for example:

    # SQL like expressions
    (task.status = "new" OR task.status = "open") AND task.owner_id = 123

    # Google like search syntax used in Gmail and other service
    subject:"some text" (from:me OR to:me) label:todo !label:done

    # Binary boolean logic expressions
    (a | b) & (c | d)

You can change literals used for boolean operators and parens. Read more
about this in description of constructor's arguments.

As you can see quoted strings are supported. Read about that below in
L<Quoting and dequoting>.

=cut
# }}}
# Declaration {{{
use 5.008;
use strict;
use warnings;


our $VERSION = '1.0';

use constant OPERAND     => 1;
use constant OPERATOR    => 2;
use constant OPEN_PAREN  => 4;
use constant CLOSE_PAREN => 8;
use constant STOP        => 16;
use constant NOT        => 32;
use constant OPERATOR_OPEN_PAREN  => 64;

my @tokens = qw[OPERAND OPERATOR OPERATOR_OPEN_PAREN OPEN_PAREN CLOSE_PAREN STOP NOT ];

use Regexp::Common qw(delimited);
my $re_delim = qr{$RE{delimited}{-delim=>qq{\'\"}}{-esc=>'\\'}};

# }}}
# POD: Methods - building parser {{{
=head1 METHODS

=head2 Building parser

=head3 new

A constructor, takes the following named arguments:

=over 4

=item operators, default is ['AND' 'OR']

Pair of literal strings representing boolean operators AND and OR,
pass it as array reference. For example:

    # from t/custom_ops.t
    my $parser = Parse::BooleanLogic->new( operators => [qw(& |)] );

    # from t/custom_googlish.t
    my $parser = Parse::BooleanLogic->new( operators => ['', 'OR'] );
$self->{'parens'}
It's ok to have any operators and even empty.

=item parens, default is ['(', ')']

Pair of literal strings representing parentheses, for example it's
possible to use curly braces:

    # from t/custom_parens.t
    my $parser = Parse::BooleanLogic->new( parens => [qw({ })] );

No matter which pair is used parens must be balanced in expression.

=back

This constructor compiles several heavy weight regular expressions
so it's better avoid building object each time right before parsing,
but instead use global or cached one.

=cut
# }}}

sub new {
    my $proto = shift;
    my $self = bless {}, ref($proto) || $proto;
    return $self->init( @_ );
}
# }}}
# init() {{{

=head3 init

An initializer, called from the constructor. Compiles regular expressions
and do other things with constructor's arguments. Returns this object back.

=cut

sub init {
    my $self = shift;
    my %args = @_;
	my @ops;
	# $args{operators} {{{
    if ( $args{'operators'} ) {
		shift;shift;
        @ops = map lc $_, @{ $args{'operators'} };
        $self->{'operators'} = [ @ops ];
        #@ops = reverse @ops if length $ops[1] > length $ops[0];
        foreach ( @ops ) {
            unless ( length ) {
                $_ = "(?<=\\s)";
            }
            else {
                if ( /^\w/ ) {
                    $_ = '\b'. "\Q$_\E";
                }
                else {
                    $_ = "\Q$_\E";
                }
                if ( /\w$/ ) {
                    $_ .= '\b';
                }
            }
            $self->{'re_operator'} = qr{(?:$ops[0]|$ops[1]|$ops[2])}i;
        }
    } else {
        $self->{'operators'} = [qw(and or not)];
        $self->{'re_operator'} = qr{\b(?:AND|OR)\b}i;
    }
	# }}}
	# $args{parens} {{{
    if ( $args{'parens'} ) {
		shift;shift;
        $self->{'parens'} = $args{'parens'};
        $self->{'re_operator_open_paren'} = qr{(?:$self->{re_operator})\Q$args{'parens'}[0]\E};
        $self->{'re_start_open_paren'} = qr{^\s*\Q$args{'parens'}[0]\E};
        $self->{'re_open_paren'} = qr{\Q$args{'parens'}[0]\E};
        $self->{'re_close_paren'} = qr{\Q$args{'parens'}[1]\E};
        $self->{'re_last_close_paren'} = qr{\Q$args{'parens'}[1]\E\Z};
    } else {
        $self->{'parens'} = [ '\(', '\)' ] ;
        $self->{'re_open_paren'} = qr{\(};
        $self->{'re_start_open_paren'} = qr{^\s*\(};
        $self->{'re_close_paren'} = qr{\)};
        $self->{'re_last_close_paren'} = qr{\)\Z};
    }
	# }}}
	# other keys {{{
    %args = @_;
	#my @wkeys=qw( debug logname ); 
	foreach my $wkey (keys %args){
		if (grep { $wkey eq  $_ } keys %args){
			if (defined($args{$wkey})){
				$self->{$wkey}=$args{$wkey};
			}
		}
	}
	#print "init BL: log $self->{log}\n";
	#print "init BL: fhlog " . $self->{fhlog} . "\n";exit;
	# }}}
	# re_tokens; regex {{{

       $self->{'open_paren'} = $self->{'parens'}[0];
       $self->{'close_paren'} = $self->{'parens'}[1];
  	   $self->{'re_tokens'}  = qr{(?:$self->{'re_operator'}|$self->operators[2])};
# the following need some explanation
# operand is something consisting of delimited strings and other strings that are not our major tokens
# so it's a (delim string or anything until a token, ['"](start of a delim) or \Z) - this is required part
# then you can have zero or more occurrences of above group, but with one exception - "anything" can not start with a token or ["']
    $self->{'re_operand'} = qr{(?:$re_delim|.+?(?=$self->{re_tokens}|["']|\Z))(?:$re_delim|(?!$self->{re_tokens}|["']).+?(?=$self->{re_tokens}|["']|\Z))*};

    foreach my $re (qw(re_operator 
			re_operand 
			re_open_paren 
			re_start_open_paren 
			re_close_paren 
			re_last_close_paren )) {
        $self->{"m$re"} = qr{\G($self->{$re})};
    }
	$self->{"mre_not"}=qr{\G($self->{'operators'}[2])}i;
	$self->{"mre_operator_open_paren"}=qr{\G($self->{re_operator})($self->{re_open_paren})};
# }}}

    return $self;
}
# }}}
# Parsing {{{
=head2 Parsing expressions

=cut 

# as_array() {{{

=head3 as_array $string [ %options ]

Takes a string and parses it into perl structure, where parentheses represented using
array references, operands are hash references with one key/value pair: operand,
when binary operators are simple scalars. So string C<x = 10 OR (x > 20 AND x < 30)>
is parsed into the following structure:

    [
        { operand => 'x = 10' },
        'OR',
        [
            { operand => 'x > 20' },
            'AND',
            { operand => 'x < 30' },
        ]
    ]

Aditional options:

=over 4

=item operand_cb - custom operands handler, for example:

    my $tree = $parser->as_array(
        "some s                                          tring",
        operand_cb => sub {
            my $op = shift;
            if ( $op =~ m/^(!?)(label|subject|from|to):(.*)/ ) {
                ...
            } else {
                die "You have an error in your query, in '$op'";
            }
        },
    );


=item error_cb - custom errors handler

    my $tree = $parser->as_array(
        "some string",
        error_cb => sub {
            my $msg = shift;
            MyParseException->throw($msg);
        },
    );

=back

=cut

{ # static variables

my ($tree, $node, @pnodes);
my %callback;
$callback{'open_paren'} = sub {
    push @pnodes, $node;
    push @{ $pnodes[-1] }, $node = []
};
$callback{'close_paren'}     = sub { $node = pop @pnodes };
$callback{'operator'} = sub { push @$node, $_[0] };
$callback{'not'} = sub { push @$node, $_[0] };
$callback{'operand'} = sub { push @$node, { operand => $_[0] } };

sub as_array {
    my $self = shift;
    my $string = shift;
    my %arg = (@_);

    $tree = ( $node = [] );
    @pnodes = ();

    unless ( $arg{'operand_cb'} || $arg{'error_cb'} ) {
        $self->parse(string => $string, callback => \%callback);
		$tree = $node;
        return $tree;
    }

    my %cb = %callback;
	#$cb{'error'}= sub { $self->pdebug("$_[0]","$_[1]\n"); };
    if ( $arg{'operand_cb'} ) {
        $cb{'operand'} = sub { push @$node, $arg{'operand_cb'}->( $_[0] ) };
    }
    $cb{'error'} = $arg{'error_cb'} if $arg{'error_cb'};
    $self->parse(string => $string, callback => \%cb);
	$tree = $node;
    return $tree;
} }
# }}}
# parse() {{{
# POD for parse() {{{
=head3 parse

Takes named arguments: string and callback. Where the first one is scalar with
expression, the latter is a reference to hash with callbacks: open_paren, operator
operand, close_paren and error. Callback for errors is optional and parser dies if
it's omitted. Each callback is called when parser finds corresponding element in the
string. In all cases the current match is passed as argument into the callback.

Here is simple example based on L</as_array> method:

    # result tree and the current group
    my ($tree, $node);
    $tree = $node = [];

    # stack with nested groups, outer most in the bottom, inner on the top
    my @pnodes = ();

    my %callback;
    # on open_paren put the current group on top of the stack,
    # create new empty group and at the same time put it into
    # the end of previous one
    $callback{'open_paren'} = sub {
        push @pnodes, $node;
        push @{ $pnodes[-1] }, $node = []
    };

    # on close_paren just switch to previous group by taking it
    # from the top of the stack
    $callback{'close_paren'} = sub { $node = pop @pnodes };

    # push binary operators as is and operands as hash references
    $callback{'operator'} = sub { push @$node, $_[0] };
    $callback{'operand'}  = sub { push @$node, { operand => $_[0] } };

    # run parser
    $parser->parse( string => $string, callback => \%callback );

    return $tree;

Using this method you can build other representations of an expression.

=cut
# }}}

{
# vars and subs: vars, get_names() print_bit_var() pdebug()  {{{

# %tokvals %names %opts {{{
my %tokvals=(
	1	=>	"OPERAND",
	2	=>	"OPERATOR",
	4	=>	"OPEN_PAREN",
	8	=>	"CLOSE_PAREN",
	16	=>	"STOP",
	32	=>	"NOT",
	64	=>	"OPERATOR_OPEN_PAREN"
);
my %names=( 
	self	=>	"Parse::BL" 
);

# }}}

sub get_names(){
	my($self,$namekey)=@_;
	return $names{$namekey};
}

sub chvars(){
	my($self,%O)=@_;
	foreach my $k(keys %O){
		$self->{$k}=$O{$k};
		$self->setvars($k);
		$self->pdebug("chvars","Setting parser's value for the hash key $k to: $O{$k}\n");
	}
}

sub setvars(){
	my($self,@argv)=@_;
	if (@argv){
		foreach(@argv){
			if (/^nline$/){
				my $nline=$self->{'nline'};
				my $max=$self->{'wBLmax'};
				my $min=$self->{'wBLmin'};
		   #     $self->{'debug'}=
				#(
					#($self->{'wBLcheck'}) && (
						#( 
							#(($nline>$max) || ($nline<$min)) && (defined $max && defined $min)
						#)||(
							#($nline>$max) && (defined $max && !defined $min)
						#)||(	
							#($nline<$min) && (defined $min && !defined $max)
						#)
					#)||(!$self->{'wBLcheck'})
				#) ? 1 : 0;
			}
		}
	}
}

sub lprint(){
	# {{{
	my($self,$text)=@_;
	if ($self->{'log'}){
				foreach( qw( fhlog fhlogtex )){
					if (defined $self->{$_}){
						print { $self->{$_} } "$text";
					}
				}
		}else{
				print "$text";
	}
	# }}}
}

sub print_bit_var(){
# {{{
	my $nOR=0;
	my($self,$svar,$var,$thissub,$ntabs)=@_;
	my $stab="";
	if ($self->{debug}){
		if (defined($ntabs)){
			$stab=" " x $ntabs; 
		}
		$self->lprint("#$thissub> $stab\$$svar=");
		my $nmatch=0;
		foreach(keys %tokvals){
			if ( $var & $_ ){
				$nmatch++;
				if ($nOR){ $self->lprint("|"); }
					$self->lprint("$tokvals{$_}");
					$nOR++;
			}
		}
		if (!$nmatch){ $self->lprint("$var"); }
		$self->lprint("\n");
	}

# }}}
}

sub pdebug {
	# {{{
	my($self,$sub,$text,$ntabs)=@_;
	my $pref=$self->get_names("self");
	my $stab="";
	if ($self->{debug}){
			if (defined($ntabs)){
				$stab=" " x $ntabs; 
			}
			#print "$self->{'log'}\n";
			if ($self->{'log'}){
				foreach( qw( fhlog fhlogtex )){
					if (defined $self->{$_}){
						print { $self->{$_} } "#$pref" ."::$sub> $stab$text";
					}
				}
			}else{
					print "#$pref" ."::$sub> $stab$text";
			}
	}
	# }}}
}
# }}}

sub parse {
	# {{{
	# intro {{{
    my $self = shift;
    my %args = (
        string => '',
        callback => {},
        @_
    );
	my $thissub=caller(0)."::parse";
    my ($string, $cb) = @args{qw(string callback)};
    $string = '' unless defined $string;

    # States
    my $want = OPERAND | OPEN_PAREN | STOP | NOT | OPERATOR_OPEN_PAREN ;
    my $last = 0;
    my $depth = 0;

	$self->pdebug("parse","\$string=$string\n",0);

	my $istep=1;
	my $pos;
	my $need_complete_operand;
	my $operand;
	my $open_paren=0;
	# }}}

    while (1) {
        # State Machine {{{
		# regex definitions  {{{
#    $self->{'re_operand'} = qr{(?:$re_delim|.+?(?=$self->{re_tokens}|["']|\Z))(?:$re_delim|(?!$self->{re_tokens}|["']).+?(?=$self->{re_tokens}|["']|\Z))*};

    #foreach my $re (qw(re_operator 
			#re_operand 
			#re_open_paren 
			#re_start_open_paren 
			#re_close_paren 
			#re_last_close_paren )) {
        #$self->{"m$re"} = qr{\G($self->{$re})};
    #}
	#$self->{"mre_not"}=qr{\G($self->{'operators'}[2])}i;
	#$self->{"mre_operator_open_paren"}=qr{\G($self->{re_operator})($self->{re_open_paren})}
	# }}}

		$pos=pos($string);
		$self->print_bit_var("want",$want,$thissub,4);
		$self->print_bit_var("last",$last,$thissub,6);
		$self->pdebug("parse","Step: $istep\n");
		$self->pdebug("parse","\$pos=$pos\n",2) if defined($pos);
		$self->pdebug("parse","depth=$depth\n",2);

        if ( $string =~ /\G\s+/gc ) {
        }
		# OPERATOR_OPEN_PAREN {{{
		elsif ( ($want & OPERATOR_OPEN_PAREN   ) && $string =~ /$self->{'mre_operator_open_paren'}/gc ) {
            $cb->{'operator'}->( $1 );
            $cb->{'open_paren'}->( $2 );
			if (defined($2)){ $open_paren=1; }
			$self->pdebug("parse","operator=$1\n",2);
            $last = OPERATOR_OPEN_PAREN;
			$depth++;
            $want = NOT | OPERAND | OPEN_PAREN;
        }
		# }}}
		# NOT {{{
		elsif ( ($want & NOT   ) && $string =~ /$self->{'mre_not'}/gc ) {
			my $m=$1;
			$self->pdebug("parse","operand=$m\n",2);
            $cb->{'not'}->( $1 );
            $last = NOT;
            $want = OPERAND | OPEN_PAREN;
        }
		# }}}
		# OPERATOR {{{
        elsif ( ($want & OPERATOR   ) && $string =~ /$self->{'mre_operator'}/gc ) {
			my $m=$1;
            $cb->{'operator'}->( $1 );
			$self->pdebug("parse","operator=$m\n",2);
            $last = OPERATOR;
            $want = OPERAND | NOT;
        }
		# }}}
		## OPEN_PAREN  {{{
		#elsif ( ($want & OPEN_PAREN ) && $string =~ /$self->{'mre_start_open_paren'}/gc ) {
			#$cb->{'open_paren'}->( $1 );
			#$string =~ s/$self->{'mre_start_open_paren'}//g;
			##$string =~ s/$self->{'mre_last_close_paren'}//g;
			#$last = OPEN_PAREN;
			#$want = OPERAND | NOT | OPEN_PAREN | OPERATOR_OPEN_PAREN;
		#}
		## }}}
		# CLOSE_PAREN  {{{
        elsif ( ($want & CLOSE_PAREN) && $string =~ /$self->{'mre_close_paren'}/gc ) {
            $cb->{'close_paren'}->( $1 );
			$depth--;
            $last = CLOSE_PAREN;
            $want = OPERATOR | OPERATOR_OPEN_PAREN;
            $want |= $depth? CLOSE_PAREN : STOP;
        }
		# }}}
		# OPERAND  {{{
        elsif ( ($want & OPERAND    ) && $string =~ /$self->{'mre_operand'}/gc ) {
			$operand="" if (!$need_complete_operand);
            my $opthis = $1;
			$pos=pos($string);
			my $ss=substr($string,$pos);
            $opthis=~ s/\s+$//;
			$operand.=$opthis;
		    if ($open_paren){
				if ($operand =~ s/$self->{close_paren}$//g ){
					pos($string)--;
					$operand=substr($operand,0,length($operand));
				}
			}
			## check parens {{{
			my $is=0;
			my $sy;
			my ($start_open,$end_close);
			my %closed=( 
				start	=>	0,
				end		=>	0
			);
			my @ids=qw(close open);
			my %n;
			foreach my $id(@ids){ $n{$id}=0; }
			$sy=substr($operand,$is);

			if (($operand =~ /^$self->{open_paren}/i)){ $start_open=1; }
			if (($operand =~ /$self->{close_paren}$/i)){ $end_close=1; }

			while($is < length($operand)){
				$sy=substr($operand,$is);
				my %idmatch;
				foreach my $id (@ids){
					if ($sy =~ /^$self->{"$id"."_paren"}/i){ $n{$id}++; $idmatch{$id}=1; }
				}
				if ($idmatch{close}){
					if (($start_open) && (!$closed{start}) && ($n{open}==1) && ($is<length($operand)-1)){
						$closed{start}=1;
					}elsif(!$start_open){
						$closed{start}=1;
					}
				}
				$is++;
			}
			my $parbal=$n{close}-$n{open};

			if (( $parbal ==1 ) && ($n{close} ==1 )){ $operand =~ s/$self->{'close_paren'}$//g; }
			if (( $parbal ==-1 ) && ($n{open} ==1 )){ $operand =~ s/^$self->{'open_paren'}//g; }
			if (!$closed{start}){ 	
					$operand =~ s/^$self->{'open_paren'}//g; 
					$operand =~ s/$self->{'close_paren'}$//g; 
			}
			# }}}
			$self->pdebug("parse","operand=$operand\n",2);
            $cb->{'operand'}->( $operand );
            $last = OPERAND;
            $want = OPERATOR | OPERATOR_OPEN_PAREN;
            $want |= $depth? CLOSE_PAREN : STOP;
        }
		# }}}
		# STOP {{{
        elsif ( ($want & STOP) && $string =~ /\G\s*$/igc ) {
            $last = STOP;
            last;
        }
		# }}}
        else {
            last;
        }
		$istep++;
		# }}}
    }

   if (!$last || !($want & $last)) {
	   # {{{
		my $tmp = substr( $string, 0, pos($string) );
		$tmp .= '>>>here<<<'. substr($string, pos($string));
		my $msg = "Incomplete or incorrect expression, expecting a ". $self->bitmask_to_string($want) ." in '$tmp'";
		$cb->{'error'}? $cb->{'error'}->("parse",$msg): die $msg;
		return;
		# }}}
	}

    if ( $depth ) {
        my $msg = "Incomplete query, $depth paren(s) isn't closed in '$string'";
        $cb->{'error'}? $cb->{'error'}->("parse",$msg): die $msg;
        return;
    }
	# }}}
} 

}

sub bitmask_to_string {
	# {{{
    my $self = shift;
    my $mask = shift;

    my @res;
    for( my $i = 0; $i < @tokens; $i++ ) {
        next unless $mask & (1<<$i);
        push @res, $tokens[$i];
    }

    my $tmp = join ', ', splice @res, 0, -1;
    unshift @res, $tmp if $tmp;
    return join ' or ', @res;
	# }}}
}
# }}}
# }}}
# Quoting and dequoting {{{

=head2 Quoting and dequoting

This module supports quoting with single quote ' and double ",
literal quotes escaped with \.

from L<Regexp::Common::delimited> with ' and " as delimiters.

=head3 q, qq, fq and dq

Four methods to work with quotes:

=over 4

=item q - quote a string with single quote character.

=item qq - quote a string with double quote character.

=item fq - quote with single if string has no single quote character, otherwisee use double quotes.

=item dq - delete either single or double quotes from a string if it's quoted.

=back

All four works either in place or return result, for example:

    $parser->q($str); # inplace

    my $q = $parser->q($s); # $s is untouched

=cut

sub q {
    if ( defined wantarray ) {
        my $s = $_[1];
        $s =~ s/(?=['\\])/\\/g;
        return "'$s'";
    } else {
        $_[1] =~ s/(?=['\\])/\\/g;
        substr($_[1], 0, 0) = "'";
        $_[1] .= "'";
        return;
    }
}

sub qq {
    if ( defined wantarray ) {
        my $s = $_[1];
        $s =~ s/(?=["\\])/\\/g;
        return "\"$s\"";
    } else {
        $_[1] =~ s/(?=["\\])/\\/g;
        substr($_[1], 0, 0) = '"';
        $_[1] .= '"';
        return;
    }
}

sub fq {
    if ( index( $_[1], "'" ) >= 0 ) {
        if ( defined wantarray ) {
            my $s = $_[1];
            $s =~ s/(?=["\\])/\\/g;
            return "\"$s\"";
        } else {
            $_[1] =~ s/(?=["\\])/\\/g;
            substr($_[1], 0, 0) = '"';
            $_[1] .= '"';
            return;
        }
    } else {
        if ( defined wantarray ) {
            my $s = $_[1];
            $s =~ s/(?=\\)/\\/g;
            return "'$s'";
        } else {
            $_[1] =~ s/(?=\\)/\\/g;
            substr($_[1], 0, 0) = "'";
            $_[1] .= "'";
            return;
        }
    }
}

sub dq {
    return defined wantarray? $_[1] : ()
        unless $_[1] =~ /^$re_delim$/o;

    if ( defined wantarray ) {
        my $s = $_[1];
        my $q = substr( $s, 0, 1, '' );
        substr( $s, -1   ) = '';
        $s =~ s/\\([$q\\])/$1/g;
        return $s;
    } else {
        my $q = substr( $_[1], 0, 1, '' );
        substr( $_[1], -1 ) = '';
        $_[1] =~ s/\\([$q\\])/$1/g;
        return;
    }
}
# }}}
# Tree evaluation and modification {{{

=head2 Tree evaluation and modification

Several functions taking a tree of boolean expressions as returned by
L<as_array> method and evaluating or changing it using a callback.

=head3 walk $tree $callbacks @rest

A simple method for walking a $tree using four callbacks: open_paren,
close_paren, operand and operator. All callbacks are optional.

Example:

    $parser->walk(
        $tree,
        {
            open_paren => sub { ... },
            close_paren => sub { ... },
            ...
        },
        $some_context_argument, $another, ...
    );

Any additional arguments (@rest) are passed all the time into callbacks.

=cut

sub walk {
    my ($self, $tree, $cb, @rest) = @_;

    foreach my $entry ( @$tree ) {
        if ( ref $entry eq 'ARRAY' ) {
            $cb->{'open_paren'}->( @rest ) if $cb->{'open_paren'};
            $self->walk( $entry, $cb, @rest );
            $cb->{'close_paren'}->( @rest ) if $cb->{'close_paren'};
        } elsif ( ref $entry ) {
            $cb->{'operand'}->( $entry, @rest ) if $cb->{'operand'};
        } else {
            $cb->{'operator'}->( $entry, @rest ) if $cb->{'operator'};
        }
    }
}

=head3 filter $tree $callback @rest

Filters a $tree using provided $callback. The callback is called for each operand
in the tree and operand is left when it returns true value.

Any additional arguments (@rest) are passed all the time into the callback.
See example below.

Boolean operators (AND/OR) are skipped according to parens and left first rule,
for example:

    X OR Y AND Z -> X AND Z
    X OR (Y AND Z) -> X OR Z
    X OR Y AND Z -> Y AND Z
    X OR (Y AND Z) -> Y AND Z
    X OR Y AND Z -> X OR Y
    X OR (Y AND Z) -> X OR Y

Returns new sub-tree. Original tree is not changed, but operands in new tree
still refer to the same hashes in the original.

Example:

    my $filter = sub {
        my ($condition, $some) = @_;
        return 1 if $condition->{'operand'} eq $some;
        return 0;
    };
    my $new_tree = $parser->filter( $tree, $filter, $some );

See also L<solve|/"solve $tree $callback @rest">

=cut

sub filter {
    my ($self, $tree, $cb, @rest) = @_;

    my $skip_next = 0;

    my @res;
    foreach my $entry ( @$tree ) {
        $skip_next-- and next if $skip_next > 0;

        if ( ref $entry eq 'ARRAY' ) {
            my $tmp = $self->filter( $entry, $cb, @rest );
            $tmp = $tmp->[0] if @$tmp == 1;
            if ( !$tmp || (ref $tmp eq 'ARRAY' && !@$tmp) ) {
                pop @res;
                $skip_next++ unless @res;
            } else {
                push @res, $tmp;
            }
        } elsif ( ref $entry ) {
            if ( $cb->( $entry, @rest ) ) {
                push @res, $entry;
            } else {
                pop @res;
                $skip_next++ unless @res;
            }
        } else {
            push @res, $entry;
        }
    }
    return $res[0] if @res == 1 && ref $res[0] eq 'ARRAY';
    return \@res;
}

=head3 solve $tree $callback @rest

Solves a boolean expression represented by a $tree using provided $callback.
The callback is called for operands and should return a boolean value
(0 or 1 will work).

Any additional arguments (@rest) are passed all the time into the callback.
See example below.

Functions matrixes:

    A B AND OR
    0 0 0   0
    0 1 0   1
    1 0 0   1
    1 1 1   1

Whole branches of the tree can be skipped when result is obvious, for example:

    1 OR  (...)
    0 AND (...)

Returns result of the expression.

Example:

    my $solver = sub {
        my ($condition, $some) = @_;
        return 1 if $condition->{'operand'} eq $some;
        return 0;
    };
    my $result = $parser->solve( $tree, $filter, $some );

See also L<filter|/"filter $tree $callback @rest">.

=cut

sub solve {
    my ($self, $tree, $cb, @rest) = @_;

    my ($res, $ea, $skip_next) = (0, $self->{'operators'}[1], 0);
    foreach my $entry ( @$tree ) {
        $skip_next-- and next if $skip_next > 0;
        unless ( ref $entry ) {
            $ea = lc $entry;
            $skip_next++ if
                   ( $res && $ea eq $self->{'operators'}[1])
                || (!$res && $ea eq $self->{'operators'}[0]);
            next;
        }

        my $cur;
        if ( ref $entry eq 'ARRAY' ) {
            $cur = $self->solve( $entry, $cb, @rest );
        } else {
            $cur = $cb->( $entry, @rest );
        }
        if ( $ea eq $self->{'operators'}[1] ) {
            $res ||= $cur;
        } else {
            $res &&= $cur;
        }
    }
    return $res;
}

=head3 fsolve $tree $callback @rest

Does in filter+solve in one go. Callback can return undef to filter out an operand,
and a defined boolean value to be used in solve.

Any additional arguments (@rest) are passed all the time into the callback.

Returns boolean result of the equation or undef if all operands have been filtered.

See also L<filter|/"filter $tree $callback @rest"> and L<solve|/"solve $tree $callback @rest">.

=cut

sub fsolve {
    my ($self, $tree, $cb, @rest) = @_;

    my ($res, $ea, $skip_next) = (undef, $self->{'operators'}[1], 0);
    foreach my $entry ( @$tree ) {
        $skip_next-- and next if $skip_next > 0;
        unless ( ref $entry ) {
            $ea = lc $entry;
            $skip_next++ if
                   ( $res && $ea eq $self->{'operators'}[1])
                || (!$res && $ea eq $self->{'operators'}[0]);
            next;
        }

        my $cur;
        if ( ref $entry eq 'ARRAY' ) {
            $cur = $self->fsolve( $entry, $cb, @rest );
        } else {
            $cur = $cb->( $entry, @rest );
        }
        if ( defined $cur ) {
            $res ||= 0;
            if ( $ea eq $self->{'operators'}[1] ) {
                $res ||= $cur;
            } else {
                $res &&= $cur;
            }
        } else {
            $skip_next++ unless defined $res;
        }
    }
    return $res;
}

=head3 collect $tree 

Collapse the tree into a string. Returns a string.

=cut

sub collect {
	my($self,$tree,$opname)=@_;
	my($ea,$x);
	my $res="";
	unless (ref $tree){
		return $tree;
	}
    foreach my $entry ( @$tree ) {
        if( ! ref $entry ) {
            $ea = lc $entry;
			if (grep { $ea eq $_ } @{$self->{'operators'}} ){
				$res="( $res )";
				$res.=" $ea ";
			}
		}
		elsif (ref $entry eq 'ARRAY'){
			$x=$self->collect($entry,$opname);
			$res.=" ( $x ) ";
		}else{
			$x=$entry->{$opname};
			$res.=" $x";
		}
	}
	return $res;
}

=head3 partial_solve $tree $callback @rest

Partially solve a $tree. Callback can return undef or a new expression
and a defined boolean value to be used in solve.

Returns either result or array reference with expression.

Any additional arguments (@rest) are passed all the time into the callback.

=cut

sub partial_solve {
    my ($self, $tree, $cb, @rest) = @_;

    my @res;

    my ($last, $ea, $skip_next) = (0, $self->{'operators'}[1], 0);
    foreach my $entry ( @$tree ) {
        $skip_next-- and next if $skip_next > 0;
        unless ( ref $entry ) {
            $ea = lc $entry;
            unless ( ref $last ) {
                $skip_next++ if
                       ( $last && $ea eq $self->{'operators'}[1])
                    || (!$last && $ea eq $self->{'operators'}[0]);
            } else {
                push @res, $entry;
            }
            next;
        }

        if ( ref $entry eq 'ARRAY' ) {
			# op
            $last = $self->partial_solve( $entry, $cb, @rest );
            #$last = $self->solve( $entry, $cb, @rest );
            # drop parens with one condition inside
            $last = $last->[0] if ref $last && @$last == 1;
        } else {
            $last = $cb->( $entry, @rest );
            $last = $entry unless defined $last;
        }
        unless ( ref $last ) {
            if ( $ea eq $self->{'operators'}[0] ) {
                # (...) AND 0
                unless ( $last ) { @res = () } else { pop @res };
            }
            elsif ( $ea eq $self->{'operators'}[1] ) {
                # (...) OR 1
                if ( $last ) { @res = () } else { pop @res };
            }
            elsif ( $ea eq $self->{'operators'}[2] ) {
				# NOT 1
                if ( $last ) { @res = () } else { pop @res };
				# NOT 0
                unless ( $last ) { @res = () } else { pop @res };
			}
        } else {
            push @res, $last;
        }
    }

    return $last unless @res; # solution
    return \@res; # more than one condition
}
# }}}
# End of POD  {{{
1;

=head1 ALTERNATIVES

There are some alternative implementations available on the CPAN.

=over 4

=item L<Search::QueryParser> - similar purpose with several differences.

=item Another?

=back

=head1 AUTHORS

The authors of the initial package Parse::BooleanLogic are:

Ruslan Zakirov E<lt>ruz@cpan.orgE<gt>, Robert Spier E<lt>rspier@pobox.comE<gt>

Parse::BL was forked from Parse::BooleanLogic by op226, op226@cpan.org

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
# }}}


