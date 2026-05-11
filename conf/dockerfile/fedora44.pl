return {
    from => 'fedora:44',
    base => 'centos',
    yum  => {
        _replace => {
            'mysql'        => 'mariadb',
            'mysql-server' => 'mariadb-server',
            'mysql-devel'  => 'mariadb-devel',
            'procps'       => 'perl-Unix-Process',
            'phpunit'      => '',
        },
        base   => [qw( distribution-gpg-keys glibc-langpack-en glibc-langpack-ja xz )],
        images => [qw( libomp-devel )],
    },
    cpan => {
#        no_test  => [qw( App::Prove::Plugin::MySQLPool )],
        _replace => {
            'Imager::File::AVIF' => '',    # test fails
        },
    },
    patch                  => ['Test-mysqld-1.0030', 'Crypt-DES-2.07'],
    make_dummy_cert        => '/usr/bin',
    create_make_dummy_cert => 1,
    make                   => {
        # package is broken for unknown reason
        GraphicsMagick => '1.3.46',
    },
    installer                      => 'dnf',
    phpunit                        => 12,
    nogpgcheck                     => 1,
    mysql_require_secure_transport => 1,
};
