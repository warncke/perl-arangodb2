package ArangoDB::HTTP::LWP;

use strict;
use warnings;

use base qw(
    ArangoDB::HTTP
);

use Data::Dumper;
use JSON::XS;
use LWP::UserAgent;
use Scalar::Util qw(weaken);



my $JSON = JSON::XS->new->utf8;



sub new
{
    my($class, $arango) = @_;
    # we do not want to hold this reference if the
    # parent goes out of scope
    weaken $arango;

    my $lwp = LWP::UserAgent->new(
        keep_alive => 1
    );

    my $self = {
        arango  => $arango,
        lwp     => $lwp,
    };

    return bless($self, $class);
}

# delete
#
# make a DELETE request using the ArangoDB API uri along with
# the path and any args passed
sub delete
{
    my($self, $path, $args) = @_;
    # get copy of ArangoDB API URI
    my $uri = $self->arango->uri->clone;
    # set path for request
    $uri->path($path);
    # set query params on URI if passed
    $uri->query_form($args) if $args;
    # make request
    my $response = $self->lwp->delete($uri);
    # process response
    return $self->response($response);
}

# get
#
# make a GET request using the ArangoDB API uri along with
# the path and any args passed
sub get
{
    my($self, $path, $args) = @_;
    # get copy of ArangoDB API URI
    my $uri = $self->arango->uri->clone;
    # set path for request
    $uri->path($path);
    # set query params on URI if passed
    $uri->query_form($args) if $args;
    # make request
    my $response = $self->lwp->get($uri);
    # process response
    return $self->response($response);
}

# head
#
# make a HEAD request using the ArangoDB API uri along with
# the path and any args passed
sub head
{
    my($self, $path, $args) = @_;
    # get copy of ArangoDB API URI
    my $uri = $self->arango->uri->clone;
    # set path for request
    $uri->path($path);
    # set query params on URI if passed
    $uri->query_form($args) if $args;
    # make request
    my $response = $self->lwp->head($uri);
    # return code
    return $response->code;
}

# lwp
#
# LWP::UserAgent instance
sub lwp { $_[0]->{lwp} }

# patch
#
# make a PATCH request using the ArangoDB API uri along with
# the path and any args passed
sub patch
{
    my($self, $path, $args, $patch) = @_;
    # get copy of ArangoDB API URI
    my $uri = $self->arango->uri->clone;
    # set path for request
    $uri->path($path);
    # set query params on URI if passed
    $uri->query_form($args) if $args;
    # build HTTP::Request
    my $request = HTTP::Request->new('PATCH', $uri);
    $request->content($patch);
    # make request
    my $response = $self->lwp->request($request);
    # process response
    return $self->response($response);
}

# put
#
# make a PUT request using the ArangoDB API uri along with
# the path and any args passed
sub put
{
    my($self, $path, $args, $put) = @_;
    # get copy of ArangoDB API URI
    my $uri = $self->arango->uri->clone;
    # set path for request
    $uri->path($path);
    # set query params on URI if passed
    $uri->query_form($args) if $args;
    # make request
    my $response = ref $put
        # if put is hashref then treat as key/value pairs
        # to be form encoded
        ? $self->lwp->put($uri, $put)
        # if put is string then put raw data
        : $self->lwp->put($uri, Content => $put);
    # process response
    return $self->response($response);
}

# post
#
# make a POST request using the ArangoDB API uri along with
# the path and any args passed
sub post
{
    my($self, $path, $args, $post) = @_;
    # get copy of ArangoDB API URI
    my $uri = $self->arango->uri->clone;
    # set path for request
    $uri->path($path);
    # set query params on URI if passed
    $uri->query_form($args) if $args;
    # make request
    my $response = ref $post
        # if post is hashref then treat as key/value pairs
        # to be form encoded
        ? $self->lwp->post($uri, $post)
        # if post is string then post raw data
        : $self->lwp->post($uri, Content => $post);
    # process response
    return $self->response($response);
}

# response
#
# process LWP::UserAgent response
sub response
{
    my($self, $response) = @_;

    if ($response->is_success) {
        my $res = $JSON->decode($response->content);
        # if there is a result object and no error then only
        # return the result object
        if ($res->{result} && !$res->{error}) {
            return $res->{result};
        }
        # otherwise return entire response
        else {
            return $res;
        }
    }
    else {
        # set error code
        $self->error($response->code);
        return;
    }
}

1;

__END__


=head1 NAME

ArangoDB::HTTP::LWP - ArangoDB HTTP transport layer implemented with LWP

=head1 METHODS

=over 4

=item new

=item delete

=item get

=item head

=item lwp

=item patch

=item put

=item post

=item response

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


