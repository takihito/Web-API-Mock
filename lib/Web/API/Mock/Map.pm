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

sub init {
    my ($self) = @_;

    $self->resources({});

    $self->add_resource( '/',  Web::API::Mock::Resource->status_404);
}


sub add_resource {
    my ($self, $url, $args) = @_;

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

    my $resource = $self->resources->{$url} ? $self->resources->{$url} : '';
    unless ($resource) {
        $url =~ s!^(.+\/).+?$!$1\{\.+?}!;
        ($url) = grep { m!^$url! } @{$self->url_list};
        if ( $url && $self->resources->{$url} ) {
            $resource = $self->resources->{$url};
        }
    }
    return $resource->response($method) if $resource;

    return;
}

sub url_list {
    my ($self) = @_;
    return [keys %{$self->resources}];
}

1;
