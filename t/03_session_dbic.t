
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

my $dsn   = $ENV{EGG_RDBMS_DSN}        || "";
my $uid   = $ENV{EGG_RDBMS_USER}       || "";
my $psw   = $ENV{EGG_RDBMS_PASSWORD}   || "";
my $table = $ENV{EGG_RDBMS_TEST_TABLE} || 'egg_plugin_session_table';

SKIP: {
eval{ require Egg::Model::DBIC };
skip q{ 'Egg::Model::DBIC' module is not installed. } if $@;

skip q{ Data base is not setup. } unless ($dsn and $uid);

my $v= Egg::Helper::VirtualTest->new;
my $g= $v->global;
@{$g}{qw/ dbic_dsn dbic_uid dbic_psw dbic_table /}= ($dsn, $uid, $psw, $table);
$v->prepare(
  controller  => { egg_includes => [qw/ SessionKit DBIC::Transaction /] },
  config => {
    MODEL=> [ [ DBIC=> {} ] ],
    plugin_session => {
      base  => [ DBIC => { schema_name=> 'Schema', source_name=> 'Session' } ],
      store => 'Base64',
      },
    },
  create_files=> [ $v->yaml_load( join '', <DATA> ) ],
  );

my $e= $v->egg_pcomp_context;
ok my $session= $e->session;
isa_ok $session, 'HASH';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::handler';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Base::DBIC';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Store::Base64';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Bind::Cookie';
isa_ok tied(%$session), 'Egg::Plugin::SessionKit::Issue::MD5';

can_ok tied(%$session), qw/
  model
  dbic
  schema
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
  get_session_id
  _setup_session_data
  _get_session_data
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

$ENV{DBIC_TRACE}= 1;

my $dbh= $e->model('schema')->storage->dbh;
eval{
$dbh->do(<<END_ST);
CREATE TABLE $table (
  id        char(32)   primary key,
  lastmod   timestamp,
  a_session text
  );
END_ST
};

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


__DATA__
---
filename: lib/<$e.project_name>/DBIC/Schema.pm
value: |
  package <$e.project_name>::DBIC::Schema;
  use strict;
  use warnings;
  use base qw/Egg::Model::DBIC::Schema/;
  our $VERSION = '0.01';
  
  __PACKAGE__->config(
    dsn      => '<$e.dbic_dsn>',
    user     => '<$e.dbic_uid>',
    password => '<$e.dbic_psw>',
    options  => { AutoCommit => 1, RaiseError=> 1 },
    );
  
  __PACKAGE__->load_classes;
  
  1;
---
filename: lib/<$e.project_name>/DBIC/Schema/Session.pm
value: |
  package <$e.project_name>::DBIC::Schema::Session;
  use strict;
  use warnings;
  use base 'DBIx::Class';
  
  __PACKAGE__->load_components("PK::Auto", "Core");
  __PACKAGE__->table("<$e.dbic_table>");
  __PACKAGE__->add_columns(
    "id",
    {
      data_type => "character",
      default_value => undef,
      is_nullable => 0,
      size => 32,
    },
    "lastmod",
    {
      data_type => "timestamp without time zone",
      default_value => undef,
      is_nullable => 1,
      size => 8,
    },
    "a_session",
    {
      data_type => "text",
      default_value => undef,
      is_nullable => 1,
      size => undef,
    },
  );
  __PACKAGE__->set_primary_key("id");
  
  1;
