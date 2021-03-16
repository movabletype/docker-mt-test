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
    my ($image, $base, $perl, $php, $mysql, $openssl) = split '\|', $line;
    next if $image =~ /(?:addons|chromedriver|chromiumdriver|openldap)/;
    $image =~ s/ .+$//;
    $mapping{$image} = {perl => $perl, php => $php, mysql => $mysql, openssl => $openssl};
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
    my ($perl) = $log =~ /Perl exists \((.+?)\)/;
    my ($php) = $log =~ /PHP exists \((.+?)\)/;
    my ($mysql) = $log =~ /(?:MySQL|MariaDB) exists \((.+?)\)/;
    my ($openssl) = $log =~ /openssl exists \((.+?)\)/;
    is $perl => $mapping{$image}{perl} => "$image has correct Perl";
    is $php => $mapping{$image}{php} => "$image has correct PHP";
    is $mysql => $mapping{$image}{mysql} => "$image has correct MySQL";
    is $openssl => $mapping{$image}{openssl} => "$image has correct OpenSSL";
}

done_testing;
