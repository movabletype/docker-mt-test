FROM movabletype/test:cloud7

RUN dnf install -y \
  vsftpd ftp gettext &&\
 curl -kLO https://github.com/jedisct1/pure-ftpd/releases/download/1.0.49/pure-ftpd-1.0.49.tar.gz &&\
 tar xf pure-ftpd-1.0.49.tar.gz && cd pure-ftpd-1.0.49 &&\
 ./configure --prefix=/usr/local --with-altlog --with-virtualhosts --with-nonroot --with-tls --with-puredb &&\
 make && make install && cd .. && rm -rf pure-ftpd-* &&\
 curl -kLO ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.7a.tar.gz &&\
 tar xf proftpd-1.3.7a.tar.gz && cd proftpd-1.3.7a &&\
 ./configure --prefix=/usr/local --enable-dso --enable-openssl --with-pic --enable-nls --with-modules=mod_tls &&\
 make && make install && cd .. && rm -rf proftpd-*
