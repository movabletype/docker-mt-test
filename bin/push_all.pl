#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

my @targets = @ARGV ? @ARGV : glob "*";

for my $name (@targets) {
    next unless -f "$name/Dockerfile";
    say $name;
    system("docker push movabletype/test:$name");
}
