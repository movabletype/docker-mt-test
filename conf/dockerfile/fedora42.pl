return {
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
};
