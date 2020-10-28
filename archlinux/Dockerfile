FROM archlinux

WORKDIR /root

RUN pacman -Syu --noconfirm \
 ca-certificates git make gcc curl openssh perl unzip bzip2 pkgconf which\
 mariadb\
 imagemagick graphicsmagick netpbm gd libpng giflib libjpeg-turbo\
 libxml2 gmp openssl\
 php php-gd php-memcached\
 apache vsftpd memcached\
 && yes | pacman -Scc &&\
 curl -sL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpm install -g XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp &&\
 cpm install -g\
 Net::LDAP Linux::Pid\
 Archive::Zip@1.65 Crypt::Curve25519@0.05\
 JSON::XS Starman\
 && curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm/

RUN set -ex &&\
 mkdir /var/www &&\
 find /etc/httpd/ | grep '\.conf' | xargs perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!/srv/http!/var/www!g'

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
