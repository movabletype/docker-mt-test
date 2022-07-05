FROM oraclelinux:8-slim

WORKDIR /root

RUN microdnf -y install\
 which glibc-locale-source git make gcc curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mariadb-devel mariadb-server mariadb\
 vim nano\
 netpbm-progs libpng-devel libjpeg-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 httpd mod_ssl vsftpd ftp memcached\
 &&\
    microdnf -y module reset php ;\
    microdnf -y module enable php:7.4 ;\
    microdnf -y install\
 php php-cli php-gd php-mysqlnd php-mbstring\
 &&\
 microdnf -y install oracle-epel-release-el8 &&\
    microdnf -y --enablerepo=ol8_developer_EPEL install\
 ImageMagick ImageMagick-perl GraphicsMagick GraphicsMagick-perl gd-devel libwebp-devel perl-GD\
 && microdnf clean --enablerepo=ol8_developer_EPEL all &&\
 microdnf -y install oracle-instantclient-release-el8 &&\
    microdnf -y --enablerepo=ol8_oracle_instantclient21 install\
 oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus\
 && microdnf clean --enablerepo=ol8_oracle_instantclient21 all &&\
 microdnf clean all && rm -rf /var/cache/microdnf &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g DBI Test::NoWarnings XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver &&\
 cpm install -g --test\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman\
 DBD::Oracle\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
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
    open my $fh, ">", $inifile; print $fh $ini'

RUN cd /usr/bin && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]