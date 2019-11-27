FROM debian:jessie-slim

WORKDIR /root

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive\
 apt-get --no-install-recommends -y install\
  git make gcc curl\
  perl perlmagick\
  unzip bzip2\
  netpbm\
  php5 php5-cli php5-mysqlnd php5-gd php5-memcache phpunit\
  mysql-server mysql-client\
  memcached\
  libssl-dev libgmp-dev libgd2-xpm-dev libpng-dev libgif-dev libjpeg-dev libxml2-dev libmysql++-dev &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 curl -sL https://phar.phpunit.de/phpunit-4.8.36.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
# a test for XMLRPC::Lite has been too fragile
 cpm install -g XMLRPC::Lite &&\
 cpm install -g\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65\
# for speed
  JSON::XS &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm/

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
