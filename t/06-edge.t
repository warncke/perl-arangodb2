use strict;
use warnings;

use Data::Dumper;
use Test::More;

use ArangoDB2;

my $res;

my $arango = ArangoDB2->new("http://localhost:8529");

my $dbname = "ngukvderybvfgjutecbxzsfhyujmnvgf";
my $database = $arango->database($dbname);
my $collection = $database->collection('test');
my $edge = $collection->edge();
isa_ok($edge, 'ArangoDB2::Edge');

# test required methods
my @methods = qw(
    create
    data
    delete
    get
    head
    list
    patch
    replace
    rev
);

for my $method (@methods) {
    can_ok($edge, $method);
}

# skip tests against the actual ArangoDB2 server unless
# LIVE_TEST env param is set
if (!$ENV{LIVE_TEST}) {
    diag("Skipping live API tests - set LIVE_TEST=1 to enable");
    done_testing();
    exit;
}

# create database
$database->create();
# create edge collection
$res = $collection->create({type => "edge"});
# create document collection
my $collection2 = $database->collection('test2');
$collection2->create();
# create some documents
my $doc1 = $collection2->document;
$doc1->create({test => "test"});
my $doc2 = $collection2->document;
$doc2->create({test => "test"});
# create edge
$res = $edge->to($doc1)->from($doc2)->create(
    {test => "test"},
);
ok($res->{_key}, "create: edge created");
ok($edge->to, "create: to set");
ok($edge->from, "create: from set");
is($res->{_key}, $edge->name, "create: name set");
is($res->{_rev}, $edge->rev, "create: rev set");
is_deeply($edge->data, {test => "test"}, "create: local data set");
is($edge, $collection->edge($res->{_key}), "create: edge registered");
# get edges
$res = $doc1->edges($collection);
ok(@{$res->{edges}}, "edges");
$res = $doc1->edges($collection, {direction => "in"});
ok(@{$res->{edges}}, "edges in");
$res = $doc1->edges($collection, {direction => "out"});
ok(!@{$res->{edges}}, "edges out");
$res = $doc2->edges($collection);
ok(@{$res->{edges}}, "edges");
$res = $doc2->edges($collection, {direction => "in"});
ok(!@{$res->{edges}}, "edges in");
$res = $doc2->edges($collection, {direction => "out"});
ok(@{$res->{edges}}, "edges out");
# get edge
$res = $edge->get();
is_deeply($edge->data, {test => "test"}, "get: local data set");
is($res->{_rev}, $edge->rev, "get: rev set");
ok($edge->to, "create: to set");
ok($edge->from, "create: from set");
# delete edge from register so we can get get it again
delete $collection->edges->{test};
# get edge from name (_key)
$edge = $collection->edge($res->{_key});
is_deeply($edge->data, {test => "test"}, "new(name): local data set");
ok($edge->to, "create: to set");
ok($edge->from, "create: from set");
# replace
$res = $edge->replace({test2 => "test2"});
is_deeply($edge->data, {test2 => "test2"}, "replace: local data set");
is($res->{_rev}, $edge->rev, "replace: rev set");
# patch
$res = $edge->patch({test3 => "test3"});
is($edge->data->{test2}, "test2", "patch: local data set");
is($edge->data->{test3}, "test3", "patch: local data set");
is($res->{_rev}, $edge->rev, "patch: rev set");
# head
$res = $edge->head();
is($res, 200, "head: edge exists");
# list
$res = $collection->edge->list();
ok($res->{documents}, "list");
# delete
$res = $edge->delete();
is_deeply($edge->data, {}, "delete: local data deleted");
ok(!$edge->rev, "delete: local rev deleted");
# try getting again
$edge = $collection->edge($res->{_key});
ok(!$edge->rev, "delete: edge deleted");


# delete
$res = $collection->delete();
# delete database
$res = $arango->database($dbname)->delete();

done_testing();
