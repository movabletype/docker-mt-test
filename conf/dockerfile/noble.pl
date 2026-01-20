return {
    from => 'ubuntu:noble',
    base => 'debian',
    apt  => {
        php => [qw( php-mbstring php-xml )],
    },
    repo => {
        # taken from https://dev.mysql.com/downloads/repo/apt/
        mysql84 => 'https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb',
    },
    cpan => {
        no_test  => [qw(GD)],
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    patch   => ['Test-mysqld-1.0030'],
    phpunit => 12,
};
