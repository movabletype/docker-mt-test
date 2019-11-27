FROM movabletype/test:buster

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
  vsftpd ftp
