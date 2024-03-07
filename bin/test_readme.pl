use strict;
use warnings;
use Test::More;
use Mojo::File qw/path/;
use Data::Dump qw/dump/;

my %mapping;
for my $line (split /\n/, path('README.md')->slurp) {
    next unless $line =~ /^\|/;
    next if $line =~ /^\|(?:\-|image name)/;
    $line =~ s/(^\|)|(\|$)//g;
    $line =~ s/\*//g;
    $line =~ s/MariaDB //;
    my ($image, $base, @rest) = split '\|', $line;
    next if $image =~ /(?:openldap|chromedriver)/;
    if ($image =~ /(?:addons|chromiumdriver|playwright)/) {
        my @extra = split /,\s*/, $rest[0];
        $mapping{$image} = { map {split / /, $_} @extra };
    } else {
        my ($perl, $php, $mysql, $openssl) = @rest;
        $image =~ s/ .+$//;
        $mapping{$image} = {perl => $perl, php => $php, mysql => $mysql, openssl => $openssl};
    }
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
    for my $key (sort keys %{%mapping{$image}}) {
        my $wanted = $key;
        $wanted = '(?:mysql|mariadb)' if $key eq 'mysql';
        my ($version) = $log =~ /$wanted exists \((.+?)\)/i;
        is $version => $mapping{$image}{$key} => "$image has correct $key";
    }
}

done_testing;
