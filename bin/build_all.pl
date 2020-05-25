#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long;

GetOptions(
    'no_cache|no-cache' => \my $no_cache,
    'workers=i'         => \my $workers,
);

my @targets = @ARGV ? @ARGV : glob "*";

my $pm = Parallel::ForkManager->new($workers // 2);
for my $name (@targets) {
    next unless -f "$name/Dockerfile";
    say $name;
    my $pid = $pm->start and next;
    my $res = system("docker build $name --tag movabletype/test:$name" . ($no_cache ? "--no-cache" : "") . " 2>&1 | tee log/build_$name.log");
    $pm->finish;
}
$pm->wait_all_children;
