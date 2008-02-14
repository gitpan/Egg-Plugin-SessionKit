use Module::Build;

my $builder = Module::Build->new(

  module_name       => 'Egg::Plugin::SessionKit',
  dist_version_from => 'lib/Egg/Plugin/SessionKit.pm',
  dist_abstract     => 'lib/Egg/Plugin/SessionKit.pm',
  dist_author       => 'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>',
  license           => 'perl',

  requires => {

    'Egg::Release'         => '3.00',
    'Egg::Release::DBI'    => '0.01',
    'Egg::Release::DBIC'   => '0.01',
    'Cache::Cache'         => '1.05',
    'Data::UUID'           => '1.14',
    'Storable'             => '2.18',
    'Convert::UU'          => '0.52',
    'Time::Piece::MySQL'   => '0.05',

    'Test::More'           => 0,
    'Test::Pod'            => 0,
    'Test::Perl::Critic'   => 0,
    'Test::Pod::Coverage'  => 0,
    },

  );

$builder->create_build_script();
