use Module::Build;

my $builder = Module::Build->new(

  module_name       => 'Egg::Plugin::SessionKit',
  dist_version_from => 'lib/Egg/Plugin/SessionKit.pm',
  dist_abstract     => 'lib/Egg/Plugin/SessionKit.pm',
  dist_author       => 'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>',
  license           => 'perl',

  requires => {

    'Cache::Cache'             => 1.05,
    'Class::Data::Inheritable' => 0.06,
#    'Data::UUID'               => 1.14,
    'Digest::MD5'              => 2.36,
    'Digest::SHA1'             => 2.11,
    'MIME::Base64'             => 3.07,
    'Egg::Release'             => 2.25,
    'Egg::Plugin::IxHash'      => 2.03,
#    'Egg::Model::DBIC'         => 2.03,

    'Test::More'           => 0,
    'Test::Pod'            => 0,
    'Test::Perl::Critic'   => 0,
    'Test::Pod::Coverage'  => 0,
    },

  );

$builder->create_build_script();
