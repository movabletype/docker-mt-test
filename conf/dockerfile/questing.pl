return {
    from => 'ubuntu:questing',
    base => 'debian',
    apt  => {
        base     => [qw( libstdc++-15-dev xz-utils )],
        php      => [qw( php-mbstring php-xml )],
        _replace => {
            'graphicsmagick'          => '',
            'imagemagick'             => '',
            'perlmagick'              => '',
            'libgraphics-magick-perl' => '',
        },
    },
    cpan => {
        # cf. https://rt.cpan.org/Public/Bug/Display.html?id=156899
        no_test  => [qw( GD XML::LibXML Web::Query )],
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    patch => ['Test-mysqld-1.0030', 'Crypt-DES-2.07', 'YAML-Syck-1.36'],
    plenv => '5.42.0',
    make  => {
        ImageMagick    => '7.1.2-12',
        GraphicsMagick => '1.3.46',
    },
    php_build => {
        version => '8.4',
    },
    phpunit => 12,
};
