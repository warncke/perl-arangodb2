package ArangoDB2::Base;

use strict;
use warnings;

use Scalar::Util qw(weaken);



# new
#
# Arango organizes data hierarchically: Databases > Collections > Documents
#
# This constructor can build ArangoDB2::Database, Collection, Document, Edge,
# and Query objects which all follow the same pattern
sub new
{
    my $class = shift;
    # new instance
    my $self = {};
    # process args
    while (my $arg = shift) {
        # if arg is a ref it should be another
        # ArangoDB::* object
        if (ref $arg) {
            # prevent circular ref
            weaken $arg;
            # create reference to parent object
            $self->{$arg->_class} = $arg;
        }
        # if arg is a string then it is the "name"
        # of this object
        else {
            $self->{name} = $arg;
        }
    }

    return bless($self, $class);
}

# api_path
#
# return /_db/<db name>/_api
sub api_path
{
    my $self = shift;

    my $db_name
        = $self->database
        ? $self->database->name
        : $self->name;

    return '/' . join('/', '_db', $db_name, '_api', @_);
}

# arango
#
# ArangoDB2 instance
sub arango { $_[0]->{arango} }

# collection
#
# parent Arango::DB collection instance
sub collection { $_[0]->{collection} }

# data
#
# ref to hash containing document data
sub data { $_[0]->{data} ||= {} }

# database
#
# parent Arango::DB database instance
sub database { $_[0]->{database} }

# name
#
# name/handle of object
sub name {
    my($self, $name) = @_;

    if (defined $name) {
        $self->{name} = $name;
        return $self;
    }

    return $self->{name};
}

1;

__END__


=head1 NAME

ArangoDB2::Base - Base class for other ArangoDB2 objects

=head1 METHODS

=over 4

=item new

=item api_path

=item arango

=item collection

=item data

=item database

=item name

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
