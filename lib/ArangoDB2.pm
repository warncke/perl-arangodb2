package ArangoDB2;

use strict;
use warnings;

our $VERSION = '0.02';

use URI;

use ArangoDB2::Admin;
use ArangoDB2::Database;
use ArangoDB2::HTTP;



# new
#
# create new ArangoDB2 instance from string argument specifying
# API endpoint or hashref of args
sub new
{
    my $class = shift;
    # create instance
    my $self = {};
    bless($self, $class);
    # for now only accept single string arg
    $self->uri(@_);

    return $self;
}

# admin
#
# ArangoDB2::Admin object which provides access to methods in
# the /_admin group
sub admin
{
    my($self) = @_;

    return $self->{admin} ||= ArangoDB2::Admin->new($self);
}

# database
#
# ArangoDB2::Database object which provides access to methods
# in the /_api/database group
sub database
{
    my($self, $name) = @_;
    # default database for arango is _system
    $name ||= "_system";
    # only create one instance per ArangoDB2 per database, each ArangoDB2
    # keeps its own instances since they may have different credentials
    return $self->databases->{$name} ||= ArangoDB2::Database->new($self, $name);
}

# databases
#
# Index of active ArangoDB2::Database objects by name
sub databases { $_[0]->{databases} ||= {} }

# http
#
# ArangoDB2::HTTP object.  This provides normalized interface to
# various HTTP clients.
sub http
{
    my($self, $http) = @_;

    $self->{http} = $http
        if defined $http;

    return $self->{http} ||= ArangoDB2::HTTP->new($self);
}

# uri
#
# get/set URI for API
sub uri
{
    my($self, $uri) = @_;

    $self->{uri} = URI->new($uri)
        if defined $uri;

    return $self->{uri};
}

# version
#
# GET /_api/version
#
# Returns the server name and version number. The response is a JSON object with the following attributes:
#
# server: will always contain arango
# version: the server version string. The string has the format "major.minor.sub". major and minor will be numeric, and sub may contain a number or a textual version.
# details: an optional JSON object with additional details. This is returned only if the details URL parameter is set to true in the request.
sub version
{
    my($self) = @_;

    return $self->http->get('/_api/version');
}

1;

__END__

=head1 NAME

ArangoDB2 - ArangoDB2 HTTP API Interface

=head1 SYNOPSIS

my $arango = ArangoDB2->new("http://localhost:8259");

my $database = $arango->database("test");
my $collection = $database->collection("test");
my $document = $collection->document();

# create a new document
$document->create({hello => world});
# update existing document
$document->patch({foo => bar});

=head1 DESCRIPTION

ArangoDB2 provides an interface to the ArangoDB database.

The Collection and Document APIs are 100% implemented, with the exception of
support for ETag based conditional operations.

This is very alpha, so expect significant additions and potentially changes.

See the official docs for details on the API: L<https://docs.arangodb.com>

=head1 METHODS

=over 4

=item new

=item admin

=item database

=item databases

=item http

=item uri

=item version

=back

=head1 SEE ALSO

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
