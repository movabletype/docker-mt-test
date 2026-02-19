return {
    from => 'rockylinux/rockylinux:9.6',
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
};
