#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long qw/:config pass_through/;

GetOptions(
    'no_cache|no-cache' => \my $no_cache,
    'workers=i'         => \my $workers,
);

my %aliases = qw(
    perl-5.10 centos6
    perl-5.20 jessie
    perl-5.28 buster
    perl-5.30 fedora

    php-5.3 centos6
    php-5.6 jessie
    php-7.3 fedora
    php-7.4 focal
);
my %aliases_rev;
while (my ($alias, $name) = each %aliases) {
    $aliases_rev{$name} ||= [];
    push @{$aliases_rev{$name}}, $alias;
}

my @targets = @ARGV ? @ARGV : glob "*";

my $pm = Parallel::ForkManager->new($workers // 2);
for my $name (@targets) {
    next unless -f "$name/Dockerfile";
    say $name;
    my $pid = $pm->start and next;
    my $tags = "--tag movabletype/test:$name";
    for my $t (@{$aliases_rev{$name} || []}) {
        $tags .= " --tag movabletype/test:$t";
    }
    my $res = system("docker build $name $tags" . ($no_cache ? " --no-cache" : "") . " 2>&1 | tee log/build_$name.log");
    $pm->finish;
}
$pm->wait_all_children;
