
use Test::More tests => 7;
use Egg::Plugin::SessionKit::Store::Base64;

my $hash= {
  test1=> 'test1',
  test2=> 'test2',
  };

ok( my $enc= Egg::Plugin::SessionKit::Store::Base64->store_encode($hash) );
ok( ! ref($enc) );
ok( my $dec= Egg::Plugin::SessionKit::Store::Base64->store_decode(\$enc) );
ok( $dec->{test1});
ok( $dec->{test2});
ok( $dec->{test1} eq 'test1' );
ok( $dec->{test2} eq 'test2' );

