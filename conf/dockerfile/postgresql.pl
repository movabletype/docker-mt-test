return {
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
};
