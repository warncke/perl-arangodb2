use strict;
use warnings;

use Data::Dumper;
use Test::More;

use ArangoDB2;

my $res;

my $arango = ArangoDB2->new("http://localhost:8529");

my $dbname = "ngukvderybvfgjutecbxzsfhyujmnvgf";
my $database = $arango->database($dbname);
my $replication = $database->replication;

# test required methods
my @api_methods = qw(
    clusterInventory
    dump
    inventory
    serverId
    sync
);

my @methods = qw(
    chunkSize
    collection
    from
    includeSystem
    ticks
    to
);

for my $method (@methods, @api_methods) {
    can_ok($replication, $method);
}

# skip tests against the actual ArangoDB server unless
# LIVE_TEST env param is set
if (!$ENV{LIVE_TEST}) {
    diag("Skipping live API tests - set LIVE_TEST=1 to enable");
    done_testing();
    exit;
}

# delete database first in case it exists
$database->delete();
# create database
$database->create();

ok($replication->inventory, "inventory");
ok($replication->serverId, "serverId");

# need cluster set up to test these
# ok($replication->clusterInventory, "clusterInventory");
# ok($replication->dump, "dump");
# ok($replication->sync, "sync");

# delete database
$database->delete;

done_testing();
