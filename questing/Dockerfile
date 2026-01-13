FROM ubuntu:questing

WORKDIR /root

COPY ./patch/ /root/patch/

RUN \
 apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
 libstdc++-15-dev xz-utils ca-certificates netbase git make cmake gcc clang curl ssh locales perl zip unzip bzip2 procps\
  ssl-cert postfix libsasl2-dev libsasl2-modules\
 mysql-server mysql-client libmysqlclient-dev\
 vim nano\
 netpbm libgd-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev icc-profiles-free libavif-dev libheif-dev\
 libxml2-dev libgmp-dev libssl-dev\
 phpunit\
 ruby ruby-dev libyaml-dev libffi-dev\
 apache2 vsftpd ftp memcached\
 && ln -s /usr/sbin/apache2 /usr/sbin/httpd &&\
  git clone --depth 1 https://github.com/tokuhirom/plenv.git ~/.plenv &&\
  git clone --depth 1 https://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/ &&\
  echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.bash_profile &&\
  echo 'eval "$(plenv init -)"' >> ~/.bash_profile &&\
  export PATH="$HOME/.plenv/bin:$PATH" &&\
  eval "$(plenv init -)" &&\
  plenv install 5.42.0 &&\
  plenv global 5.42.0 &&\
  apt-get install -y autoconf bison re2c libonig-dev libsqlite3-dev &&\
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
  echo "--with-jpeg" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-webp" >> /usr/local/share/php-build/default_configure_options &&\
  echo "--with-pear" >> /usr/local/share/php-build/default_configure_options &&\
  echo 'install_package "https://www.php.net/distributions/php-8.4.16.tar.bz2"' > /usr/local/share/php-build/definitions/my_php &&\
  php-build --verbose my_php /usr &&\
  yes | pecl install memcache &&\
  echo "extension=memcache.so" >> /usr/etc/php.ini &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 mkdir src && cd src &&\
 curl -LO https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.46/GraphicsMagick-1.3.46.tar.xz &&\
 tar xf GraphicsMagick-1.3.46.tar.xz && cd GraphicsMagick-1.3.46 &&\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-opencl --disable-dependency-tracking --without-x \
   --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-fpx \
   --without-jpig --without-lcms2 --without-lzma --without-xml --with-quantum-depth=16 && make && make install &&\
   cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\
 curl -LO https://imagemagick.org/archive/releases/ImageMagick-7.1.2-12.tar.xz &&\
 tar xf ImageMagick-7.1.2-12.tar.xz && cd ImageMagick-7.1.2-12 &&\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-dependency-tracking --disable-cipher --disable-assert \
   --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps \
   --without-djvu --without-fftw --without-fpx --without-fontconfig --without-freetype --without-jbig --without-lcms \
   --without-lcms2 --without-lqr --without-lzma --without-openexr --without-pango --without-xml \
   --enable-delegate-build --with-xml --disable-openmp --disable-opencl && make && make install &&\
   cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -sL https://phar.phpunit.de/phpunit-12.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd:1.18.0\
 &&\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm &&\
 perl -pi -E \
   's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' \
   cpanm && mv cpanm /usr/local/bin &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g --show-build-log-on-failure GD XML::LibXML Web::Query XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpm install -g --test --show-build-log-on-failure Archive::Zip@1.65 DBD::mysql@4.052 &&\
      cd /root/patch/Test-mysqld-1.0030 && cpanm --installdeps . && cpanm . && cd /root &&\
      cd /root/patch/Crypt-DES-2.07 && cpanm --installdeps . && cpanm . && cd /root &&\
      cd /root/patch/YAML-Syck-1.36 && cpanm --installdeps . && cpanm . && cd /root &&\
      cd /root/patch/EV-4.36 && cpanm --installdeps . && cpanm . && cd /root &&\
    rm -rf /root/patch &&\
 cpanm -v \
 AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir Net::LDAP Linux::Pid Data::Section::Simple\
 pQuery\
 JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy Devel::CheckLib\
 JavaScript::Minifier CSS::Minifier\
 Fluent::Logger\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm -v --installdeps . \
 && rm -rf cpanfile /root/.perl-cpm/ /root/.cpanm /root/.qws

RUN set -ex &&\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
 localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 &&\
 a2dismod mpm_event &&\
 a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl  &&\
 a2enconf serve-cgi-bin &&\
 a2ensite default-ssl &&\
 make-ssl-cert generate-default-snakeoil &&\
 find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' &&\
 perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+"?(/\S+/php.ini)"?!; my $ini = do { open my $fh, "<", $inifile or die $!; local $/; <$fh> }; $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; open my $fh, ">", $inifile or die $!; print $fh $ini'

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_CONF_DIR=/etc/apache2

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
