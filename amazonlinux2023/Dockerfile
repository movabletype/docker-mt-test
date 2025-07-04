FROM amazonlinux:2023

WORKDIR /root


RUN dnf -y --allowerasing install\
 which hostname glibc-langpack-ja glibc-locale-source git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix cyrus-sasl-devel cyrus-sasl-plain\
 mariadb1011-pam mariadb1011-devel mariadb1011-server mariadb1011\
 vim nano\
 ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs ImageMagick GraphicsMagick giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel icc-profiles-openicc\
 libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php-cli php-xml php-json php php-mysqlnd php-gd php-mbstring\
 ruby ruby-devel\
 httpd mod_ssl vsftpd memcached\
 &&\
 dnf -y update --skip-broken &&\
 dnf clean all && rm -rf /var/cache/dnf &&\
 curl -sL https://phar.phpunit.de/phpunit-11.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  json fluentd\
 &&\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm && perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm && mv cpanm /usr/local/bin &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -v ExtUtils::ParseXS@3.51 &&\
 cpanm -n XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v Archive::Zip@1.65 DBD::mysql@4.052 &&\
 cpanm -v \
 AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir Net::LDAP Linux::Pid Data::Section::Simple\
 pQuery\
 JSON::XS Starman Imager::File::WEBP Plack::Middleware::ReverseProxy Devel::CheckLib\
 JavaScript::Minifier CSS::Minifier\
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
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; open my $fh, ">", $inifile; print $fh $ini' &&\
  sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

RUN cd /usr/bin && ./make-dummy-cert /etc/pki/tls/certs/localhost.crt &&\
  perl -i -pe 's!SSLCertificateKeyFile /etc/pki/tls/private/localhost.key!!' \
  /etc/httpd/conf.d/ssl.conf && cd $WORKDIR

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
