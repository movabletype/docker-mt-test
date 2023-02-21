FROM fedora:36

WORKDIR /root

COPY ./patch/ /root/patch/

RUN dnf -y  install\
 glibc-langpack-en glibc-langpack-ja git make gcc curl perl perl-core tar zip unzip bzip2 which perl-Unix-Process postfix\
 community-mysql-devel community-mysql-server community-mysql\
 vim nano\
 ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel icc-profiles-openicc\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php php-mysqlnd php-gd php-mbstring php-pecl-memcache\
 mod_ssl vsftpd ftp memcached\
 &&\
 dnf -y update --skip-broken &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\
      cd /root/patch/Test-mysqld-1.0013 && cpanm --installdeps . && cpanm . && cd /root &&\
    rm -rf /root/patch &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g HTML::TreeBuilder::LibXML XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver &&\
 cpm install -g --test\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 Archive::Zip@1.65\
 JSON::XS Starman Imager::File::WEBP\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
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
    open my $fh, ">", $inifile; print $fh $ini'

RUN cd /usr/bin && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
