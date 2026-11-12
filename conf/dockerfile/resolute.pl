return {
    from => 'ubuntu:resolute',
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
        no_test  => [qw( GD XML::LibXML Web::Query Starman )],
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    patch => ['Test-mysqld-1.0030', 'Crypt-DES-2.07'],
    plenv => '5.44.0',
    make  => {
        ImageMagick    => '7.1.2',
        GraphicsMagick => '1.3.46',
    },
    php_build => {
        version => '8.5',
        no_memcache => 1,
    },
    phpunit => 12,
};
