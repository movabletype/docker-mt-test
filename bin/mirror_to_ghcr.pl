#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

my @tags = qw(bullseye buster centos7 cloud7 fedora35 fedora37 fedora39 fedora40);

for my $tag (@tags) {
    next unless -f "$tag/Dockerfile";

    my $id = `docker images movabletype/test:$tag --no-trunc --format '{{.ID}}'`;
    chomp $id;
    die "Image not found: $tag" unless $id;

    my $ghcr_name = "ghcr.io/movabletype/movabletype/test:$tag";
    system("docker tag movabletype/test:$tag $ghcr_name && docker push $ghcr_name");
}
