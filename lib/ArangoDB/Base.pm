package ArangoDB::Base;

use strict;
use warnings;

use Scalar::Util qw(weaken);



# new
#
# Arango organizes data hierarchically as: Databases > Collections > Documents
#
# This constructor can build ArangoDB::Database, Collection, and Document objects
# which all follow the same pattern
sub new
{
    my($class, $arango, $database, $collection, $document) = @_;
    # arango object is always required
    die "ArangoDB Object Required"
        unless defined $arango;
    # prevent circular ref
    weaken $arango;
    # create new instance
    my $self = {arango => $arango};
    # if collection has value then this might be a collection
    # or a document
    if ($collection) {
        # if collection is a ref then this is a document
        if (ref $collection) {
            # prevent circular ref
            weaken $database;
            weaken $collection;
            $self->{database} = $database;
            $self->{collection} = $collection;
            $self->{name} = $document
                if $document;
        }
        # otherwise it is collection
        else {
            # prevent circular ref
            weaken $database;
            $self->{database} = $database;
            $self->{name} = $collection;
        }
    }
    # otherwise if database has value it is a database
    elsif ($database) {
        $self->{name} = $database;
    }

    return bless($self, $class);
}

# arango
#
# ArangoDB instance
sub arango { $_[0]->{arango} }

# collection
#
# parent Arango::DB collection instance
sub collection { $_[0]->{collection} }

# database
#
# parent Arango::DB database instance
sub database { $_[0]->{database} }

# db_path
#
# return /_db/<db name>
sub db_path
{
    my($self) = @_;

    my $db_name
        = $self->database
        ? $self->database->name
        : $self->name;

    return "/_db/$db_name";
}

# name
#
# name/handle of object
sub name { $_[0]->{name} }

1;

__END__


=head1 NAME

ArangoDB::Base - Base class for other ArangoDB objects

=head1 METHODS

=over 4

=item new

=item arango

=item collection

=item database

=item db_path

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


