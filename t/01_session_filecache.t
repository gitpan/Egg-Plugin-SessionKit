
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

SKIP: {
eval{ require Cache::FileCache };
skip q{ 'Cache::FileCache' is not installed. } if $@;

my $v= Egg::Helper::VirtualTest->new( prepare=> {
  controller=> { egg_includes=> [qw/ SessionKit /] },
  });

ok my $e= $v->egg_pcomp_context;
ok my $session= $e->session();
isa_ok $session, 'HASH';
isa_ok $session, 'Egg::Plugin::SessionKit::handler';
can_ok $session, qw/
  session_id session_ticket access_time_now access_time_old
  new context e conf attr is_handler is_update is_newentry
  change clear create_id
  __sessionkit_config __sessionkit_name_conv
  /;

ok my $context= $session->context;
isa_ok $context, 'Egg::Plugin::SessionKit::handler::TieHash';
isa_ok $context, 'Egg::Plugin::SessionKit::Base::FileCache';
isa_ok $context, 'Egg::Plugin::SessionKit::Bind::Cookie';
isa_ok $context, 'Egg::Plugin::SessionKit::Store::Plain';
isa_ok $context, 'Egg::Plugin::SessionKit::base';
can_ok $context, qw/
  e conf attr mod_conf parent
  is_update is_newentry is_rollback is_output_id is_session_id
  agent_key_name addr_key_name
  TIEHASH STORE initialize normalize
  create_session_id output_session_id issue_id
  commit_ok insert update restore set_bind_data get_bind_data
  startup DESTROY
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

