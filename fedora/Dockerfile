FROM fedora:31

WORKDIR /root

RUN dnf -y install\
 make gcc curl bzip2\
 perl perl-core\
 ImageMagick-perl perl-GD perl-XML-Parser\
# NetPBM driver
 netpbm-progs\
# for Archive::Zip
 zip unzip\
# for DBD::mysql
 community-mysql-devel\
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
 php php-mysqlnd php-gd php-pecl-memcache\
# for Test::mysqld and mysqld_safe
 which hostname perl-Unix-Process\
 community-mysql-server memcached\
 phpunit &&\
 dnf clean all &&\
# PHP setting
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# CPAN modules
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
# a test for XMLRPC::Lite has been too fragile
 cpm install -g XMLRPC::Lite &&\
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

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
