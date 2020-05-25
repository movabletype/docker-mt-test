#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Getopt::Long;
use LWP::UserAgent;
use Test::More;
use Test::TCP;

GetOptions(
    'mt_home|mt=s' => \my $mt_home,
    'test_mt|test-mt' => \my $test_mt,
);

my @targets = @ARGV ? @ARGV : glob "*";

for my $name (@targets) {
    diag "testing $name";
    test_tcp(
        server => sub {
            my $port = shift;
            exec "MT_IMAGE=$name WWW_PORT=$port SSL_PORT=10443 docker-compose up";
        },
        client => sub {
            my $port = shift;
            sleep 10;
            my $test_log = path("log/test_$name.log");
            my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
            my $res = $ua->get("http://mt:$port/cgi-bin/mt.cgi");
            ok $res->is_success, "$name: http mt.cgi" or append_log($test_log, $res);
               $res = $ua->get("https://mt:10443/cgi-bin/mt.cgi");
            ok $res->is_success, "$name: https mt.cgi" or append_log($test_log, $res);
               $res = $ua->get("http://mt:$port/mt-static/mt.js");
            ok $res->is_success, "$name: http mt-static" or append_log($test_log, $res);
            if ($test_mt) {
                ok eval { !system("docker-compose exec mt bash -c 'cd /var/www/cgi-bin/; prove -j4 -It/lib -lr -PMySQLPool=MT::Test::Env t plugins/*/t' 2>&1 | tee $test_log"); };
            }
            system("docker-compose down");
        }
    );
}
done_testing;

sub append_log {
    my ($file, $res) = @_;
    open my $fh, '>>', $file; say $fh $res;
}
