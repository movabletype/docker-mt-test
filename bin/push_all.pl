#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

my @targets = @ARGV ? @ARGV : glob "*";

for my $name (@targets) {
    next unless -f "$name/Dockerfile";

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
