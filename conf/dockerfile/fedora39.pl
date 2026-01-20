return {
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
};
