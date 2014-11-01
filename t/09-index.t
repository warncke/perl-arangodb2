use strict;
use warnings;

use Data::Dumper;
use Test::More;

use ArangoDB2;

my $res;

my $arango = ArangoDB2->new("http://localhost:8529");

my $dbname = "ngukvderybvfgjutecbxzsfhyujmnvgf";
my $database = $arango->database($dbname);
my $collection = $database->collection('places');
my $index = $collection->index();

isa_ok($index, 'ArangoDB2::Index');

# test required methods
my @methods = qw(
    new
    get
);

for my $method (@methods) {
    can_ok($index, $method);
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
#create collection
$res = $collection->create();

# create some data



# delete
$res = $collection->delete();
# delete database
$res = $arango->database($dbname)->delete();

done_testing();
