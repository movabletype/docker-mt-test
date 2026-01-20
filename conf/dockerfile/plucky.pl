return {
    from => 'ubuntu:plucky',
    base => 'debian',
    apt  => {
        base => [qw( libstdc++-15-dev )],
        php  => [qw( php-mbstring php-xml )],
    },
    cpan => {
        # cf. https://rt.cpan.org/Public/Bug/Display.html?id=156899
        no_test  => [qw( GD XML::LibXML Web::Query )],
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    patch   => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
    phpunit => 12,
};
