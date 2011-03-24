use strict;
use Test::More;

use Plack::Test;
use Plack::App::PAR;
use HTTP::Request::Common;

my $app = Plack::App::PAR->new(file => "t/MyApp.par")->to_app;

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET "/");
    like $res->content, qr/Hello/;
};

done_testing;
