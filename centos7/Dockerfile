FROM centos:7

WORKDIR /root

COPY ./patch/ /root/patch/

RUN  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
 yum -y  install\
 git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix cyrus-sasl-devel cyrus-sasl-plain\
 mariadb-devel mariadb-server mariadb\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs ImageMagick giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel\
  icc-profiles-openicc\
 libstdc++-static libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 libyaml-devel libffi-devel\
 mod_ssl vsftpd ftp memcached\
 &&\
 yum -y install epel-release &&\
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
    yum -y --enablerepo=epel install\
 GraphicsMagick-perl GraphicsMagick\
 &&\
 yum -y update --skip-broken &&\
 yum clean all && rm -rf /var/cache/yum &&\
  yum install -y \
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
  echo "--with-libxml" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-openssl" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-gd" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-jpeg-dir=/usr" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-png-dir=/usr" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-webp-dir=/usr" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-webp" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-pear" >> /usr/local/share/php-build/default_configure_options &&\
  echo 'patch_file "php-8.0-support-openssl-3.patch"' > /usr/local/share/php-build/definitions/my_php &&\
  echo 'install_package "https://secure.php.net/distributions/php-7.3.33.tar.bz2"' > /usr/local/share/php-build/definitions/my_php &&\
  php-build --verbose my_php /usr &&\
  yes | pecl install memcache-4.0.5.2 &&\
  echo "extension=memcache.so" >> /usr/etc/php.ini &&\
 mkdir src && cd src &&\
 curl -LO https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz &&\
 tar xf ruby-2.7.8.tar.gz &&\
 cd ruby-2.7.8 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -sL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
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
 cpanm -n Net::SSH::Perl XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v SQL::Translator@1.63 Data::MessagePack::Stream@1.04 Archive::Zip@1.65 DBD::mysql@4.052 &&\
      cd /root/patch/EV-4.36 && cpanm --installdeps . && cpanm . && cd /root &&\
    rm -rf /root/patch &&\
 cpanm -v \
 AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir Net::LDAP Linux::Pid Data::Section::Simple\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy Devel::CheckLib\
 JavaScript::Minifier CSS::Minifier\
 TAP::Harness::Env\
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

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
