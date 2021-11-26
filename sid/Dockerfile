FROM debian:sid-slim

WORKDIR /root

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
 ca-certificates netbase git make gcc curl ssh locales perl zip unzip bzip2 procps ssl-cert postfix\
 libdbd-mysql-perl mariadb-server mariadb-client\
 vim nano\
 perlmagick libgraphics-magick-perl netpbm imagemagick graphicsmagick libgd-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev icc-profiles-free\
 libxml2-dev libgmp-dev libssl-dev\
 php8.0-mbstring php8.0-xml php8.0 php8.0-cli php8.0-mysql php8.0-gd\
 apache2 vsftpd ftp memcached\
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 ln -s /usr/sbin/apache2 /usr/sbin/httpd &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g HTML::TreeBuilder::LibXML XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver &&\
 cpm install -g\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman Imager::File::WEBP\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm/

RUN set -ex &&\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
 localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 &&\
 a2dismod mpm_event &&\
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl  &&\
 a2enconf serve-cgi-bin &&\
 a2ensite default-ssl &&\
 make-ssl-cert generate-default-snakeoil &&\
 find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g' &&\
 perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \
   my $ini = do { open my $fh, "<", $inifile or die $!; local $/; <$fh> }; \
   $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \
   open my $fh, ">", $inifile or die $!; print $fh $ini'


ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_CONF_DIR=/etc/apache2

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
