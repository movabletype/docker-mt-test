#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Parallel::ForkManager;
use Getopt::Long qw/:config pass_through/;
use Mojo::File   qw/path/;

GetOptions(
    'builder=s'                         => \my $builder,
    'push'                              => \my $push,
    'no_cache|no-cache'                 => \my $no_cache,
    'workers=i'                         => \my $workers,
    'errored|errored_only|errored-only' => \my $errored_only,
);

my %aliases = qw(
    perl-5.16 centos7
    perl-5.38 noble
    perl-5.40 plucky
    perl-5.42 questing

    php-7.3 buster
    php-7.4 fedora32
    php-8.0 fedora35
    php-8.1 fedora37
    php-8.2 fedora39
    php-8.3 fedora41
    php-8.4 fedora42
);
my %aliases_rev;

my %multi_platform = map {$_ => 1} qw( noble plucky questing );

while (my ($alias, $name) = each %aliases) {
    $aliases_rev{$name} ||= [];
    push @{ $aliases_rev{$name} }, $alias;
}

my @targets = @ARGV ? @ARGV : glob "*";

my $pm = Parallel::ForkManager->new($workers // 2);
for my $name (@targets) {
    next unless -f "$name/Dockerfile";
    next if $errored_only && !-f "log/build_error_$name.log";
    say $name;
    my $pid  = $pm->start and next;
    my $tags = "--tag movabletype/test:$name";
    for my $t (@{ $aliases_rev{$name} || [] }) {
        $tags .= " --tag movabletype/test:$t";
    }
    my $dockerfile = path("$name/Dockerfile")->slurp;
    my ($from)     = $dockerfile =~ /^FROM (\S+)/;
    system("docker pull $from") if $no_cache;
    if ($builder && $multi_platform{$name}) {
        system("docker buildx build --builder $builder --platform linux/amd64,linux/arm64 $name $tags --output=type=image" . ($no_cache ? " --no-cache" : "") . ($push ? " --push" : "") . " 2>&1 | tee log/build_$name.log");
    } else {
        if ($push) {
            if ($multi_platform{$name}) {
                say "$name requires multi-platform build to push";
            } else {
                my $id = `docker images movabletype/test:$name --no-trunc --format '{{.ID}}'`;
                chomp $id;
                die "Image not found: $name" unless $id;

                say "$name : $id";

                my @tags = map { s/ .*//r }
                    grep { /$id/ }
                    split /\n/, `docker images -f 'reference=movabletype/test:*' --no-trunc --format '{{.Tag}} {{.ID}}'`;

                for my $tag (@tags) {
                    system("docker push movabletype/test:$tag");
                }
            }
        } else {
            system("docker build $name $tags" . ($no_cache ? " --no-cache" : "") . " 2>&1 | tee log/build_$name.log");
        }
    }
    my $log = path("log/build_$name.log")->slurp;
    if ($log =~ m!(naming to docker.io/movabletype/test:$name (\S+ )?done|Successfully built|exporting manifest list .* done)!) {
        if ($log =~ /No package (.+) available/) {
            rename "log/build_$name.log" => "log/build_warn_$name.log";
        } else {
            unlink "log/build_warn_$name.log";
        }
        unlink "log/build_error_$name.log";
    } else {
        rename "log/build_$name.log" => "log/build_error_$name.log";
    }
    $pm->finish;
}
$pm->wait_all_children;
