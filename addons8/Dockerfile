FROM movabletype/test:cloud7

RUN dnf install -y \
 vsftpd ftp gettext openldap-servers openldap-clients iproute sudo &&\
 dnf install -y yum-utils &&\
 yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&\
 dnf install -y docker-ce iptables-utils &&\
 curl -kLO https://github.com/jedisct1/pure-ftpd/releases/download/1.0.50/pure-ftpd-1.0.50.tar.gz &&\
 tar xf pure-ftpd-1.0.50.tar.gz && cd pure-ftpd-1.0.50 &&\
 ./configure --prefix=/usr/local --with-altlog --with-virtualhosts --with-nonroot --with-tls --with-puredb &&\
 make && make install && cd .. && rm -rf pure-ftpd-* &&\
 curl -kLO ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.8b.tar.gz &&\
 tar xf proftpd-1.3.8b.tar.gz && cd proftpd-1.3.8b &&\
 ./configure --prefix=/usr/local --enable-dso --enable-openssl --with-pic --enable-nls --with-modules=mod_tls &&\
 make && make install && cd .. && rm -rf proftpd-* &&\
 curl -LO https://garagehq.deuxfleurs.fr/_releases/v2.1.0/`uname -m`-unknown-linux-musl/garage &&\
 chmod +x garage && mv garage /usr/local/bin

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
