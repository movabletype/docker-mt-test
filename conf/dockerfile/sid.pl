return {
    from => 'debian:sid',
    base => 'debian',
    apt  => {
        _replace => {
            'mysql-server' => 'mariadb-server',
            'mysql-client' => 'mariadb-client',
            'php'          => 'php8.4',
            'php-cli'      => 'php8.4-cli',
            'php-mysqlnd'  => 'php8.4-mysql',
            'php-gd'       => 'php8.4-gd',
            'php-memcache' => 'php8.4-memcache',
            'phpunit'      => '',
        },
        libs => [qw( libstdc++-14-dev libcrypt-dev )],
        db   => [qw( libdbd-mysql-perl )],
        php  => [qw( php8.4-mbstring php8.4-xml )],
    },
    cpan => {
        # cf. https://rt.cpan.org/Public/Bug/Display.html?id=156899
        no_test  => [qw( GD XML::LibXML Web::Query )],
        _replace => {
            'Imager::File::AVIF' => '',    # test fails
        },
    },
    patch   => [qw(Crypt-DES-2.07 YAML-Syck-1.36)],
    phpunit => 12,
};
