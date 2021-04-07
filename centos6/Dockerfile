FROM centos:6

WORKDIR /root

RUN  sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo &&\
  sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo &&\
 yum -y install\
 git make gcc curl perl perl-core zip unzip bzip2 which procps\
 mysql-devel mysql-server mysql\
 vim nano\
 ImageMagick-perl perl-GD netpbm-progs giflib-devel libpng-devel libjpeg-devel gd-devel\
 perl-XML-Parser libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 php-xml php php-mysql php-gd php-mbstring php-pecl-memcache\
 mod_ssl vsftpd ftp memcached\
 &&\
 yum -y install epel-release &&\
    yum -y --enablerepo=epel install\
 GraphicsMagick-perl\
 && yum clean --enablerepo=epel all &&\
 yum clean all && rm -rf /var/cache/yum &&\
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
 curl -sL https://phar.phpunit.de/phpunit-4.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Net::SSLeay@1.85 &&\
 cpm install -g --test\
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman\
 App::cpanminus DBD::SQLite\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm --installdeps . &&\
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  perl -i -pe \
    's{AllowOverride None}{AllowOverride All}g' \
    /etc/httpd/conf/httpd.conf


COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
