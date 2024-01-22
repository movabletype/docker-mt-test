#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Getopt::Long;
use Test::More;
use Mojo::File qw/path/;
use LWP::UserAgent;
use TAP::Parser;
use Term::ANSIColor qw/colorstrip colored/;

my @targets = @ARGV ? @ARGV : glob "*";

LWP::UserAgent->new->mirror("https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile", "t/cpanfile");

my %summary;
for my $name (@targets) {
    my $dockerfile = path("$name/Dockerfile");
    next unless -f $dockerfile;
    next if (my $conf = $dockerfile->slurp) =~ /EXPOSE/;
    diag "testing $name";
    my $res = eval { !system("docker run -it --rm -v\$PWD:/mt -w /mt movabletype/test:$name bash -c 'TEST_IMAGE=$name prove -lv bin/checker.t' 2>&1 | tee log/check_$name.log"); };
    my ($has_ok, $has_fail, $has_todo) = (0, 0, 0);
    if ($res) {
        my $log = path("log/check_$name.log")->slurp;
        $log = colorstrip($log);
        if ($log) {
            my $parser = TAP::Parser->new({source => $log});
            while (my $result = $parser->next) {
                next unless $result->is_test;
                if ($result->is_ok) {
                    $has_ok++;
                    $has_todo++ if $result->raw =~ /# TODO/;
                } else {
                    next if $result->is_unplanned;
                    $has_fail++;
                }
            }
        } else {
            $has_fail++;
        }
    }
    ok $has_ok, $name;
    if ($has_fail or !$has_ok) {
        rename "log/check_$name.log" => "log/check_error_$name.log";
        unlink "log/check_warn_$name.log";
    } else {
        if ($has_todo) {
            rename "log/check_$name.log" => "log/check_warn_$name.log";
            unlink "log/check_error_$name.log";
        } else {
            unlink "log/check_error_$name.log";
            unlink "log/check_warn_$name.log";
        }
    }
    $summary{$name} = [$has_ok, $has_fail, $has_todo];
}
done_testing;

diag "summary";
for my $name (sort keys %summary) {
    my ($ok, $fail, $todo) = @{$summary{$name}};
    my $message = "$name ok: $ok fail: $fail todo: $todo";
    $message = colored(['red'], $message) if $fail || !$ok;
    diag $message;
}
