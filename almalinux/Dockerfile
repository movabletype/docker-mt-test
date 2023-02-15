FROM almalinux:9.0

WORKDIR /root

RUN dnf -y --allowerasing install\
 glibc-langpack-ja glibc-langpack-en glibc-locale-source git make gcc curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mysql-server mysql\
 vim nano\
 netpbm-progs libpng-devel libjpeg-devel gd-devel libwebp-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 mod_ssl vsftpd ftp memcached\
 &&\
    dnf -y --enablerepo=crb install\
 mysql-devel giflib-devel\
 &&\
 dnf -y install epel-release &&\
    dnf -y --enablerepo=epel install\
 GraphicsMagick-perl ImageMagick-perl perl-GD ImageMagick GraphicsMagick\
 &&\
 dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm &&\
    dnf -y module reset php ;\
    dnf -y module enable php:remi-8.1 ;\
    dnf -y install\
 php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml\
 &&\
 dnf -y update --skip-broken &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install --show-build-log-on-failure -g HTML::TreeBuilder::LibXML XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver &&\
 cpm install --show-build-log-on-failure -g --test\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman Imager::File::WEBP\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install --show-build-log-on-failure -g --test &&\
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
