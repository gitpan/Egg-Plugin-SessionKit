
use Test::More qw/no_plan/;

SKIP: {
eval{ require Data::UUID };
skip q{ 'Data::UUID' is not installed. } if $@;

my $pkg= 'Egg::Plugin::SessionKit::Issue::UUID';

eval" require $pkg ";
ok 0 if $@;

ok my $id= $pkg->issue_id;
ok $pkg->issue_check_id($id);

  };

