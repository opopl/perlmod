package Report::Trades;

use strict;
use warnings;

use feature qw(switch);

###use
use FindBin qw( $Bin $Script );
use DBI;
use Data::Dumper;
use DBD::Pg;
use Pod::Usage;
use Getopt::Long;
use IO::String;
use HTML::Table;
use File::Slurp qw( write_file );

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
  format
  ofile
);

# dbh       - DBI database handler
# dbname    - name of the database, as understood by PostgreSQL
# dbfile    - full path to the dump of the database
# dbuser    - name of the user who connects to the database
# format    - output format for the command-line application. 
#               Possible values: text, html
# ofile     - name of the file where generated output will be printed to 

###__ACCESSORS_HASH
our @hash_accessors = qw(
  dbattr
  opt
  optdesc
  table_columns
);

###__ACCESSORS_ARRAY
our @array_accessors = qw(
  optstr
  table_names
  taskids
);

# optstr        - list of command-line options, as accepted by Getopt::Long
# taskids       - list of available task ids
# table_names   - list of available tables

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

sub db_dump_trades_all {
    my $self = shift;


    foreach my $task ($self->taskids) {
	    $self->db_print_select(
	        cols  => [ qw( * ) ],
	        from  => "trades",
	        where => "task_id = '$task'",
	    );
    }

}

sub db_list_trades {
    my $self = shift;

    my @query = ();
    my $task=$self->taskid;

    my $ref={
        cols        => [qw( * )],
        table       => "trades",
        where       => "task_id = '$task'",
        format      => $self->format,
    };

    $ref->{ofile}=$self->ofile if $self->ofile;

    $self->db_print_select( %$ref );

}

sub db_print_select {
    my $self=shift;

    my %opts=@_;

    my @str=();

    my $table_name=$opts{table} // '';

    # output format, currently supported: text, html
    #   default is 'text' ;
    my $format=$opts{format} // 'text';

    my @cols=@{$opts{cols}};
    my $colnames=$self->table_columns($table_name);
    
    push(@str,'SELECT ' . join(',', @cols ));
    push(@str,' FROM public.' . $table_name );
    push(@str,' WHERE ' . $opts{where} );

    my $q=join(' ',@str);
    $self->db_exec_query( $q );

    my $rows;
    while ( my $a = $self->sth->fetchrow_arrayref ) {
        push(@$rows, $a);
    }

    my $text;
    given($format){
        when('text') { 
            foreach my $row (@$rows) {
                $text.=join(' ',@$row) . "\n";
            }
        }
        when('html') { 
            my $header=$colnames;
            my $table=HTML::Table->new(
              -cols     =>  scalar @$colnames,
              -head     =>  $header,
              -data     =>  $rows,
              -align    =>  'center',
              -rules    =>  'rows',
              -border   =>  0,
              -bgcolor  =>  'white',
              -width    =>  '50%',
              -spacing  =>  0,
              -padding  =>  0,
              -style    =>  'color: black',
          );

          $text=$table . "\n";
        }
        default { }
    }
    # output filehandle where to send output
    #   by default print to standard output
    my $fh=$opts{out} // \*STDOUT;

    if( defined $opts{ofile} ){
        write_file($opts{ofile},$text);
    }else{
        print $fh,  $text;
    }
}

sub db_list_tables {
    my $self = shift;

    my @query = ();

    foreach my $table_name ($self->table_names) {
        print $table_name . "\n";
    }

}

sub runweb {
    my $self = shift;

    require Mojolicious::Commands;
    my $commands=Mojolicious::Commands->new;
    push @{$commands->namespaces}, 'Report::Trades::App::Command';

    $commands->run('daemon');

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
        print "Try --help for more help\n";
        exit 0;
    }
    else {
        GetOptions( \%opt, $self->optstr );
    }
    $self->opt(%opt);

    $self->dhelp if $self->opt('help');

}

sub dhelp {
    my $self = shift;

    my $lev = shift;

    pod2usage( 
        -input      => $self->fh_pod_help, 
        -verbose    => 2,
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

    # output format for the command-line part of the 
    #   application
    $self->format('text');

}

sub init_pod {
    my $self = shift;

    $self->optstr(
        qw(
          help
          dbname=s
          dbfile=s
          format=s
          list_tables
          list_trades
          dump_trades_all
          taskid=s
          ofile=s
          list_symbols
          dbinfo
          webserver
          )
    );

    $self->optdesc(
        "help"              => "Display this help message",
        "dbname"            => "PostgreSQL database name to be loaded",
        "dbfile"            => "PostgreSQL database dump file to be restored",
        "list_tables"       => "List available tables",
        "list_trades"       => "",
        "list_symbols"      => "",
        "ofile"             => "Write generated content to a specified file, "
                                        . " instead of sending it to standard output",
        "dump_trades_all"   => "",
        "format"            => "Output format for the command-line application",
        "taskid"            => "Select task id",
        "dbinfo"            => "Show short database info",
        "webserver"         => "Run web-server (Mojolicious-based)"
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
    my @ex=();

    push(@ex,'--taskid 1000 --list_trades');
    push(@ex,'--taskid 1000 --list_trades --format html --ofile 1000.html');

    push( @pod_text, map { "$_" ? '=item ' . $Script . ' ' . "$_\n" : () } @ex);  
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

    foreach my $x (qw( taskid format ofile )) {
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
