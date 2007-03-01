
use Test::More tests => 8;
BEGIN {
  use_ok('Egg::Plugin::SessionKit');
  use_ok('Egg::Plugin::SessionKit::TieHash');
  use_ok('Egg::Plugin::SessionKit::Base::FileCache');
  use_ok('Egg::Plugin::SessionKit::Bind::Cookie');
  use_ok('Egg::Plugin::SessionKit::Issue::MD5');
  use_ok('Egg::Plugin::SessionKit::Issue::UniqueID');
  use_ok('Egg::Plugin::SessionKit::Store::Plain');
  use_ok('Egg::Plugin::SessionKit::Store::Base64');
  };

