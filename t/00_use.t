
use Test::More tests => 6;
BEGIN {
  use_ok('Egg::Plugin::SessionKit');
  use_ok('Egg::Plugin::SessionKit::Bind::Cookie');
  use_ok('Egg::Plugin::SessionKit::Issue::MD5');
  use_ok('Egg::Plugin::SessionKit::Issue::UniqueID');
  use_ok('Egg::Plugin::SessionKit::Store::Plain');
  use_ok('Egg::Plugin::SessionKit::Store::Base64');
  };
