return {
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
};
