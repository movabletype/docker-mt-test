return {
    from => 'rockylinux/rockylinux:9.5',
    base => 'centos',
    yum  => {
        _replace => {
            'php'                  => '',
            'php-cli'              => '',
            'php-mysqlnd'          => '',
            'php-mbstring'         => '',
            'php-gd'               => '',
            'php-pecl-memcache'    => '',
            'phpunit'              => '',
            'perl-GD'              => '',
            'ImageMagick'          => '',
            'ImageMagick-perl'     => '',
            'GraphicsMagick'       => '',
            'GraphicsMagick-perl'  => '',
            'icc-profiles-openicc' => '',
            'giflib-devel'         => '',
            'mysql-devel'          => '',
            'mysql-server'         => '',
            'mysql'                => '',
            'libyaml-devel'        => '',
            'libavif-devel'        => '',
            'libheif-devel'        => '',
        },
        base   => [qw/ glibc-langpack-ja glibc-langpack-en glibc-locale-source xz /],
        libs   => [qw/ ncurses-devel libdb-devel /],
        db     => [qw/ mariadb mariadb-server mariadb-connector-c-devel mariadb-pam /],
        images => [qw( libomp-devel )],
    },
    cpan => {
        addons => [qw(
            Net::LibIDN AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir
            Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers Data::Section::Simple
        )],
        _replace => {
            'Imager::File::AVIF' => '',
        },
    },
    phpunit => 12,
    make    => {
        perl           => '5.38.2',
        ImageMagick    => '7.1.2-12',
        GraphicsMagick => '1.3.43',
    },
    repo => {
        crb   => [qw( giflib-devel )],
        epel  => [qw( libidn-devel )],
        devel => [qw( libtool-ltdl-devel )],
    },
    epel => {
        rpm => 'epel-release',
    },
    php_build => {
        version => '8.3',
        enable  => 'devel',
    },
    cloud_prereqs       => 'conf/cloud_prereqs7',
    patch               => ['Test-mysqld-1.0030'],
    installer           => 'dnf',
    make_dummy_cert     => '/usr/bin',
    allow_erasing       => 1,
    locale_def          => 1,
    no_update           => 1,
    use_legacy_policies => 1,
};
