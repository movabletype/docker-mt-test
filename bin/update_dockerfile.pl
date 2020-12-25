#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use Data::Section::Simple qw/get_data_section/;
use Mojo::Template;
use Mojo::File qw/path/;

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
            editor => [qw( vim nano )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken  => [qw( Archive::Zip@1.65 Crypt::Curve25519@0.05 )],
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
            editor => [qw( vim nano )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken  => [qw( Archive::Zip@1.65 Crypt::Curve25519@0.05 )],
            extra   => [qw( JSON::XS Starman )],
            addons  => [qw( Net::LDAP Linux::Pid )],
        },
    },
    sid => {
        from => 'debian:sid-slim',
        base => 'debian',
        apt  => {
            _replace => {
                'mysql-server'       => 'mariadb-server',
                'mysql-client'       => 'mariadb-client',
                'libmysqlclient-dev' => '',
                'php'                => 'php8.0',
                'php-cli'            => 'php8.0-cli',
                'php-mysqlnd'        => 'php8.0-mysql',
                'php-gd'             => 'php8.0-gd',
                'php-memcache'       => '',
                'phpunit'            => '',
            },
            db => [qw( libdbd-mysql-perl )],
        },
        phpunit => 9,
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
        phpunit => 4,
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
        phpunit => 6,
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
        phpunit => 4,
    },
    fedora => {
        from => 'fedora:32',
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
    fedora31 => {
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
        phpunit => 4,
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
        phpunit => 4,
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
        phpunit => 4,
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
        make_dummy_cert => '/usr/bin',
        phpunit => 8,
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
        phpunit => 4,
    },
    oracle => {
        from => 'oraclelinux:7-slim',
        base => 'centos',
        yum  => {
            _replace => {
                'mysql-server'      => 'mariadb-server',
                'mysql-client'      => 'mariadb',
                'mysql-devel'       => 'mariadb-devel',
            },
            base   => [qw( which )],
            server => [qw( httpd )],
        },
        cpan => {
            missing => [qw( DBD::Oracle )],
        },
        make_dummy_cert => '/etc/pki/tls/certs/',
        phpunit => 4,
        release => 19.6,
    },
    archlinux => {
        from => 'archlinux',
        pacman => {
            base => [qw(
                ca-certificates git make gcc curl openssh perl
                unzip bzip2 pkgconf which
            )],
            images => [qw(
                imagemagick graphicsmagick netpbm
                gd libpng giflib libjpeg-turbo
            )],
            server => [qw( apache vsftpd memcached )],
            db     => [qw( mariadb )],
            libs   => [qw( libxml2 gmp openssl )],
            php    => [qw( php php-gd php-memcached )],
        },
        cpan => {
            ## fragile tests, or broken by other modules (Atom, Pulp)
            no_test => [qw( XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp )],
            ## cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
            broken  => [qw( Archive::Zip@1.65 Crypt::Curve25519@0.05 Net::SSLeay@1.85 )],
            extra   => [qw( JSON::XS Starman )],
            addons  => [qw( Net::LDAP Linux::Pid )],
        },
        phpunit => 9,
    },
);

my $templates = get_data_section();

my @targets = @ARGV ? @ARGV : grep $Conf{$_}{base}, sort keys %Conf;
for my $name (@targets) {
    if (!exists $Conf{$name}) {
        say "unknown target: $name";
        next;
    }
    my $base = $Conf{$name}{base};
    my $template    = $templates->{$name} || $templates->{$base};
    my $ep_template = $templates->{"$name-entrypoint"} || $templates->{"$base-entrypoint"};
    say $name;
    mkdir $name unless -d $name;
    my $conf       = merge_conf($name);
    my $dockerfile = Mojo::Template->new->render($template, $name, $conf);
    my $entrypoint = Mojo::Template->new->render($ep_template, $name, $conf);
    path("$name/Dockerfile")->spurt($dockerfile);
    path("$name/docker-entrypoint.sh")->spurt($entrypoint)->chmod(0755);
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
% if ($conf->{phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
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
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl <%= join " ", @{ $conf->{apache}{enmod} || [] } %> &&\\
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
% if ($type eq 'centos6') {
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo &&\\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo &&\\
% }
% if ($type eq 'amazonlinux') {
 amazon-linux-extras install epel &&\\
% } elsif ($type eq 'oracle') {
 yum -y install oracle-release-el7 && yum-config-manager --enable ol7_oracle_instantclient &&\\
 yum -y install oracle-instantclient<%= $conf->{release} %>-basic oracle-instantclient<%= $conf->{release} %>-devel oracle-instantclient<%= $conf->{release} %>-sqlplus &&\\
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
% if ($conf->{phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
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
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

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

@@ debian-entrypoint
% my ($type, $conf) = @_;
#!/bin/bash
set -e

% if ($type =~ /^(?:trusty|focal|bionic)$/) {
find /var/lib/mysql -type f | xargs touch
% } elsif ($type =~ /^(?:buster|jessie)$/) {
chown -R mysql:mysql /var/lib/mysql
% }
% if ($type eq 'sid') {
service mariadb start
% } else {
service mysql start
% }
service memcached start

mysql -e "create database mt_test character set utf8;"
% if ($type !~ /^(?:trusty|jessie)$/) {
mysql -e "create user mt@localhost;"
% }
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"

@@ centos-entrypoint
% my ($type, $conf) = @_;
#!/bin/bash
set -e

% if ($type eq 'centos6') {
service mysqld start
service memcached start
% } elsif ($type =~ /^(?:centos7|fedora23|oracle|amazonlinux)$/) {
mysql_install_db --user=mysql --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld_safe --user=mysql --datadir=/var/lib/mysql &"
sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% } elsif ($type =~ /^(?:centos8|fedora|fedora31)$/) {  ## MySQL 8.*
echo 'default_authentication_plugin = mysql_native_password' >> /etc/my.cnf.d/<% if (grep /community/, @{$conf->{yum}{db}}) { %>community-<% } %>mysql-server.cnf
mysqld --initialize-insecure --user=mysql --skip-name-resolve >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done
% }

% if ($type eq 'centos6') {
mysql -e "create database if not exists mt_test character set utf8;"
% } else {
mysql -e "create database mt_test character set utf8;"
% }
% if ($type ne 'centos6') {
mysql -e "create user mt@localhost;"
% }
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

memcached -d -u root

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"

@@ archlinux
% my ($type, $conf) = @_;
FROM <%= $conf->{from} %>

WORKDIR /root

RUN pacman -Syu --noconfirm \\
% for my $key (sort keys %{ $conf->{pacman} }) {
 <%= join " ", @{$conf->{pacman}{$key}} %>\\
% }
 && yes | pacman -Scc &&\\
% if ($conf->{phpunit}) {
 curl -sL https://phar.phpunit.de/phpunit-<%= $conf->{phpunit} %>.phar > phpunit && chmod +x phpunit &&\\
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
 mkdir /var/www &&\\
 find /etc/httpd/ | grep '\.conf' | xargs perl -i -pe \\
   's!AllowOverride None!AllowOverride All!g; s!/srv/http!/var/www!g'

ENV LANG=en_US.UTF-8 \\
    LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

@@ archlinux-entrypoint
% my ($type, $conf) = @_;
#!/bin/bash
set -e

memcached -u root&

mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --auth-root-authentication-method=normal --skip-name-resolve --force >/dev/null

bash -c "cd /usr; mysqld --datadir='/var/lib/mysql' --user=mysql &"

sleep 1
until mysqladmin ping -h localhost --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 1
done

mysql -e "create database mt_test character set utf8;"
mysql -e "create user mt@localhost;"
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

PATH=$PATH:/usr/bin/site_perl:/usr/bin/core_perl

cat <<PHP >> /etc/php/conf.d/mt.ini
extension=gd
extension=mysqli
extension=pdo_mysql
PHP

if [ -f t/cpanfile ]; then
    cpm install -g --cpanfile=t/cpanfile
fi

exec "$@"
