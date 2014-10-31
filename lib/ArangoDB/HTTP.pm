package ArangoDB::HTTP;

use strict;
use warnings;

use ArangoDB::HTTP::LWP;



# new
#
# create new ArangoDB::HTTP instance which will always be
# one of the sub-classes of ArangoDB::HTTP which implements
# a particular HTTP client
sub new
{
    my $self = shift;
    # for now use LWP client
    return ArangoDB::HTTP::LWP->new(@_);
}

# arango
#
# ArangoDB instance
sub arango { $_[0]->{arango} }

# error
#
# get/set last error (HTTP status) code
sub error
{
    my($self, $error) = @_;

    $self->{error} = $error
        if defined $error;

    return $self->{error};
}

1;

__END__


=head1 NAME

ArangoDB::HTTP - Base class for HTTP transport layer implementations

=head1 METHODS

=over 4

=item new

=item arango

=item error

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

