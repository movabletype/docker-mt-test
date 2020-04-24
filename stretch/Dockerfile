FROM debian:stretch-slim

WORKDIR /root

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
  ca-certificates netbase\
  git make gcc curl ssh locales\
  perl perlmagick\
  unzip bzip2\
  netpbm\
  php php-cli php-mysqlnd php-gd php-memcache phpunit\
  mysql-server mysql-client\
  memcached\
  libssl-dev libgmp-dev libgd2-xpm-dev libpng-dev libgif-dev libjpeg-dev libxml2-dev libmysql++-dev &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
 curl -sL https://phar.phpunit.de/phpunit-4.8.36.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
# tests for XMLRPC::Lite and XML::Atom have been too fragile
 cpm install -g XMLRPC::Lite XML::Atom YAML::Syck@1.31 &&\
 cpm install -g\
# cf https://rt.cpan.org/Public/Bug/Display.html?id=130525
  Archive::Zip@1.65\
# for speed
  JSON::XS &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm/

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
