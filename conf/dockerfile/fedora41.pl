return {
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
        # package sometimes causes segfault for unknown reason
        ImageMagick => '7.1.2',
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
};
