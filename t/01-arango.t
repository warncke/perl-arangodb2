use strict;
use warnings;

use Data::Dumper;
use Test::More;

use ArangoDB;

my $res;

my $arango = ArangoDB->new("http://localhost:8529");

# test required methods
my @methods = qw(
    admin
    database
    databases
    http
    uri
    version
);

for my $method (@methods) {
    can_ok($arango, $method);
}

# test for sub objects accessors
isa_ok($arango->admin, 'ArangoDB::Admin');
isa_ok($arango->database, 'ArangoDB::Database');
isa_ok($arango->http, 'ArangoDB::HTTP');
isa_ok($arango->uri, 'URI');

# skip tests against the actual ArangoDB server unless
# LIVE_TEST env param is set
if (!$ENV{LIVE_TEST}) {
    diag("Skipping live API tests - set LIVE_TEST=1 to enable");
    done_testing();
    exit;
}

# api methods
$res = $arango->version;

ok(defined $res->{version}, "version: version");
ok(defined $res->{server}, "version: server");

done_testing();
