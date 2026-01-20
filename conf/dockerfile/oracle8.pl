return {
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
};
