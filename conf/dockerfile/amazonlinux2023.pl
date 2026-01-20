return {
    from => 'amazonlinux:2023',
    base => 'centos',
    yum  => {
        _replace => {
            'mysql'             => 'mariadb1011',
            'mysql-server'      => 'mariadb1011-server',
            'mysql-devel'       => 'mariadb1011-devel',
            ftp                 => '',
            'php-pecl-memcache' => '',
            'phpunit'           => '',
            'libavif-devel'     => '',
            'libheif-devel'     => '',
        },
        base   => [qw( which hostname glibc-langpack-ja glibc-locale-source )],
        server => [qw( httpd )],                                                  ## for mod_ssl
        db     => [qw( mariadb1011-pam )],
        php    => [qw( php-cli php-xml php-json )],
    },
    cpan => {
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    gem => {
        fluentd => [qw(json)],
    },
    make_dummy_cert => '/usr/bin',
    installer       => 'dnf',
    allow_erasing   => 1,
    phpunit         => 12,
    locale_def      => 1,
};
