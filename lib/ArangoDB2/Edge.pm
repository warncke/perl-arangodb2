package ArangoDB2::Edge;

use strict;
use warnings;

use base qw(
    ArangoDB2::Document
);

use Scalar::Util qw(blessed);



# create
#
# override ArangoDB2::Document create so that we can add from
# and to values to the request
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
    # set to and from
    $args->{from} = $self->from;
    $args->{to} = $self->to;

    return $self->SUPER::create($doc, $args);
}

# from
#
# _id ("collection/_key") of document that edge links to
sub from
{
    my($self, $from) = @_;

    if (defined $from) {
        # get value from an ArangoDB2::Document
        if ( blessed $from && $from->isa('ArangoDB2::Document') ) {
            $self->{from} = join('/', $from->collection->name, $from->name);
        }
        # use string value
        else {
            $self->{from} = $from;
        }

        return $self;
    }
    else {
        return $self->{from};
    }
}

# get
#
# override ArangoDB2::Document get to populate to and from
# values from the response
sub get
{
    my $self = shift;

    my $res = $self->SUPER::get(@_);

    if ($res) {
        $self->from( $res->{_from} );
        $self->to( $res->{_to} );
    }

    return $res;
}

# to
#
# _id ("collection/_key") of document that edge links to
sub to
{
    my($self, $to) = @_;

    if (defined $to) {
        # get value from an ArangoDB2::Document
        if ( blessed $to && $to->isa('ArangoDB2::Document') ) {
            $self->{to} = join('/', $to->collection->name, $to->name);
        }
        # use string value
        else {
            $self->{to} = $to;
        }

        return $self;
    }
    else {
        return $self->{to};
    }
}

# type
#
# type of document: either `document` or `edge`
sub type { 'edge' }

1;

__END__

=head1 NAME

ArangoDB2::Edge - ArangoDB2 edge API methods

=head1 DESCRIPTION

ArangoDB edges are fundamentally documents, with a few extra features
thrown in.  ArangoDB2::Edge inherits most of its methods from
ArangoDB2::Document.

=head1 ORIGINAL METHODS

=over 4

=item from

=item to

=back

=head1 INHERITED METHODS

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

=item type

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

