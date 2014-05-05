package Web::API::Mock;
use 5.008005;
use strict;
use warnings;

use Plack::Request;
use Web::API::Mock::Parser;
use Web::API::Mock::Resource;
use Class::Accessor::Lite (
    new => 1,
    rw  => [ qw/config files not_implemented_url map/ ],
);

our $VERSION = "0.01";

sub setup {
    my ($self, $files, $not_implement) = @_;
    my $markdown;
    for my $file (@{$files}) {
        open my $fh, "<:encoding(utf8)", $file or die "cannot open file. $file:$!";
        while ( my $line = <$fh> ) {
            $markdown .= $line;
        }
        close($fh);
    }
    my $parser = Web::API::Mock::Parser->new();
    $parser->md($markdown);
    $self->map($parser->create_map());

    $self->not_implemented_url([]);
    if ($not_implement) {
        open my $fh, "<:encoding(utf8)", $not_implement or die "cannot open file. $not_implement:$!";
        while ( my $line = <$fh> ) {
            chomp $line;
            $line =~ s/\ //g;
            push @{$self->not_implemented_url}, $line;
        }
        close($fh);
    }
}

sub psgi {
    my $self = shift;
    sub {
        my $env = shift;

        my $req = Plack::Request->new($env);
        my $plack_response = $req->new_response(404);

        my $response = $self->map->request($req->method, $req->path_info);
        if ($response && $response->{status}) {
           if ($self->check_implemented_url($req->method, $req->path_info)) {
                $response  = Web::API::Mock::Resource->status_501;
           }
        }
        else {
             $response  = Web::API::Mock::Resource->status_404;
        }

        $plack_response->headers($response->{header});
        $plack_response->content_type($response->{content_type});
        $plack_response->status($response->{status});
        $plack_response->body($response->{body});
        $plack_response->finalize;
    };
}

sub check_implemented_url {
    my ($self, $method, $path) = @_;

    return if ( ref $self->not_implemented_url ne 'ARRAY');

    my $target = join(',', $method,$path);
    my ($url) = grep { m!^$target$! } @{$self->not_implemented_url};
    # TODO 再帰
    unless ($url) {
        $target =~ s!^(.+\/).+?$!$1\{.+?}!;
        ($url) = grep { m!^$target$! } @{$self->not_implemented_url};
    }
    return $url;
}

1;
__END__

=encoding utf-8

=head1 NAME

Web::API::Mock - It's new $module

=head1 SYNOPSIS

    use Web::API::Mock;

=head1 DESCRIPTION

Web::API::Mock is ...

=head1 LICENSE

Copyright (C) akihito.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

akihito E<lt>takeda.akihito@gmail.comE<gt>

=cut

