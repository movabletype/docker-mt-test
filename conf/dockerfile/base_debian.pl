return {
    apt => {
        base => [qw(
            ca-certificates netbase git make cmake gcc clang curl ssh locales perl
            zip unzip bzip2 procps ssl-cert postfix libsasl2-dev libsasl2-modules
        )],
        images => [qw(
            perlmagick libgraphics-magick-perl netpbm imagemagick graphicsmagick
            libgd-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev
            icc-profiles-free
            libavif-dev libheif-dev
        )],
        server => [qw( apache2 vsftpd ftp memcached )],
        db     => [qw( mysql-server mysql-client libmysqlclient-dev )],
        libs   => [qw( libxml2-dev libgmp-dev libssl-dev )],
        php    => [qw( php php-cli php-mysqlnd php-gd php-memcache phpunit )],
        ruby   => [qw( ruby ruby-dev libyaml-dev libffi-dev )],
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
