package ArangoDB2::Index;

use strict;
use warnings;

use base qw(
    ArangoDB2::Base
);

use Data::Dumper;
use JSON::XS;

# parameters that can be set when creating index or
# are returned when creating/getting index
our @PARAMS = qw(
    byteSize constraint fields geoJson id ignoreNull
    isNewlyCreated type minLength unique size
);

my $JSON = JSON::XS->new->utf8;



# new
#
# create new instance.  optionally try to get index by name.
sub new
{
    my($class) = shift;
    # call inherited constructor
    my $self = $class->SUPER::new(@_);
    # if a name arg was passed then try to get
    $self->get if $self->name;

    return $self;
}

# byteSize
#
# get/set byteSize
sub byteSize
{
    my($self, $byteSize) = @_;

    if (defined $byteSize) {
        $self->{byteSize} = $byteSize;
        return $self;
    }
    else {
        return $self->{byteSize};
    }
}

# constraint
#
# get/set constraint value
sub constraint
{
    my($self, $constraint) = @_;

    if (defined $constraint) {
        $self->{constraint} = $constraint ? JSON::XS::true : JSON::XS::false;
        return $self;
    }
    else {
        return $self->{constraint};
    }
}

# create
#
# POST /_api/index
sub create
{
    my($self, $index, $args) = @_;
    # set default args
    $index ||= {};
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $index eq 'HASH'
        and ref $args eq 'HASH';
    # set collection name
    $args->{collection} = $self->collection->name;
    # set args
    for my $arg (@PARAMS) {
        # if the arg was passed then set it
        $self->$arg($args->{$args});
        # use the set value if set
        $args->{$arg} = $self->$arg
            if defined $self->$arg;
    }

    my $res = $self->arango->http->post(
        $self->api_path('index'),
        $args,
        $JSON->encode($index),
    ) or return;

    # get name from id
    my($name) = $res->{id} =~ m{/(\d+)$}
        or return;
    $self->{name} = $name;
    # copy properties from response
    do { $self->{$_} = $res->{$_} if exists $res->{$_} } for @PARAMS;
    # register
    $self->collection->indexes->{$name} = $self;

    return $self;
}

# delete
#
# DELETE /_api/index/{index-handle}
sub delete
{
    my($self) = @_;

    my $res = $self->arango->http->delete(
        $self->api_path('index', $self->id),
    ) or return;

    # remove from register
    delete $self->collection->indexes->{$self->name};

    return $res;
}

# fields
#
# get/set fields
sub fields
{
    my($self, $fields) = @_;

    if (defined $fields) {
        $self->{fields} = $fields;
        return $self;
    }
    else {
        return $self->{fields};
    }
}

# geoJson
#
# get/set geoJson value
sub geoJson
{
    my($self, $geoJson) = @_;

    if (defined $geoJson) {
        $self->{geoJson} = $geoJson ? JSON::XS::true : JSON::XS::false;
        return $self;
    }
    else {
        return $self->{geoJson};
    }
}

# get
#
# GET /_api/index/{index-handle}
sub get
{
    my($self, $name) = @_;
    # name arg is optional.  If name is already set then
    # object will morph into the new name.
    $self->{name} = $name
        if defined $name;

    my $res = $self->arango->http->get(
        $self->api_path('index', $self->id),
    );

    # copy properties from response
    $self->{$_} = $res->{$_} for @PARAMS;

    return $res;
}

# id
#
# get index id
sub id
{
    my($self) = @_;

    return defined $self->{id}
        ? $self->{id}
        : $self->name
            ? join('/', $self->collection->name, $self->name)
            : undef;
}

# ignoreNull
#
# get/set ignoreNull value
sub ignoreNull
{
    my($self, $ignoreNull) = @_;

    if (defined $ignoreNull) {
        $self->{ignoreNull} = $ignoreNull ? JSON::XS::true : JSON::XS::false;
        return $self;
    }
    else {
        return $self->{ignoreNull};
    }
}

# isNewlyCreated
#
# get isNewlyCreated value
sub isNewlyCreated { $_[0]->{isNewlyCreated} }

# list
#
# GET /_api/index
sub list
{
    my($self, $args) = @_;
    # set default args
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $args eq 'HASH';

    $args->{collection} ||= $self->collection->name;

    return $self->arango->http->get(
        $self->api_path('index'),
        $args
    );
}

# minLength
#
# get/set minLength
sub minLength
{
    my($self, $minLength) = @_;

    if (defined $minLength) {
        $self->{minLength} = $minLength;
        return $self;
    }
    else {
        return $self->{minLength};
    }
}

# size
#
# get/set size
sub size
{
    my($self, $size) = @_;

    if (defined $size) {
        $self->{size} = $size;
        return $self;
    }
    else {
        return $self->{size};
    }
}

# type
#
# get/set type
sub type
{
    my($self, $type) = @_;

    if (defined $type) {
        $self->{type} = $type;
        return $self;
    }
    else {
        return $self->{type};
    }
}

# unique
#
# get/set unique value
sub unique
{
    my($self, $unique) = @_;

    if (defined $unique) {
        $self->{unique} = $unique ? JSON::XS::true : JSON::XS::false;
        return $self;
    }
    else {
        return $self->{unique};
    }
}

1;

__END__

=head1 NAME

ArangoDB2::Index - ArangoDB2 index API methods

=head1 METHODS

=over 4

=item new

=item create

=item delete

=item get

=item id

=item list

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
