FROM oraclelinux:8-slim

WORKDIR /root


RUN  microdnf -y install dnf &&\
 dnf -y  install\
 which glibc-locale-source git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mariadb-devel mariadb-server mariadb\
 vim nano\
 netpbm-progs libpng-devel libjpeg-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 httpd mod_ssl vsftpd ftp memcached\
 &&\
    dnf -y --enablerepo=ol8_codeready_builder install\
 giflib-devel\
 && dnf clean --enablerepo=ol8_codeready_builder all &&\
 dnf -y install oracle-epel-release-el8 &&\
    dnf -y --enablerepo=ol8_developer_EPEL install\
 ImageMagick ImageMagick-perl GraphicsMagick GraphicsMagick-perl gd-devel libwebp-devel perl-GD\
 && dnf clean --enablerepo=ol8_developer_EPEL all &&\
 dnf -y install oracle-instantclient-release-23ai-el8 &&\
    dnf -y --enablerepo=ol8_oracle_instantclient23 install\
 oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus\
 && dnf clean --enablerepo=ol8_oracle_instantclient23 all &&\
 dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.4.rpm &&\
    dnf -y module reset php ;\
    dnf -y module enable php:remi-8.2 ;\
    dnf -y install\
 php php-mbstring php-mysqlnd php-gd php-pecl-memcache php-xml php-oci8\
 &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
 mkdir src && cd src &&\
 curl -kLO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.4.tar.gz && tar xf ruby-3.1.4.tar.gz &&\
 cd ruby-3.1.4 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
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
 cpanm -n DBI Test::NoWarnings XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v Archive::Zip@1.65 DBD::mysql@4.050 HTML::TreeBuilder::LibXML@0.27 &&\
 cpanm -v \
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
 DBD::Oracle\
 Fluent::Logger\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm --installdeps -v . &&\
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
  localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 &&\
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
