package ArangoDB2::Transaction;

use strict;
use warnings;

use base qw(
    ArangoDB2::Base
);

use Data::Dumper;
use JSON::XS;

my $JSON = JSON::XS->new->utf8;

# parameters that can be set when executing transaction
our @PARAMS = qw(
    action collections lockTimeout params waitForSync
);



# action
#
# get/set action
sub action
{
    my($self, $action) = @_;

    if (defined $action) {
        $self->{action} = $action;
        return $self;
    }
    else {
        return $self->{action};
    }
}

# collections
#
# get/set collections
sub collections
{
    my($self, $collections) = @_;

    if (defined $collections) {
        $self->{collections} = $collections;
        return $self;
    }
    else {
        return $self->{collections};
    }
}

sub execute
{
    my($self, $args) = @_;
    # set default args
    $args ||= {};
    # require valid args
    die 'Invalid Args'
        unless ref $args eq 'HASH';
    # set args
    for my $arg (@PARAMS) {
        # if the arg was passed then set it
        $self->$arg($args->{$args});
        # use the set value if set
        $args->{$arg} = $self->$arg
            if defined $self->$arg;
    }

    return $self->arango->http->post(
        $self->api_path('transaction'),
        undef,
        $JSON->encode($args),
    );
}

# lockTimeout
#
# get/set lockTimeout
sub lockTimeout
{
    my($self, $lockTimeout) = @_;

    if (defined $lockTimeout) {
        $self->{lockTimeout} = $lockTimeout;
        return $self;
    }
    else {
        return $self->{lockTimeout};
    }
}

# params
#
# get/set params
sub params
{
    my($self, $params) = @_;

    if (defined $params) {
        $self->{params} = $params;
        return $self;
    }
    else {
        return $self->{params};
    }
}

# waitForSync
#
# get/set waitForSync value
sub waitForSync
{
    my($self, $waitForSync) = @_;

    if (defined $waitForSync) {
        $self->{waitForSync} = $waitForSync ? JSON::XS::true : JSON::XS::false;
        return $self;
    }
    else {
        return $self->{waitForSync};
    }
}

1;

__END__

=head1 NAME

ArangoDB2::Transaction - ArangoDB2 transaction API methods

=head1 METHODS

=over 4

=item new

=item action

=item collections

=item execute

=item lockTimeout

=item params

=item waitForSync

=back

=head1 AUTHOR

Ersun Warncke, C<< <ersun.warncke at outlook.com> >>

http://ersun.warnckes.com

=head1 COPYRIGHT

Copyright (C) 2014 Ersun Warncke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
