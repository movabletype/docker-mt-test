FROM ubuntu:disco

WORKDIR /root

RUN apt-get update &&\
\
 DEBIAN_FRONTEND=noninteractive apt-get -y install\
  apache2\
  php php-cli php-mysql php-gd php-memcache phpunit\
  git make gcc wget curl unzip bzip2\
  perl perlmagick\
  libssl-dev libgmp-dev libgd-dev libpng-dev libgif-dev libjpeg-dev netpbm libxml2-dev libmysql++-dev libgif-dev libdb-dev &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 &&\
 tar jxf phantomjs-1.9.8-linux-x86_64.tar.bz2 &&\
 cp phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/local/bin/ &&\
 rm -rf /phantomjs-1.9.8-linux-x86_64*

# https://github.com/ajgb/crypt-curve25519/issues/9
RUN curl -O -- https://cpan.metacpan.org/authors/id/A/AJ/AJGB/Crypt-Curve25519-0.06.tar.gz\
 && tar xzvf Crypt-Curve25519-0.06.tar.gz\
 && cd Crypt-Curve25519-0.06\
 && grep -rl "fmul" ./ | xargs sed -i 's/fmul/fixedvar/g'\
 && perl Makefile.PL\
 && make\
 && make test\
 && make install\
 && cd ..\
 && rm -rf Crypt-Curve25519-0.06*

RUN curl -sL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 wget https://raw.githubusercontent.com/movabletype/movabletype/5e636cc16c7c3f96215c8f52d2715cfd835e5584/t/cpanfile &&\
 cpm install -g --test JSON::XS TAP::Harness::Env Test::Base &&\
 cpm install -g --test &&\
 rm -rf cpanfile /root/.perl-cpm/ /root/.qws/

RUN apt-get update &&\
\
 DEBIAN_FRONTEND=noninteractive\
 apt-get -y install\
  mysql-server mysql-client\
  memcached &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
\
 service mysql start &&\
 mysql -e "create database mt_test character set utf8;" &&\
 mysql -e "grant all privileges on mt_test.* to mt@localhost identified by 'password';" &&\
 mysql -e "set password for mt@localhost = '';"

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

