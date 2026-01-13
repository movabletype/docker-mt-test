return {
    from => 'debian:bookworm-slim',
    base => 'debian',
    apt  => {
        _replace => {
            'mysql-server'       => 'mariadb-server',
            'mysql-client'       => 'mariadb-client',
            'libmysqlclient-dev' => 'libmariadb-dev',
            'phpunit'            => '',
        },
        db  => [qw( libdbd-mysql-perl libmariadb-dev-compat )],
        php => [qw( php-mbstring php-xml )],
    },
    phpunit => 11,
};
