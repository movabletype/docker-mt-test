return {
    from => 'fedora:35',
    base => 'centos',
    yum  => {
        _replace => {
            'mysql'         => 'community-mysql',
            'mysql-server'  => 'community-mysql-server',
            'mysql-devel'   => 'community-mysql-devel',
            'procps'        => 'perl-Unix-Process',
            'phpunit'       => '',
            'libheif-devel' => '',
        },
        base => [qw( glibc-langpack-en glibc-langpack-ja )],
    },
    patch           => ['Test-mysqld-1.0030'],
    make_dummy_cert => '/usr/bin',
    installer       => 'dnf',
    setcap          => 1,
    phpunit         => 9,
};
