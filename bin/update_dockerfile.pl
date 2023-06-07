#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Data::Section::Simple qw/get_data_section/;
use Mojo::Template;
use Mojo::File qw/path/;

my %Conf = (
    debian => {
        apt => {
            base => [qw(
                ca-certificates netbase git make gcc curl ssh locales perl
                zip unzip bzip2 procps ssl-cert postfix
            )],
            images => [qw(
                perlmagick libgraphics-magick-perl netpbm imagemagick graphicsmagick
                libgd-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev
                icc-profiles-free
            )],
            server => [qw( apache2 vsftpd ftp memcached )],
            db     => [qw( mysql-server mysql-client libmysqlclient-dev )],
            libs   => [qw( libxml2-dev libgmp-dev libssl-dev )],
            php    => [qw( php php-cli php-mysqlnd php-gd php-memcache phpunit )],
            editor => [qw( vim nano )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken  => [qw( Archive::Zip@1.65 )],
            extra   => [qw( JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy )],
            addons  => [qw( Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers )],
            bcompat => [qw( pQuery )],
        },
    },
    centos => {
        yum => {
            base => [qw(
                git make gcc curl perl perl-core
                tar zip unzip bzip2 which procps postfix
            )],
            images => [qw(
                ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick
                giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel
                icc-profiles-openicc
            )],
            server => [qw( mod_ssl vsftpd ftp memcached )],
            db     => [qw( mysql-devel mysql-server mysql )],
            libs   => [qw( libxml2-devel expat-devel openssl-devel openssl gmp-devel )],
            php    => [qw( php php-mysqlnd php-gd php-mbstring php-pecl-memcache phpunit )],
            editor => [qw( vim nano )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken  => [qw( Archive::Zip@1.65 )],
            extra   => [qw( JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy )],
            addons  => [qw( Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers )],
            bcompat => [qw( pQuery )],
        },
    },
    sid => {
        from => 'debian:sid-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => '',
                'php'                => 'php8.2',
                'php-cli'            => 'php8.2-cli',
                'php-mysqlnd'        => 'php8.2-mysql',
                'php-gd'             => 'php8.2-gd',
                'php-memcache'       => 'php8.2-memcache',
                'phpunit'            => '',
            },
            db => [qw( libdbd-mysql-perl )],
            php => [qw( php8.2-mbstring php8.2-xml )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
            extra   => [qw( GD )],
        },
        phpunit => 9,
    },
    bookworm => {
        from => 'debian:bookworm-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => '',
                'phpunit'            => '',
            },
            db => [qw( libdbd-mysql-perl )],
            php => [qw( php-mbstring php-xml )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        phpunit => 9,
    },
    bullseye => {
        from => 'debian:bullseye-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => '',
                'phpunit'            => '',
            },
            db => [qw( libdbd-mysql-perl )],
            php => [qw( php-mbstring php-xml )],
        },
        phpunit => 9,
    },
    buster => {
        from => 'debian:buster-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => '',
                'phpunit' => '',
            },
            db => [qw( libdbd-mysql-perl )],
            php => [qw( php-mbstring php-xml )],
        },
        apache => {
            enmod => [qw( php7.3 )],
        },
        phpunit => 9,
    },
    jessie => {
        from => 'debian/eol:jessie-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'php'          => 'php5',
                'php-cli'      => 'php5-cli',
                'php-mysqlnd'  => 'php5-mysqlnd',
                'php-gd'       => 'php5-gd',
                'php-memcache' => 'php5-memcache',
                'libgd-dev'    => 'libgd2-xpm-dev',
            },
        },
        cpan => {
            no_test => [qw( YAML::Syck@1.31 )],
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for jessie is too old (0.4.1 as of this writing)
            },
        },
        apache => {
            enmod => [qw( php5 )],
        },
        phpunit => 5,
    },
    stretch => {
        from => 'debian:stretch-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'libgd-dev'          => 'libgd2-xpm-dev',
                'libmysqlclient-dev' => 'libmysql++-dev',
            },
            php => [qw/ php-mbstring /],
        },
        cpan => {
            no_test => [qw( YAML::Syck@1.31 )],
        },
        apache => {
            enmod => [qw( php7.0 )],
        },
        phpunit => 6,
        use_cpanm => 1,
    },
    bionic => {
        from => 'ubuntu:bionic',
        base => 'debian',
        apt  => {
            _replace => {
                'php-mysqlnd' => 'php-mysql',
                'phpunit' => '',
            },
            php => [qw( php-mbstring php-xml )]
        },
        apache => {
            enmod => [qw( php7.2 )],
        },
        phpunit => 8,
    },
    trusty => {
        from => 'ubuntu:trusty',
        base => 'debian',
        apt  => {
            _replace => {
                'php'                => 'php5',
                'php-cli'            => 'php5-cli',
                'php-mysqlnd'        => 'php5-mysql',
                'php-gd'             => 'php5-gd',
                'php-memcache'       => 'php5-memcache',
                'libgd-dev'          => 'libgd2-xpm-dev',
                'libmysqlclient-dev' => 'libmysql++-dev',
                'libpng-dev'         => 'libpng12-dev',
            },
        },
        cpan => {
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for trusty is too old (0.4.0 as of this writing)
            },
        },
        apache => {
            enmod => [qw( php5 )],
        },
        phpunit => 4,
        use_cpanm => 1,
    },
    fedora37 => {
        from => 'fedora:37',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
                'phpunit' => '',
            },
            base => [qw( glibc-langpack-en glibc-langpack-ja )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        patch => ['Test-mysqld-1.0013'],
        make_dummy_cert => '/usr/bin',
        installer => 'dnf',
        setcap    => 1,
        phpunit => 9,
    },
    fedora36 => {
        from => 'fedora:36',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
                'phpunit' => '',
            },
            base => [qw( glibc-langpack-en glibc-langpack-ja )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        patch => ['Test-mysqld-1.0013'],
        make_dummy_cert => '/usr/bin',
        installer => 'dnf',
        setcap    => 1,
        phpunit => 9,
    },
    fedora35 => {
        from => 'fedora:35',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
                'phpunit' => '',
            },
            base => [qw( glibc-langpack-en glibc-langpack-ja )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        patch => ['Test-mysqld-1.0013'],
        make_dummy_cert => '/usr/bin',
        installer => 'dnf',
        setcap    => 1,
        phpunit => 9,
    },
    fedora32 => {
        from => 'fedora:32',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
                'phpunit' => '',
            },
            base => [qw( glibc-langpack-en glibc-langpack-ja )],
        },
        make_dummy_cert => '/usr/bin',
        installer => 'dnf',
        setcap    => 1,
        phpunit => 9,
    },
    fedora23 => {
        from => 'fedora:23',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
            },
            base => [qw( hostname )],
        },
        cpan => {
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for fedora23 is too old (0.4.4 as of this writing)
            },
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        installer => 'dnf',
        make_dummy_cert => '/etc/pki/tls/certs/',
        phpunit => 5,
        no_update => 1,
    },
    centos6 => {
        from => 'centos:6',
        base => 'centos',
        yum  => {
            _replace => {
                'php-mysqlnd' => 'php-mysql',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'libwebp-devel' => '',
                'icc-profiles-openicc' => '',
            },
            libs => [qw( perl-XML-Parser )],
        },
        repo => {
            epel => [qw( GraphicsMagick-perl GraphicsMagick libwebp-devel )],
            remi => [qw( php55-php php55-php-mbstring php55-php-mysqlnd php55-php-gd php55-php-pecl-memcache php55-php-xml )],
        },
        epel => {
            rpm => 'epel-release',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-6.rpm',
            enable => 'remi,remi-php55',
            php_version => 'php55',
        },
        cpan => {
            no_test => [qw(
                CryptX Test::Deep@1.130 Email::MIME::ContentType@1.026 Email::MIME::Encodings@1.315
                Email::MessageID@1.406 Email::Date::Format@1.005 Email::Simple@2.217 Email::MIME@1.952
            )],
            broken => [qw( Math::GMP@2.22 Mojolicious@8.43 JSON::Validator@4.25 )],
            missing => [qw( App::cpanminus DBD::SQLite )],
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for centos6/epel is too old (0.4.3 as of this writing)
            },
        },
        use_cpanm => 1,
        phpunit => 4,
    },
    centos7 => {
        from => 'centos:7',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'mariadb',
                'mysql-server' => 'mariadb-server',
                'mysql-devel'  => 'mariadb-devel',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
            },
        },
        repo => {
            epel => [qw( GraphicsMagick-perl GraphicsMagick )],
            remi => [qw( php71-php php71-php-mbstring php71-php-mysqlnd php71-php-gd php71-php-pecl-memcache php71-php-xml )],
        },
        epel => {
            rpm => 'epel-release',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-7.rpm',
            enable => 'remi,remi-php71',
            php_version => 'php71',
        },
        cpan => {
            missing => [qw( TAP::Harness::Env )],
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for centos7/updates is too old (0.3.0 as of this writing)
            },
        },
        phpunit => 7,
        locale_def => 1,
    },
    centos8 => {
        from => 'centos:8',
        base => 'centos',
        yum  => {
            _replace => {
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'ssh' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'ImageMagick' => '',
                'ImageMagick-perl' => '',
                'perl-GD' => '',
                'giflib-devel' => '',
                'icc-profiles-openicc' => '',
            },
            base => [qw/ glibc-langpack-ja /],
        },
        epel => {
            rpm => 'epel-release',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-8.4.rpm',
            module => {
                reset => 'php',
                enable => 'php:remi-8.0',
            },
            php_version => 'php80',
        },
        repo => {
            epel => [qw( GraphicsMagick-perl ImageMagick-perl perl-GD ImageMagick GraphicsMagick )],
            remi => [qw( php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml )],
            PowerTools => [qw/ giflib-devel /],
        },
        installer               => 'dnf',
        setcap                  => 1,
        make_dummy_cert => '/usr/bin',
        phpunit => 9,
        no_best => 1,
        use_cpanm => 1,
    },
    rockylinux => {
        from => 'rockylinux:9.2',
        base => 'centos',
        yum  => {
            _replace => {
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'ssh' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'ImageMagick' => '',
                'ImageMagick-perl' => '',
                'perl-GD' => '',
                'giflib-devel' => '',
                'icc-profiles-openicc' => '',
                'mysql-devel' => '',
            },
            base => [qw/ glibc-langpack-ja glibc-langpack-en glibc-locale-source libdb-devel /],
        },
        epel => {
            rpm => 'epel-release',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-9.rpm',
            module => {
                reset => 'php',
                enable => 'php:remi-8.1',
            },
            php_version => 'php81',
        },
        repo => {
            epel => [qw( GraphicsMagick-perl ImageMagick-perl perl-GD ImageMagick GraphicsMagick )],
            remi => [qw( php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml )],
            crb  => [qw( mysql-devel giflib-devel )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        patch => ['Test-mysqld-1.0013'],
        installer               => 'dnf',
        setcap                  => 1,
        make_dummy_cert => '/usr/bin',
        phpunit => 9,
        allow_erasing => 1,
    },
    almalinux => {
        from => 'almalinux:9.0',
        base => 'centos',
        yum  => {
            _replace => {
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'ssh' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'ImageMagick' => '',
                'ImageMagick-perl' => '',
                'perl-GD' => '',
                'giflib-devel' => '',
                'icc-profiles-openicc' => '',
                'mysql-devel' => '',
            },
            base => [qw/ glibc-langpack-ja glibc-langpack-en glibc-locale-source /],
        },
        epel => {
            rpm => 'epel-release',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-9.rpm',
            module => {
                reset => 'php',
                enable => 'php:remi-8.1',
            },
            php_version => 'php81',
        },
        repo => {
            epel => [qw( GraphicsMagick-perl ImageMagick-perl perl-GD ImageMagick GraphicsMagick )],
            remi => [qw( php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml )],
            crb  => [qw( mysql-devel giflib-devel )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        patch => ['Test-mysqld-1.0013'],
        installer               => 'dnf',
        setcap                  => 1,
        make_dummy_cert => '/usr/bin',
        phpunit => 9,
        allow_erasing => 1,
    },
    cloud6 => {
        from => 'centos:7',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => '',
                'mysql-server' => '',
                'mysql-devel'  => '',
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'perl-GD' => '',
                'ImageMagick' => '',
                'ImageMagick-perl' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
            },
        },
        cpan => {
            missing => [qw( App::cpanminus TAP::Harness::Env )],
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for cloud6/updates is too old (0.3.0 as of this writing)
            },
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        phpunit => 9,
        make => {
            perl => '5.28.2',
            ImageMagick => '7.0.8-68',
            GraphicsMagick => '1.3.36',
        },
        repo => {
            'mysql57-community' => [qw( mysql-community-server mysql-community-client mysql-community-devel )],
            remi => [qw( php74-php php74-php-mbstring php74-php-mysqlnd php74-php-gd php74-php-pecl-memcache php74-php-xml )],
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-7.rpm',
            enable => 'remi,remi-php74',
            php_version => 'php74',
        },
        'mysql57-community' => {
            rpm => 'http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm',
            gpg_key => 'https://repo.mysql.com/RPM-GPG-KEY-mysql-2022',
        },
        cloud_prereqs => 'conf/cloud_prereqs6',
        use_cpanm => 1,
        locale_def => 1,
        no_update => 1,
    },
    cloud7 => {
        from => 'rockylinux:9.2',
        base => 'centos',
        yum  => {
            _replace => {
                'php' => '',
                'php-cli' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-gd' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'perl-GD' => '',
                'ImageMagick' => '',
                'ImageMagick-perl' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'icc-profiles-openicc' => '',
                'giflib-devel' => '',
                'mysql-devel' => '',
            },
            base => [qw/ glibc-langpack-ja glibc-langpack-en glibc-locale-source xz /],
            libs => [qw/ ncurses-devel libdb-devel /],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
            addons  => [qw( Net::LibIDN )],
        },
        phpunit => 9,
        make => {
            perl => '5.36.1',
            ImageMagick => '7.0.8-68',
            GraphicsMagick => '1.3.36',
        },
        repo => {
            remi => [qw( php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml )],
            crb  => [qw( mysql-devel giflib-devel )],
            epel => [qw( libidn-devel )],
        },
        epel => {
            rpm => 'epel-release',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-9.rpm',
            module => {
                reset => 'php',
                enable => 'php:remi-8.0',
            },
            php_version => 'php80',
        },
        cloud_prereqs => 'conf/cloud_prereqs7',
        patch => ['Test-mysqld-1.0013'],
        installer => 'dnf',
        setcap => 1,
        make_dummy_cert => '/usr/bin',
        allow_erasing => 1,
        use_cpanm => 1,
        locale_def => 1,
        no_update => 1,
    },
    amazonlinux => {
        from => 'amazonlinux:2',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'mariadb',
                'mysql-server' => 'mariadb-server',
                'mysql-devel'  => 'mariadb-devel',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'php' => '',
                'php-mysqlnd' => '',
                'php-gd' => '',
                'php-mbstring' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
            },
            base   => [qw( which hostname glibc-langpack-ja )],
            server => [qw( httpd )], ## for mod_ssl
        },
        cpan => {
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for amazonlinux is too old (0.3.0)
            },
            no_test => [qw(XML::DOM)],
        },
        'GraphicsMagick1.3' => {
            enable => 'amzn2extra-GraphicsMagick1.3',
        },
        'php7.4' => {
            enable => 'amzn2extra-php7.4',
        },
        repo => {
            'GraphicsMagick1.3' => [qw( GraphicsMagick-perl GraphicsMagick )],
            'php7.4' => [qw( php php-mysqlnd php-gd php-mbstring php-xml )],
        },
        make_dummy_cert => '/etc/pki/tls/certs/',
        phpunit => 9,
        use_cpanm => 1,
    },
    amazonlinux2022 => {
        from => 'amazonlinux:2022',
        base => 'centos',
        yum  => {
            _replace => {
                ftp => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
            },
            base   => [qw( which hostname glibc-langpack-ja glibc-locale-source )],
            server => [qw( httpd )], ## for mod_ssl
            db     => [qw( mariadb105-pam )],
            php    => [qw( php-cli php-xml php-json )],
        },
        cpan => {
            # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/17
            no_test => [qw( HTML::TreeBuilder::LibXML )],
        },
        make_dummy_cert => '/usr/bin',
        installer => 'dnf',
        phpunit => 9,
        locale_def => 1,
    },
    oracle => {
        from => 'oraclelinux:7-slim',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'mariadb',
                'mysql-server' => 'mariadb-server',
                'mysql-devel'  => 'mariadb-devel',
                'php' => '',
                'php-gd' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'giflib-devel' => '',
                'gd-devel' => '',
                'libwebp-devel' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'icc-profiles-openicc' => '',
            },
            base   => [qw( which )],
            server => [qw( httpd )],
        },
        epel => {
            rpm => 'oracle-epel-release-el7',
            enable => 'ol7_developer_EPEL',
        },
        ol7_developer_php74 => {
            rpm => 'oracle-php-release-el7',
            enable => 'ol7_developer_php74',
        },
        instantclient => {
            rpm => 'https://download.oracle.com/otn_software/linux/instantclient/217000/oracle-instantclient-basic-21.7.0.0.0-1.x86_64.rpm',
        },
        repo => {
            ol7_optional_latest => [qw( gd-devel giflib-devel libwebp-devel )],
            ol7_developer_php74 => [qw( php php-mysqlnd php-gd php-mbstring phpunit php-oci8-21c )],
            epel => [qw( GraphicsMagick-perl-1.3.32-1.el7 )],
        },
        cpan => {
            no_test => [qw( DBI Test::NoWarnings )],
            missing => [qw( DBD::Oracle )],
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for oracle is too old (0.3.0 as of this writing)
            },
        },
        make_dummy_cert => '/etc/pki/tls/certs/',
        phpunit => 9,
        release => 19.6,
        use_cpanm => 1,
    },
    oracle8 => {
        from => 'oraclelinux:8-slim',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql' => 'mariadb',
                'mysql-server' => 'mariadb-server',
                'mysql-devel'  => 'mariadb-devel',
                'php' => '',
                'php-gd' => '',
                'php-mysqlnd' => '',
                'php-mbstring' => '',
                'php-pecl-memcache' => '',
                'phpunit' => '',
                'giflib-devel' => '',
                'gd-devel' => '',
                'libwebp-devel' => '',
                'ImageMagick' => '',
                'ImageMagick-perl' => '',
                'GraphicsMagick' => '',
                'GraphicsMagick-perl' => '',
                'icc-profiles-openicc' => '',
                'perl-GD' => '',
            },
            base   => [qw( which glibc-locale-source )],
            server => [qw( httpd )],
        },
        epel => {
            rpm => 'oracle-epel-release-el8',
            enable => 'ol8_developer_EPEL',
        },
        instantclient => {
            rpm => 'oracle-instantclient-release-el8',
            enable => 'ol8_oracle_instantclient21',
        },
        codeready => {
            enable => 'ol8_codeready_builder',
        },
        remi => {
            rpm => 'https://rpms.remirepo.net/enterprise/remi-release-8.4.rpm',
            module => {
                reset => 'php',
                enable => 'php:remi-8.2',
            },
            php_version => 'php82',
        },
        repo => {
            instantclient => [qw(
                oracle-instantclient-basic
                oracle-instantclient-devel
                oracle-instantclient-sqlplus
            )],
            # oracle epel8 does not have giflib-devel
            epel => [qw(
                ImageMagick ImageMagick-perl GraphicsMagick GraphicsMagick-perl
                gd-devel libwebp-devel
                perl-GD
            )],
            remi => [qw( php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml php-oci8 )],
            codeready => [qw( giflib-devel )],
        },
        cpan => {
            no_test => [qw( DBI Test::NoWarnings )],
            missing => [qw( DBD::Oracle )],
            _replace => {
                'Imager::File::WEBP' => '',   # libwebp for oracle is too old (0.3.0 as of this writing)
            },
        },
        make_dummy_cert => '/usr/bin',
        phpunit => 9,
        installer => 'microdnf',
        release => 19.6,
        locale_def => 1,
        no_update => 1,
    },
);

my $templates = get_data_section();

my @targets = @ARGV ? @ARGV : grep $Conf{$_}{base}, sort keys %Conf;
for my $name (@targets) {
    if (!exists $Conf{$name}) {
        say "unknown target: $name";
        next;
    }
    my $base = $Conf{$name}{base};
    my $template    = $templates->{$name} || $templates->{$base};
    my $ep_template = $templates->{"$name-entrypoint"} || $templates->{"$base-entrypoint"};
    say $name;
    mkdir $name unless -d $name;
    my $conf       = merge_conf($name);
    my $dockerfile = Mojo::Template->new->render($template, $name, $conf);
    my $entrypoint = Mojo::Template->new->render($ep_template, $name, $conf);
    path("$name/Dockerfile")->spurt($dockerfile);
    path("$name/docker-entrypoint.sh")->spurt($entrypoint)->chmod(0755);
    if ($conf->{patch}) {
        require File::Copy::Recursive;
        for my $target (@{$conf->{patch}}) {
            path("$name/patch")->make_path;
            File::Copy::Recursive::dircopy("patch/$target", "$name/patch/$target");
        }
        path("$name/patch/.gitignore")->spurt('*');
    }
}

sub merge_conf {
    my $name  = shift;
    my %conf = %{ $Conf{$name} // {} };
    my $base = $conf{base} or return \%conf;
    for my $key (keys %{ $Conf{$base} }) {
        my %replace = %{ delete $conf{$key}{_replace} || {} };
        for my $subkey (keys %{ $Conf{$base}{$key} }) {
            my @values = @{ $conf{$key}{$subkey} || [] };
            for my $value (@{ $Conf{$base}{$key}{$subkey} }) {
                if (exists $replace{$value}) {
                    my $new_value = $replace{$value};
                    push @values, $new_value if $new_value;
                } else {
                    push @values, $value;
                }
            }
            $conf{$key}{$subkey} = \@values if @values;
        }
    }
    \%conf;
}

sub load_prereqs {
    my $file = shift;
    my @dists = grep {defined $_ && $_ ne '' && !/^#/} split /\n/, path($file)->slurp;
    # Use cpan.metacpan.org explicitly as it is actually a backpan
    # (CDN-based) www.cpan.org does not serve some of the older prereqs anymore (which should be updated anyway)
    return map { join "/", "https://cpan.metacpan.org/authors/id", substr($_, 0, 1), substr($_, 0, 2), $_} @dists;
}

__DATA__

@@ debian
% my ($type, $conf) = @_;
FROM <%= $conf->{from} %>

WORKDIR /root

RUN apt-get update &&\\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\\
 apt-get --no-install-recommends -y install\\
% for my $key (sort keys %{ $conf->{apt} }) {
 <%= join " ", @{$conf->{apt}{$key}} %>\\
% }
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\\
 ln -s /usr/sbin/apache2 /usr/sbin/httpd &&\\
% if ($conf->{phpunit}) {
 curl -skL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
 mv phpunit /usr/local/bin/ &&\\
% }
% if ($conf->{use_cpanm} or $conf->{patch}) {
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\\
% }
% if ($conf->{patch}) {
%   for my $patch (@{$conf->{patch}}) {
      cd /root/patch/<%= $patch %> && cpanm --installdeps . && cpanm . && cd /root &&\\
%   }
    rm -rf /root/patch &&\\
% }
 curl -skL --compressed https://git.io/cpm > cpm &&\\
 chmod +x cpm &&\\
 mv cpm /usr/local/bin/ &&\\
 cpm install -g <%= join " ", @{delete $conf->{cpan}{no_test}} %> &&\\
% if ($conf->{use_cpanm}) {
 cpanm -v \\
% } else {
 cpm install -g --test\\
% }
% for my $key (sort keys %{ $conf->{cpan} }) {
 <%= join " ", @{ $conf->{cpan}{$key} } %>\\
% }
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\\
% if ($conf->{use_cpanm}) {
 cpanm -v --installdeps . \\
% } else {
 cpm install -g --test\\
% }
 && rm -rf cpanfile /root/.perl-cpm/

RUN set -ex &&\\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\\
 localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 &&\\
 a2dismod mpm_event &&\\
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl <%= join " ", @{ $conf->{apache}{enmod} || [] } %> &&\\
 a2enconf serve-cgi-bin &&\\
 a2ensite default-ssl &&\\
 make-ssl-cert generate-default-snakeoil &&\\
 find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe \\
   's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' &&\\
 perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \\
   my $ini = do { open my $fh, "<", $inifile or die $!; local $/; <$fh> }; \\
   $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \\
   open my $fh, ">", $inifile or die $!; print $fh $ini'


ENV LANG=en_US.UTF-8 \\
    LC_ALL=en_US.UTF-8 \\
    APACHE_RUN_DIR=/var/run/apache2 \\
    APACHE_RUN_USER=www-data \\
    APACHE_RUN_GROUP=www-data \\
    APACHE_LOG_DIR=/var/log/apache2 \\
    APACHE_PID_FILE=/var/run/apache2.pid \\
    APACHE_LOCK_DIR=/var/lock/apache2 \\
    APACHE_CONF_DIR=/etc/apache2

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

@@ centos
% my ($type, $conf) = @_;
FROM <%= $conf->{from} %>

WORKDIR /root

% if ($conf->{patch}) {
COPY ./patch/ /root/patch/
% }

RUN\
% if ($type =~ /^centos[68]$/) {
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\\
% }
% if ($type =~ /^oracle[89]$/) {
  <%= $conf->{installer} // 'yum' %> -y install dnf &&\\
  % $conf->{installer} = 'dnf';
% }
 <%= $conf->{installer} // 'yum' %> -y <% if ($conf->{allow_erasing}) { %>--allowerasing<% } %> install\\
% for my $key (sort keys %{ $conf->{yum} }) {
 <%= join " ", @{$conf->{yum}{$key}} %>\\
% }
 &&\\
% if ($type eq 'oracle') {
 yum -y install <%= $conf->{instantclient}{rpm} %> &&\\
 yum -y install oracle-instantclient-basic oracle-instantclient-release-el7 &&\\
 yum -y install oracle-instantclient-devel oracle-instantclient-sqlplus &&\\
 yum -y reinstall glibc-common &&\\
% }
% for my $repo (sort keys %{$conf->{repo} || {}}) {
%   if ($type eq 'amazonlinux') {
 amazon-linux-extras install <%= $repo %> &&\\
%   } elsif ($conf->{$repo}{rpm}) {
 <%= $conf->{installer} // 'yum' %> -y install <%= $conf->{$repo}{rpm} %> &&\\
%     if ($conf->{$repo}{gpg_key}) {
 rpm --import <%= $conf->{$repo}{gpg_key} %> &&\\
%     }
%     if ($type =~ /^centos[68]$/) {
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\\
%     }
%   }
%   if ($conf->{$repo}{module}) {
%#    unfortunately the return value of dnf module seems too unstable
    % if ($conf->{$repo}{module}{reset}) {
    <%= $conf->{installer} // 'yum' %> -y module reset <%= $conf->{$repo}{module}{reset} %> ;\\
    % }
    <%= $conf->{installer} // 'yum' %> -y module enable <%= $conf->{$repo}{module}{enable} %> ;\\
    <%= $conf->{installer} // 'yum' %> -y install\\
%   } else {
    <%= $conf->{installer} // 'yum' %> -y --enablerepo=<%= $conf->{$repo}{enable} // $repo %> install\\
%   }
 <%= join " ", @{$conf->{repo}{$repo}} %>\\
%   if ($conf->{$repo}{enable}) {
 && <%= $conf->{installer} // 'yum' %> clean --enablerepo=<%= $conf->{$repo}{enable} // $repo %> all &&\\
%   } else {
 &&\\
%   }
% }
% if (!$conf->{no_update}) {
 <%= $conf->{installer} // 'yum' %> -y update --skip-broken<% if ($conf->{no_best}) { %> --nobest<% } %> &&\\
% }
 <%= $conf->{installer} // 'yum' %> clean all && rm -rf /var/cache/<%= $conf->{installer} // 'yum' %> &&\\
% if ($conf->{make}) {
 mkdir src && cd src &&\\
 curl -kLO http://cpan.metacpan.org/src/5.0/perl-<%= $conf->{make}{perl} %>.tar.gz && tar xf perl-<%= $conf->{make}{perl} %>.tar.gz &&\\
 cd perl-<%= $conf->{make}{perl} %> && ./Configure -des -Dprefix=/usr -Accflags=-fPIC -Duseshrplib && make && make install && cd .. &&\\
 curl -kLO https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/<%= $conf->{make}{GraphicsMagick} %>/GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %>.tar.gz &&\\
 tar xf GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %>.tar.gz && cd GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %> &&\\
 ./configure --enable-shared --with-perl --disable-openmp --disable-opencl --disable-dependency-tracking --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-fpx --without-jpig --without-lcms2 --without-lzma --without-xml --without-gs --with-quantum-depth=16 && make && make install && cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\\
 curl -kLO https://imagemagick.org/archive/releases/ImageMagick-<%= $conf->{make}{ImageMagick} %>.tar.xz &&\\
 tar xf ImageMagick-<%= $conf->{make}{ImageMagick} %>.tar.xz && cd ImageMagick-<%= $conf->{make}{ImageMagick} %> &&\\
 ./configure --enable-shared --with-perl --disable-openmp --disable-dependency-tracking --disable-cipher --disable-assert --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-djvu --without-fftw --without-fpx --without-fontconfig --without-freetype --without-jbig --without-lcms --without-lcms2 --without-lqr --without-lzma --without-openexr --without-pango --without-xml && make && make install && cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\\
% }
% if ($conf->{remi} && !$conf->{remi}{module}) {
 ln -s /usr/bin/<%= $conf->{remi}{php_version} %> /usr/local/bin/php &&\\
% }
% if ($conf->{setcap}) {
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\\
% }
% if ($conf->{phpunit}) {
 curl -skL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
 mv phpunit /usr/local/bin/ &&\\
% }
% if ($conf->{use_cpanm} or $conf->{patch}) {
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\\
% }
% if ($conf->{patch}) {
%   for my $patch (@{$conf->{patch}}) {
      cd /root/patch/<%= $patch %> && cpanm --installdeps . && cpanm . && cd /root &&\\
%   }
    rm -rf /root/patch &&\\
% }
 curl -skL --compressed https://git.io/cpm > cpm &&\\
 chmod +x cpm &&\\
 mv cpm /usr/local/bin/ &&\\
 cpm install -g <%= join " ", @{delete $conf->{cpan}{no_test}} %> &&\\
% if ($conf->{use_cpanm}) {
 cpanm -v \\
% } else {
 cpm install -g --test\\
% }
% for my $key (sort keys %{ $conf->{cpan} }) {
 <%= join " ", @{ $conf->{cpan}{$key} } %>\\
% }
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\\
% if ($conf->{use_cpanm}) {
 cpanm --installdeps -v . &&\\
% } else {
 cpm install -g --test &&\\
% }
% if ($conf->{cloud_prereqs}) {
%   my @cloud_prereqs = main::load_prereqs($conf->{cloud_prereqs});
# use cpanm to avoid strong caching of cpm
%   for my $prereq (@cloud_prereqs) {
 cpanm -nfv <%= $prereq %> &&\\
%   }
% }
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \\
    LC_ALL=en_US.UTF-8

RUN set -ex &&\\
% if ($conf->{locale_def}) {
  localedef -i en_US -f UTF-8 en_US.UTF-8 &&\\
  localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 &&\\
% }
  perl -i -pe \\
   's!AllowOverride None!AllowOverride All!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' \\
    /etc/httpd/conf/httpd.conf &&\\
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \\
    my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; \\
    $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \\
    open my $fh, ">", $inifile; print $fh $ini'

% # cf https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html
% if (exists $conf->{make_dummy_cert}) {
RUN cd <%= $conf->{make_dummy_cert} %> && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \\
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR
% }

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

@@ debian-entrypoint
% my ($type, $conf) = @_;
#!/bin/bash
set -e

% if ($type =~ /^(?:trusty|bionic)$/) {
find /var/lib/mysql -type f | xargs touch
% } elsif ($type =~ /^(?:buster|jessie)$/) {
chown -R mysql:mysql /var/lib/mysql
% }
% if ($type =~ /sid|bookworm|bullseye/) {
service mariadb start
% } else {
service mysql start
% }
service memcached start

mysql -e "create database mt_test character set utf8;"
% if ($type !~ /^(?:trusty|jessie)$/) {
mysql -e "create user mt@localhost;"
% }
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"

@@ centos-entrypoint
% my ($type, $conf) = @_;
#!/bin/bash
set -e

% if ($type eq 'centos6') {
service mysqld start
service memcached start
% } elsif ($type =~ /^(?:centos7|fedora23|oracle|oracle8|amazonlinux|amazonlinux2022)$/) {
mysql_install_db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld_safe --user=mysql --datadir=/var/lib/mysql &"
sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% } elsif ($type =~ /^(?:cloud[67]|centos8|fedora|fedora3[0-9]|rockylinux|almalinux)$/) {  ## MySQL 8.*
echo 'default_authentication_plugin = mysql_native_password' >> /etc/my.cnf.d/<% if (grep /community/, @{$conf->{yum}{db}}) { %>community-<% } %>mysql-server.cnf
mysqld --initialize-insecure --user=mysql --skip-name-resolve >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% }

% if ($type eq 'centos6') {
mysql -e "create database if not exists mt_test character set utf8;"
% } else {
mysql -e "create database mt_test character set utf8;"
% }
% if ($type ne 'centos6') {
mysql -e "create user mt@localhost;"
% }
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

memcached -d -u root

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"

