#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Getopt::Long;
use Test::More;
use Mojo::File qw/path/;

my @targets = @ARGV ? @ARGV : glob "*";

for my $name (@targets) {
    my $dockerfile = path("$name/Dockerfile");
    next unless -f $dockerfile;
    next if $dockerfile->slurp =~ /EXPOSE/;
    diag "testing $name";
    ok eval { !system("docker run -it -v\$PWD:/mt -w /mt movabletype/test:$name bash -c 'prove -lv bin/checker.t' 2>&1 | tee log/check_$name.log"); };
    my $log = path("log/check_$name.log")->slurp;
    if ($log =~ /Result: FAIL/) {
        rename "log/check_$name.log" => "log/check_error_$name.log";
        unlink "log/check_warn_$name.log";
    } else {
        if ($log =~ /Failed \(TODO\)/) {
            rename "log/check_$name.log" => "log/check_warn_$name.log";
            unlink "log/check_error_$name.log";
        } else {
            unlink "log/check_error_$name.log";
            unlink "log/check_warn_$name.log";
        }
    }
}
done_testing;
