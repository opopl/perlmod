package Report::Trades;

use strict;
use warnings;

###use
use Env qw($hm PERLMODDIR);

use FindBin qw( $Bin $Script );
use DBI;
use Data::Dumper;
use DBD::Pg;
use Pod::Usage;
use Getopt::Long;
use IO::String;

use lib("$PERLMODDIR/mods/Report-Trades/lib/");
use Report::Trades::App;

use parent qw( Class::Accessor::Complex );

###__ACCESSORS_SCALAR
our @scalar_accessors = qw(
  dbh
  dbname
  dbfile
  dbdata
  dbuser
  fh_pod_help
  sth
  taskid
  webapp
);

# dbh       - DBI database handler
# dbname    - name of the database, as understood by PostgreSQL
# dbfile    - full path to the dump of the database
# dbuser    - name of the user who connects to the database

###__ACCESSORS_HASH
our @hash_accessors = qw(
  dbattr
  opt
  optdesc
  tasks
  trades
  table_columns
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
  optstr
  table_names
);

__PACKAGE__->mk_scalar_accessors(@scalar_accessors)
  ->mk_array_accessors(@array_accessors)->mk_hash_accessors(@hash_accessors);

sub main {
    my $self = shift;

    $self->init_vars;
    $self->get_opt;
    $self->process_opt;

    $self->run;

    $self->finish;

}

sub db_list_trades {
    my $self = shift;

    my @query = ();

    $self->db_exec_query(
        "SELECT * FROM public.trades",
    );

    while ( my @a = $self->sth->fetchrow_array ) {
        print join(' ',@a) . "\n";
    }

}

sub db_list_tables {
    my $self = shift;

    my @query = ();

    $self->db_exec_query(
        " SELECT table_name, table_schema ",
        "   FROM information_schema.tables ",
    );

    while ( my $ref = $self->sth->fetchrow_hashref ) {
        my ( $tablename) =
          ( $ref->{'table_name'}, $ref->{'table_schema'});
        print "$tablename\n";
    }

}

sub runweb {
    my $self = shift;

    $self->webapp(Report::Trades::App->new);

    $self->webapp->start;

}

sub load_db {
    my $self=shift;

    $self->load_dump if $self->dbfile;

    $self->db_connect if $self->dbname;
}

sub run {
    my $self = shift;

    # connect to the database;
    #   if necessary, restore beforehand the dumped database
    $self->load_db;

    $self->print_dbinfo if $self->opt('dbinfo');

    foreach my $id  ( $self->table_names ) {
	    if ( $self->opt('list_' . $id) ) {
	        eval '$self->db_list_' . $id;
	        $self->finish;
	        exit 0;
	    }
    }

    $self->runweb if $self->opt('webserver');

}

sub get_opt {
    my $self = shift;

    Getopt::Long::Configure(
        qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always)
    );

    my %opt;

    unless (@ARGV) {

        #$self->dhelp;
        #exit 0;
    }
    else {
        GetOptions( \%opt, $self->optstr );
    }
    $self->opt(%opt);

    $self->dhelp if $self->opt('help');

}

sub dhelp {
    my $self = shift;

    pod2usage( 
        -input => $self->fh_pod_help, 
        -verbose => 2 
    );

}

sub init_vars {
    my $self = shift;

    my $a = {
        RaiseError => 1,
        AutoCommit => 0,
    };

    $self->dbattr($a);

    $self->init_pod;


}

sub init_pod {
    my $self = shift;

    $self->optstr(
        qw(
          help
          man
          dbname=s
          dbfile=s
          list_tables
          list_trades
          list_symbols
          taskid
          dbinfo
          webserver
          )
    );

    $self->optdesc(
        "help"        => "Display help message",
        "man"               => "Display man page",
        "dbname"            => "PostgreSQL database name to be loaded",
        "dbfile"            => "PostgreSQL database dump file to be restored",
        "list_tables"       => "List available tables",
        "list_trades"       => "",
        "list_symbols"      => "",
        "taskid"            => "Select task id",
        "dbinfo"            => "Show short database info",
        "webserver"         => "Run web-server (Mojolicious-based)",
    );

    my @pod_text;

    # prepare help message string in POD
    #   to do this, we need to use IO::String, which
    #   allows one to treat strings as filehandles, so that
    #   we could pass them further to Pod::Text parser's filter function.

    push( @pod_text, '=head1 NAME' );
    push( @pod_text, ' ' );
    push( @pod_text,
        ' ' . $Script . " - Perl script for PostgreSQL database reporting." );
    push( @pod_text, ' ' );
    push( @pod_text, '=head1 PURPOSE' );
    push( @pod_text, ' ' );
    push( @pod_text, '=head1 USAGE' );
    push( @pod_text, ' ' );
    push( @pod_text, '=head1 COMMAND-LINE OPTIONS' );
    push( @pod_text, ' ' );
    push( @pod_text, '=over ' );
    push( @pod_text, ' ' );
    foreach my $opt ( $self->optstr ) {
        ( my $optname = $opt ) =~ s/=s$//g;
        push( @pod_text,
            '=item --' . $optname . ' ' . $self->optdesc($optname) );
        push( @pod_text, ' ' );
    }
    push( @pod_text, '=back ' );
    push( @pod_text, ' ' );
    push( @pod_text, '=head1 EXAMPLES' );
    push( @pod_text, ' ' );
    push( @pod_text, '=over' );
    push( @pod_text, ' ' );

    push( @pod_text, '=back' );
    push( @pod_text, ' ' );

    my $fh = IO::String->new( join( "\n", @pod_text ) );

    $self->fh_pod_help($fh);

}


sub print_dbinfo {
    my $self=shift;

    print '=' x 50 . "\n";

    print "Database name: " . $self->dbname . "\n";
    print "Available tables within the database:\n";
    print ' ' . join(' ',$self->table_names) . "\n";

    print "Available columns for each database are:\n";
    foreach my $table_name ($self->table_names) {
        print "  table: $table_name\n";
        foreach my $col ( @{$self->table_columns($table_name)} ){
                print "     $col\n"  ;
        }
    }

    print '=' x 50 . "\n";

}

sub process_opt {
    my $self = shift;

    my %opt = $self->opt;

    $self->dbname( $opt{dbname} // $ENV{PGDATABASE} );

    unless ( $self->dbname ) {
        die "No database name provided";
    }

    foreach my $x (qw( taskid )) {
        eval '$self->' . $x . '($self->opt("' . $x . '"))';
        die $@ if $@;
    }

}

sub load_dump {
    my $self = shift;

}

sub db_connect {
    my $self = shift;

    my $data_source = 'dbi:Pg:dbname=' . $self->dbname;
    my $attr        = $self->dbattr;

    $self->dbh( DBI->connect( $data_source, '', '', $attr ) )
      or die "Unable to connect to the database: "
      . $self->dbname
      . " $DBI::errstr ";

    # retrieve available table names
    $self->db_exec_query(
            "select table_name",
            "    from information_schema.tables",
            "    where table_schema='public'",
        );

    my @tables;
    while (my @a=$self->sth->fetchrow_array) {
            push(@tables,@a);
    }
    $self->table_names(@tables); 

    # retrieve column names for each available table
    foreach my $table_name ($self->table_names) {
        my $q="select column_name from information_schema.columns where table_name='$table_name'";
        $self->db_exec_query($q);

        my @cols;
        while (my @a=$self->sth->fetchrow_array) {
            push(@cols,@a);
        }
        $self->table_columns( $table_name  => \@cols ); 
    }

}

sub db_exec_query {
    my $self = shift;

    my $query = join( "\n", @_ ) . '' ;

    $self->sth( $self->dbh->prepare($query) );

    my $rv = $self->sth->execute;

    unless ( defined $rv ) {
        print "Error while executing '$query': " . $self->dbh->errstr . "\n";
        exit(0);
    }

}

sub finish {
    my $self = shift;

    $self->sth->finish;
    $self->dbh->disconnect;
}

#Вот небольшое тестовое задание. Используя его, мы сможет увидеть Ваш уровень в:
#- разработке web приложений на Perl
#- анализе баз данных
#- умении обрабатывать big data(в базе всего несколько дней торгов, но она уже не самая маленькая)
#- подход к реализации продуманного и удобного UI, способного решать задачи, а не отвлекать.

#Во вложении - схема данных и сами данные(PostgreSQL 9), образец отчета.

#Так же хочу услышать оценки по срокам реализации.

#Есть приложение, выполняющие торговые операции(купля-продажа) согласно заранее заданным параметрам(таблица tasks). В течении рабочего для система выполняет операции купли-продажи и сохраняет результат(таблица trades). За один день одна стратегия(tasks) может создать много сделок(trades).
#Задача:
#1. Проанализировать базу данных и провести оптимизацию(если она нужна)

#2. Построить приложение генератор отчетов на основе Catalyst или Mojo(или уже на чем получится):
#2.1 Пользователь зашел на index и видит статистику торгов за сегодня по всем задачам(tasks). Статистика должна включать в себя сумму всех сделок(trades) за сегодня, а так же суммарный PnL за сегодня(trades.pl)
#2.2 Пользователь должен иметь возможность просмотреть все сделки для сегодня для выбранной стратегии
#2.3 Пользователь должен иметь возможность ввести дату по которой должен быть построен отчет и система должна перестроить index.
#2.4 Пользователь должен иметь возможность просматривать все сделки по стратегии за конкретную дату.

1;
