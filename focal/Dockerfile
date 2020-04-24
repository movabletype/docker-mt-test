FROM ubuntu:focal

WORKDIR /root

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
  ca-certificates netbase\
  php php-cli php-mysql php-gd php-memcache phpunit\
  git make gcc ssh curl unzip bzip2 locales\
  perl perlmagick libgraphics-magick-perl\
  libssl-dev libgmp-dev libgd-dev libpng-dev libgif-dev libjpeg-dev netpbm libxml2-dev libgif-dev\
  mysql-server mysql-client libmysqlclient-dev\
  memcached procps &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
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
 rm -rf cpanfile /root/.perl-cpm/ /root/.qws/

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
