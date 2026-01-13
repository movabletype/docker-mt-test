return {
    yum => {
        base => [qw(
            git make cmake gcc clang curl perl perl-core
            tar zip unzip bzip2 which procps postfix cyrus-sasl-devel cyrus-sasl-plain
        )],
        images => [qw(
            ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick
            giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel
            icc-profiles-openicc
            libavif-devel libheif-devel
        )],
        server => [qw( mod_ssl vsftpd ftp memcached )],
        db     => [qw( mysql-devel mysql-server mysql )],
        libs   => [qw( libxml2-devel expat-devel openssl-devel openssl gmp-devel )],
        php    => [qw( php php-mysqlnd php-gd php-mbstring php-pecl-memcache phpunit )],
        ruby   => [qw( ruby ruby-devel libyaml-devel libffi-devel )],
        editor => [qw( vim nano )],
    },
    cpan => {
        ## fragile tests, or broken by other modules (Atom, Pulp)
        no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver )],
        ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
        broken => [qw(
            Archive::Zip@1.65 DBD::mysql@4.052
        )],
        extra  => [qw( JSON::XS Starman Imager::File::WEBP Imager::File::AVIF Plack::Middleware::ReverseProxy Devel::CheckLib )],
        addons => [qw(
            AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir
            Net::LDAP Linux::Pid Data::Section::Simple
        )],
        bcompat => [qw( pQuery )],
        make_mt => [qw( JavaScript::Minifier CSS::Minifier )],
        temp    => [qw( Fluent::Logger )],
    },
    # cf. https://github.com/Perl/perl5/issues/22353
    patch => [qw(EV-4.36)],
    gem   => {
        fluentd => [qw(fluentd:1.18.0)],
    },
};
