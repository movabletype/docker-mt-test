FROM centos:6

WORKDIR /root

RUN yum -y install\
 gcc curl openssh-clients\
 perl perl-core\
 ImageMagick-perl perl-GD perl-XML-Parser\
 GraphicsMagick-perl\
 mysql-server mysql-client memcached\
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
 openssl-devel\
# for XML::LibXML
 libxml2-devel\
# for XML::SAX::ExpatXS
 expat-devel\
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
# tests for XMLRPC::Lite and XML::Atom have been too fragile
 cpm install -g XMLRPC::Lite XML::Atom &&\
 cpm install -g --test\
# for compat
  App::cpanminus\
# for speed
  JSON::XS\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65\
# for SQL::Translator
  DBD::SQLite &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
# cpm stalls for unknown reasons
# cpm install -g --test &&\
 cpanm --installdeps . &&\
 rm -rf cpanfile /root/.perl-cpm /root/.qws /root/.cpanm &&\
# latest PHPUnit that supports both PHPUnit\Framework\TestCase namespace and PHP 5.3
 curl -sL https://phar.phpunit.de/phpunit-4.8.36.phar > phpunit &&\
 chmod +x phpunit &&\
 mv phpunit /usr/local/bin/

RUN service mysqld start &&\
service memcached start &&\
mysql -e "create database if not exists mt_test character set utf8;" &&\
mysql -e "grant all privileges on mt_test.* to mt@localhost;"

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

