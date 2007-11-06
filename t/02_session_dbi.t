
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

my $dsn   = $ENV{EGG_RDBMS_DSN}      || "";
my $uid   = $ENV{EGG_RDBMS_USER}     || "";
my $psw   = $ENV{EGG_RDBMS_PASSWORD} || "";
my $table = $ENV{EGG_SESSION_TABLE}  || 'sessions';

#$ENV{DBI_TRACE}= 1;

SKIP: {
skip q{ Data base is not setup. } unless ($dsn and $uid);

eval{ require DBI };
skip q{ 'DBI' module is not installed. } if $@;

my $v= Egg::Helper::VirtualTest->new( prepare => {
  controller => {
    egg_includes => [qw/ DBI::Transaction SessionKit /],
    },
  config => {
    MODEL=> [ [ DBI=> {
      dsn      => $dsn,
      user     => $uid,
      password => $psw,
      option   => { AutoCommit=> 1, RaiseError=> 1 },
      } ] ],
    plugin_session => {
      component=> [
        [ 'Base::DBI'=> {
          dbname     => $table,
          data_field => 'a_session',
          time_field => 'access_date', #'lastmod',
          } ],
        qw/ Bind::Cookie Store::Base64 /,
        ],
      },
    },
  } );

ok my $e= $v->egg_pcomp_context;
ok my $session= $e->session;
isa_ok $session, 'HASH';
isa_ok $session, 'Egg::Plugin::SessionKit::handler';

ok my $context= $session->context;
isa_ok $context, 'Egg::Plugin::SessionKit::handler::TieHash';
isa_ok $context, 'Egg::Plugin::SessionKit::Base::DBI';
isa_ok $context, 'Egg::Plugin::SessionKit::Bind::Cookie';
isa_ok $context, 'Egg::Plugin::SessionKit::Store::Base64';
isa_ok $context, 'Egg::Plugin::SessionKit::base';
can_ok $context, qw/
  startup TIEHASH restore insert update commit_ok DESTROY
  /;

ok my $ssid= $context->is_session_id;
ok $session->{test}= '12345';
is $session->{test}, '12345';

undef $context;

ok $e->session_close, 'close';
ok $session= $e->session($ssid);
is $session->{test}, '12345';
ok my $cookie= $e->response->cookies->{ss};
is $cookie->{value}, $ssid;

  };
