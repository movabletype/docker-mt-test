FROM debian/eol:stretch-slim

WORKDIR /root

RUN \
  sed -i -E 's/deb.debian.org/archive.debian.org/' /etc/apt/sources.list &&\
  sed -i -E 's/security.debian.org/archive.debian.org/' /etc/apt/sources.list &&\
  sed -i -E 's/^.+\-updates.+//' /etc/apt/sources.list &&\
 apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
 ca-certificates netbase git make cmake gcc clang curl ssh locales perl zip unzip bzip2 procps ssl-cert postfix\
 mysql-server mysql-client libmysql++-dev\
 vim nano\
 perlmagick libgraphics-magick-perl netpbm imagemagick graphicsmagick libgd2-xpm-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev icc-profiles-free\
 libxml2-dev libgmp-dev libssl-dev\
 php-mbstring php php-cli php-mysqlnd php-gd php-memcache phpunit\
 apache2 vsftpd ftp memcached\
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 ln -s /usr/sbin/apache2 /usr/sbin/httpd &&\
 mkdir src && cd src &&\
 curl -LO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.4.tar.gz && tar xf ruby-3.1.4.tar.gz &&\
 cd ruby-3.1.4 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -sL https://phar.phpunit.de/phpunit-6.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd\
 &&\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm && perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm && mv cpanm /usr/local/bin &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g --show-build-log-on-failure YAML::Syck@1.31 XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpm install -g --test --show-build-log-on-failure Archive::Zip@1.65 DBD::mysql@4.050 HTTP::Message@6.46 &&\
 cpanm -v \
 pQuery\
 JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
 Fluent::Logger\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm -v --installdeps . \
 && rm -rf cpanfile /root/.perl-cpm/ /root/.cpanm /root/.qws

RUN set -ex &&\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
 localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 &&\
 a2dismod mpm_event &&\
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl php7.0 &&\
 a2enconf serve-cgi-bin &&\
 a2ensite default-ssl &&\
 make-ssl-cert generate-default-snakeoil &&\
 find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' &&\
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
