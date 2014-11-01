package ArangoDB2::Collection;

use strict;
use warnings;

use base qw(
    ArangoDB2::Base
);

use Data::Dumper;
use JSON::XS;

use ArangoDB2::Document;
use ArangoDB2::Edge;
use ArangoDB2::Index;

my $JSON = JSON::XS->new->utf8;



# checksum
#
# GET /_api/collection/{collection-name}/checksum
#
# Query Parameters
#
# withRevisions: Whether or not to include document revision ids in the checksum calculation.
# withData: Whether or not to include document body data in the checksum calculation.
sub checksum
{
    my($self, $args) = @_;

    return $self->arango->http->get(
        $self->api_path('collection', $self->name, 'checksum'),
        $args,
    );
}

# count
#
# GET /_api/collection/{collection-name}/count
sub count
{
    my($self) = @_;

    return $self->arango->http->get(
        $self->api_path('collection', $self->name, 'count'),
    );
}

# create
#
# POST /_api/collection
#
# return self on success, undef on failure
sub create
{
    my($self, $args) = @_;

    # require hashref
    $args ||= {};
    die "invalid argument"
        unless ref $args eq 'HASH';
    # set name arg
    $args->{name} = $self->name;

    # allow type to be passed by name
    if ($args->{type}) {
        $args->{type} = 3 if $args->{type} =~ m{edge}i;
        $args->{type} = 2 if $args->{type} =~ m{doc}i;
    }

    my $res = $self->arango->http->post(
        $self->api_path('collection'),
        undef,
        $JSON->encode($args),
    ) or return;

    return $self;
}

# delete
#
# DELETE /_api/collection/{collection-name}
sub delete
{
    my($self) = @_;

    return $self->arango->http->delete(
        $self->api_path('collection', $self->name),
    );
}

# document
#
# get a specific ArangoDB2::Document by name (_key) or create a
# new blank ArangoDB2::Document
sub document
{
    my($self, $name) = @_;

    # if name (_key) is passed then instantiate a new
    # object with that name, which will retrieve the object
    if (defined $name) {
        return $self->documents->{$name} ||= ArangoDB2::Document->new(
            $self->arango,
            $self->database,
            $self,
            $name,
        );
    }
    # otherwise create a new empty document that can be used to
    # create a new document
    else {
        return ArangoDB2::Document->new(
            $self->arango,
            $self->database,
            $self,
        );
    }
}

# documents
#
# register of ArangoDB2::Document objects by name (_key)
sub documents { $_[0]->{documents} ||= {} }

# edge
#
# get a specific ArangoDB2::Edge by name (_key) or create a
# new blank ArangoDB2::Edge
sub edge
{
    my($self, $name) = @_;

    # if name (_key) is passed then instantiate a new
    # object with that name, which will retrieve the object
    if (defined $name) {
        return $self->edges->{$name} ||= ArangoDB2::Edge->new(
            $self->arango,
            $self->database,
            $self,
            $name,
        );
    }
    # otherwise create a new empty document that can be used to
    # create a new document
    else {
        return ArangoDB2::Edge->new(
            $self->arango,
            $self->database,
            $self,
        );
    }
}

# edges
#
# register of ArangoDB2::Edge objects by name (_key)
sub edges { $_[0]->{edges} ||= {} }

# figures
#
# GET /_api/collection/{collection-name}/figures
sub figures
{
    my($self) = @_;

    return $self->arango->http->get(
        $self->api_path('collection', $self->name, 'figures'),
    );
}

# index
#
# get an ArangoDB::Index by name or create new empty instance
sub index
{
    my($self, $name) = @_;

    # if name then create/retrieve named instance
    if (defined $name) {
        return $self->indexes->{$name} ||= ArangoDB2::Index->new(
            $self->arango,
            $self->database,
            $self,
            $name,
        );
    }
    # otherwise create a new empty instance
    else {
        return ArangoDB2::Index->new(
            $self->arango,
            $self->database,
            $self,
        );
    }
}

# indexes
#
# register of ArangoDB2::Index objects by name
sub indexes { $_[0]->{indexes} ||= {} }

# info
#
# GET /_api/collection/{collection-name}
sub info
{
    my($self) = @_;

    return $self->arango->http->get(
        $self->api_path('collection', $self->name),
    );
}

# list
#
# GET /_api/collection
#
# Query Parameters
#
# excludeSystem: Whether or not system collections should be excluded from the result.
sub list
{
    my($self, $args) = @_;

    return $self->arango->http->get(
        $self->api_path('collection'),
        $args,
    );
}

# load
#
# PUT /_api/collection/{collection-name}/load
#
# Query Parameters
#
# count: set false to disable counting of documents
sub load
{
    my($self, $args) = @_;

    return $self->arango->http->put(
        $self->api_path('collection', $self->name, 'load'),
        $args,
    );
}


# properties
#
# GET /_api/collection/{collection-name}/properties
#
# or
#
# PUT /_api/collection/{collection-name}/properties
#
# Params
#
# waitForSync: If true then creating or changing a document will wait until the data has been synchronised to disk.
# journalSize: Size (in bytes) for new journal files that are created for the collection.
sub properties
{
    my($self, $args) = @_;

    my $path = $self->api_path('collection', $self->name, 'properties');

    # need to use true / false bool values
    if ( $args && exists $args->{waitForSync} ) {
        $args->{waitForSync} = $args->{waitForSync} ? JSON::XS::true : JSON::XS::false;
    }

    return $args
        # if args are passed then set with PUT
        ? $self->arango->http->put($path, undef, $JSON->encode($args))
        # otherwise get properties
        : $self->arango->http->get($path);
}

# rename
#
# PUT /_api/collection/{collection-name}/rename
#
# Params
#
# name: new name
sub rename
{
    my($self, $args) = @_;

    my $old_name = $self->name;
    my $new_name = $args->{name};

    my $res = $self->arango->http->put(
        $self->api_path('collection', $self->name, 'rename'),
        undef,
        $JSON->encode($args),
    );

    # if rename successful apply changes locally
    if ($res && $res->{name} eq $new_name) {
        # change internal name
        $self->{name} = $new_name;
        # delete old name from ArangoDB2::Database register
        delete $self->database->collections->{$old_name};
        # set new name in ArangoDB2::Database register
        $self->database->collections->{$new_name} = $self;
    }

    return $res;
}

# revision
#
# GET /_api/collection/{collection-name}/revision
sub revision
{
    my($self) = @_;

    return $self->arango->http->get(
        $self->api_path('collection', $self->name, 'revision'),
    );
}

# rotate
#
# PUT /_api/collection/{collection-name}/rotate
sub rotate
{
    my($self) = @_;

    return $self->arango->http->put(
        $self->api_path('collection', $self->name, 'rotate'),
    );
}

# truncate
#
# PUT /_api/collection/{collection-name}/truncate
sub truncate
{
    my($self) = @_;

    return $self->arango->http->put(
        $self->api_path('collection', $self->name, 'truncate'),
    );
}

# unload
#
# PUT /_api/collection/{collection-name}/unload
sub unload
{
    my($self) = @_;

    return $self->arango->http->put(
        $self->api_path('collection', $self->name, 'unload'),
    );
}

1;

__END__


=head1 NAME

ArangoDB2::Collection - ArangoDB2 collection API methods

=head1 METHODS

=over 4

=item new

=item checksum

=item count

=item create

=item delete

=item document

=item documents

=item edge

=item edges

=item figures

=item index

=item indexes

=item info

=item list

=item load

=item properties

=item rename

=item revision

=item rotate

=item truncate

=item unload

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
