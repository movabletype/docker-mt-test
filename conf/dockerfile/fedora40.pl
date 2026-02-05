return {
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
        no_test   => [qw( Starman )],
        _replace  => {
            'Imager::File::AVIF' => '',    # test fails
        },
    },
    patch           => ['Test-mysqld-1.0030', 'Crypt-DES-2.07'],
    make_dummy_cert => '/usr/bin',
    make            => {
        # package is broken for unknown reason
        GraphicsMagick => '1.3.43',
        # package sometimes causes segfault for unknown reason
        ImageMagick => '7.1.2',
    },
    php_build => {
        version => '8.2',
    },
    installer => 'dnf',
    phpunit   => 11,
};
