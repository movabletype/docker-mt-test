FROM centos:8

WORKDIR /root


RUN  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
 dnf -y  install\
 glibc-langpack-ja git make gcc curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mysql-devel mysql-server mysql\
 vim nano\
 netpbm-progs libpng-devel libjpeg-devel gd-devel libwebp-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 mod_ssl vsftpd ftp memcached\
 &&\
    dnf -y --enablerepo=PowerTools install\
 giflib-devel\
 &&\
 dnf -y install epel-release &&\
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
    dnf -y --enablerepo=epel install\
 GraphicsMagick-perl ImageMagick-perl perl-GD ImageMagick GraphicsMagick\
 &&\
 dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.4.rpm &&\
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
    dnf -y module reset php ;\
    dnf -y module enable php:remi-8.0 ;\
    dnf -y install\
 php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml\
 &&\
 dnf -y update --skip-broken --nobest &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
 mkdir src && cd src &&\
 curl -kLO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.4.tar.gz && tar xf ruby-3.1.4.tar.gz &&\
 cd ruby-3.1.4 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 gem install \
  fluentd\
 &&\
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -n XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm Archive::Zip@1.65 DBD::mysql@4.050 &&\
 cpanm -v \
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
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
