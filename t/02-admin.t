use strict;
use warnings;

use Data::Dumper;
use Test::More;

use ArangoDB2;

my $res;

my $arango = ArangoDB2->new("http://localhost:8529");
my $admin = $arango->admin;

isa_ok($admin, 'ArangoDB2::Admin');

# test required methods
my @methods = qw(
    echo
);

for my $method (@methods) {
    can_ok($admin, $method);
}

# skip tests against the actual ArangoDB2 server unless
# LIVE_TEST env param is set
if (!$ENV{LIVE_TEST}) {
    diag("Skipping live API tests - set LIVE_TEST=1 to enable");
    done_testing();
    exit;
}

done_testing();
