FROM centos:6

WORKDIR /root


RUN  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
 yum -y  install\
 git make cmake gcc curl perl perl-core tar zip unzip bzip2 which procps postfix cyrus-sasl-devel cyrus-sasl-plain\
 mysql-devel mysql-server mysql\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs ImageMagick giflib-devel libpng-devel libjpeg-devel gd-devel\
 perl-XML-Parser libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php php-mysql php-gd php-mbstring php-pecl-memcache\
 mod_ssl vsftpd ftp memcached\
 &&\
 yum -y install epel-release &&\
  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-* &&\
    yum -y --enablerepo=epel install\
 GraphicsMagick-perl GraphicsMagick libwebp-devel clang\
 &&\
 yum -y update --skip-broken &&\
 yum clean all && rm -rf /var/cache/yum &&\
 mkdir src && cd src &&\
 curl -LO https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz && tar xf ruby-2.7.8.tar.gz &&\
 cd ruby-2.7.8 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 curl -sL https://phar.phpunit.de/phpunit-4.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd\
 &&\
 curl -sL https://cpanmin.us > cpanm && chmod +x cpanm && perl -pi -E 's{http://(www\.cpan\.org|backpan\.perl\.org|cpan\.metacpan\.org|fastapi\.metacpan\.org|cpanmetadb\.plackperl\.org)}{https://$1}g' cpanm && mv cpanm /usr/local/bin &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm --no-lwp -n CryptX XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm --no-lwp -v Test::MockModule@v0.176.0 Data::OptList@0.113 Sub::Exporter@0.990 Data::Section@0.200007 Software::License@0.104004 Test::Deep@1.130 Email::MIME::ContentType@1.026 Email::MIME::Encodings@1.315 Email::MessageID@1.406 Email::Date::Format@1.005 Email::Simple@2.217 Email::MIME@1.952 Data::OptList@0.112 Sub::Exporter@0.987 IO::Socket::IP@0.41 Mixin::Linewise::Readers@0.108 Pod::Eventual@0.094001 Pod::Coverage::TrustPod@0.100005 Math::GMP@2.22 Mojolicious@8.43 JSON::Validator@4.25 Plack@1.0050 DBD::SQLite SQL::Translator@1.63 HTML::TreeBuilder::LibXML@0.26 Mouse@2.5.10 Archive::Zip@1.65 DBD::mysql@4.050 &&\
 cpanm --no-lwp -v \
 AnyEvent::FTP::Server Class::Method::Modifiers Capture::Tiny Moo File::chdir Net::LDAP Linux::Pid Data::Section::Simple\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy Devel::CheckLib\
 JavaScript::Minifier CSS::Minifier\
 Fluent::Logger\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm --no-lwp --installdeps -v . &&\
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
