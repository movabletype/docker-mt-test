FROM fedora:23

WORKDIR /root


RUN dnf -y  install\
 hostname git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix\
 community-mysql-devel community-mysql-server community-mysql\
 vim nano\
 ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel icc-profiles-openicc\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php php-mysqlnd php-gd php-mbstring php-pecl-memcache phpunit\
 mod_ssl vsftpd ftp memcached\
 &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
 mkdir src && cd src &&\
 curl -kLO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.4.tar.gz && tar xf ruby-3.1.4.tar.gz &&\
 cd ruby-3.1.4 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -skL https://phar.phpunit.de/phpunit-5.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 gem install \
  fluentd\
 &&\
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g --show-build-log-on-failure XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpm install -g --test --show-build-log-on-failure Archive::Zip@1.65 DBD::mysql@4.050 HTML::TreeBuilder::LibXML@0.27 &&\
 cpm install -g --test --show-build-log-on-failure\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
 Fluent::Logger\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test --show-build-log-on-failure &&\
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' \
    /etc/httpd/conf/httpd.conf &&\
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \
    my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; \
    $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \
    open my $fh, ">", $inifile; print $fh $ini' &&\
  sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

RUN cd /etc/pki/tls/certs/ && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
