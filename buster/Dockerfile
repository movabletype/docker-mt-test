FROM debian:buster-slim

WORKDIR /root

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive\
 apt-get --no-install-recommends -y install\
  git make gcc curl\
  perl perlmagick\
  unzip bzip2\
  netpbm\
  php php-cli php-mysqlnd php-gd php-memcache phpunit\
  mariadb-server mariadb-client\
  memcached\
  libssl-dev libgmp-dev libgd-dev libpng-dev libgif-dev libjpeg-dev libxml2-dev libmariadb-dev &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
# a test for XMLRPC::Lite has been too fragile
 cpm install -g XMLRPC::Lite &&\
 cpm install -g\
# for speed
  JSON::XS\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65\
# Net::SFTP
  Crypt::Curve25519@0.05 &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm/

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
