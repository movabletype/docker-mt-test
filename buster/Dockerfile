FROM debian:buster-slim

WORKDIR /root

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
  ca-certificates netbase\
  git make gcc curl ssh\
  perl perlmagick\
  unzip bzip2\
  netpbm\
  php php-cli php-mysqlnd php-gd php-memcache phpunit\
  mariadb-server mariadb-client\
# unfortunately DBD::mysql 4.050 has a bug that has been fixed only in the repo
  libdbd-mysql-perl\
# for App::Prove::Plugin::MySQL
  procps\
  memcached\
  libssl-dev libgmp-dev libgd-dev libpng-dev libgif-dev libjpeg-dev libxml2-dev &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
 curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
# a test for XMLRPC::Lite has been too fragile
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
 rm -rf cpanfile /root/.perl-cpm/

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
