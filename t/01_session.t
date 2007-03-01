
use Test::More tests=> 18;
use Egg::Helper;

my $t= Egg::Helper->run('O:Test');
$t->prepare( controller=> { egg=> 'SessionKit' } );
my $e= $t->egg_virtual;

ok( my $session= $e->session );
ok( ref($session) eq 'HASH' );
ok( ref(tied(%$session)) eq 'Egg::Plugin::SessionKit::handler' );
ok( $session->{test_value}= 'session_test' );
ok( $session->{test_value} eq 'session_test' );
ok( my $ticket= $e->ticket_id(1) );
ok( $ticket eq $e->ticket_id );
ok( $ticket eq $session->{session_ticket_id} );
ok( my $session_id= tied(%$session)->session_id );
ok( untie(%$session) );
ok( ! $session->{test_value} );
ok( ! $e->ticket_id );
my $conf = $e->config->{plugin_session}{base};
my $cache= Cache::FileCache->new($conf);
ok( my $hash= $cache->get($session_id) );
ok( ref($hash) eq 'HASH' );
ok( $hash->{test_value} );
ok( $hash->{test_value} eq 'session_test' );
ok( $hash->{session_ticket_id} );
ok( $ticket eq $hash->{session_ticket_id} );
