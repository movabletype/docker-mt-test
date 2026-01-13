FROM oraclelinux:9-slim

WORKDIR /root

COPY ./patch/ /root/patch/

RUN  microdnf -y install dnf &&\
 dnf -y  install\
 which glibc-locale-source git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix\
  cyrus-sasl-devel cyrus-sasl-plain\
 vim nano\
 netpbm-progs libpng-devel libjpeg-devel\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 libffi-devel\
 httpd mod_ssl vsftpd ftp memcached\
 &&\
    dnf -y --enablerepo=ol9_codeready_builder install\
 giflib-devel mariadb mariadb-server mariadb-devel\
 && dnf clean --enablerepo=ol9_codeready_builder all &&\
 dnf -y install oracle-epel-release-el9 &&\
    dnf -y --enablerepo=ol9_developer_EPEL install\
 ImageMagick ImageMagick-perl GraphicsMagick GraphicsMagick-perl gd-devel libwebp-devel perl-GD\
 && dnf clean --enablerepo=ol9_developer_EPEL all &&\
 dnf -y install oracle-instantclient-release-26ai-el9 &&\
    dnf -y --enablerepo=ol9_oracle_instantclient26 install\
 oracle-instantclient-basic oracle-instantclient-devel oracle-instantclient-sqlplus\
 && dnf clean --enablerepo=ol9_oracle_instantclient26 all &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
  dnf install -y --enablerepo=ol9_codeready_builder\
    autoconf bison re2c oniguruma-devel sqlite-devel &&\
  git clone --depth 1 https://github.com/php-build/php-build.git &&\
  cd php-build && ./install.sh && cd .. && rm -rf php-build &&\
  rm -rf /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-mbstring" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-session" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-dom" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-json" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-ctype" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-tokenizer" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-libxml" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-xml" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-xmlwriter" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-gd" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-pdo" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-phar" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--enable-fpm" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--disable-ipv6" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-mysqli=mysqlnd" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-pdo-mysql=mysqlnd" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-sqlite3" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-pdo-sqlite" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-oci8=instantclient,/usr/lib/oracle/23/client64/lib" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-pdo-oci=instantclient,/usr/lib/oracle/23/client64/lib" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-libxml" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-openssl" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-gd" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-jpeg" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-webp" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-pear" >> /usr/local/share/php-build/default_configure_options &&\
  echo 'install_package "https://www.php.net/distributions/php-8.3.29.tar.bz2"' > /usr/local/share/php-build/definitions/my_php &&\
  php-build --verbose my_php /usr &&\
  yes | pecl install memcache &&\
  echo "extension=memcache.so" >> /usr/etc/php.ini &&\
 mkdir src && cd src &&\
 curl -LO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.6.tar.gz &&\
 tar xf ruby-3.1.6.tar.gz &&\
 cd ruby-3.1.6 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -sL https://phar.phpunit.de/phpunit-12.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd:1.18.0\
 &&\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm &&\
 perl -pi -E \
   's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm &&\
 mv cpanm /usr/local/bin &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -n DBI Test::NoWarnings XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v Archive::Zip@1.65 DBD::mysql@4.052 &&\
      cd /root/patch/Test-mysqld-1.0030 && cpanm --installdeps . && cpanm . && cd /root &&\
      cd /root/patch/EV-4.36 && cpanm --installdeps . && cpanm . && cd /root &&\
    rm -rf /root/patch &&\
 cpanm -v \
 AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir Net::LDAP Linux::Pid Data::Section::Simple\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy Devel::CheckLib\
 JavaScript::Minifier CSS::Minifier\
 DBD::Oracle\
 Fluent::Logger\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
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
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+"?(/\S+/php.ini)"?!; my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; open my $fh, ">", $inifile; print $fh $ini' &&\
  sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

RUN cd /usr/bin && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
