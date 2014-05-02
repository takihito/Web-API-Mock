package Web::API::Mock::Map;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use  Web::API::Mock::Resource;

use Class::Accessor::Lite (
    new => 1,
    rw  => [ qw/resources/ ]
);

sub add_resource {
    my ($self, $url, $args) = @_;

    $self->resources({})
        unless $self->resources;

    my $resource = $self->resources->{$url} || Web::API::Mock::Resource->new();
    $resource->add({
        status       => $args->{status},
        content_type => $args->{content_type},
        method       => $args->{method},
        header       => $args->{header},
        body         => $args->{body}
    });
    $self->resources->{$url} = $resource;
}

sub request {
    my ($self, $method, $url) = @_;

    my $resource = $self->resources->{$url};
    unless ($resource) {
        $url =~ s/^(.*\/).+?$/$1\{/;
        ($url) = grep { m!^$url! } @{$self->url_list};
        $resource = $self->resources->{$url};
    }
    return $resource->response($method) if $resource;

    return;
}

sub url_list {
    my ($self) = @_;
    return [keys %{$self->resources}];
}

1;
