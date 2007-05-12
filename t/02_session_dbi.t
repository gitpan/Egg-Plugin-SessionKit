
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

my $dsn   = $ENV{EGG_RDBMS_DSN}        || "";
my $uid   = $ENV{EGG_RDBMS_USER}       || "";
my $psw   = $ENV{EGG_RDBMS_PASSWORD}   || "";
my $table = $ENV{EGG_RDBMS_TEST_TABLE} || 'egg_plugin_session_table';

SKIP: {
skip q{ Data base is not setup. } unless ($dsn and $uid);

eval{ require DBI };
skip q{ 'DBI' module is not installed. } if $@;

my $v= Egg::Helper::VirtualTest->new( prepare => {
  controller => { egg_includes => [qw/ SessionKit DBI::Transaction /] },
  config => {
    MODEL=> [ [ DBI=> {
      dsn      => $dsn,
      user     => $uid,
      password => $psw,
      option   => { AutoCommit=> 1, RaiseError=> 1 },
      } ] ],
    plugin_session => {
      base  => [ DBI => { dbname=> $table } ],
      store => 'Base64',
      },
    },
  } );

ok my $e= $v->egg_pcomp_context;

my $dbh= $e->model('DBI')->dbh;
eval{
$dbh->do(<<END_ST);
CREATE TABLE $table (
  id        char(32)   primary key,
  lastmod   timestamp,
  a_session text
  );
END_ST
};

ok my $session= $e->session;
isa_ok $session, 'HASH';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::handler';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Base::DBI';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Store::Base64';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Bind::Cookie';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Issue::MD5';

can_ok tied(%$session), qw/
  dbh
  dbname
  datafield
  timefield
  e
  config
  new_entry
  update_ok
  rollback
  param_name
  id_length
  session_id
  user_agent
  remote_addr
  create_time
  access_time_old
  access_time_now
  startup
  commit_ok
  mk_accessors
  mk_session_accessors
  _setup_session_data
  _get_session_data
  get_session_id
  restore
  create_session_id
  get_bind_data
  issue_check_id
  issue_id
  normalize
  set_bind_data
  output_session_id
  clear
  change
  close
  insert
  update
  DESTROY
  /;

ok my $session_id= tied(%$session)->session_id;
like $session_id, qr{^[0-9a-f]{32}$};
ok $session->{test_value}= 'session_test';
is $session->{test_value}, 'session_test';
ok my $ticket= $e->ticket_id(1);
is $ticket, $e->ticket_id;
is $ticket, $session->{session_ticket_id};
ok untie(%$session);
ok ! $session->{test_value};
ok ! $e->ticket_id;

$e->{session}= 0;
ok $cookie_name= $e->config->{plugin_session}{bind}{cookie_name};
$e->request->cookies->{$cookie_name}=
   Egg::Response::FetchCookie->new({ value=> $session_id });

ok $session2= $e->session;
is tied(%$session2)->session_id, $session_id;
ok $session2->{test_value};
is $session2->{test_value}, 'session_test';
ok $session2->{session_ticket_id};

my $ticket_name= $e->config->{plugin_session}{ticket}{param_name};
$e->request->param( $ticket_name => $ticket );
ok $e->ticket_check;

$dbh->do(qq{ DROP TABLE $table });

  };
