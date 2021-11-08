use strict;
use warnings;
use Test::More;
use version;

my %prereqs = (
    'Archive::Tar' => '',
    'Archive::Zip' => '<= 1.65?(cloud6|cloud7)',
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

my $image_name = $ENV{TEST_IMAGE};

diag "\nChecking $image_name";

for my $module (sort keys %prereqs) {
    my $optional = $module =~ s/\?$//;
    my $required = $prereqs{$module};
    no strict 'refs';
    eval "require $module";
    if ($@ && $@ =~ /Can't locate/) {
        next if $optional;
        fail "$image_name: $module does not exist";
        next;
    }
    my $version = $module->VERSION // 0;
    if ($required) {
        my $todo = $required =~ s/\?(.*)$//;
        if (my $condition = $1) {
            $todo = 0 if $image_name !~ /$condition/;
        }
        SKIP: {
            local $TODO = 'may fail' if $todo;
            my ($op, $required_version);
            if ($required =~ / /) {
                ($op, $required_version) = split / /, $required;
            } else {
                ($op, $required_version) = ('>=', $required);
            }
            ok eval qq{version->parse($version) $op version->parse("$required_version")}, "$image_name: $module $version (required $required)";
        }
    } else {
        pass "$image_name: $module $version exists";
    }
}

my ($perl_version) = `perl -v` =~ /v(5\.\d+\.\d+)/;
ok $perl_version, "$image_name: Perl exists ($perl_version)";

my %imager_supports = map {$_ => 1} Imager->read_types;
ok $imager_supports{gif}, "$image_name: Imager supports GIF";
ok $imager_supports{png}, "$image_name: Imager supports PNG";
ok $imager_supports{jpeg}, "$image_name: Imager supports JPEG";

my %imagemagick_supports = map {$_ => 1} Image::Magick->QueryFormat;
ok $imagemagick_supports{gif}, "$image_name: ImageMagick supports GIF";
ok $imagemagick_supports{png}, "$image_name: ImageMagick supports PNG";
ok $imagemagick_supports{jpeg}, "$image_name: ImageMagick supports JPEG";
SKIP: {
    local $TODO = 'WebP may not be supported' if $image_name =~ /amazonlinux|bionic|centos6|centos7|jessie|oracle|stretch|trusty/;
    ok $imagemagick_supports{webp}, "$image_name: ImageMagick supports WebP";
}
my $imagemagick_depth = Image::Magick->new->Get('depth');
is $imagemagick_depth => '16', "$image_name: ImageMagick Quantum Depth: Q$imagemagick_depth";

my %graphicsmagick_supports = map {$_ => 1} Graphics::Magick->QueryFormat;
ok $graphicsmagick_supports{gif}, "$image_name: GraphicsMagick supports GIF";
ok $graphicsmagick_supports{png}, "$image_name: GraphicsMagick supports PNG";
ok $graphicsmagick_supports{jpeg}, "$image_name: GraphicsMagick supports JPEG";
SKIP: {
    local $TODO = 'WebP may not be supported' if $image_name =~ /centos6|jessie|trusty/;
    ok $graphicsmagick_supports{webp}, "$image_name: GraphicsMagick supports WebP";
}
SKIP: {
    local $TODO = 'may be 8' if $image_name =~ /centos6|jessie|trusty/;
    my $graphicsmagick_depth = Graphics::Magick->new->Get('depth');
    is $graphicsmagick_depth => '16', "$image_name: GraphicsMagick Quantum Depth: Q$graphicsmagick_depth";
}

my ($php_version) = `php --version` =~ /PHP (\d\.\d+\.\d+)/;
ok $php_version, "$image_name: PHP exists ($php_version)";

my $phpinfo = `php -i`;
ok $phpinfo =~ /(?:Multibyte decoding support using mbstring => enabled|Zend Multibyte Support => provided by mbstring|mbstring extension makes use of "streamable kanji code filter and converter")/, "$image_name: PHP has mbstring";
ok $phpinfo =~ /PDO drivers => .*?mysql/, "$image_name: PHP has PDO mysql driver";
ok $phpinfo =~ /GD Support => enabled/, "$image_name: PHP has GD";
ok $phpinfo =~ /DOM.XML => enabled/, "$image_name: PHP has DOM/XML";
ok $phpinfo =~ /GIF Read Support => enabled/, "$image_name: PHP supports GIF read";
ok $phpinfo =~ /GIF Create Support => enabled/, "$image_name: PHP supports GIF create";
ok $phpinfo =~ /JPEG Support => enabled/, "$image_name: PHP supports JPEG";
ok $phpinfo =~ /PNG Support => enabled/, "$image_name: PHP supports PNG";
SKIP: {
    local $TODO = 'Memcache may not be supported' if $image_name =~ /amazonlinux|oracle|sid/;
    ok $phpinfo =~ /memcache support => enabled/, "$image_name: PHP supports memcache";
}

my ($php_ini) = $phpinfo =~ m!Loaded Configuration File => (/\S+/php\.ini)!;
ok $php_ini, "$image_name: Loaded php.ini: $php_ini";
if (-e $php_ini) {
    my $ini = do { open my $fh, '<', $php_ini; local $/; <$fh>; };
    ok $ini =~ m!date\.timezone = "Asia/Tokyo"!, "$image_name: php.ini contains date.timezone = \"Asia/Tokyo\"";
}

my ($phpunit) = `phpunit --version` =~ /PHPUnit (\d+\.\d+\.\d+)/;
ok $phpunit, "$image_name: phpunit exists ($phpunit)";

my ($mysql_version, $is_maria) = `mysql --verbose --help 2>/dev/null` =~ /mysql\s+Ver.+?(\d+\.\d+\.\d+).+?(MariaDB)?/;
my $mysql = $is_maria ? "MariaDB" : "MySQL";
ok $mysql_version, "$image_name: $mysql exists ($mysql_version)";
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
ok $vsftpd_version, "$image_name: vsftpd exists ($vsftpd_version)";

my ($openssl_version) = Net::SSLeay::SSLeay_version() =~ /OpenSSL (\d+\.\d+\.\d+\w*)/i;
ok $openssl_version, "$image_name: openssl exists ($openssl_version)";

my $locale = `locale -a`;
ok $locale =~ /ja_JP\.utf8/, "$image_name: has Japanese locale" or warn $locale;

my ($tar) = `tar --version 2>&1` =~ /\A\w*tar (.+?[0-9.]+)/;
ok $tar, "$image_name: has tar $tar";

my ($zip) = `zip --version 2>&1` =~ /This is Zip ([0-9.]+)/;;
ok $zip, "$image_name: has zip $zip";

my ($unzip) = `unzip --version 2>&1` =~ /UnZip ([0-9.]+)/;
ok $unzip, "$image_name: has unzip $unzip";

my (@icc_profiles) = (`find /usr/share | grep '.icc\$'` // '') =~ /(\w+\.icc)$/gm;
my $srgb = grep /\bsRGB\.icc$/i, @icc_profiles;
SKIP: {
    local $TODO = 'CentOS 6 has no icc profile packages' if $image_name =~ /centos6/;
    ok @icc_profiles, "$image_name: has " . join(",", @icc_profiles);
    ok $srgb, "$image_name: has sRGB.icc";
}

done_testing;
