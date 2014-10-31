package ArangoDB::Admin;

use strict;
use warnings;

use base qw(
    ArangoDB::Base
);



# echo
#
# GET /_admin/echo
#
# The call returns an object that includes the following attributes:
#
# headers: a list of HTTP headers received
# requestType: the HTTP request method (e.g. GET)
# parameters: list of URL parameters received
sub echo
{
    my($self) = @_;

    return $self->arango->http->get('/_admin/echo');
}

1;

__END__


=head1 NAME

ArangoDB::Admin - ArangoDB admin API methods

=head1 METHODS

=over 4

=item new

=item echo

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


