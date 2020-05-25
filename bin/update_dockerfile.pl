#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Data::Section::Simple qw/get_data_section/;
use Mojo::Template;

my %Conf = (
    debian => {
        apt => {
            base => [qw(
                ca-certificates netbase git make gcc curl ssh locales perl
                unzip bzip2 procps ssl-cert
            )],
            images => [qw(
                perlmagick libgraphics-magick-perl netpbm
                libgd-dev libpng-dev libgif-dev libjpeg-dev
            )],
            server => [qw( apache2 vsftpd ftp memcached )],
            db     => [qw( mysql-server mysql-client libmysqlclient-dev )],
            libs   => [qw( libxml2-dev libgmp-dev libssl-dev )],
            php    => [qw( php php-cli php-mysqlnd php-gd php-memcache phpunit )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken => [qw( Archive::Zip@1.65 Crypt::Curve25519@0.05 )],
            extra   => [qw( JSON::XS Starman )],
            addons  => [qw( Net::LDAP Linux::Pid )],
        },
    },
    centos => {
        yum => {
            base => [qw(
                git make gcc curl perl perl-core glibc-langpack-en
                zip unzip bzip2 which procps
            )],
            images => [qw(
                ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs
                giflib-devel libpng-devel libjpeg-devel
            )],
            server => [qw( mod_ssl vsftpd ftp memcached )],
            db     => [qw( mysql-devel mysql-server )],
            libs   => [qw( libxml2-devel expat-devel openssl-devel openssl gmp-devel )],
            php    => [qw( php php-mysqlnd php-gd php-pecl-memcache phpunit )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken => [qw( Archive::Zip@1.65 Crypt::Curve25519@0.05 )],
            extra   => [qw( JSON::XS Starman )],
            addons  => [qw( Net::LDAP Linux::Pid )],
        },
    },
    buster => {
        from => 'debian:buster-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => '',
            },
            db => [qw( libdbd-mysql-perl )],
        },
        apache => {
            enmod => [qw( php7.3 )],
        },
    },
    jessie => {
        from => 'debian:jessie-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'php'          => 'php5',
                'php-cli'      => 'php5-cli',
                'php-mysqlnd'  => 'php5-mysqlnd',
                'php-gd'       => 'php5-gd',
                'php-memcache' => 'php5-memcache',
                'libgd-dev'    => 'libgd2-xpm-dev',
            },
        },
        cpan => {
            no_test => [qw( YAML::Syck@1.31 )],
        },
        apache => {
            enmod => [qw( php5 )],
        },
        requires_old_phpunit => 1,
    },
    stretch => {
        from => 'debian:stretch-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'libgd-dev'          => 'libgd2-xpm-dev',
                'libmysqlclient-dev' => 'libmysql++-dev',
            },
            php => [qw/ php-mbstring /],
        },
        cpan => {
            no_test => [qw( YAML::Syck@1.31 )],
        },
        apache => {
            enmod => [qw( php7.0 )],
        },
        requires_old_phpunit => 1,
    },
    focal => {
        from => 'ubuntu:focal',
        base => 'debian',
        apt  => {
            _replace => {
                'php-mysqlnd' => 'php-mysql',
            },
        },
        apache => {
            enmod => [qw( php7.4 )],
        },
    },
    bionic => {
        from => 'ubuntu:bionic',
        base => 'debian',
        apt  => {
            _replace => {
                'php-mysqlnd' => 'php-mysql',
            },
        },
        apache => {
            enmod => [qw( php7.2 )],
        },
    },
    trusty => {
        from => 'ubuntu:trusty',
        base => 'debian',
        apt  => {
            _replace => {
                'php'                => 'php5',
                'php-cli'            => 'php5-cli',
                'php-mysqlnd'        => 'php5-mysql',
                'php-gd'             => 'php5-gd',
                'php-memcache'       => 'php5-memcache',
                'libgd-dev'          => 'libgd2-xpm-dev',
                'libmysqlclient-dev' => 'libmysql++-dev',
                'libpng-dev'         => 'libpng12-dev',
            },
        },
        apache => {
            enmod => [qw( php5 )],
        },
        requires_old_phpunit => 1,
    },
    fedora => {
        from => 'fedora:31',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql-server' => 'community-mysql-server',
                'mysql-client' => 'community-mysql-client',
                'mysql-devel'  => 'community-mysql-devel',
                'procps'       => 'perl-Unix-Process',
            },
        },
        make_dummy_cert => '/usr/bin',
        installer => 'dnf',
        setcap    => 1,
    },
    fedora23 => {
        from => 'fedora:23',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql-server' => 'community-mysql-server',
                'mysql-client' => 'community-mysql-client',
                'mysql-devel'  => 'community-mysql-devel',
                'glibc-langpack-en' => '',
            },
            base => [qw( hostname )],
        },
        installer => 'dnf',
        make_dummy_cert => '/etc/pki/tls/certs/',
    },
    centos6 => {
        from => 'centos:6',
        base => 'centos',
        yum  => {
            _replace => {
                'php-mysqlnd' => 'php-mysql',
            },
            libs => [qw( perl-XML-Parser )],
        },
        cpan => {
            missing => [qw( App::cpanminus DBD::SQLite )],
        },
        use_cpanm => 1,
    },
    centos7 => {
        from => 'centos:7',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql-server' => 'mariadb-server',
                'mysql-client' => 'mariadb',
                'mysql-devel'  => 'mariadb-devel',
            },
        },
        cpan => {
            missing => [qw( TAP::Harness::Env )],
        },
    },
    centos8 => {
        from => 'centos:8',
        base => 'centos',
        yum  => {
            _replace => {
                'php-mysql'         => 'php-mysqlnd',
                'php-pecl-memcache' => '',
                'phpunit'           => '',
                'ssh'               => '',
            },
            php => [qw/ php-json php-mbstring php-pdo php-xml /],
        },
        enablerepo              => [qw( PowerTools )],    ## for giflib-devel
        installer               => 'dnf',
        setcap                  => 1,
        requires_latest_phpunit => 1,
        make_dummy_cert => '/usr/bin',
    },
    amazonlinux => {
        from => 'amazonlinux:2',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql-server'      => 'mariadb-server',
                'mysql-client'      => 'mariadb',
                'mysql-devel'       => 'mariadb-devel',
            },
            base   => [qw( which )],
            server => [qw( httpd )], ## for mod_ssl
        },
        make_dummy_cert => '/etc/pki/tls/certs/',
    },
);

my $templates = get_data_section();

my @targets = @ARGV ? @ARGV : glob "*";
for my $name (@targets) {
    my $template   = $templates->{$name} or next;
    say $name;
    my $conf       = merge_conf($name);
    my $dockerfile = Mojo::Template->new->render($template, $name, $conf);
    open my $fh, '>', "$name/Dockerfile";
    say $fh $dockerfile;
}

sub merge_conf {
    my $name  = shift;
    my %conf = %{ $Conf{$name} // {} };
    my $base = $conf{base} or return \%conf;
    for my $key (keys %{ $Conf{$base} }) {
        my %replace = %{ delete $conf{$key}{_replace} || {} };
        for my $subkey (keys %{ $Conf{$base}{$key} }) {
            my @values = @{ $conf{$key}{$subkey} || [] };
            for my $value (@{ $Conf{$base}{$key}{$subkey} }) {
                if (exists $replace{$value}) {
                    my $new_value = $replace{$value};
                    push @values, $new_value if $new_value;
                } else {
                    push @values, $value;
                }
            }
            $conf{$key}{$subkey} = \@values if @values;
        }
    }
    \%conf;
}

__DATA__

@@ debian
% my ($type, $conf) = @_;
FROM <%= $conf->{from} %>

WORKDIR /root

RUN apt-get update &&\\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\\
 apt-get --no-install-recommends -y install\\
% for my $key (sort keys %{ $conf->{apt} }) {
 <%= join " ", @{$conf->{apt}{$key}} %>\\
% }
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\\
 ln -s /usr/sbin/apache2 /usr/sbin/httpd &&\\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\\
% if ($conf->{requires_old_phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit-4.8.36.phar > phpunit && chmod +x phpunit &&\\
 mv phpunit /usr/local/bin/ &&\\
% }
 curl -sL --compressed https://git.io/cpm > cpm &&\\
 chmod +x cpm &&\\
 mv cpm /usr/local/bin/ &&\\
 cpm install -g <%= join " ", @{delete $conf->{cpan}{no_test}} %> &&\\
 cpm install -g\\
% for my $key (sort keys %{ $conf->{cpan} }) {
 <%= join " ", @{ $conf->{cpan}{$key} } %>\\
% }
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\\
 cpm install -g --test &&\\
 rm -rf cpanfile /root/.perl-cpm/

RUN set -ex &&\\
 a2dismod mpm_event &&\\
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl <%= join " ", @{ $conf->{apache}{enmod} } %> &&\\
 a2enconf serve-cgi-bin &&\\
 a2ensite default-ssl &&\\
 make-ssl-cert generate-default-snakeoil &&\\
 find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe \\
   's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g'

ENV LANG=en_US.UTF-8 \\
    LC_ALL=en_US.UTF-8 \\
    APACHE_RUN_DIR=/var/run/apache2 \\
    APACHE_RUN_USER=www-data \\
    APACHE_RUN_GROUP=www-data \\
    APACHE_LOG_DIR=/var/log/apache2 \\
    APACHE_PID_FILE=/var/run/apache2.pid \\
    APACHE_LOCK_DIR=/var/lock/apache2 \\
    APACHE_CONF_DIR=/etc/apache2

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

@@ centos
% my ($type, $conf) = @_;
FROM <%= $conf->{from} %>

WORKDIR /root

RUN\
% if ($type eq 'amazonlinux') {
 amazon-linux-extras install epel &&\\
% } elsif ($type =~ /centos/) {
 <%= $conf->{installer} // 'yum' %> -y install epel-release &&\\
% }
 <%= $conf->{installer} // 'yum' %> -y <%= join " ", map {"--enablerepo=$_"} @{ $conf->{enablerepo} || [] } %> install \\
% for my $key (sort keys %{ $conf->{yum} }) {
 <%= join " ", @{$conf->{yum}{$key}} %>\\
% }
 && <%= $conf->{installer} // 'yum' %> clean all &&\\
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\\
% if ($conf->{setcap}) {
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\\
% }
% if ($conf->{requires_old_phpunit} or $conf->{requires_latest_phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit<%= $conf->{requires_old_phpunit} ? "-4.8.36" : '' %>.phar > phpunit && chmod +x phpunit &&\\
 mv phpunit /usr/local/bin/ &&\\
% }
 curl -sL --compressed https://git.io/cpm > cpm &&\\
 chmod +x cpm &&\\
 mv cpm /usr/local/bin/ &&\\
 cpm install -g <%= join " ", @{delete $conf->{cpan}{no_test}} %> &&\\
 cpm install -g --test\
% for my $key (sort keys %{ $conf->{cpan} }) {
 <%= join " ", @{ $conf->{cpan}{$key} } %>\\
% }
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
% if ($conf->{use_cpanm}) {
 cpanm --installdeps . &&\\
% } else {
 cpm install -g --test &&\\
% }
 rm -rf cpanfile /root/.perl-cpm /root.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \\
    LC_ALL=en_US.UTF-8

RUN set -ex &&\\
  perl -i -pe \\
    's{AllowOverride None}{AllowOverride All}g' \\
    /etc/httpd/conf/httpd.conf

% # cf https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html
% if (exists $conf->{make_dummy_cert}) {
RUN cd <%= $conf->{make_dummy_cert} %> && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \\
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR
% }

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
