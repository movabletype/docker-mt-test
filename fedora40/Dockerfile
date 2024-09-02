FROM fedora:40

WORKDIR /root

COPY ./patch/ /root/patch/

RUN dnf -y  install\
 glibc-langpack-en glibc-langpack-ja xz git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which perl-Unix-Process postfix\
 community-mysql-devel community-mysql-server community-mysql\
 vim nano\
 libomp-devel ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel icc-profiles-openicc\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php php-mysqlnd php-gd php-mbstring php-pecl-memcache\
 ruby ruby-devel\
 mod_ssl vsftpd ftp memcached\
 &&\
 dnf -y update --skip-broken &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
 mkdir src && cd src &&\
 curl -kLO https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.43/GraphicsMagick-1.3.43.tar.xz &&\
 tar xf GraphicsMagick-1.3.43.tar.xz && cd GraphicsMagick-1.3.43 &&\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-opencl --disable-dependency-tracking --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-fpx --without-jpig --without-lcms2 --without-lzma --without-xml --without-gs --with-quantum-depth=16 && make && make install && cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd\
 &&\
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm && mv cpanm /usr/local/bin &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -v DBI@1.643 &&\
 cpanm -n XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v Archive::Zip@1.65 DBD::mysql@4.050 HTML::TreeBuilder::LibXML@0.27 &&\
      cd /root/patch/Test-mysqld-1.0020 && cpanm --installdeps . && cpanm . && cd /root &&\
    rm -rf /root/patch &&\
 cpanm -v \
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
 Fluent::Logger\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm --installdeps -v . &&\
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

RUN cd /usr/bin && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
