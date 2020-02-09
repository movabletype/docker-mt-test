FROM amazonlinux:2

WORKDIR /root

RUN amazon-linux-extras install epel && yum -y install\
 make gcc curl bzip2\
 perl perl-core\
 ImageMagick-perl perl-GD perl-XML-Parser\
 mariadb mariadb-server mariadb-devel memcached\
# NetPBM driver
 netpbm-progs\
# for Archive::Zip
 zip unzip\
# for DBD::mysql
 mariadb-devel\
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
 which procps\
 php php-mysql php-gd php-pecl-memcache phpunit &&\
# PHP setting
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# CPAN modules
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 # tests for XMLRPC::Lite and XML::Atom have been too fragile
 cpm install -g XMLRPC::Lite XML::Atom &&\
 cpm install -g --test\
  JSON::XS\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65 &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm

ENV LANG=en_US.UTF8
ENV LC_ALL=en_US.UTF8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

