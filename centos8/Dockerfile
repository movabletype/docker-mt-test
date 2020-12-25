FROM centos:8

WORKDIR /root

RUN dnf -y install epel-release &&\
 dnf -y --enablerepo=PowerTools install \
 git make gcc curl perl perl-core glibc-langpack-en zip unzip bzip2 which procps\
 mysql-devel mysql-server\
 vim nano\
 ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs giflib-devel libpng-devel libjpeg-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php-json php-mbstring php-pdo php-xml php php-mysqlnd php-gd\
 mod_ssl vsftpd ftp memcached\
 && dnf clean all &&\
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
 curl -sL https://phar.phpunit.de/phpunit-8.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp &&\
 cpm install -g --test Net::LDAP Linux::Pid\
 Archive::Zip@1.65 Crypt::Curve25519@0.05 Net::SSLeay@1.85\
 JSON::XS Starman\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile && cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm /root.cpanm /root/.qws

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
