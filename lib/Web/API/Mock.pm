package Web::API::Mock;
use 5.008005;
use strict;
use warnings;

use Plack::Request;
use Web::API::Mock::Parser;
use Class::Accessor::Lite (
    new => 1,
    rw  => [ qw/config files map/ ],
);

our $VERSION = "0.01";


sub setup {
    my ($self, $files) = @_;
    my $markdown;
    for my $file (@{$files}) {
        open my $fh, "<:encoding(utf8)", $file or die "cannot open file. $file:$!";
        while ( my $line = <$fh> ) {
            $markdown .= $line;
        }
    }
    my $parser = Web::API::Mock::Parser->new();
    $parser->md($markdown);
    $self->map($parser->create_map());
}

sub psgi {
    my $self = shift;
    sub { 
        my $env = shift;
        my $req = Plack::Request->new($env);
        my $plack_response = $req->new_response(404);

        my $response = $self->map->request($req->method, $req->path_info);
        if ($response && $response->{status}) {
            $plack_response->headers($response->{header});
            $plack_response->content_type($response->{content_type});
            $plack_response->status($response->{status});
            $plack_response->body($response->{body});
        }
        else {
            $plack_response->status(404);
            $plack_response->content_type('text/plain');
            $plack_response->body('404 Not Found');
        }
        $plack_response->finalize;
    };
}

#  use Plack::Runner;
#  my $app = sub { ... };
#
#  my $runner = Plack::Runner->new;
#  $runner->parse_options(@ARGV);
#  $runner->run($app);



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

