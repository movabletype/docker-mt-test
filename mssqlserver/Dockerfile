FROM mcr.microsoft.com/mssql/server:2022-latest

WORKDIR /root

USER root

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes apt-get --no-install-recommends -y install ca-certificates netbase git make cmake gcc clang curl ssh locales perl zip unzip bzip2 procps ssl-cert postfix vim nano perlmagick libgraphics-magick-perl netpbm imagemagick graphicsmagick libgd-dev libpng-dev libgif-dev libjpeg-dev libwebp-dev icc-profiles-free libxml2-dev libgmp-dev libssl-dev php-mbstring php-xml php php-cli php-gd php-memcache phpunit apache2 vsftpd ftp memcached unixodbc unixodbc-dev mysql-server mysql-client libmysql++-dev
RUN apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN ln -s /usr/sbin/apache2 /usr/sbin/httpd
RUN mkdir src && cd src 
RUN curl -kLO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.4.tar.gz && tar xf ruby-3.1.4.tar.gz
RUN cd ruby-3.1.4 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. 
RUN cd .. && rm -rf src && ldconfig /usr/local/lib
RUN curl -skL https://phar.phpunit.de/phpunit-8.phar > phpunit && chmod +x phpunit
RUN mv phpunit /usr/local/bin/
RUN (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) 
RUN gem install fluentd
RUN curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin
RUN curl -skL --compressed https://git.io/cpm > cpm
RUN chmod +x cpm
RUN mv cpm /usr/local/bin/
RUN cpm install -g --show-build-log-on-failure XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver
RUN cpm install -g --test --show-build-log-on-failure Archive::Zip@1.65 HTML::TreeBuilder::LibXML@0.27
RUN cpanm -v Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers pQuery JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy JavaScript::Minifier CSS::Minifier Fluent::Logger
RUN curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile

RUN DBD_ODBC_UNICODE=1 cpm install -g --test --show-build-log-on-failure DBD::ODBC
RUN cpm install -g --test --show-build-log-on-failure DBD::mysql@4.050

# cpanm with -n options because some tests are fails, IPC::Run for example
RUN cpanm -v --installdeps -n .
RUN rm -rf cpanfile /root/.perl-cpm/ /root/.cpanm /root/.qws

RUN set -ex
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork cgi rewrite proxy proxy_http ssl php8.1
RUN a2enconf serve-cgi-bin
RUN a2ensite default-ssl
RUN make-ssl-cert generate-default-snakeoil
RUN find /etc/apache2/ | grep '\.conf' | xargs perl -i -pe 's!AllowOverride None!AllowOverride All!g; s!/usr/lib/cgi-bin!/var/www/cgi-bin!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;'
RUN perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \
   my $ini = do { open my $fh, "<", $inifile or die $!; local $/; <$fh> }; \
   $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \
   open my $fh, ">", $inifile or die $!; print $fh $ini'

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_CONF_DIR=/etc/apache2 \
    MSSQL_SA_PASSWORD=Password.1 \
    MSSQL_PID=Developer \
    MT_TEST_ODBCDRIVER="ODBC Driver 18 for SQL Server" \
    MT_TEST_ODBCENCRYPT=No \
    MT_TEST_BACKEND=UMSSQLServer \
    MT_TEST_OBJECTDRIVER=DBI::UMSSQLServer \
    MT_TEST_DATABASE=mt_test \
    MT_TEST_DBHOST=localhost \
    MT_TEST_DBUSER=SA \
    MT_TEST_DBPASSWORD=Password.1 \
    MT_TEST_IGNORE_FIXTURE=1

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
