FROM fedora:32

WORKDIR /root

RUN dnf -y install\
 glibc-langpack-en glibc-langpack-ja git make gcc curl perl perl-core zip unzip bzip2 which perl-Unix-Process\
 community-mysql-devel community-mysql-server community-mysql\
 vim nano\
 ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs giflib-devel libpng-devel libjpeg-devel gd-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php php-mysqlnd php-gd php-mbstring php-pecl-memcache phpunit\
 mod_ssl vsftpd ftp memcached\
 && dnf clean all &&\
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 &&\
 cpm install -g --test\
 Net::LDAP Linux::Pid\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  perl -i -pe \
    's{AllowOverride None}{AllowOverride All}g' \
    /etc/httpd/conf/httpd.conf

RUN cd /usr/bin && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
