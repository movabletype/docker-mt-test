use strict;
use warnings;
use Test::More;
use Mojo::File qw/path/;
use YAML;

my %mapping;
my $phase;
for my $line (split /\n/, path('README.md')->slurp) {
    if ($line =~ /^## .*for CI/) {
        $phase = 'ci';
    }
    if ($line =~ /^## .*multi platforms/) {
        $phase = 'multi';
    }
    if ($line =~ /^## .*manual testing/) {
        $phase = 'manual';
    }
    if ($line =~ /^## Special images/) {
        $phase = 'special';
    }
    next unless $line =~ /^\|/;
    next if $line     =~ /^\|(?:\-|image name)/;
    $line             =~ s/(^\|)|(\|$)//g;
    $line             =~ s/\*//g;
    $line             =~ s/(?:MariaDB|Postgres) //;
    my ($image, $base, @rest) = split '\|', $line;
    next if $image =~ /(?:openldap|chromedriver)/;
    if ($image =~ /(?:addons|chromiumdriver|playwright)/) {
        my @extra = split /,\s*/, $rest[0];
        $mapping{$image} = { map { split / /, $_ } @extra };
    } else {
        my ($perl, $php, $mysql, $openssl) = @rest;
        my $ci = $phase eq 'ci' ? 1 : $image =~ /\(\\2\)/ ? 2 : 0;
        $image =~ s/ .+$//;
        $mapping{$image} = { perl => $perl, php => $php, mysql => $mysql, openssl => $openssl };
        $mapping{$image}{ci} = $ci if $ci;
    }
    $mapping{$image}{base} = $base;
}

my $used = {};
if (-e './tmp/used_images.yml') {
    $used = YAML::LoadFile('./tmp/used_images.yml');
}

for my $image (sort keys %mapping) {
    my $logfile = "log/check_$image.log";
    if (!-f $logfile) {
        $logfile = "log/check_warn_$image.log";
        if (!-f $logfile) {
            warn "No logfile for $image";
            next;
        }
    }
    my $log = path($logfile)->slurp;
    for my $key (sort keys %{ $mapping{$image} }) {
        if ($key eq 'base') {
            my $dockerfile = path("$image/Dockerfile")->slurp;
            my ($from) = $dockerfile =~ /FROM ([\w:\/-]+)/;
            is $from => $mapping{$image}{$key} => "$image has correct $key";
            next;
        }
        if ($key eq 'ci') {
            if ($mapping{$image}{ci} == 1) {
                ok $used->{$image}{develop}, "$image is used in workflow files";
            }
            if ($mapping{$image}{ci} == 2) {
                ok $used->{$image} && !$used->{$image}{develop}, "$image is previously used in workflow files";
            }
            next;
        }
        my $wanted = $key;
        $wanted = '(?:mysql|mariadb|postgresql)' if $key eq 'mysql';
        my ($version) = $log =~ /$wanted exists \((.+?)\)/i;
        is $version => $mapping{$image}{$key} => "$image has correct $key";
    }
}

for my $image (sort keys %$used) {
    next if $mapping{$image}{ci};
    next if $image =~ /addons8|chromiumdriver/;
    fail "$image is no longer used in workflow files";
}

done_testing;
