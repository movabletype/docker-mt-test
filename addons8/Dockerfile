FROM movabletype/test:cloud7

ADD ./ldif/* /root/

RUN dnf install -y \
  vsftpd ftp gettext openldap-servers openldap-clients iproute &&\
 mkdir /var/lib/ldap/jp/ &&\
 chown ldap:ldap /var/lib/ldap/jp/ &&\
 slapd -h "ldap:/// ldapi:/// ldaps:///" -u ldap -F /etc/openldap/slapd.d &&\
 ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif &&\
 ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif &&\
 ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif &&\
 ldapmodify -Y EXTERNAL -H ldapi:// -f /root/cn=config.ldif &&\
 ldapadd -f /root/example_com.ldif -x -D "cn=admin,dc=example,dc=com" -w secret &&\
 ldapadd -f /root/example_jp.ldif -x -D "cn=admin,dc=example,dc=jp" -w secret &&\
 ldapadd -f /root/domain1_example_jp.ldif -x -D "cn=admin,dc=example,dc=jp" -w secret &&\
 ldapadd -f /root/domain2_example_jp.ldif -x -D "cn=admin,dc=example,dc=jp" -w secret &&\
 curl -kLO https://github.com/jedisct1/pure-ftpd/releases/download/1.0.50/pure-ftpd-1.0.50.tar.gz &&\
 tar xf pure-ftpd-1.0.50.tar.gz && cd pure-ftpd-1.0.50 &&\
 ./configure --prefix=/usr/local --with-altlog --with-virtualhosts --with-nonroot --with-tls --with-puredb &&\
 make && make install && cd .. && rm -rf pure-ftpd-* &&\
 curl -kLO ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.8b.tar.gz &&\
 tar xf proftpd-1.3.8b.tar.gz && cd proftpd-1.3.8b &&\
 ./configure --prefix=/usr/local --enable-dso --enable-openssl --with-pic --enable-nls --with-modules=mod_tls &&\
 make && make install && cd .. && rm -rf proftpd-*

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
