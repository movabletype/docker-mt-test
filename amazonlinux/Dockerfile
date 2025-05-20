FROM amazonlinux:2

WORKDIR /root


RUN yum -y  install\
 which hostname glibc-langpack-ja git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix cyrus-sasl-devel cyrus-sasl-plain\
 mariadb-devel mariadb-server mariadb\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs ImageMagick giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel icc-profiles-openicc\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 httpd mod_ssl vsftpd ftp memcached\
 &&\
 amazon-linux-extras install GraphicsMagick1.3 &&\
    yum -y --enablerepo=amzn2extra-GraphicsMagick1.3 install\
 GraphicsMagick-perl GraphicsMagick\
 && yum clean --enablerepo=amzn2extra-GraphicsMagick1.3 all &&\
 amazon-linux-extras install php7.4 &&\
    yum -y --enablerepo=amzn2extra-php7.4 install\
 php php-mysqlnd php-gd php-mbstring php-xml\
 && yum clean --enablerepo=amzn2extra-php7.4 all &&\
 yum -y update --skip-broken &&\
 yum clean all && rm -rf /var/cache/yum &&\
 mkdir src && cd src &&\
 curl -LO https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.6.tar.gz && tar xf ruby-3.1.6.tar.gz &&\
 cd ruby-3.1.6 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -sL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd\
 &&\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm && perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm && mv cpanm /usr/local/bin &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -v ExtUtils::ParseXS@3.51 &&\
 cpanm -n XML::DOM XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v SQL::Translator@1.63 Archive::Zip@1.65 DBD::mysql@4.050 &&\
 cpanm -v \
 AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir Net::LDAP Linux::Pid Data::Section::Simple\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy Devel::CheckLib\
 JavaScript::Minifier CSS::Minifier\
 Fluent::Logger\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm --installdeps -v . &&\
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' \
    /etc/httpd/conf/httpd.conf &&\
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; open my $fh, ">", $inifile; print $fh $ini' &&\
  sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

RUN cd /etc/pki/tls/certs/ && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
