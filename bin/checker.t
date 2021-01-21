use strict;
use warnings;
use Test::More;
use version;

my %prereqs = (
    'Archive::Tar' => '',
    'Archive::Zip' => '<= 1.65?',
    'DBD::mysql' => '4.000',
    'DBI' => '1.633',
    'GD' => 0,
    'Graphics::Magick' => 0,
    'Image::Magick?' => 0,
    'Image::Magick::Q16?' => 0,
    'Image::Magick::Q16HDRI?' => 0,
    'Imager' => 0,
    'Net::SSLeay' => '1.85',
    'IO::Socket::SSL' => '2.058',
);

for my $module (sort keys %prereqs) {
    my $optional = $module =~ s/\?$//;
    my $required = $prereqs{$module};
    no strict 'refs';
    eval "require $module";
    if ($@ && $@ =~ /Can't locate/) {
        next if $optional;
        fail "$module does not exist";
        next;
    }
    my $version = $module->VERSION // 0;
    if ($required) {
        my $todo = $required =~ s/\?$//;
        SKIP: {
            local $TODO = 'may fail' if $todo;
            my ($op, $required_version);
            if ($required =~ / /) {
                ($op, $required_version) = split / /, $required;
            } else {
                ($op, $required_version) = ('>=', $required);
            }
            ok eval qq{version->parse($version) $op version->parse("$required_version")}, "$module $version (required $required)";
        }
    } else {
        pass "$module $version exists";
    }
}

my ($perl_version) = `perl -v` =~ /v(5\.\d+\.\d+)/;
ok $perl_version, "Perl exists ($perl_version)";

my %imager_supports = map {$_ => 1} Imager->read_types;
ok $imager_supports{gif}, "Imager supports GIF";
ok $imager_supports{png}, "Imager supports PNG";
ok $imager_supports{jpeg}, "Imager supports JPEG";

my %imagemagick_supports = map {$_ => 1} Image::Magick->QueryFormat;
ok $imagemagick_supports{gif}, "ImageMagick supports GIF";
ok $imagemagick_supports{png}, "ImageMagick supports PNG";
ok $imagemagick_supports{jpeg}, "ImageMagick supports JPEG";

my %graphicsmagick_supports = map {$_ => 1} Graphics::Magick->QueryFormat;
ok $graphicsmagick_supports{gif}, "GraphicsMagick supports GIF";
ok $graphicsmagick_supports{png}, "GraphicsMagick supports PNG";
ok $graphicsmagick_supports{jpeg}, "GraphicsMagick supports JPEG";

my ($php_version) = `php --version` =~ /PHP (\d\.\d+\.\d+)/;
ok $php_version, "PHP exists ($php_version)";

my $phpinfo = `php -i`;
ok $phpinfo =~ /(?:Multibyte decoding support using mbstring => enabled|Zend Multibyte Support => provided by mbstring|mbstring extension makes use of "streamable kanji code filter and converter")/, "PHP has mbstring";
ok $phpinfo =~ /PDO drivers => .*?mysql/, "PHP has PDO mysql driver";
ok $phpinfo =~ /GD Support => enabled/, "PHP has GD";
ok $phpinfo =~ /GIF Read Support => enabled/, "PHP supports GIF read";
ok $phpinfo =~ /GIF Create Support => enabled/, "PHP supports GIF create";
ok $phpinfo =~ /JPEG Support => enabled/, "PHP supports JPEG";
ok $phpinfo =~ /PNG Support => enabled/, "PHP supports PNG";

my ($mysql_version, $is_maria) = `mysql --verbose --help 2>/dev/null` =~ /mysql\s+Ver.+?(\d+\.\d+\.\d+).+?(MariaDB)?/;
my $mysql = $is_maria ? "MariaDB" : "MySQL";
ok $mysql_version, "$mysql exists ($mysql_version)";
my $sql_mode = `mysql -Nse 'select \@\@sql_mode'`;
note "SQL mode: $sql_mode";
if ($mysql_version =~ /^5\.[567]\./ or $mysql_version =~ /^10\.[0123]\./) {
    my ($file_format) = `mysql -Nse 'select \@\@innodb_file_format'` =~ /(\w+)/;
    my ($file_per_table) = `mysql -Nse 'select \@\@innodb_file_per_table'` =~ /(\w+)/;
    my ($large_prefix) = `mysql -Nse 'select \@\@innodb_large_prefix'` =~ /(\w+)/;
    note "InnoDB: file format $file_format, file per table $file_per_table, large prefix $large_prefix";
}

my ($vsftpd_version) = `/usr/sbin/vsftpd -version 2>&1` =~ /version (\d+\.\d+\.\d+)/;
if (!$vsftpd_version) {
    $vsftpd_version = -f '/usr/sbin/vsftpd' ? 'failed to capture; see output' : 0;
}
ok $vsftpd_version, "vsftpd exists ($vsftpd_version)";

my ($openssl_version) = Net::SSLeay::SSLeay_version() =~ /OpenSSL (\d+\.\d+\.\d+\w*)/i;
ok $openssl_version, "openssl exists ($openssl_version)";

done_testing;
