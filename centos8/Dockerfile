FROM centos:8

WORKDIR /root

RUN dnf -y install epel-release &&\
# enable PowerTools for giflib-devel
 dnf -y --enablerepo=PowerTools install \
 make gcc curl bzip2 glibc-langpack-en\
 perl perl-core git\
 ImageMagick-perl perl-GD perl-XML-Parser\
 GraphicsMagick-perl\
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
 php php-mysqlnd php-gd php-json php-mbstring php-pdo php-xml\
# for Test::mysqld and mysqld_safe
 which hostname\
 mysql-server memcached &&\
 dnf clean all &&\
# MySQL 8.0 capability issue (https://bugs.mysql.com/bug.php?id=91395)
 setcap -r /usr/libexec/mysqld &&\
# PHP setting
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
 curl -kLO https://phar.phpunit.de/phpunit.phar &&\
 chmod +x phpunit.phar && mv phpunit.phar /usr/local/bin/phpunit &&\
# CPAN modules
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
# tests for XMLRPC::Lite and XML::Atom have been too fragile
 cpm install -g XMLRPC::Lite XML::Atom &&\
 cpm install -g --test\
# for speed
  JSON::XS\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65\
# Net::SFTP
  Crypt::Curve25519@0.05 &&\
  curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
  cpm install -g --test &&\
  rm -rf cpanfile /root/.perl-cpm

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
