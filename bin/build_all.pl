#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long qw/:config pass_through/;
use Mojo::File qw/path/;
use Mojo::JSON qw/decode_json/;

GetOptions(
    'no_cache|no-cache' => \my $no_cache,
    'workers=i'         => \my $workers,
    'errored|errored_only|errored-only' => \my $errored_only,
);

my %aliases = qw(
    fedora  fedora32

    perl-5.10 centos6
    perl-5.20 jessie
    perl-5.28 buster
    perl-5.30 fedora32
    perl-5.32 bullseye
    perl-5.34 fedora35

    php-5.5 centos6
    php-5.6 jessie
    php-7.3 buster
    php-7.4 fedora32
    php-8.0 fedora35
    php-8.1 sid
);
my %aliases_rev;
while (my ($alias, $name) = each %aliases) {
    $aliases_rev{$name} ||= [];
    push @{$aliases_rev{$name}}, $alias;
}

my %supported_platforms = map { $_ => 1 } qw(linux/amd64 linux/arm64/v8);

my @targets = @ARGV ? @ARGV : glob "*";

my $pm = Parallel::ForkManager->new($workers // 2);
for my $name (@targets) {
    my $dockerfile = "$name/Dockerfile";
    next unless -f $dockerfile;
    next if $errored_only && !-f "log/build_error_$name.log";
    say $name;
    my $pid = $pm->start and next;
    my $tags = "--tag movabletype/test:$name";
    for my $t (@{$aliases_rev{$name} || []}) {
        $tags .= " --tag movabletype/test:$t";
    }

    my @platforms = qw(linux/amd64);
    my $from = path($dockerfile)->slurp =~ m/^FROM\s+(.+)$/m ? $1 : undef;
    my $manifest = $from && decode_json(join('', `docker manifest inspect $from`));
    if ($manifest && $manifest->{manifests}) {
        @platforms = grep {
            $supported_platforms{$_}
        } map {
            $_->{platform}->{os} . '/' . $_->{platform}->{architecture} .
                ($_->{platform}->{variant} ? '/' . $_->{platform}->{variant} : '')
        } @{$manifest->{manifests}}
    }

    system("docker buildx build $name --push --platform @{[join(',', @platforms)]} $tags" . ($no_cache ? " --no-cache" : "") . " 2>&1 | tee log/build_$name.log");
    my $log = path("log/build_$name.log")->slurp;
    if ($log =~ /Successfully built/) {
        if ($log =~ /No package (.+) available/) {
            rename "log/build_$name.log" => "log/build_warn_$name.log";
        } else {
            unlink "log/build_warn_$name.log"
        }
        unlink "log/build_error_$name.log"
    } else {
        rename "log/build_$name.log" => "log/build_error_$name.log";
    }
    $pm->finish;
}
$pm->wait_all_children;
