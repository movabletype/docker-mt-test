FROM amazonlinux:2

WORKDIR /root

RUN yum -y install\
 which hostname glibc-langpack-ja git make gcc curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mariadb-devel mariadb-server mariadb\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 httpd mod_ssl vsftpd ftp memcached\
 &&\
 amazon-linux-extras install GraphicsMagick1.3 &&\
    yum -y --enablerepo=amzn2extra-GraphicsMagick1.3 install\
 GraphicsMagick-perl\
 && yum clean --enablerepo=amzn2extra-GraphicsMagick1.3 all &&\
 amazon-linux-extras install php7.4 &&\
    yum -y --enablerepo=amzn2extra-php7.4 install\
 php php-mysqlnd php-gd php-mbstring php-xml\
 && yum clean --enablerepo=amzn2extra-php7.4 all &&\
 yum clean all && rm -rf /var/cache/yum &&\
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
 curl -sL https://phar.phpunit.de/phpunit-4.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver &&\
 cpm install -g --test\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
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

RUN cd /etc/pki/tls/certs/ && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
