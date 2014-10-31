package ArangoDB::Collection;

use strict;
use warnings;

use base qw(
    ArangoDB::Base
);

use Data::Dumper;
use JSON::XS;

use ArangoDB::Document;

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
        $self->db_path . '/_api/collection/' . $self->name . '/checksum',
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
        $self->db_path . '/_api/collection/' . $self->name . '/count'
    );
}

# create
#
# POST /_api/collection
sub create
{
    my($self, $args) = @_;

    # require hashref
    $args ||= {};
    die "invalid argument"
        unless ref $args eq 'HASH';
    # set name arg
    $args->{name} = $self->name;

    return $self->arango->http->post(
        $self->db_path . '/_api/collection',
        undef,
        $JSON->encode($args),
    );
}

# delete
#
# DELETE /_api/collection/{collection-name}
sub delete
{
    my($self) = @_;

    return $self->arango->http->delete(
        $self->db_path . '/_api/collection/' . $self->name
    );
}

# document
#
# get a specific ArangoDB::Document by handle or create a
# new blank ArangoDB::Document
sub document
{
    my($self, $name) = @_;

    # if name (document _id) is passed then instantiate a new
    # object with that name, which will retrieve the object
    if (defined $name) {
        return $self->documents->{$name} ||= ArangoDB::Document->new(
            $self->arango,
            $self->database,
            $self,
            $name,
        );
    }
    # otherwise create a new empty document that can be used to
    # create a new document
    else {
        return ArangoDB::Document->new(
            $self->arango,
            $self->database,
            $self,
        );
    }
}

# documents
#
#
sub documents { $_[0]->{documents} ||= {} }

# figures
#
# GET /_api/collection/{collection-name}/figures
sub figures
{
    my($self) = @_;

    return $self->arango->http->get(
        $self->db_path . '/_api/collection/' . $self->name . '/figures'
    );
}

# info
#
# GET /_api/collection/{collection-name}
sub info
{
    my($self) = @_;

    return $self->arango->http->get(
        $self->db_path . '/_api/collection/' . $self->name
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
        $self->db_path . '/_api/collection',
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
        $self->db_path . '/_api/collection/' . $self->name . '/load',
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

    my $path = $self->db_path . '/_api/collection/' . $self->name . '/properties';

    # need to use true / false bool values
    if ( $args && exists $args->{waitForSync} ) {
        $args->{waitForSync} = $args->{waitForSync} ? JSON::XS::true : JSON::XS::false;
    }

    return $args
        ? $self->arango->http->put($path, undef, $JSON->encode($args))
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
        $self->db_path . '/_api/collection/' . $self->name . '/rename',
        undef,
        $JSON->encode($args),
    );

    # if rename successful apply changes locally
    if ($res && $res->{name} eq $new_name) {
        # change internal name
        $self->{name} = $new_name;
        # delete old name from ArangoDB::Database register
        delete $self->database->collections->{$old_name};
        # set new name in ArangoDB::Database register
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
        $self->db_path . '/_api/collection/' . $self->name . '/revision'
    );
}

# rotate
#
# PUT /_api/collection/{collection-name}/rotate
sub rotate
{
    my($self) = @_;

    return $self->arango->http->put(
        $self->db_path . '/_api/collection/' . $self->name . '/rotate',
    );
}

# truncate
#
# PUT /_api/collection/{collection-name}/truncate
sub truncate
{
    my($self) = @_;

    return $self->arango->http->put(
        $self->db_path . '/_api/collection/' . $self->name . '/truncate'
    );
}

# unload
#
# PUT /_api/collection/{collection-name}/unload
sub unload
{
    my($self) = @_;

    return $self->arango->http->put(
        $self->db_path . '/_api/collection/' . $self->name . '/unload'
    );
}

1;

__END__


=head1 NAME

ArangoDB::Collection - ArangoDB collection API methods

=head1 METHODS

=over 4

=item new

=item checksum

=item count

=item create

=item delete

=item document

=item documents

=item figures

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

