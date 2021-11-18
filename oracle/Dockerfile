FROM oraclelinux:7-slim

WORKDIR /root

RUN yum -y install\
 which git make gcc curl perl perl-core tar zip unzip bzip2 which procps postfix\
 mariadb-devel mariadb-server mariadb\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs ImageMagick libpng-devel libjpeg-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 httpd mod_ssl vsftpd ftp memcached\
 &&\
 yum -y install oracle-release-el7 && yum-config-manager --enable ol7_oracle_instantclient &&\
 yum -y install oracle-instantclient19.6-basic oracle-instantclient19.6-devel oracle-instantclient19.6-sqlplus &&\
 yum -y reinstall glibc-common &&\
 yum -y install oracle-epel-release-el7 &&\
    yum -y --enablerepo=ol7_developer_EPEL install\
 GraphicsMagick-perl-1.3.32-1.el7 gd-devel giflib-devel libwebp-devel\
 && yum clean --enablerepo=ol7_developer_EPEL all &&\
 yum -y install oracle-php-release-el7 &&\
    yum -y --enablerepo=ol7_developer_php74 install\
 php php-mysqlnd php-gd php-mbstring phpunit php-oci8-19c\
 && yum clean --enablerepo=ol7_developer_php74 all &&\
    yum -y --enablerepo=ol7_optional_latest install\
 gd-devel giflib-devel libwebp-devel\
 && yum clean --enablerepo=ol7_optional_latest all &&\
    yum -y --enablerepo=ol7_oracle_instantclient install\
 oracle-instantclient19.6-basic oracle-instantclient19.6-sqlplus\
 && yum clean --enablerepo=ol7_oracle_instantclient all &&\
 yum clean all && rm -rf /var/cache/yum &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 Selenium::Remote::Driver &&\
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
  perl -i -pe \
    's{AllowOverride None}{AllowOverride All}g' \
    /etc/httpd/conf/httpd.conf &&\
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \
    my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; \
    $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \
    open my $fh, ">", $inifile; print $fh $ini'

RUN cd /etc/pki/tls/certs/ && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
