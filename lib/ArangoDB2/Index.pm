package ArangoDB2::Index;

use strict;
use warnings;

use base qw(
    ArangoDB2::Base
);

use Data::Dumper;
use JSON::XS;

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

    my $res = $self->arango->http->post(
        $self->api_path('index'),
        $args,
        $JSON->encode($index),
    ) or return;

    warn Dumper $res;

    return $self;
}

# delete
#
# DELETE /_api/index/{index-handle}
sub delete
{
    my($self) = @_;

    return $self->arango->http->delete(
        $self->api_path('index', $self->name),
    );
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
        $self->api_path('index', $self->name),
    );

    return $res;
}

# list
#
# GET /_api/index
sub list
{

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
