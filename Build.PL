use Module::Build;

my $builder = Module::Build->new(
  module_name => 'Egg::Plugin::SessionKit',
  dist_author => 'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>',
  dist_version_from=> 'lib/Egg/Plugin/SessionKit.pm',
  license => 'perl',
  requires => {
    'Egg::Release' => 1.09,
    'CGI'          => 3.00,
    'Cache::Cache' => 1.05,
    'Digest::MD5'  => 2.30,
    'MIME::Base64' => 3.00,
    'Test::More'   => 0,
    'Test::Pod'    => 0,
    },
  );

$builder->create_build_script();
