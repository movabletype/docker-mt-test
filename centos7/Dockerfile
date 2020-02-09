FROM centos:7

WORKDIR /root

RUN yum -y install\
 make gcc curl bzip2\
 perl perl-core\
 ImageMagick-perl perl-GD perl-XML-Parser\
 mariadb mariadb-server mariadb-devel memcached\
# NetPBM driver
 netpbm-progs\
# for Archive::Zip
 zip unzip\
# for DBD::mysql
 mysql-devel\
# for Imager
 giflib-devel libpng-devel libjpeg-devel\
# for Math::GMP
 gmp-devel\
# for Net::SSLeay
 openssl openssl-devel\
# for XML::LibXML
 libxml2-devel\
# for XML::SAX::ExpatXS
 expat-devel\
# for Test::mysqld and mysqld_safe
 which\
 php php-mysql php-gd php-pecl-memcache\
 epel-release &&\
 yum -y install phpunit &&\
 yum clean all &&\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
# PHP setting
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# CPAN modules
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 # a test for XMLRPC::Lite has been too fragile
 cpm install -g XMLRPC::Lite &&\
 cpm install -g --test\
  JSON::XS\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65\
  TAP::Harness::Env &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm &&\
# latest PHPUnit that supports both PHPUnit\Framework\TestCase namespace and PHP 5.3
 curl -sL https://phar.phpunit.de/phpunit-4.8.36.phar > phpunit &&\
 chmod +x phpunit &&\
 mv phpunit /usr/local/bin/

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

