use inc::Module::Install;
name 'Egg-Plugin-SessionKit';
author 'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>';
all_from 'lib/Egg/Plugin/SessionKit.pm';
version_from 'lib/Egg/Plugin/SessionKit.pm';
license      'perl';

requires 'Egg::Release' => 1.09;
requires 'CGI'          => 3.00;
requires 'Cache::Cache' => 1.05;
requires 'Digest::MD5'  => 2.30;
requires 'MIME::Base64' => 3.00;

build_requires 'Test::More';
build_requires 'Test::Pod';

use_test_base;
auto_include;
WriteAll;
