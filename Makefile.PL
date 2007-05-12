use inc::Module::Install;

name         'Egg-Plugin-SessionKit';
all_from     'lib/Egg/Plugin/SessionKit.pm';
version_from 'lib/Egg/Plugin/SessionKit.pm';
author       'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>';
license      'perl';

requires 'Egg::Release'     => 2.00;
requires 'Egg::Model::DBIC' => 2.00;
requires 'Cache::Cache'     => 1.05;
requires 'MIME::Base64'     => 3.07;
requires 'Storable'         => 2.16;
requires 'Digest::SHA1'     => 2.11;
requires 'Data::UUID'       => 1.14;

build_requires 'Test::Simple';
build_requires 'Test::Pod';
build_requires 'Test::Perl::Critic';
build_requires 'Test::Pod::Coverage';

use_test_base;
auto_include;
WriteAll;
