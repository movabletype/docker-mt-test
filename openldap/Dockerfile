FROM centos:6

ADD ./ldif/* /root/

RUN yum -y install openldap-servers openldap-clients\
 && yum clean all\
 && mkdir /var/lib/ldap/jp/\
 && chown ldap:ldap /var/lib/ldap/jp/\
 && service slapd start\
 && ldapmodify -Y EXTERNAL -H ldapi:// -f /root/cn=config.ldif\
 && ldapadd -f /root/example_com.ldif -x -D "cn=admin,dc=example,dc=com" -w secret\
 && ldapadd -f /root/example_jp.ldif -x -D "cn=admin,dc=example,dc=jp" -w secret\
 && ldapadd -f /root/domain1_example_jp.ldif -x -D "cn=admin,dc=example,dc=jp" -w secret\
 && ldapadd -f /root/domain2_example_jp.ldif -x -D "cn=admin,dc=example,dc=jp" -w secret\
 && service slapd stop\
 && chown -R ldap:ldap /var/lib/ldap/

CMD ["slapd", "-d", "0"]
EXPOSE 389

