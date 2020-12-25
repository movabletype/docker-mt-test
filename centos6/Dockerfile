FROM centos:6

WORKDIR /root

RUN yum -y install epel-release &&\
 yum -y  install \
 git make gcc curl perl perl-core glibc-langpack-en zip unzip bzip2 which procps\
 mysql-devel mysql-server\
 vim nano\
 ImageMagick-perl perl-GD GraphicsMagick-perl netpbm-progs giflib-devel libpng-devel libjpeg-devel\
 perl-XML-Parser libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php php-mysql php-gd php-pecl-memcache phpunit\
 mod_ssl vsftpd ftp memcached\
 && yum clean all &&\
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
 curl -sL https://phar.phpunit.de/phpunit-4.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 &&\
 cpm install -g --test Net::LDAP Linux::Pid\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman\
 App::cpanminus DBD::SQLite\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile && cpanm --installdeps . &&\
 rm -rf cpanfile /root/.perl-cpm /root.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  perl -i -pe \
    's{AllowOverride None}{AllowOverride All}g' \
    /etc/httpd/conf/httpd.conf


COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
