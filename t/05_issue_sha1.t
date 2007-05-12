
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

SKIP: {
eval{ require Digest::SHA1 };
skip q{ 'Digest::SHA1' is not installed. } if $@;

my $e= Egg::Helper::VirtualTest->new( prepare=> {} )->egg_context;
$e->mk_accessors(qw/id_length/);
$e->id_length(32);

my $pkg= 'Egg::Plugin::SessionKit::Issue::SHA1';
eval" require Egg::Plugin::SessionKit::Issue::SHA1 ";
ok 0 if $@;

ok my $id= &{"${pkg}::issue_id"}($e);

  };


