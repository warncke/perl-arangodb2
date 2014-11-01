package ArangoDB2::Query;

use strict;
use warnings;

use base qw(
    ArangoDB2::Base
);

use Data::Dumper;
use JSON::XS;

use ArangoDB2::Cursor;

my $JSON = JSON::XS->new->utf8;



# new
#
# create new instance
sub new
{
    my($class, $arango, $database, $query) = @_;

    my $self = $class->SUPER::new($arango, $database);
    $self->query($query);

    return $self;
}

# batchSize
#
# maximum number of result documents
sub batchSize
{
    my($self, $batchSize) = @_;

    if (defined $batchSize) {
        $self->{batchSize} = $batchSize;
        return $self;
    }

    return $self->{batchSize};
}

# count
#
# boolean flag that indicates whether the number of documents in the
# result set should be returned.
#
# default false
sub count
{
    my($self, $count) = @_;

    if (defined $count) {
        $self->{count} = $count ? JSON::XS::true : JSON::XS::false;
        return $self;
    }

    return $self->{count};
}

# execute
#
# POST /_api/cursor
sub execute
{
    my($self, $bind, $args) = @_;
    # set default args
    $bind ||= {};
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $bind eq 'HASH'
        and ref $args eq 'HASH';
    # use ArangoDB2::Query properties for args unless args are set
    for my $arg ( qw(batchSize count ttl) ) {
        next unless $self->$arg;
        $args->{$arg} = $self->$arg
            unless defined $args->{$arg};
    }
    # populate options from ArangoDB2::Query properties
    for my $arg ( qw(fullCount) ) {
        next unless defined $self->$arg;
        $args->{options} ||= {};
        $args->{options}->{$arg} = $self->$arg
            unless defined $args->{options}->{$arg};
    }
    # set bindVars if bind is passed
    $args->{bindVars} = $bind
        if defined $bind;
    # set query string
    $args->{query} = $self->query;
    # perform query which returns a cursor if successful
    my $res = $self->arango->http->post(
        $self->api_path('cursor'),
        undef,
        $JSON->encode($args),
    );
    # query was successful
    if ($res) {
        return ArangoDB2::Cursor->new($self->arango, $self->database, $res);
    }
    else {
        return;
    }
}

# fullCount
#
# include result count greater than LIMIT
#
# default false
sub fullCount
{
    my($self, $fullCount) = @_;

    if (defined $fullCount) {
        $self->{fullCount} = $fullCount ? JSON::XS::true : JSON::XS::false;
        return $self;
    }

    return $self->{fullCount};
}

# explain
#
# POST /_api/explain
sub explain
{
    my($self) = @_;

    return $self->arango->http->post(
        $self->api_path('explain'),
        undef,
        $JSON->encode({query => $self->query}),
    );
}

# parse
#
# POST /_api/query
sub parse
{
    my($self) = @_;

    return $self->arango->http->post(
        $self->api_path('query'),
        undef,
        $JSON->encode({query => $self->query}),
    );
}

# query
#
# AQL query
sub query {
    my($self, $query) = @_;

    if (defined $query) {
        $self->{query} = $query;
        return $self;
    }

    return $self->{query};
}

# ttl
#
# an optional time-to-live for the cursor (in seconds)
sub ttl
{
    my($self, $ttl) = @_;

    if (defined $ttl) {
        $self->{ttl} = $ttl;
        return $self;
    }

    return $self->{ttl};
}

1;

__END__

=head1 NAME

ArangoDB2::Query - ArangoDB2 query API methods

=head1 METHODS

=over 4

=item new

=item batchSize

=item count

=item execute

=item fullCount

=item explain

=item parse

=item query

=item ttl

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

