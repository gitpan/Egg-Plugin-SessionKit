use Module::Build;

my $builder = Module::Build->new(

  module_name       => 'Egg::Plugin::SessionKit',
  dist_version_from => 'lib/Egg/Plugin/SessionKit.pm',
  dist_author       => 'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>',
  license           => 'perl',

  requires => {

    'Egg::Release'     => 2.00,
    'Egg::Model::DBIC' => 2.00,
    'Cache::Cache'     => 1.05,
    'MIME::Base64'     => 3.07,
    'Storable'         => 2.16,
    'Digest::SHA1'     => 2.11,
    'Data::UUID'       => 1.14,

    'Test::Simple'          => 0,
    'Test::Pod'             => 0,
    'Test::Perl::Critic'    => 0,
    'Test::Pod::Coverage'   => 0,
    },

  );

$builder->create_build_script();
