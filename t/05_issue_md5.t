
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

SKIP: {
eval{ require Digest::MD5 };
skip q{ 'Digest::MD5' is not installed. } if $@;

my $e= Egg::Helper::VirtualTest->new( prepare=> {} )->egg_context;
$e->mk_accessors(qw/id_length/);
$e->id_length(32);

my $pkg= 'Egg::Plugin::SessionKit::Issue::MD5';
eval" require Egg::Plugin::SessionKit::Issue::MD5 ";
ok 0 if $@;

ok my $id= &{"${pkg}::issue_id"}($e);

  };


