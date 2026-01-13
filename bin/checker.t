use strict;
use warnings;
use Test::More;
use version;

my $image_name = $ENV{TEST_IMAGE};

diag "\nChecking $image_name";

my %prereqs = (
    'Archive::Tar'            => '',
    'Archive::Zip'            => '<= 1.65?(cloud7|addons)',
    'DBI'                     => '1.633',
    'GD'                      => 0,
    'Graphics::Magick'        => 0,
    'Image::Magick?'          => 0,
    'Image::Magick::Q16?'     => 0,
    'Image::Magick::Q16HDRI?' => 0,
    'Imager'                  => 0,
    'Net::SSLeay'             => '1.85',
    'IO::Socket::SSL'         => '2.058',
);

if ($image_name eq 'postgresql') {
    $prereqs{'DBD::Pg'} = 0;
} else {
    $prereqs{'DBD::mysql'} = '4.000';
}

# temporary files

my @files = grep /[a-z]/, split /\n/, `ls -1a /root/`;
note explain \@files;
ok !grep(/\.(?:cpanm|perl-cpm)/, @files), "$image_name: no cpanm|cpm directories" or note explain \@files;

my $entrypoint_is_executed;
if (-e '/docker-entrypoint.sh' && $image_name !~ /chromedriver/) {
    my $entrypoint_sh = do { open my $fh, '<', '/docker-entrypoint.sh'; local $/; <$fh> };
    if ($entrypoint_sh =~ /mysql/ && $image_name !~ /(?:postgresql)/) {
        my $entrypoint = `/docker-entrypoint.sh`;
        note $entrypoint;
        $entrypoint_is_executed = 1;
    } else {
        note $entrypoint_sh;
    }
}

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

my @image_files = glob("./t/images/*");

my $gd_version     = eval { GD::LIBGD_VERSION() }  || 0;
my $gd_version_str = eval { GD::VERSION_STRING() } || 'unknown';
note "$image_name: GD version $gd_version ($gd_version_str)";
if ($gd_version >= 2.0101) {
    ok eval { GD::supportsFileType('test.gif') },  "$image_name: GD supports GIF";
    ok eval { GD::supportsFileType('test.png') },  "$image_name: GD supports PNG";
    ok eval { GD::supportsFileType('test.jpg') },  "$image_name: GD supports JPEG";
    ok eval { GD::supportsFileType('test.bmp') },  "$image_name: GD supports BMP";
    ok eval { GD::supportsFileType('test.webp') }, "$image_name: GD supports WEBP";
    SKIP: {
        local $TODO = 'AVIF may not be supported';
        ok eval { GD::supportsFileType('test.avif') }, "$image_name: GD supports AVIF";
    }
}
require GD::Image;
for my $file (@image_files) {
    my $gd = GD::Image->new($file);
    if (!$gd) {
        # bmp support is broken on all the known images
        local $TODO = 'GD does not support BMP?' if $file =~ /\.bmp$/ or ($file =~ /\.webp$/ && $image_name =~ /^(?:addons8|amazonlinux|centos|cloud7|fedora3[579]|fedora40|oracle|rockylinux)/);
        fail "$image_name: GD failed to read $file";
        next;
    }
    my ($w, $h) = $gd->getBounds();
    ok $w && $h, "$image_name: GD can get size of $file";
}

my $has_imager_webp = eval { require Imager::File::WEBP };
my $has_imager_avif = eval { require Imager::File::AVIF };
my %imager_supports = map { $_ => 1 } Imager->read_types;
ok $imager_supports{gif},  "$image_name: Imager supports GIF";
ok $imager_supports{png},  "$image_name: Imager supports PNG";
ok $imager_supports{jpeg}, "$image_name: Imager supports JPEG";
ok $imager_supports{bmp},  "$image_name: Imager supports BMP";
SKIP: {
    local $TODO = 'WebP may not be supported' unless $has_imager_webp;
    ok $imager_supports{webp}, "$image_name: Imager supports WebP";
}
SKIP: {
    local $TODO = 'AVIF may not be supported' unless $has_imager_avif;
    ok $imager_supports{avif}, "$image_name: Imager supports AVIF";
}
for my $file (@image_files) {
    next if $file =~ /\.webp$/ and !$has_imager_webp;
    my $imager = Imager->new;
    if (!$imager->read(file => $file)) {
        fail "$image_name: Imager failed to read $file";
        next;
    }
    my ($w, $h) = ($imager->getwidth, $imager->getheight);
    ok $w && $h, "$image_name: Imager can get size of $file";
}

my %imagemagick_supports = map { $_ => 1 } Image::Magick->QueryFormat;
ok $imagemagick_supports{gif},  "$image_name: ImageMagick supports GIF";
ok $imagemagick_supports{png},  "$image_name: ImageMagick supports PNG";
ok $imagemagick_supports{jpeg}, "$image_name: ImageMagick supports JPEG";
ok $imagemagick_supports{bmp},  "$image_name: ImageMagick supports BMP";
SKIP: {
    local $TODO = 'WebP may not be supported' if $image_name =~ /^(?:amazonlinux|centos7|oracle)$/;
    ok $imagemagick_supports{webp}, "$image_name: ImageMagick supports WebP";
}
SKIP: {
    local $TODO = 'AVIF may not be supported';
    ok $imagemagick_supports{avif}, "$image_name: ImageMagick supports AVIF";
}
my $imagemagick_depth = Image::Magick->new->Get('depth');
is $imagemagick_depth => '16', "$image_name: ImageMagick Quantum Depth: Q$imagemagick_depth";

for my $file (@image_files) {
    next if $file =~ /\.webp$/ and $image_name =~ /^(?:amazonlinux|centos7|oracle)$/;
    my $magick = Image::Magick->new;
    if (my $error = $magick->Read($file)) {
        fail "$image_name: ImageMagick failed to read $file: $error";
        next;
    }
    my ($w, $h) = $magick->Get('width', 'height');
    ok $w && $h, "$image_name: ImageMagick can get sizes of $file";
}

my %graphicsmagick_supports = map { $_ => 1 } Graphics::Magick->QueryFormat;
ok $graphicsmagick_supports{gif},  "$image_name: GraphicsMagick supports GIF";
ok $graphicsmagick_supports{png},  "$image_name: GraphicsMagick supports PNG";
ok $graphicsmagick_supports{jpeg}, "$image_name: GraphicsMagick supports JPEG";
ok $graphicsmagick_supports{bmp},  "$image_name: GraphicsMagick supports BMP";
ok $graphicsmagick_supports{webp}, "$image_name: GraphicsMagick supports WebP";
SKIP: {
    local $TODO = 'AVIF may not be supported';
    ok $graphicsmagick_supports{avif}, "$image_name: GraphicsMagick supports AVIF";
}
my $graphicsmagick_depth = Graphics::Magick->new->Get('depth');
is $graphicsmagick_depth => '16', "$image_name: GraphicsMagick Quantum Depth: Q$graphicsmagick_depth";

for my $file (@image_files) {
    my $magick = Graphics::Magick->new;
    if (my $error = $magick->Read($file)) {
        fail "$image_name: GraphicsMagick failed to read $file: $error";
        next;
    }
    my ($w, $h) = $magick->Get('width', 'height');
    ok $w && $h, "$image_name: GraphicsMagick can get sizes of $file";
}

my ($has_identify) = `which identify`;
ok $has_identify, "$image_name: has identify";
my ($has_convert) = `which convert`;
ok $has_convert, "$image_name: has convert";
my ($has_gm) = `which gm`;
ok $has_gm, "$image_name: has gm";

my ($php_version) = `php --version` =~ /PHP (\d\.\d+\.\d+)/;
ok $php_version, "$image_name: PHP exists ($php_version)";
(my $php_version_number = $php_version) =~ s/\.\d+$//;

my $phpinfo = `php -i`;
ok $phpinfo =~ /(?:
    Multibyte[ ]decoding[ ]support[ ]using[ ]mbstring[ ]=>[ ]enabled |
    Zend[ ]Multibyte[ ]Support[ ]=>[ ]provided[ ]by[ ]mbstring |
    mbstring[ ]extension[ ]makes[ ]use[ ]of[ ]"streamable[ ]kanji[ ]code[ ]filter[ ]and[ ]converter"
)/x, "$image_name: PHP has mbstring";
if ($image_name eq 'postgresql') {
    ok $phpinfo =~ /PDO drivers => .*?pgsql/, "$image_name: PHP has PDO pgsql driver";
} else {
    ok $phpinfo =~ /PDO drivers => .*?mysql/, "$image_name: PHP has PDO mysql driver";
}
ok $phpinfo =~ /GD Support => enabled/, "$image_name: PHP has GD";
ok $phpinfo =~ /DOM.XML => enabled/, "$image_name: PHP has DOM/XML";
ok $phpinfo =~ /GIF Read Support => enabled/,   "$image_name: PHP supports GIF read";
ok $phpinfo =~ /GIF Create Support => enabled/, "$image_name: PHP supports GIF create";
ok $phpinfo =~ /JPEG Support => enabled/,       "$image_name: PHP supports JPEG";
ok $phpinfo =~ /PNG Support => enabled/,        "$image_name: PHP supports PNG";
ok $phpinfo =~ /WebP Support => enabled/, "$image_name: PHP supports WebP";
SKIP: {
    local $TODO = 'Memcache may not be supported' if $image_name =~ /amazonlinux|oracle/;
    ok $phpinfo =~ /memcache support => enabled/, "$image_name: PHP supports memcache";
}
if ($image_name =~ /oracle/) {
    ok $phpinfo =~ /oci8/,              "$image_name: PHP supports oci8";
    ok $phpinfo =~ /PDO drivers .*oci/, "$image_name: PHP PDO supports oci";
}

my ($php_ini) = $phpinfo =~ m!Loaded Configuration File => (/\S+/php\.ini)!;
ok $php_ini, "$image_name: Loaded php.ini: $php_ini";
if (-e $php_ini) {
    my $ini = do { open my $fh, '<', $php_ini; local $/; <$fh>; };
    ok $ini =~ m!date\.timezone = "Asia/Tokyo"!, "$image_name: php.ini contains date.timezone = \"Asia/Tokyo\"";
}

# php cache stuff
my @wanted_lines = (
    'Configure Command',
    'Opcode Caching',
    'Optimization',
    'SHM Cache',
    'File Cache',
    'JIT',
    'Startup',
    'Shared memory model',
    'opcache.enable_cli',
    'opcache.jit',
);
for my $line (@wanted_lines) {
    my ($got) = $phpinfo =~ /^($line =>.+)$/m;
    $got ||= "no $line";
    diag "$image_name: php: $got";
}

SKIP: {
    my ($phpunit) = (`phpunit --version` // '') =~ /PHPUnit (\d+\.\d+\.\d+)/;
    ok $phpunit, "$image_name: phpunit exists ($phpunit)";
    if ($php_version_number >= 8.2) {
        is substr($phpunit, 0, 2) => 11, "$image_name: phpunit 11 (11.x.x) for php >= 8.2 ($php_version)";
    } elsif ($php_version_number >= 8.1) {
        is substr($phpunit, 0, 2) => 10, "$image_name: phpunit 10 (10.x.x) for php >= 8.1 ($php_version)";
    } elsif ($php_version_number >= 7.3) {
        is substr($phpunit, 0, 1) => 9, "$image_name: phpunit 9 (9.5.x) for php >= 7.3 ($php_version)";
    } elsif ($php_version_number >= 7.2) {
        is substr($phpunit, 0, 1) => 8, "$image_name: phpunit 8 (8.5.21) for php >= 7.2 ($php_version)";
    } elsif ($php_version_number >= 7.1) {
        is substr($phpunit, 0, 1) => 7, "$image_name: phpunit 7 (7.5.20) for php >= 7.1 ($php_version)";
    } elsif ($php_version_number >= 7.0) {
        is substr($phpunit, 0, 1) => 6, "$image_name: phpunit 6 (6.5.14) for php >= 7.0 ($php_version)";
    } elsif ($php_version_number >= 5.6) {
        is substr($phpunit, 0, 1) => 5, "$image_name: phpunit 5 (5.7.27) for php >= 5.6 ($php_version)";
    } else {
        is substr($phpunit, 0, 1) => 4, "$image_name: phpunit 4 (4.8.36) for php >= 5.3 ($php_version)";
    }
}

if ($image_name eq 'postgresql') {
    my ($postgresql_version) = `su -c 'postgres --version' postgres 2>/dev/null` =~ /postgres .+?(\d+\.\d+)/;
    ok $postgresql_version, "$image_name: postgresql exists ($postgresql_version)";
} else {
    my ($mysql_version, $is_maria) = `mysql --verbose --help 2>/dev/null` =~ /mysql\s+(?:from|Ver).+?(\d+\.\d+\.\d+).+?(MariaDB)?/;
    my $mysql = $is_maria ? "MariaDB" : "MySQL";
    ok $mysql_version, "$image_name: $mysql exists ($mysql_version)";
    my $sql_mode = `mysql -Nse 'select \@\@sql_mode' 2>&1`;
    note "SQL mode: $sql_mode";
    if ($sql_mode =~ /Can't connect to local MySQL/) {
        fail "$image_name: failed to connect to local mysql" if $entrypoint_is_executed;
    }
    if ($mysql_version =~ /^5\.[567]\./ or $mysql_version =~ /^10\.[0123]\./) {
        my ($file_format)    = `mysql -Nse 'select \@\@innodb_file_format'`    =~ /(\w+)/;
        my ($file_per_table) = `mysql -Nse 'select \@\@innodb_file_per_table'` =~ /(\w+)/;
        my ($large_prefix)   = `mysql -Nse 'select \@\@innodb_large_prefix'`   =~ /(\w+)/;
        $file_format    //= '';
        $file_per_table //= '';
        $large_prefix   //= '';
        note "InnoDB: file format $file_format, file per table $file_per_table, large prefix $large_prefix";
    }
}

my ($ruby_version) = `ruby --version 2>&1` =~ /ruby (\d+\.\d+.\d+)/;
ok $ruby_version, "$image_name: ruby exists ($ruby_version)";
my ($fluentd_version) = `fluentd --version 2>&1` =~ /fluentd (\d+\.\d+\.\d+)/;
ok $fluentd_version, "$image_name: fluentd exists ($fluentd_version)";

my ($openssl_version) = Net::SSLeay::SSLeay_version() =~ /OpenSSL (\d+\.\d+\.\d+\w*)/i;
ok $openssl_version, "$image_name: openssl exists ($openssl_version)";

my $locale = `locale -a`;
ok $locale =~ /ja_JP\.utf8/, "$image_name: has Japanese locale" or warn $locale;

my ($tar) = `tar --version 2>&1` =~ /\A\w*tar (.+?[0-9.]+)/;
ok $tar, "$image_name: has tar $tar";

my ($zip) = `zip --version 2>&1` =~ /This is Zip ([0-9.]+)/;
ok $zip, "$image_name: has zip $zip";

my ($unzip) = `unzip --version 2>&1` =~ /UnZip ([0-9.]+)/;
ok $unzip, "$image_name: has unzip $unzip";

my ($mailpit) = `mailpit version 2>&1` =~ /mailpit v([0-9.]+)/;
ok $mailpit, "$image_name: has mailpit $mailpit";

my (@icc_profiles) = (`find /usr/share | grep '.icc\$'` // '') =~ /(\w+\.icc)$/gm;
my $srgb = grep /\bsRGB\.icc$/i, @icc_profiles;
ok @icc_profiles, "$image_name: has " . join(",", @icc_profiles);
ok $srgb,         "$image_name: has sRGB.icc";

if ($image_name =~ /oracle/) {
    my ($sqlplus_version) = (`sqlplus -v`) =~ /^Version (\d+\.\d+)/m;
    ok $sqlplus_version, "$image_name: sqlplus exists ($sqlplus_version)";
}

if (`which sendmail`) {
    ok !system('sendmail', '-bd'), "start sendmail daemon" or diag $!;
}

if ($image_name =~ /chrom/) {
    my ($chromedriver_version) = `/usr/bin/chromedriver -v` =~ /ChromeDriver ([0-9.]+)/;
    ok $chromedriver_version, "$image_name: chromedriver exists ($chromedriver_version)";
}

if ($image_name =~ /playwright/) {
    my ($playwright_version) = `/usr/bin/playwright --version` =~ /Version ([0-9.]+)/;
    ok $playwright_version, "$image_name: playwright exists ($playwright_version)";
    my ($node_version) = `node -v` =~ /v([0-9.]+)/;
    ok $node_version, "$image_name: node exists ($node_version)";
}

if ($image_name =~ /addons/) {
    my ($vsftpd_version) = `/usr/sbin/vsftpd -v 0>&1 2>&1` =~ /version (\d+\.\d+\.\d+)/;
    ok $vsftpd_version, "$image_name: vsftpd exists ($vsftpd_version)";
    my ($proftpd_version) = `/usr/local/sbin/proftpd -v 2>&1` =~ /ProFTPD Version (\d+\..+)/;
    ok $proftpd_version, "$image_name: proftpd exists ($proftpd_version)";
    my ($pureftpd_version) = `/usr/local/sbin/pure-ftpd --help 2>&1` =~ /pure-ftpd v(\d+\.\d+.\d+)/;
    ok $pureftpd_version, "$image_name: pureftpd exists ($pureftpd_version)";
}

if ($image_name =~ /addons8/) {
    my ($slapd_version) = `/usr/sbin/slapd -V 2>&1` =~ /OpenLDAP: slapd (\d+\.\d+\.\d+)/s;
    ok $slapd_version, "$image_name: slapd exists ($slapd_version)";
}

# security

my $has_xz = `which xz` =~ /\bxz$/;
if ($has_xz) {
    my ($xz_version) = `xz --version` =~ /xz.+?([0-9.]+)/;
    ok $xz_version !~ /^5\.6\.[01]$/, "$image_name: xz is not affected by CVE-2024-3094 ($xz_version)";
}

done_testing;
