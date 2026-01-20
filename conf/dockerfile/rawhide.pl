return {
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
};
