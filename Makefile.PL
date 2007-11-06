use inc::Module::Install;

name          'Egg-Plugin-SessionKit';
all_from      'lib/Egg/Plugin/SessionKit.pm';
abstract_from 'lib/Egg/Plugin/SessionKit.pm';
version_from  'lib/Egg/Plugin/SessionKit.pm';
author        'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>';
license       'perl';

requires 'Cache::Cache'             => 1.05;
requires 'Class::Data::Inheritable' => 0.06;
# requires 'Data::UUID'               => 1.14;
requires 'Digest::MD5'              => 2.36;
requires 'Digest::SHA1'             => 2.11;
requires 'MIME::Base64'             => 3.07;
requires 'Egg::Release'             => 2.25;
requires 'Egg::Plugin::IxHash'      => 2.03;
# requires 'Egg::Model::DBIC'         => 2.03;

build_requires 'Test::More';
build_requires 'Test::Pod';
build_requires 'Test::Perl::Critic';
build_requires 'Test::Pod::Coverage';

use_test_base;
auto_include;
WriteAll;
