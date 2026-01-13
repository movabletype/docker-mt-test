return {
    from => 'debian:buster-slim',
    base => 'debian',
    apt  => {
        _replace => {
            'mysql-server'       => 'mariadb-server',
            'mysql-client'       => 'mariadb-client',
            'libmysqlclient-dev' => 'libmariadb-dev',
            'phpunit'            => '',
            'ruby'               => '',
            'ruby-dev'           => '',
            'libavif-dev'        => '',
        },
        db  => [qw( libdbd-mysql-perl libmariadb-dev-compat )],
        php => [qw( php-mbstring php-xml )],
    },
    cpan => {
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    apache => {
        enmod => [qw( php7.3 )],
    },
    make => {
        ruby => '3.4.8',
    },
    phpunit     => 9,
    use_archive => 1,
};
