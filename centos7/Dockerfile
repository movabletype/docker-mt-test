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
 php php-mysql php-gd php-pecl-memcache\
 epel-release &&\
 yum -y install phpunit &&\
 yum clean all &&\
# PHP setting
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# CPAN modules
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/5e636cc16c7c3f96215c8f52d2715cfd835e5584/t/cpanfile &&\
 cpm install -g --test\
# Installing Devel::GlobalPhase@0.003000 fails
  Devel::GlobalPhase@0.002004\
  JSON::XS\
  TAP::Harness::Env\
  Test::Base\
# for SQL::Translator
  DBD::SQLite\
# for Test::Differences
  Capture::Tiny Text::Diff &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

