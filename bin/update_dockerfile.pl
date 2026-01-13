#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Data::Section::Simple qw/get_data_section/;
use Mojo::Template;
use Mojo::File qw/path/;
use File::Basename;
use File::Path qw/rmtree/;
use Text::Wrap;

$Text::Wrap::columns = 120;
my $ruby_version = '3.4.8';

my %Conf = (
    debian => {
        apt => {
            base => [qw(
                ca-certificates netbase git make cmake gcc clang curl ssh locales perl
                zip unzip bzip2 procps ssl-cert postfix libsasl2-dev libsasl2-modules
            )],
            images => [qw(
                perlmagick libgraphics-magick-perl netpbm imagemagick graphicsmagick
                libgd-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev
                icc-profiles-free
                libavif-dev libheif-dev
            )],
            server => [qw( apache2 vsftpd ftp memcached )],
            db     => [qw( mysql-server mysql-client libmysqlclient-dev )],
            libs   => [qw( libxml2-dev libgmp-dev libssl-dev )],
            php    => [qw( php php-cli php-mysqlnd php-gd php-memcache phpunit )],
            ruby   => [qw( ruby ruby-dev libyaml-dev libffi-dev )],
            editor => [qw( vim nano )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken => [qw(
                Archive::Zip@1.65 DBD::mysql@4.052
            )],
            extra  => [qw( JSON::XS Starman Imager::File::WEBP Imager::File::AVIF Plack::Middleware::ReverseProxy Devel::CheckLib )],
            addons => [qw(
                AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir
                Net::LDAP Linux::Pid Data::Section::Simple
            )],
            bcompat => [qw( pQuery )],
            make_mt => [qw( JavaScript::Minifier CSS::Minifier )],
            temp    => [qw( Fluent::Logger )],
        },
        # cf. https://github.com/Perl/perl5/issues/22353
        patch => [qw(EV-4.36)],
        gem   => {
            fluentd => [qw(fluentd:1.18.0)],
        },
    },
    centos => {
        yum => {
            base => [qw(
                git make cmake gcc clang curl perl perl-core
                tar zip unzip bzip2 which procps postfix cyrus-sasl-devel cyrus-sasl-plain
            )],
            images => [qw(
                ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick
                giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel
                icc-profiles-openicc
                libavif-devel libheif-devel
            )],
            server => [qw( mod_ssl vsftpd ftp memcached )],
            db     => [qw( mysql-devel mysql-server mysql )],
            libs   => [qw( libxml2-devel expat-devel openssl-devel openssl gmp-devel )],
            php    => [qw( php php-mysqlnd php-gd php-mbstring php-pecl-memcache phpunit )],
            ruby   => [qw( ruby ruby-devel libyaml-devel libffi-devel )],
            editor => [qw( vim nano )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken => [qw(
                Archive::Zip@1.65 DBD::mysql@4.052
            )],
            extra  => [qw( JSON::XS Starman Imager::File::WEBP Imager::File::AVIF Plack::Middleware::ReverseProxy Devel::CheckLib )],
            addons => [qw(
                AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir
                Net::LDAP Linux::Pid Data::Section::Simple
            )],
            bcompat => [qw( pQuery )],
            make_mt => [qw( JavaScript::Minifier CSS::Minifier )],
            temp    => [qw( Fluent::Logger )],
        },
        # cf. https://github.com/Perl/perl5/issues/22353
        patch => [qw(EV-4.36)],
        gem   => {
            fluentd => [qw(fluentd:1.18.0)],
        },
    },
    sid => {
        from => 'debian:sid',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server' => 'mariadb-server',
                'mysql-client' => 'mariadb-client',
                'php'          => 'php8.4',
                'php-cli'      => 'php8.4-cli',
                'php-mysqlnd'  => 'php8.4-mysql',
                'php-gd'       => 'php8.4-gd',
                'php-memcache' => 'php8.4-memcache',
                'phpunit'      => '',
            },
            libs => [qw( libstdc++-14-dev libcrypt-dev )],
            db   => [qw( libdbd-mysql-perl )],
            php  => [qw( php8.4-mbstring php8.4-xml )],
        },
        cpan => {
            # cf. https://rt.cpan.org/Public/Bug/Display.html?id=156899
            no_test  => [qw( GD XML::LibXML Web::Query )],
            _replace => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        patch   => [qw(Crypt-DES-2.07 YAML-Syck-1.36)],
        phpunit => 12,
    },
    bookworm => {
        from => 'debian:bookworm-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => 'libmariadb-dev',
                'phpunit'            => '',
            },
            db  => [qw( libdbd-mysql-perl libmariadb-dev-compat )],
            php => [qw( php-mbstring php-xml )],
        },
        phpunit => 11,
    },
    bullseye => {
        from => 'debian:bullseye-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => 'libmariadb-dev',
                'phpunit'            => '',
            },
            db  => [qw( libdbd-mysql-perl libmariadb-dev-compat )],
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
                'libmysqlclient-dev' => 'libmariadb-dev',
                'phpunit'            => '',
                'ruby'               => '',
                'ruby-dev'           => '',
                'libavif-dev'        => '',
            },
            db  => [qw( libdbd-mysql-perl libmariadb-dev-compat )],
            php => [qw( php-mbstring php-xml )],
        },
        cpan => {
            _replace => {
                'Imager::File::AVIF' => '',
            },
        },
        apache => {
            enmod => [qw( php7.3 )],
        },
        make => {
            ruby => $ruby_version,
        },
        phpunit     => 9,
        use_archive => 1,
    },
    noble => {
        from => 'ubuntu:noble',
        base => 'debian',
        apt  => {
            php => [qw( php-mbstring php-xml )],
        },
        repo => {
            # taken from https://dev.mysql.com/downloads/repo/apt/
            mysql84 => 'https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb',
        },
        cpan => {
            no_test  => [qw(GD)],
            _replace => {
                'Imager::File::AVIF' => '',
            },
        },
        patch   => ['Test-mysqld-1.0030'],
        phpunit => 12,
    },
    plucky => {
        from => 'ubuntu:plucky',
        base => 'debian',
        apt  => {
            base => [qw( libstdc++-15-dev )],
            php  => [qw( php-mbstring php-xml )],
        },
        cpan => {
            # cf. https://rt.cpan.org/Public/Bug/Display.html?id=156899
            no_test  => [qw( GD XML::LibXML Web::Query )],
            _replace => {
                'Imager::File::AVIF' => '',
            },
        },
        patch   => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
        phpunit => 12,
    },
    questing => {
        from => 'ubuntu:questing',
        base => 'debian',
        apt  => {
            base     => [qw( libstdc++-15-dev xz-utils )],
            php      => [qw( php-mbstring php-xml )],
            _replace => {
                'graphicsmagick'          => '',
                'imagemagick'             => '',
                'perlmagick'              => '',
                'libgraphics-magick-perl' => '',
            },
        },
        cpan => {
            # cf. https://rt.cpan.org/Public/Bug/Display.html?id=156899
            no_test  => [qw( GD XML::LibXML Web::Query )],
            _replace => {
                'Imager::File::AVIF' => '',
            },
        },
        patch => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
        plenv => '5.42.0',
        make  => {
            ImageMagick    => '7.1.2-12',
            GraphicsMagick => '1.3.46',
        },
        php_build => {
            version => '8.4',
        },
        phpunit => 12,
    },
    rawhide => {
        from => 'fedora:rawhide',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => '',
                'mysql-server' => '',
                'mysql-devel'  => '',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            base   => [qw( distribution-gpg-keys glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
        },
        cpan => {
            no_test  => [qw( App::Prove::Plugin::MySQLPool )],
            _replace => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        patch                  => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
        make_dummy_cert        => '/usr/bin',
        create_make_dummy_cert => 1,
        make                   => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        repo => {
            mysql84 => [qw(mysql-community-server mysql-community-client mysql-community-libs-compat mysql-community-libs mysql-community-devel)],
        },
        mysql84 => {
            # taken from https://dev.mysql.com/downloads/repo/yum/
            rpm    => 'https://dev.mysql.com/get/mysql84-community-release-fc42-1.noarch.rpm',
            enable => 'mysql-8.4-lts-community',
            # enable => 'mysql-innovation-community',
            no_weak_deps        => 1,
            fix_release_version => {
                version => 42,
                repo    => 'mysql-community.repo',
            },
        },
        installer                      => 'dnf',
        phpunit                        => 12,
        nogpgcheck                     => 1,
        mysql_require_secure_transport => 1,
    },
    fedora43 => {
        from => 'fedora:43',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => '',
                'mysql-server' => '',
                'mysql-devel'  => '',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            base   => [qw( distribution-gpg-keys glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
        },
        cpan => {
            no_test  => [qw( App::Prove::Plugin::MySQLPool )],
            _replace => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        patch                  => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
        make_dummy_cert        => '/usr/bin',
        create_make_dummy_cert => 1,
        make                   => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        repo => {
            mysql84 => [qw(mysql-community-server mysql-community-client mysql-community-libs-compat mysql-community-libs mysql-community-devel)],
        },
        mysql84 => {
            # taken from https://dev.mysql.com/downloads/repo/yum/
            rpm    => 'https://dev.mysql.com/get/mysql84-community-release-fc42-1.noarch.rpm',
            enable => 'mysql-8.4-lts-community',
            # enable => 'mysql-innovation-community',
            no_weak_deps        => 1,
            fix_release_version => {
                version => 42,
                repo    => 'mysql-community.repo',
            },
        },
        installer                      => 'dnf',
        phpunit                        => 12,
        nogpgcheck                     => 1,
        mysql_require_secure_transport => 1,
    },
    fedora42 => {
        from => 'fedora:42',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => '',
                'mysql-server' => '',
                'mysql-devel'  => '',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            base   => [qw( distribution-gpg-keys glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
        },
        cpan => {
            no_test  => [qw( App::Prove::Plugin::MySQLPool )],
            _replace => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        make_dummy_cert => '/usr/bin',
        make            => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        repo => {
            mysql93 => [qw(mysql-community-server mysql-community-client mysql-community-libs-compat mysql-community-libs mysql-community-devel)],
        },
        mysql93 => {
            # taken from https://dev.mysql.com/downloads/repo/yum/
            rpm          => 'https://dev.mysql.com/get/mysql84-community-release-fc42-1.noarch.rpm',
            disable      => 'mysql-8.4-lts-community',
            enable       => 'mysql-innovation-community',
            no_weak_deps => 1,
        },
        patch     => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
        installer => 'dnf',
        phpunit   => 12,
        use_ipv4  => 1,
    },
    fedora41 => {
        from => 'fedora:41',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => '',
                'mysql-server' => '',
                'mysql-devel'  => '',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            base   => [qw( distribution-gpg-keys glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
        },
        cpan => {
            no_test  => [qw( App::Prove::Plugin::MySQLPool )],
            _replace => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        make_dummy_cert => '/usr/bin',
        make            => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        repo => {
            mysql84 => [qw(mysql-community-server mysql-community-client mysql-community-libs-compat mysql-community-libs mysql-community-devel)],
        },
        mysql84 => {
            # taken from https://dev.mysql.com/downloads/repo/yum/
            rpm    => 'https://dev.mysql.com/get/mysql84-community-release-fc41-1.noarch.rpm',
            enable => 'mysql-8.4-lts-community',
            # enable => 'mysql-innovation-community',
        },
        patch     => ['Test-mysqld-1.0030', 'Crypt-DES-2.07'],
        installer => 'dnf',
        phpunit   => 12,
    },
    fedora40 => {
        from => 'fedora:40',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'             => 'mariadb',
                'mysql-server'      => 'mariadb-server',
                'mysql-devel'       => 'mariadb-devel',
                'procps'            => 'perl-Unix-Process',
                'php'               => '',
                'php-cli'           => '',
                'php-mysqlnd'       => '',
                'php-mbstring'      => '',
                'php-gd'            => '',
                'php-pecl-memcache' => '',
                'phpunit'           => '',
            },
            base   => [qw( glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
        },
        cpan => {
            # GTest (installed by libheif-devel) breaks the latest version
            # Adding -DMSGPACK_BUILD_TESTS=OFF to builder/MyBuilder.pm helps
            # but it's easier to install an older version here
            temporary => [qw( Data::MessagePack::Stream@1.04 )],
            _replace  => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        patch           => ['Test-mysqld-1.0030', 'Crypt-DES-2.07'],
        make_dummy_cert => '/usr/bin',
        make            => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        php_build => {
            version => '8.2',
        },
        installer => 'dnf',
        phpunit   => 11,
    },
    fedora39 => {
        from => 'fedora:39',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            base   => [qw( glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
        },
        cpan => {
            # seems broken with the current gcc/clang, and the patch for 1.05 does not work
            # but let's wait and see...
            temporary => [qw(Data::MessagePack::Stream@1.04)],
            _replace  => {
                'Imager::File::AVIF' => '',    # test fails
            },
        },
        patch           => ['Test-mysqld-1.0030'],
        make_dummy_cert => '/usr/bin',
        make            => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        installer => 'dnf',
        setcap    => 1,
        phpunit   => 11,
    },
    fedora37 => {
        from => 'fedora:37',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => 'community-mysql',
                'mysql-server' => 'community-mysql-server',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            base => [qw( glibc-langpack-en glibc-langpack-ja )],
        },
        cpan => {
            # seems broken with the current gcc/clang, and the patch for 1.05 does not work
            # but let's wait and see...
            temporary => [qw(Data::MessagePack::Stream@1.04)],
        },
        patch           => ['Test-mysqld-1.0030'],
        make_dummy_cert => '/usr/bin',
        installer       => 'dnf',
        setcap          => 1,
        phpunit         => 10,
    },
    fedora35 => {
        from => 'fedora:35',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'         => 'community-mysql',
                'mysql-server'  => 'community-mysql-server',
                'mysql-devel'   => 'community-mysql-devel',
                'procps'        => 'perl-Unix-Process',
                'phpunit'       => '',
                'libheif-devel' => '',
            },
            base => [qw( glibc-langpack-en glibc-langpack-ja )],
        },
        patch           => ['Test-mysqld-1.0030'],
        make_dummy_cert => '/usr/bin',
        installer       => 'dnf',
        setcap          => 1,
        phpunit         => 9,
    },
    centos7 => {
        from => 'centos:7',
        base => 'centos',
        yum  => {
            libs     => [qw( libstdc++-static )],
            _replace => {
                'mysql'               => 'mariadb',
                'mysql-server'        => 'mariadb-server',
                'mysql-devel'         => 'mariadb-devel',
                'GraphicsMagick'      => '',
                'GraphicsMagick-perl' => '',
                'php'                 => '',
                'php-cli'             => '',
                'php-mysqlnd'         => '',
                'php-mbstring'        => '',
                'php-gd'              => '',
                'php-pecl-memcache'   => '',
                'phpunit'             => '',
                'ruby'                => '',
                'ruby-devel'          => '',
                'libavif-devel'       => '',
                'libheif-devel'       => '',
            },
        },
        repo => {
            epel => [qw( GraphicsMagick-perl GraphicsMagick )],
        },
        epel => {
            rpm => 'epel-release',
        },
        php_build => {
            version => '7.3',
        },
        cpan => {
            no_test  => [qw( Net::SSH::Perl )],
            broken   => [qw( SQL::Translator@1.63 Data::MessagePack::Stream@1.04 )],
            missing  => [qw( TAP::Harness::Env )],
            _replace => {
                'Imager::File::WEBP' => '',    # libwebp for centos7/updates is too old (0.3.0 as of this writing)
                'Imager::File::AVIF' => '',
            },
        },
        make => {
            ruby => '2.7.8',
        },
        phpunit    => 9,
        locale_def => 1,
    },
    rockylinux => {
        from => 'rockylinux/rockylinux:9.5',
        base => 'centos',
        yum  => {
            _replace => {
                'php'                  => '',
                'php-cli'              => '',
                'php-mysqlnd'          => '',
                'php-mbstring'         => '',
                'php-gd'               => '',
                'php-pecl-memcache'    => '',
                'phpunit'              => '',
                'ssh'                  => '',
                'GraphicsMagick'       => '',
                'GraphicsMagick-perl'  => '',
                'ImageMagick'          => '',
                'ImageMagick-perl'     => '',
                'perl-GD'              => '',
                'giflib-devel'         => '',
                'icc-profiles-openicc' => '',
                'mysql-devel'          => '',
                'libyaml-devel'        => '',
                'libavif-devel'        => '',
                'libheif-devel'        => '',
            },
            base => [qw/ glibc-langpack-ja glibc-langpack-en glibc-locale-source libdb-devel /],
        },
        cpan => {
            _replace => {
                'Imager::File::AVIF' => '',
            },
            # for arm64
            no_test => [qw( indirect )],
        },
        epel => {
            rpm => 'epel-release',
        },
        php_build => {
            version => '8.1',
            enable  => 'devel',
            force   => 1,
        },
        repo => {
            epel => [qw( GraphicsMagick-perl ImageMagick-perl perl-GD ImageMagick GraphicsMagick )],
            crb  => [qw( mysql-devel giflib-devel )],
        },
        patch           => ['Test-mysqld-1.0030'],
        installer       => 'dnf',
        setcap          => 1,
        make_dummy_cert => '/usr/bin',
        phpunit         => 10,
        allow_erasing   => 1,
    },
    cloud7 => {
        from => 'rockylinux/rockylinux:9.5',
        base => 'centos',
        yum  => {
            _replace => {
                'php'                  => '',
                'php-cli'              => '',
                'php-mysqlnd'          => '',
                'php-mbstring'         => '',
                'php-gd'               => '',
                'php-pecl-memcache'    => '',
                'phpunit'              => '',
                'perl-GD'              => '',
                'ImageMagick'          => '',
                'ImageMagick-perl'     => '',
                'GraphicsMagick'       => '',
                'GraphicsMagick-perl'  => '',
                'icc-profiles-openicc' => '',
                'giflib-devel'         => '',
                'mysql-devel'          => '',
                'mysql-server'         => '',
                'mysql'                => '',
                'libyaml-devel'        => '',
                'libavif-devel'        => '',
                'libheif-devel'        => '',
            },
            base   => [qw/ glibc-langpack-ja glibc-langpack-en glibc-locale-source xz /],
            libs   => [qw/ ncurses-devel libdb-devel /],
            db     => [qw/ mariadb mariadb-server mariadb-connector-c-devel mariadb-pam /],
            images => [qw( libomp-devel )],
        },
        cpan => {
            addons => [qw(
                Net::LibIDN AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir
                Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers Data::Section::Simple
            )],
            _replace => {
                'Imager::File::AVIF' => '',
            },
        },
        phpunit => 12,
        make    => {
            perl           => '5.38.2',
            ImageMagick    => '7.1.2-12',
            GraphicsMagick => '1.3.43',
        },
        repo => {
            crb   => [qw( giflib-devel )],
            epel  => [qw( libidn-devel )],
            devel => [qw( libtool-ltdl-devel )],
        },
        epel => {
            rpm => 'epel-release',
        },
        php_build => {
            version => '8.3',
            enable  => 'devel',
        },
        cloud_prereqs       => 'conf/cloud_prereqs7',
        patch               => ['Test-mysqld-1.0030'],
        installer           => 'dnf',
        make_dummy_cert     => '/usr/bin',
        allow_erasing       => 1,
        locale_def          => 1,
        no_update           => 1,
        use_legacy_policies => 1,
    },
    amazonlinux => {
        from => 'amazonlinux:2',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'               => 'mariadb',
                'mysql-server'        => 'mariadb-server',
                'mysql-devel'         => 'mariadb-devel',
                'GraphicsMagick'      => '',
                'GraphicsMagick-perl' => '',
                'php'                 => '',
                'php-mysqlnd'         => '',
                'php-gd'              => '',
                'php-mbstring'        => '',
                'php-pecl-memcache'   => '',
                'phpunit'             => '',
                'ruby'                => '',
                'ruby-devel'          => '',
                'libavif-devel'       => '',
                'libheif-devel'       => '',
            },
            base   => [qw( which hostname glibc-langpack-ja )],
            server => [qw( httpd )],                              ## for mod_ssl
        },
        cpan => {
            _replace => {
                'Imager::File::WEBP' => '',                       # libwebp for amazonlinux is too old (0.3.0)
                'Imager::File::AVIF' => '',
            },
            no_test => [qw( XML::DOM )],
            broken  => [qw( SQL::Translator@1.63 )],
        },
        'GraphicsMagick1.3' => {
            enable => 'amzn2extra-GraphicsMagick1.3',
        },
        'php7.4' => {
            enable => 'amzn2extra-php7.4',
        },
        repo => {
            'GraphicsMagick1.3' => [qw( GraphicsMagick-perl GraphicsMagick )],
            'php7.4'            => [qw( php php-mysqlnd php-gd php-mbstring php-xml )],
        },
        make => {
            ruby => $ruby_version,
        },
        make_dummy_cert => '/etc/pki/tls/certs/',
        phpunit         => 9,
    },
    amazonlinux2023 => {
        from => 'amazonlinux:2023',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'             => 'mariadb1011',
                'mysql-server'      => 'mariadb1011-server',
                'mysql-devel'       => 'mariadb1011-devel',
                ftp                 => '',
                'php-pecl-memcache' => '',
                'phpunit'           => '',
                'libavif-devel'     => '',
                'libheif-devel'     => '',
            },
            base   => [qw( which hostname glibc-langpack-ja glibc-locale-source )],
            server => [qw( httpd )],                                                  ## for mod_ssl
            db     => [qw( mariadb1011-pam )],
            php    => [qw( php-cli php-xml php-json )],
        },
        cpan => {
            _replace => {
                'Imager::File::AVIF' => '',
            },
        },
        gem => {
            fluentd => [qw(json)],
        },
        make_dummy_cert => '/usr/bin',
        installer       => 'dnf',
        allow_erasing   => 1,
        phpunit         => 12,
        locale_def      => 1,
    },
    oracle => {
        from => 'oraclelinux:9-slim',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'                => '',
                'mysql-server'         => '',
                'mysql-devel'          => '',
                'php'                  => '',
                'php-gd'               => '',
                'php-mysqlnd'          => '',
                'php-mbstring'         => '',
                'php-pecl-memcache'    => '',
                'phpunit'              => '',
                'giflib-devel'         => '',
                'gd-devel'             => '',
                'libwebp-devel'        => '',
                'ImageMagick'          => '',
                'ImageMagick-perl'     => '',
                'GraphicsMagick'       => '',
                'GraphicsMagick-perl'  => '',
                'icc-profiles-openicc' => '',
                'perl-GD'              => '',
                'ruby'                 => '',
                'ruby-devel'           => '',
                'libyaml-devel'        => '',
                'libavif-devel'        => '',
                'libheif-devel'        => '',
            },
            base   => [qw( which glibc-locale-source )],
            server => [qw( httpd )],
        },
        epel => {
            rpm    => 'oracle-epel-release-el9',
            enable => 'ol9_developer_EPEL',
        },
        instantclient => {
            rpm    => 'oracle-instantclient-release-26ai-el9',
            enable => 'ol9_oracle_instantclient26',
        },
        codeready => {
            enable => 'ol9_codeready_builder',
        },
        php_build => {
            version => '8.3',
            enable  => 'ol9_codeready_builder',
        },
        repo => {
            instantclient => [qw(
                oracle-instantclient-basic
                oracle-instantclient-devel
                oracle-instantclient-sqlplus
            )],
            # oracle epel9 does not have giflib-devel
            epel => [qw(
                ImageMagick ImageMagick-perl GraphicsMagick GraphicsMagick-perl
                gd-devel libwebp-devel
                perl-GD
            )],
            codeready => [qw( giflib-devel mariadb mariadb-server mariadb-devel )],
        },
        cpan => {
            no_test  => [qw( DBI Test::NoWarnings )],
            missing  => [qw( DBD::Oracle )],
            _replace => {
                'Imager::File::WEBP' => '',    # libwebp for oracle is too old (0.3.0 as of this writing)
                'Imager::File::AVIF' => '',
            },
        },
        patch => ['Test-mysqld-1.0030'],
        make  => {
            ruby => '3.1.6',
        },
        make_dummy_cert => '/usr/bin',
        phpunit         => 12,
        installer       => 'microdnf',
        release         => 19.6,
        locale_def      => 1,
        no_update       => 1,
    },
    oracle8 => {
        from => 'oraclelinux:8-slim',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'                => 'mariadb',
                'mysql-server'         => 'mariadb-server',
                'mysql-devel'          => 'mariadb-devel',
                'php'                  => '',
                'php-gd'               => '',
                'php-mysqlnd'          => '',
                'php-mbstring'         => '',
                'php-pecl-memcache'    => '',
                'phpunit'              => '',
                'giflib-devel'         => '',
                'gd-devel'             => '',
                'libwebp-devel'        => '',
                'ImageMagick'          => '',
                'ImageMagick-perl'     => '',
                'GraphicsMagick'       => '',
                'GraphicsMagick-perl'  => '',
                'icc-profiles-openicc' => '',
                'perl-GD'              => '',
                'ruby'                 => '',
                'ruby-devel'           => '',
                'libyaml-devel'        => '',
                'libavif-devel'        => '',
                'libheif-devel'        => '',
            },
            base   => [qw( which glibc-locale-source )],
            server => [qw( httpd )],
        },
        epel => {
            rpm    => 'oracle-epel-release-el8',
            enable => 'ol8_developer_EPEL',
        },
        instantclient => {
            rpm    => 'oracle-instantclient-release-26ai-el8',
            enable => 'ol8_oracle_instantclient26',
        },
        codeready => {
            enable => 'ol8_codeready_builder',
        },
        php_build => {
            # re2c is too old to build php 8.3+
            version => '8.2',
            enable  => 'ol8_codeready_builder',
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
            codeready => [qw( giflib-devel )],
        },
        cpan => {
            no_test  => [qw( DBI Test::NoWarnings )],
            missing  => [qw( DBD::Oracle )],
            _replace => {
                'Imager::File::WEBP' => '',    # libwebp for oracle is too old (0.3.0 as of this writing)
                'Imager::File::AVIF' => '',
            },
        },
        make => {
            ruby => '3.1.6',
        },
        make_dummy_cert => '/usr/bin',
        phpunit         => 11,
        installer       => 'microdnf',
        release         => 19.6,
        locale_def      => 1,
        no_update       => 1,
    },
    postgresql => {
        from => 'fedora:41',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql'        => '',
                'mysql-server' => '',
                'mysql-devel'  => '',
                'php-mysqlnd'  => '',
                'procps'       => 'perl-Unix-Process',
                'phpunit'      => '',
            },
            db     => [qw( postgresql postgresql-server libpq-devel )],
            base   => [qw( distribution-gpg-keys glibc-langpack-en glibc-langpack-ja xz )],
            images => [qw( libomp-devel )],
            php    => [qw( php-pgsql )],
        },
        cpan => {
            _replace => {
                'App::Prove::Plugin::MySQLPool' => '',
                'Test::mysqld'                  => '',
                'DBD::mysql@4.052'              => '',
                'Imager::File::AVIF'            => '',    # test fails
            },
            db => [qw( DBD::Pg Test::PostgreSQL )],
        },
        remove_from_cpanfile => [qw( DBD::mysql App::Prove::Plugin::MySQLPool )],
        make_dummy_cert      => '/usr/bin',
        make                 => {
            # package is broken for unknown reason
            GraphicsMagick => '1.3.43',
        },
        patch     => ['Crypt-DES-2.07'],
        installer => 'dnf',
        phpunit   => 12,
    },
);

my $templates = get_data_section();

sub _strip_lines {
    my $text = shift;
    $text =~ s/^\n+//g;
    $text =~ s/\n\n+$/\n/g;
    $text =~ s/\n\n\n+/\n\n/g;
    $text;
}

sub Mojo::Template::Sandbox::_wrap {
    my $text = shift;
    join "\\\n", split /\n/, Text::Wrap::wrap('', '  ', $text);
}

my @targets = @ARGV ? @ARGV : grep $Conf{$_}{base}, sort keys %Conf;
for my $name (@targets) {
    if (!exists $Conf{$name}) {
        say "unknown target: $name";
        next;
    }
    my $base        = $Conf{$name}{base};
    my $template    = $templates->{$name}              || $templates->{$base};
    my $ep_template = $templates->{"$name-entrypoint"} || $templates->{"$base-entrypoint"};
    say $name;
    mkdir $name unless -d $name;
    my $conf = merge_conf($name);
    if ($conf->{cpan}{temporary}) {
        say "  temporary: $_" for @{ $conf->{cpan}{temporary} };
    }
    my $dockerfile = _strip_lines(Mojo::Template->new->render($template,    $name, $conf));
    my $entrypoint = _strip_lines(Mojo::Template->new->render($ep_template, $name, $conf));
    path("$name/Dockerfile")->spew($dockerfile);
    path("$name/docker-entrypoint.sh")->spew($entrypoint)->chmod(0755);
    path("$name/patch")->remove_tree if -d path("$name/patch");
    if ($conf->{patch}) {
        require File::Copy;
        require Parse::Distname;
        require LWP::UserAgent;
        require JSON::XS;
        path("$name/patch")->make_path;
        for my $target (@{ $conf->{patch} }) {
            my @patch_files = map { $_->realpath } path("patch/$target")->list->each;
            next unless @patch_files;

            my $tarball = path("patch/$target.tar.gz");
            unless (-f $tarball) {
                my $info = Parse::Distname->new("$tarball");
                my ($dist, $version) = ($info->dist, $info->version);
                my $ua = LWP::UserAgent->new;
                print STDERR "fetching $tarball information\n";
                my $res = $ua->get("https://fastapi.metacpan.org/v1/release/_search?q=distribution:$dist&sort=date:desc");
                die "$dist is not found" unless $res->is_success;
                my $releases = JSON::XS::decode_json($res->decoded_content)->{hits}{hits};
                my $warn_obsolete;
                my $url;

                for my $release (@$releases) {
                    my $source = $release->{_source};
                    if ($source->{version} eq $version) {
                        $url = $source->{download_url};
                        # my $path = Parse::Distname->new($source->{download_url})->{cpan_path};
                        # $url = "https://backpan.cpanauthors.org/authors/id/$path";
                        last;
                    }
                    next if $info->{version} =~ /_/;
                    print STDERR "$dist is not the latest\n" unless $warn_obsolete++;
                }
                die "$dist-$version is not found" unless $url;
                print STDERR "mirroring $tarball\n";
                $res = $ua->mirror($url, $tarball);
                die "Failed to mirror $url" unless $res->is_success;
            }
            File::Copy::copy("patch/$target.tar.gz", "$name/patch/$target.tar.gz");
            {
                require File::pushd;
                my $guard = File::pushd::pushd("$name/patch");
                print STDERR "Extracting $target.tar.gz\n";
                system("tar xf $target.tar.gz") and die "Failed to extract $target";
                chdir $target or die "Failed to chdir to $name/patch/$target";
                for my $patch_file (@patch_files) {
                    print STDERR "Applying $patch_file\n";
                    system("patch -p1 < $patch_file") and die "Failed to apply $patch_file to $target";
                }
            }
        }
        path("$name/patch/.gitignore")->spew('*');
    }
    if ($conf->{create_make_dummy_cert}) {
        my $script = Mojo::Template->new->render($templates->{'make-dummy-cert'});
        path("$name/patch/make-dummy-cert")->spew($script);
    }
}

sub merge_conf {
    my $name = shift;
    my %conf = %{ $Conf{$name} // {} };
    my $base = $conf{base} or return \%conf;
    for my $key (keys %{ $Conf{$base} }) {
        if (ref $Conf{$base}{$key} eq 'HASH') {
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
        if (ref $Conf{$base}{$key} eq 'ARRAY') {
            push @{ $conf{$key} //= [] }, @{ $Conf{$base}{$key} };
        }
    }
    if ($conf{php_build}) {
        for my $key (qw(apt yum)) {
            next unless $conf{$key};
            for my $subkey (keys %{ $conf{$key} }) {
                @{ $conf{$key}{$subkey} } = grep !/^php(?:-|$)/, @{ $conf{$key}{$subkey} };
            }
        }
        $conf{php_build}{install_package} = _find_php_package($conf{php_build}{version});
    }
    $conf{cpanm} = 'cpanm';
    if ($conf{cpanm_opt}) {
        $conf{cpanm} .= ' ' . $conf{cpanm_opt};
    }
    \%conf;
}

sub load_prereqs {
    my $file  = shift;
    my @dists = grep { defined $_ && $_ ne '' && !/^#/ } split /\n/, path($file)->slurp;
    # Use cpan.metacpan.org explicitly as it is actually a backpan
    # (CDN-based) www.cpan.org does not serve some of the older prereqs anymore (which should be updated anyway)
    return map { join "/", "https://cpan.metacpan.org/authors/id", substr($_, 0, 1), substr($_, 0, 2), $_ } @dists;
}

sub _find_php_package {
    my $version = shift;
    if (!-d './tmp/php-build' or (stat('./tmp/php-build'))[9] < time - 864000) {
        rmtree('./tmp/php-build');
        system('git clone --depth 1 https://github.com/php-build/php-build ./tmp/php-build');
    }
    if ($version !~ /^\d+.\d+\.\d+$/) {
        my ($v) = sort { $b <=> $a } map { /$version\.(\d+)/ && $1 } glob "./tmp/php-build/share/php-build/definitions/$version.*";
        die "Patch version for $version is not found" unless defined $v;
        $version = "$version.$v";
    }
    my $definition = path("./tmp/php-build/share/php-build/definitions/$version")->slurp;
    my ($package) = $definition =~ /install_package "([^"]+)"/;
    return $package;
}

__DATA__

@@ debian
% my ($type, $conf) = @_;
FROM <%= $conf->{from} %>

WORKDIR /root

% if ($conf->{patch}) {
COPY ./patch/ /root/patch/

% }
RUN \\
% if ($conf->{use_archive}) {
  sed -i -E 's/deb.debian.org/archive.debian.org/' /etc/apt/sources.list &&\\
  sed -i -E 's/security.debian.org/archive.debian.org/' /etc/apt/sources.list &&\\
  sed -i -E 's/^.+\-updates.+//' /etc/apt/sources.list &&\\
% }
% if ($conf->{repo}) {
 apt-get update &&\\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\\
 apt-get --no-install-recommends -y install curl wget gnupg ca-certificates lsb-release &&\\
%   for my $key (keys %{$conf->{repo}}) {
%     my $deb = $conf->{repo}{$key};
      curl -LO <%= $deb %> &&\\
      DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes dpkg -i <%= File::Basename::basename($deb) %> &&\\
      rm <%= File::Basename::basename($deb) %> &&\\
%   }
% }
 apt-get update &&\\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\\
 apt-get --no-install-recommends -y install\\
% for my $key (sort keys %{ $conf->{apt} }) {
 <%= _wrap(join " ", @{$conf->{apt}{$key}}) %>\\
% }
 && ln -s /usr/sbin/apache2 /usr/sbin/httpd &&\\
% if ($conf->{create_make_dummy_cert}) {
 cp /root/patch/make-dummy-cert <%= $conf->{make_dummy_cert} %> && chmod +x <%= $conf->{make_dummy_cert} %>/make-dummy-cert &&\\
% }
% if ($conf->{plenv}) {
  git clone --depth 1 https://github.com/tokuhirom/plenv.git ~/.plenv &&\\
  git clone --depth 1 https://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/ &&\\
  echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.bash_profile &&\\
  echo 'eval "$(plenv init -)"' >> ~/.bash_profile &&\\
  export PATH="$HOME/.plenv/bin:$PATH" &&\\
  eval "$(plenv init -)" &&\\
  plenv install <%= $conf->{plenv} %> &&\\
  plenv global <%= $conf->{plenv} %> &&\\
% }
% if ($conf->{php_build}) {
  apt-get install -y autoconf bison re2c libonig-dev libsqlite3-dev &&\\
  git clone --depth 1 https://github.com/php-build/php-build.git &&\\
  cd php-build && ./install.sh && cd .. && rm -rf php-build &&\\
% if ($conf->{php_build}{force}) {
  sed -i -E 's/buildconf_wrapper$/buildconf_wrapper --force/' /usr/local/bin/php-build &&\\
% }
  rm -rf /usr/local/share/php-build/default_configure_options &&\\
%#  echo "--disable-all" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-mbstring" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-session" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-dom" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-json" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-ctype" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-tokenizer" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-libxml" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-xml" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-xmlwriter" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-gd" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-pdo" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-phar" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-fpm" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--disable-ipv6" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-mysqli=mysqlnd" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-mysql=mysqlnd" >> /usr/local/share/php-build/default_configure_options &&\\
  % if ($type =~ /postgresql/) {
  echo "--with-pgsql" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-pgsql" >> /usr/local/share/php-build/default_configure_options &&\\
  % }
  echo "--with-sqlite3" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-sqlite" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-libxml" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-openssl" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-gd" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-jpeg" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-webp" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pear" >> /usr/local/share/php-build/default_configure_options &&\\
% if ($conf->{php_build}{version} < 8.1) {
  echo 'patch_file "php-8.0-support-openssl-3.patch"' > /usr/local/share/php-build/definitions/my_php &&\\
% }
  echo 'install_package "<%= $conf->{php_build}{install_package} %>"' > /usr/local/share/php-build/definitions/my_php &&\\
  php-build --verbose my_php /usr &&\\
%   unless ($conf->{php_build}{no_memcache}) {
  yes | pecl install memcache<%= $conf->{php_build}{version} < 8 ? '-4.0.5.2' : '' %> &&\\
  echo "extension=memcache.so" >> /usr/etc/php.ini &&\\
%   }
% }
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\\
% if ($conf->{make}) {
 mkdir src && cd src &&\\
%   if ($conf->{make}{perl}) {
 curl -LO https://cpan.metacpan.org/src/5.0/perl-<%= $conf->{make}{perl} %>.tar.gz && tar xf perl-<%= $conf->{make}{perl} %>.tar.gz &&\\
 cd perl-<%= $conf->{make}{perl} %> && ./Configure -des -Dprefix=/usr -Accflags=-fPIC -Duseshrplib && make && make install && cd .. &&\\
%   }
%   if ($conf->{make}{GraphicsMagick}) {
 curl -LO https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/<%= $conf->{make}{GraphicsMagick} %>/GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %>.tar.xz &&\\
 tar xf GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %>.tar.xz && cd GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %> &&\\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-opencl --disable-dependency-tracking --without-x \\
   --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-fpx \\
   --without-jpig --without-lcms2 --without-lzma --without-xml --with-quantum-depth=16 && make && make install &&\\
   cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\\
%   }
%   if ($conf->{make}{ImageMagick}) {
 curl -LO https://imagemagick.org/archive/releases/ImageMagick-<%= $conf->{make}{ImageMagick} %>.tar.xz &&\\
 tar xf ImageMagick-<%= $conf->{make}{ImageMagick} %>.tar.xz && cd ImageMagick-<%= $conf->{make}{ImageMagick} %> &&\\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-dependency-tracking --disable-cipher --disable-assert \\
   --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps \\
   --without-djvu --without-fftw --without-fpx --without-fontconfig --without-freetype --without-jbig --without-lcms \\
   --without-lcms2 --without-lqr --without-lzma --without-openexr --without-pango --without-xml \\
   --enable-delegate-build --with-xml --disable-openmp --disable-opencl && make && make install &&\\
   cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\\
%   }
%   if ($conf->{make}{ruby}) {
 curl -LO https://cache.ruby-lang.org/pub/ruby/<%= $conf->{make}{ruby} =~ s/\.\d+$//r %>/ruby-<%= $conf->{make}{ruby} %>.tar.gz &&\\
 tar xf ruby-<%= $conf->{make}{ruby} %>.tar.gz &&\\
 cd ruby-<%= $conf->{make}{ruby} %> && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\\
%   }
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\\
% }
% if ($conf->{phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
 mv phpunit /usr/local/bin/ &&\\
% }
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\\
 gem install \\
% for my $key (sort keys %{ $conf->{gem} }) {
  <%= _wrap(join " ", @{ $conf->{gem}{$key} }) %>\\
% }
 &&\\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm &&\\
 perl -pi -E \\
   's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' \\
   cpanm && mv cpanm /usr/local/bin &&\\
 curl -sL --compressed https://git.io/cpm > cpm &&\\
 chmod +x cpm &&\\
 mv cpm /usr/local/bin/ &&\\
% if ($conf->{cpan}{temporary}) {
 cpm install -g --test --show-build-log-on-failure <%= _wrap(join " ", @{delete $conf->{cpan}{temporary}}) %> &&\\
% }
 cpm install -g --show-build-log-on-failure <%= _wrap(join " ", @{delete $conf->{cpan}{no_test}}) %> &&\\
 cpm install -g --test --show-build-log-on-failure <%= _wrap(join " ", @{delete $conf->{cpan}{broken}}) %> &&\\
% if ($conf->{patch}) {
%   for my $patch (@{$conf->{patch}}) {
      cd /root/patch/<%= $patch %> && <%= $conf->{cpanm} %> --installdeps . && <%= $conf->{cpanm} %> . && cd /root &&\\
%   }
    rm -rf /root/patch &&\\
% }
% if ($conf->{use_cpm}) {
 cpm install -g --test --show-build-log-on-failure\\
% } else {
 <%= $conf->{cpanm} %> -v \\
% }
% for my $key (sort keys %{ $conf->{cpan} }) {
 <%= _wrap(join " ", @{ $conf->{cpan}{$key} }) %>\\
% }
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\\
% if ($conf->{remove_from_cpanfile}) {
 perl -i -nE 'print unless /(?:<%= join '|', @{$conf->{remove_from_cpanfile}} %>)/' cpanfile &&\\
% }
% if ($conf->{use_cpm}) {
 cpm install -g --test --show-build-log-on-failure\\
% } else {
 <%= $conf->{cpanm} %> -v --installdeps . \\
% }
 && rm -rf cpanfile /root/.perl-cpm/ /root/.cpanm /root/.qws

RUN set -ex &&\\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\\
 localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 &&\\
 a2dismod mpm_event &&\\
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl <%= _wrap(join " ", @{ $conf->{apache}{enmod} || [] }) %> &&\\
 a2enconf serve-cgi-bin &&\\
 a2ensite default-ssl &&\\
 make-ssl-cert generate-default-snakeoil &&\\
 find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe \\
   's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' &&\\
 perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+"?(/\S+/php.ini)"?!; my $ini = do { open my $fh, "<", $inifile or die $!; local $/; <$fh> }; $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; open my $fh, ">", $inifile or die $!; print $fh $ini'

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
% if ($type =~ /^centos/) {
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\\
% }
% if ($type =~ /^fedora36$/) {
  sed -i -e "s/^mirrorlist=https:\/\/mirrorlist.fedoraproject.org/#mirrorlist=https:\/\/mirrorlist.fedoraproject.org/g" /etc/yum.repos.d/fedora-* &&\\
  sed -i -e "s/^#baseurl=http:\/\/download.example\/pub\/fedora/baseurl=https:\/\/archives.fedoraproject.org\/pub\/archive\/fedora/g" /etc/yum.repos.d/fedora-* &&\\
% }
% if ($type =~ /^oracle/) {
  <%= $conf->{installer} // 'yum' %> -y install dnf &&\\
  % $conf->{installer} = 'dnf';
% }
 <%= $conf->{installer} // 'yum' %> <%= $conf->{use_ipv4} ? '--setopt=ip_resolve=4 ' : '' %>-y <%= $conf->{nogpgcheck} ? '--nogpgcheck ' : '' %><% if ($conf->{allow_erasing}) { %>--allowerasing<% } %> install\\
% for my $key (sort keys %{ $conf->{yum} }) {
 <%= _wrap(join " ", @{$conf->{yum}{$key}}) %>\\
% }
 &&\\
% for my $repo (sort keys %{$conf->{repo} || {}}) {
%   if ($type eq 'amazonlinux') {
 amazon-linux-extras install <%= $repo %> &&\\
%   } elsif ($conf->{$repo}{rpm}) {
 <%= $conf->{installer} // 'yum' %> -y <%= $conf->{nogpgcheck} ? '--nogpgcheck ' : '' %>install <%= $conf->{$repo}{rpm} %> &&\\
%     if ($conf->{$repo}{gpg_key}) {
 rpm --import <%= $conf->{$repo}{gpg_key} %> &&\\
%     }
%     if ($type =~ /^centos/) {
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
    <%= $conf->{installer} // 'yum' %> -y <%= $conf->{nogpgcheck} ? '--nogpgcheck ' : '' %>install\\
%   } else {
%     if (my $fix = $conf->{$repo}{fix_release_version}) {
    sed -i -e 's/\$releasever/<%= $fix->{version} %>/' /etc/yum.repos.d/<%= $fix->{repo} %> &&\
%     }
    <%= $conf->{installer} // 'yum' %> -y <%= $conf->{nogpgcheck} ? '--nogpgcheck ' : '' %>--enablerepo=<%= $conf->{$repo}{enable} // $repo %><%= $conf->{$repo}{disable} ? ' --disablerepo='.$conf->{$repo}{disable} : '' %><%= $conf->{$repo}{no_weak_deps} ? ' --setopt=install_weak_deps=false' : '' %> install\\
%   }
 <%= _wrap(join " ", @{$conf->{repo}{$repo}}) %>\\
%   if ($conf->{$repo}{enable}) {
 && <%= $conf->{installer} // 'yum' %> clean --enablerepo=<%= $conf->{$repo}{enable} // $repo %> all &&\\
%   } else {
 &&\\
%   }
% }
% if (!$conf->{no_update}) {
 <%= $conf->{installer} // 'yum' %> -y <%= $conf->{nogpgcheck} ? '--nogpgcheck ' : '' %>update <% if ($type =~ /(rawhide|fedora4[1-9]|postgresql)/) { %>--skip-unavailable<% } else { %>--skip-broken<% } %><% if ($conf->{no_best}) { %> --nobest<% } %> &&\\
% }
 <%= $conf->{installer} // 'yum' %> clean all && rm -rf /var/cache/<%= $conf->{installer} // 'yum' %> &&\\
% if ($conf->{use_legacy_policies}) {
  update-crypto-policies --set legacy &&\\
% }
% if ($conf->{create_make_dummy_cert}) {
 cp /root/patch/make-dummy-cert <%= $conf->{make_dummy_cert} %> && chmod +x <%= $conf->{make_dummy_cert} %>/make-dummy-cert &&\\
% }
% if ($conf->{plenv}) {
  git clone --depth 1 https://github.com/tokuhirom/plenv.git ~/.plenv &&\\
  git clone --depth 1 https://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/ &&\\
  echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.bash_profile &&\\
  echo 'eval "$(plenv init -)"' >> ~/.bash_profile &&\\
  export PATH="$HOME/.plenv/bin:$PATH" &&\\
  eval "$(plenv init -)" &&\\
  plenv install <%= $conf->{plenv} %> &&\\
  plenv global <%= $conf->{plenv} %> &&\\
% }
% if ($conf->{php_build}) {
  <%= $conf->{installer} // 'yum' %> install -y <%= $conf->{php_build}{enable} ? '--enablerepo=' . $conf->{php_build}{enable} : '' %>\\
    autoconf bison re2c oniguruma-devel sqlite-devel &&\\
  git clone --depth 1 https://github.com/php-build/php-build.git &&\\
  cd php-build && ./install.sh && cd .. && rm -rf php-build &&\\
% if ($conf->{php_build}{force}) {
  sed -i -E 's/buildconf_wrapper$/buildconf_wrapper --force/' /usr/local/bin/php-build &&\\
% }
  rm -rf /usr/local/share/php-build/default_configure_options &&\\
%#  echo "--disable-all" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-mbstring" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-session" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-dom" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-json" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-ctype" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-tokenizer" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-libxml" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-xml" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-xmlwriter" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-gd" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-pdo" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-phar" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--enable-fpm" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--disable-ipv6" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-mysqli=mysqlnd" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-mysql=mysqlnd" >> /usr/local/share/php-build/default_configure_options &&\\
  % if ($type =~ /postgresql/) {
  echo "--with-pgsql" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-pgsql" >> /usr/local/share/php-build/default_configure_options &&\\
  % }
  echo "--with-sqlite3" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-sqlite" >> /usr/local/share/php-build/default_configure_options &&\\
  % if ($type =~ /oracle/) {
  echo "--with-oci8=instantclient,/usr/lib/oracle/23/client64/lib" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pdo-oci=instantclient,/usr/lib/oracle/23/client64/lib" >> /usr/local/share/php-build/default_configure_options &&\\
  % }
  echo "--with-libxml" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-openssl" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-gd" >> /usr/local/share/php-build/default_configure_options &&\\
  % if ($conf->{php_build}{version} < 7.4) {
  echo "--with-jpeg-dir=/usr" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-png-dir=/usr" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-webp-dir=/usr" >> /usr/local/share/php-build/default_configure_options &&\\
  % } else {
  echo "--with-jpeg" >> /usr/local/share/php-build/default_configure_options &&\\
  % }
  echo "--with-webp" >> /usr/local/share/php-build/default_configure_options &&\\
  echo "--with-pear" >> /usr/local/share/php-build/default_configure_options &&\\
% if ($conf->{php_build}{version} < 8.1) {
  echo 'patch_file "php-8.0-support-openssl-3.patch"' > /usr/local/share/php-build/definitions/my_php &&\\
% }
  echo 'install_package "<%= $conf->{php_build}{install_package} %>"' > /usr/local/share/php-build/definitions/my_php &&\\
  php-build --verbose my_php /usr &&\\
%   unless ($conf->{php_build}{no_memcache}) {
  yes | pecl install memcache<%= $conf->{php_build}{version} < 8 ? '-4.0.5.2' : '' %> &&\\
  echo "extension=memcache.so" >> /usr/etc/php.ini &&\\
%   }
% }
% if ($conf->{make}) {
 mkdir src && cd src &&\\
%   if ($conf->{make}{perl}) {
 curl -LO https://cpan.metacpan.org/src/5.0/perl-<%= $conf->{make}{perl} %>.tar.gz && tar xf perl-<%= $conf->{make}{perl} %>.tar.gz &&\\
 cd perl-<%= $conf->{make}{perl} %> && ./Configure -des -Dprefix=/usr -Accflags=-fPIC -Duseshrplib && make && make install && cd .. &&\\
%   }
%   if ($conf->{make}{GraphicsMagick}) {
 curl -LO https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/<%= $conf->{make}{GraphicsMagick} %>/GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %>.tar.xz &&\\
 tar xf GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %>.tar.xz && cd GraphicsMagick-<%= $conf->{make}{GraphicsMagick} %> &&\\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-opencl --disable-dependency-tracking --without-x \\
   --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-fpx \\
   --without-jpig --without-lcms2 --without-lzma --without-xml --with-quantum-depth=16 && make && make install &&\\
   cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\\
%   }
%   if ($conf->{make}{ImageMagick}) {
 curl -LO https://imagemagick.org/archive/releases/ImageMagick-<%= $conf->{make}{ImageMagick} %>.tar.xz &&\\
 tar xf ImageMagick-<%= $conf->{make}{ImageMagick} %>.tar.xz && cd ImageMagick-<%= $conf->{make}{ImageMagick} %> &&\\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-dependency-tracking --disable-cipher --disable-assert \\
   --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps \\
   --without-djvu --without-fftw --without-fpx --without-fontconfig --without-freetype --without-jbig --without-lcms \\
   --without-lcms2 --without-lqr --without-lzma --without-openexr --without-pango --without-xml \\
   --enable-delegate-build --with-xml --disable-openmp --disable-opencl && make && make install &&\\
   cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\\
%   }
%   if ($conf->{make}{ruby}) {
 curl -LO https://cache.ruby-lang.org/pub/ruby/<%= $conf->{make}{ruby} =~ s/\.\d+$//r %>/ruby-<%= $conf->{make}{ruby} %>.tar.gz &&\\
 tar xf ruby-<%= $conf->{make}{ruby} %>.tar.gz &&\\
 cd ruby-<%= $conf->{make}{ruby} %> && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\\
%   }
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\\
% }
% if ($conf->{setcap}) {
%# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\\
% }
% if ($conf->{phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
 mv phpunit /usr/local/bin/ &&\\
% }
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\\
 gem install \\
% for my $key (sort keys %{ $conf->{gem} }) {
  <%= _wrap(join " ", @{ $conf->{gem}{$key} }) %>\\
% }
 &&\\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm &&\\
 perl -pi -E \\
   's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm &&\\
 mv cpanm /usr/local/bin &&\\
 curl -sL --compressed https://git.io/cpm > cpm &&\\
 chmod +x cpm &&\\
 mv cpm /usr/local/bin/ &&\\
% if ($conf->{use_cpm}) {
% if ($conf->{cpan}{temporary}) {
 cpm install -g --test --show-build-log-on-failure <%= _wrap(join " ", @{delete $conf->{cpan}{temporary}}) %> &&\\
% }
 cpm install -g --show-build-log-on-failure <%= _wrap(join " ", @{delete $conf->{cpan}{no_test}}) %> &&\\
 cpm install -g --test --show-build-log-on-failure <%= _wrap(join " ", @{delete $conf->{cpan}{broken}}) %> &&\\
% } else {
% if ($conf->{cpan}{temporary}) {
 <%= $conf->{cpanm} %> -v <%= _wrap(join " ", @{delete $conf->{cpan}{temporary}}) %> &&\\
% }
 <%= $conf->{cpanm} %> -n <%= _wrap(join " ", @{delete $conf->{cpan}{no_test}}) %> &&\\
 <%= $conf->{cpanm} %> -v <%= _wrap(join " ", @{delete $conf->{cpan}{broken}}) %> &&\\
% }
% if ($conf->{patch}) {
%   for my $patch (@{$conf->{patch}}) {
      cd /root/patch/<%= $patch %> && <%= $conf->{cpanm} %> --installdeps . && <%= $conf->{cpanm} %> . && cd /root &&\\
%   }
    rm -rf /root/patch &&\\
% }
% if ($conf->{use_cpm}) {
 cpm install -g --test --show-build-log-on-failure\\
% } else {
 <%= $conf->{cpanm} %> -v \\
% }
% for my $key (sort keys %{ $conf->{cpan} }) {
 <%= _wrap(join " ", @{ $conf->{cpan}{$key} }) %>\\
% }
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\\
% if ($conf->{remove_from_cpanfile}) {
 perl -i -nE 'print unless /(?:<%= join '|', @{$conf->{remove_from_cpanfile}} %>)/' cpanfile &&\\
% }
% if ($conf->{use_cpm}) {
 cpm install -g --test --show-build-log-on-failure &&\\
% } else {
 <%= $conf->{cpanm} %> --installdeps -v . &&\\
% }
% if ($conf->{cloud_prereqs}) {
%   my @cloud_prereqs = main::load_prereqs($conf->{cloud_prereqs});
# use cpanm to avoid strong caching of cpm
%   for my $prereq (@cloud_prereqs) {
 <%= $conf->{cpanm} %> -nfv <%= $prereq %> &&\\
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
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+"?(/\S+/php.ini)"?!; my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; open my $fh, ">", $inifile; print $fh $ini' &&\\
  sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

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

% if ($conf->{plenv}) {
source ~/.bash_profile
% }

% if ($type =~ /^(?:buster)$/) {
chown -R mysql:mysql /var/lib/mysql
% }
% if ($conf->{repo}{mysql84} or $type =~ /^(?:questing|plucky)$/) {
bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% } elsif ($type =~ /buster/) {
service mysql start
% } else {
service mariadb start
% }
service memcached start

mysql -e "create database mt_test character set utf8;"
% if ($type !~ /^(?:trusty|jessie)$/) {
mysql -e "create user mt@localhost;"
% }
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
% if ($conf->{remove_from_cpanfile}) {
    perl -i -nE 'print unless /(?:<%= join '|', @{$conf->{remove_from_cpanfile}} %>)/' t/cpanfile &&\\
% }
    <%= $conf->{cpanm} %> --installdeps -n . --cpanfile=t/cpanfile
fi

exec "$@"

@@ centos-entrypoint
% my ($type, $conf) = @_;
#!/bin/bash
set -e

% if ($conf->{plenv}) {
source ~/.bash_profile
% }

% if ($type =~ /^(?:centos7|fedora40|oracle|oracle8|amazonlinux|amazonlinux2023)$/) {
mysql_install_db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld_safe --user=mysql --datadir=/var/lib/mysql &"
sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% } elsif ($type =~ /^(?:fedora(?:3[0-9]|4[0-9])|rawhide|rockylinux)$/) {  ## MySQL 8.*
% if ($conf->{mysql_require_secure_transport}) {
echo 'require_secure_transport = true' >> /etc/my.cnf.d/<% if (grep /community/, @{$conf->{yum}{db} || []} and $type !~ /^(?:fedora4[0-9]|rawhide)$/) { %>community-<% } %>mysql-server.cnf
echo 'caching_sha2_password_auto_generate_rsa_keys = true' >> /etc/my.cnf.d/<% if (grep /community/, @{$conf->{yum}{db} || []} and $type !~ /^(?:fedora4[0-9]|rawhide)$/) { %>community-<% } %>mysql-server.cnf
% } else {
echo 'default_authentication_plugin = mysql_native_password' >> /etc/my.cnf.d/<% if (grep /community/, @{$conf->{yum}{db} || []} and $type !~ /^(?:fedora4[0-9]|rawhide)$/) { %>community-<% } %>mysql-server.cnf
% }
mysqld --initialize-insecure --user=mysql --skip-name-resolve >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% } elsif ($type =~ /^(?:cloud7)$/) {  ## MariaDB 10.*
echo 'default_authentication_plugin = mysql_native_password' >> /etc/my.cnf.d/<% if (grep /community/, @{$conf->{yum}{db} || []} and $type !~ /^(?:fedora4[0-9]|rawhide)$/) { %>community-<% } %>mariadb-server.cnf
mysql_install_db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld_safe --datadir=/var/lib/mysql --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% }

% if ($type ne 'postgresql') {
mysql -e "create database mt_test character set utf8;"
% }
% if ($type eq 'postgresql') {
export PGDATA=/var/lib/postgresql/data
install --verbose --directory --owner postgres --group postgres --mode 1777 /var/lib/postgresql
install --verbose --directory --owner postgres --group postgres --mode 3777 /var/run/postgresql

su -c 'initdb --show' postgres

su -c 'initdb -D /var/lib/postgresql/data' postgres
su -c 'pg_ctl -D /var/lib/postgresql/data start' postgres

su -c 'createuser mt' postgres
su -c 'createdb -O mt mt_test' postgres
% } else {
mysql -e "create user mt@localhost;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"
% }

memcached -d -u root

if [ -f t/cpanfile ]; then
% if ($conf->{remove_from_cpanfile}) {
    perl -i -nE 'print unless /(?:<%= join '|', @{$conf->{remove_from_cpanfile}} %>)/' t/cpanfile &&\\
% }
    <%= $conf->{cpanm} %> --installdeps -n . --cpanfile=t/cpanfile
fi

% if ($type eq 'postgresql') {
export MT_TEST_BACKEND=Pg
% }
% if ($type =~ /oracle/) {
export MT_TEST_BACKEND=Oracle
export NLS_LANG=Japanese_Japan.AL32UTF8
export NLS_SORT=JAPANESE_M_CI
% }

exec "$@"

@@ make-dummy-cert
#!/bin/sh
umask 077

answers() {
        echo --
        echo SomeState
        echo SomeCity
        echo SomeOrganization
        echo SomeOrganizationalUnit
        echo localhost.localdomain
        echo root@localhost.localdomain
}

if [ $# -eq 0 ] ; then
        echo $"Usage: `basename $0` filename [...]"
        exit 0
fi

for target in $@ ; do
        PEM1=`/bin/mktemp /tmp/openssl.XXXXXX`
        PEM2=`/bin/mktemp /tmp/openssl.XXXXXX`
        trap "rm -f $PEM1 $PEM2" SIGINT
        answers | /usr/bin/openssl req -newkey rsa:2048 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2 2> /dev/null
        cat $PEM1 >  ${target}
        echo ""   >> ${target}
        cat $PEM2 >> ${target}
        rm -f $PEM1 $PEM2
done
