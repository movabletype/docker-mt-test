FROM centos:6

WORKDIR /root


RUN  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
 yum -y  install\
 git make gcc curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mysql-devel mysql-server mysql\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs ImageMagick giflib-devel libpng-devel libjpeg-devel gd-devel\
 perl-XML-Parser libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 mod_ssl vsftpd ftp memcached\
 &&\
 yum -y install epel-release &&\
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
    yum -y --enablerepo=epel install\
 GraphicsMagick-perl GraphicsMagick libwebp-devel\
 &&\
 yum -y install https://rpms.remirepo.net/enterprise/remi-release-6.rpm &&\
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
    yum -y --enablerepo=remi,remi-php55 install\
 php55-php php55-php-mbstring php55-php-mysqlnd php55-php-gd php55-php-pecl-memcache php55-php-xml\
 && yum clean --enablerepo=remi,remi-php55 all &&\
 yum -y update --skip-broken &&\
 yum clean all && rm -rf /var/cache/yum &&\
 mkdir src && cd src &&\
 curl -kLO https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz && tar xf ruby-2.7.8.tar.gz &&\
 cd ruby-2.7.8 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 ln -s /usr/bin/php55 /usr/local/bin/php &&\
 curl -skL https://phar.phpunit.de/phpunit-4.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 gem install \
  fluentd\
 &&\
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -n CryptX XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm Test::Deep@1.130 Email::MIME::ContentType@1.026 Email::MIME::Encodings@1.315 Email::MessageID@1.406 Email::Date::Format@1.005 Email::Simple@2.217 Email::MIME@1.952 Data::OptList@0.112 IO::Socket::IP@0.41 Mixin::Linewise::Readers@0.108 Pod::Eventual@0.094001 Pod::Coverage::TrustPod@0.100005 Math::GMP@2.22 Mojolicious@8.43 JSON::Validator@4.25 Archive::Zip@1.65 DBD::mysql@4.050 &&\
 cpanm -v \
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
 App::cpanminus DBD::SQLite\
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


COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
