use strict;
use warnings;

use Data::Dumper;
use Test::More;

use ArangoDB;

my $res;

my $arango = ArangoDB->new("http://localhost:8529");

my $dbname = "ngukvderybvfgjutecbxzsfhyujmnvgf";
my $database = $arango->database($dbname);
my $collection = $database->collection('test');
my $document = $collection->document();
isa_ok($document, 'ArangoDB::Document');

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
    can_ok($document, $method);
}

# skip tests against the actual ArangoDB server unless
# LIVE_TEST env param is set
if (!$ENV{LIVE_TEST}) {
    diag("Skipping live API tests - set LIVE_TEST=1 to enable");
    done_testing();
    exit;
}

# create database
$database->create();
# create collection
$res = $collection->create();
# create document
$res = $document->create({test => "test"});
ok($res->{_key}, "create: document created");
is($res->{_key}, $document->name, "create: name set");
is($res->{_rev}, $document->rev, "create: rev set");
is_deeply($document->data, {test => "test"}, "create: local data set");
is($document, $collection->document($res->{_key}), "create: document registered");
# get document
$res = $document->get();
is_deeply($document->data, {test => "test"}, "get: local data set");
is($res->{_rev}, $document->rev, "get: rev set");
# delete document from register so we can get get it again
delete $collection->documents->{test};
# get document from name (_key)
$document = $collection->document($res->{_key});
is_deeply($document->data, {test => "test"}, "new(name): local data set");
# replace
$res = $document->replace({test2 => "test2"});
is_deeply($document->data, {test2 => "test2"}, "replace: local data set");
is($res->{_rev}, $document->rev, "replace: rev set");
# patch
$res = $document->patch({test3 => "test3"});
is($document->data->{test2}, "test2", "patch: local data set");
is($document->data->{test3}, "test3", "patch: local data set");
is($res->{_rev}, $document->rev, "patch: rev set");
# head
$res = $document->head();
is($res, 200, "head: document exists");
# list
$res = $collection->document->list();
ok($res->{documents}, "list");
# delete
$res = $document->delete();
is_deeply($document->data, {}, "delete: local data deleted");
ok(!$document->rev, "delete: local rev deleted");
# try getting again
$document = $collection->document($res->{_key});
ok(!$document->rev, "delete: document deleted");


# delete
$res = $collection->delete();
# delete database
$res = $arango->database($dbname)->delete();

done_testing();
