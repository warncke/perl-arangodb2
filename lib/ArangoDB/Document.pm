package ArangoDB::Document;

use strict;
use warnings;

use base qw(
    ArangoDB::Base
);

use Data::Dumper;
use JSON::XS;

my $JSON = JSON::XS->new->utf8;



# new
#
# create new instance.  optionally try to get document by name (_id).
sub new
{
    my($class) = shift;
    # call inherited constructor
    my $self = $class->SUPER::new(@_);
    # if a name arg was passed then try to get
    $self->get if $self->name;

    return $self;
}

# create
#
# POST /_api/document
#
# Query Parameters
#
# collection: The collection name.
# createCollection: If this parameter has a value of true or yes, then the collection is created if it does not yet exist. Other values will be ignored so the collection must be present for the operation to succeed.
sub create
{
    my($self, $doc, $args) = @_;
    # set default args
    $doc ||= {};
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $doc eq 'HASH'
        and ref $args eq 'HASH';
    # set collection name as query param
    $args->{collection} = $self->collection->name;

    my $res = $self->arango->http->post(
        $self->db_path . '/_api/document',
        $args,
        $JSON->encode($doc),
    );

    # if creation was success then update internal state
    if ( $res && $res->{_key} ) {
        # set name to the value of _key
        $self->{name} = $res->{_key};
        # set data pointer to the passed in doc. any patches
        # will then update the original hash
        $self->{data} = $doc;
        # store revision number
        $self->{rev} = $res->{_rev};
        # store in document register
        $self->collection->documents->{$self->name} = $self;
    }

    return $res;
}

# data
#
# ref to hash containing document data
sub data { $_[0]->{data} ||= {} }

# delete
#
# DELETE /_api/document/{document-handle}
#
# Query Parameters
#
# rev: You can conditionally delete a document based on a target revision id by using the rev URL parameter.
# policy: To control the update behavior in case there is a revision mismatch, you can use the policy parameter. This is the same as when replacing documents (see replacing documents for more details).
# waitForSync: Wait until document has been synced to disk.
sub delete
{
    my($self, $doc, $args) = @_;
    # set default args
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $args eq 'HASH';

    my $res = $self->arango->http->delete(
        $self->db_path . '/_api/document/' . $self->collection->name . '/' . $self->name,
        $args,
    );

    # if request was success then update internal state
    if ( $res && $res->{_key} ) {
        # remove registry entry
        delete $self->collection->documents->{$self->name};
        # remove data and rev which are now null
        delete $self->{data};
        delete $self->{rev};
    }

    return $res;
}

# get
#
# GET /_api/document/{document-handle}
sub get
{
    my($self) = @_;

    my $res = $self->arango->http->get(
        $self->db_path . '/_api/document/' . $self->collection->name . '/' . $self->name
    );

    # if request was success then update internal state
    if ( $res && $res->{_key} ) {
        # empty data hash
        my $data = $self->data;
        %$data = ();
        # copy data keys out of response
        for my $key (keys %$res) {
            next if substr($key, 0, 1) eq '_';
            $data->{$key} = $res->{$key};
        }
        # store revision number
        $self->{rev} = $res->{_rev};
    }

    return $res;
}

# head
#
# HEAD /_api/document/{document-handle}
sub head
{
    my($self) = @_;

    my $res = $self->arango->http->head(
        $self->db_path . '/_api/document/' . $self->collection->name . '/' . $self->name
    );

    return $res;
}

# list
#
# GET /_api/document
#
# Query Parameters
#
# collection: The name of the collection.
# type: The type of the result. The following values are allowed:
# id: returns a list of document ids (_id attributes)
# key: returns a list of document keys (_key attributes)
# path: returns a list of document URI paths. This is the default.
sub list
{
    my($self, $args) = @_;
    # set default args
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $args eq 'HASH';

    $args->{collection} = $self->collection->name;

    return $self->arango->http->get(
        $self->db_path . '/_api/document',
        $args
    );
}

# patch
#
# PATCH /_api/document/{document-handle}
#
# Query Parameters
#
# keepNull: If the intention is to delete existing attributes with the patch command, the URL query parameter keepNull can be used with a value of false. This will modify the behavior of the patch command to remove any attributes from the existing document that are contained in the patch document with an attribute value of null.
# waitForSync: Wait until document has been synced to disk.
# rev: You can conditionally patch a document based on a target revision id by using the rev URL parameter.
# policy: To control the update behavior in case there is a revision mismatch, you can use the policy parameter.
sub patch
{
    my($self, $doc, $args) = @_;
    # set default args
    $doc ||= {};
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $doc eq 'HASH'
        and ref $args eq 'HASH';

    my $res = $self->arango->http->patch(
        $self->db_path . '/_api/document/' . $self->collection->name . '/' . $self->name,
        $args,
        $JSON->encode($doc),
    );

    # if replace was success then update internal state
    if ( $res && $res->{_key} ) {
        # get data hash
        my $data = $self->data;
        # copy updated keys from doc
        for my $key (keys %$doc) {
            $data->{$key} = $doc->{$key};
        }
        # store revision number
        $self->{rev} = $res->{_rev};
    }

    return $res;
}

# replace
#
# PUT /_api/document/{document-handle}
#
# Query Parameters
#
# waitForSync: Wait until document has been synced to disk.
# rev: You can conditionally replace a document based on a target revision id by using the rev URL parameter.
# policy: To control the update behavior in case there is a revision mismatch, you can use the policy parameter (see below).
sub replace
{
    my($self, $doc, $args) = @_;
    # set default args
    $doc ||= {};
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $doc eq 'HASH'
        and ref $args eq 'HASH';

    my $res = $self->arango->http->put(
        $self->db_path . '/_api/document/' . $self->collection->name . '/' . $self->name,
        $args,
        $JSON->encode($doc),
    );

    # if replace was success then update internal state
    if ( $res && $res->{_key} ) {
        # empty data hash
        my $data = $self->data;
        %$data = ();
        # copy data keys from doc
        for my $key (keys %$doc) {
            $data->{$key} = $doc->{$key};
        }
        # store revision number
        $self->{rev} = $res->{_rev};
    }

    return $res;
}

# rev
#
# revision of currently loaded document data
sub rev { $_[0]->{rev} }

1;

__END__


=head1 NAME

ArangoDB::Document - ArangoDB document API methods

=head1 METHODS

=over 4

=item new

=item create

=item data

=item delete

=item get

=item head

=item list

=item patch

=item replace

=item rev

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


