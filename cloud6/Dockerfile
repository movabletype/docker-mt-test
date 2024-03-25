FROM centos:7

WORKDIR /root


RUN yum -y  install\
 git make cmake gcc clang curl perl perl-core tar zip unzip bzip2 which procps postfix\
 vim nano\
 netpbm-progs giflib-devel libpng-devel libjpeg-devel gd-devel libwebp-devel icc-profiles-openicc\
 gd-devel libstdc++-static libxml2-devel expat-devel openssl-devel openssl gmp-devel\
 mod_ssl vsftpd ftp memcached\
 &&\
 yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm &&\
 rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 &&\
    yum -y --enablerepo=mysql57-community install\
 mysql-community-server mysql-community-client mysql-community-devel\
 &&\
 yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm &&\
    yum -y --enablerepo=remi,remi-php74 install\
 php74-php php74-php-mbstring php74-php-mysqlnd php74-php-gd php74-php-pecl-memcache php74-php-xml\
 && yum clean --enablerepo=remi,remi-php74 all &&\
 yum clean all && rm -rf /var/cache/yum &&\
 mkdir src && cd src &&\
 curl -kLO http://cpan.metacpan.org/src/5.0/perl-5.28.2.tar.gz && tar xf perl-5.28.2.tar.gz &&\
 cd perl-5.28.2 && ./Configure -des -Dprefix=/usr -Accflags=-fPIC -Duseshrplib && make && make install && cd .. &&\
 curl -kLO https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.36/GraphicsMagick-1.3.36.tar.xz &&\
 tar xf GraphicsMagick-1.3.36.tar.xz && cd GraphicsMagick-1.3.36 &&\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-openmp --disable-opencl --disable-dependency-tracking --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-fpx --without-jpig --without-lcms2 --without-lzma --without-xml --without-gs --with-quantum-depth=16 && make && make install && cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\
 curl -kLO https://imagemagick.org/archive/releases/ImageMagick-7.0.8-68.tar.xz &&\
 tar xf ImageMagick-7.0.8-68.tar.xz && cd ImageMagick-7.0.8-68 &&\
 ./configure --prefix=/usr --enable-shared --with-perl --disable-openmp --disable-dependency-tracking --disable-cipher --disable-assert --without-x --without-ttf --without-wmf --without-magick-plus-plus --without-bzlib --without-zlib --without-dps --without-djvu --without-fftw --without-fpx --without-fontconfig --without-freetype --without-jbig --without-lcms --without-lcms2 --without-lqr --without-lzma --without-openexr --without-pango --without-xml && make && make install && cd PerlMagick && perl Makefile.PL && make install && cd ../.. &&\
 curl -kLO https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.8.tar.gz && tar xf ruby-2.7.8.tar.gz &&\
 cd ruby-2.7.8 && ./configure --enable-shared --disable-install-doc && make -j4 && make install && cd .. &&\
 cd .. && rm -rf src && ldconfig /usr/local/lib &&\
 ln -s /usr/bin/php74 /usr/local/bin/php &&\
 curl -skL https://phar.phpunit.de/phpunit-9.phar > phpunit && chmod +x phpunit &&\
 mv phpunit /usr/local/bin/ &&\
 (curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash) &&\
 gem install \
  fluentd\
 &&\
 curl -skL https://cpanmin.us > cpanm && chmod +x cpanm && mv cpanm /usr/local/bin &&\
 curl -skL --compressed https://git.io/cpm > cpm &&\
 chmod +x cpm &&\
 mv cpm /usr/local/bin/ &&\
 cpanm -n GD XMLRPC::Lite XML::Atom Net::Server Perl::Critic::Pulp Selenium::Remote::Driver &&\
 cpanm -v Archive::Zip@1.65 DBD::mysql@4.050 HTML::TreeBuilder::LibXML@0.27 &&\
 cpanm -v \
 Net::LDAP Linux::Pid AnyEvent::FTP Capture::Tiny Class::Method::Modifiers\
 pQuery\
 JSON::XS Starman Plack::Middleware::ReverseProxy\
 JavaScript::Minifier CSS::Minifier\
 App::cpanminus TAP::Harness::Env\
 Fluent::Logger\
 && curl -skLO https://raw.githubusercontent.com/movabletype/movabletype/develop/t/cpanfile &&\
 cpanm --installdeps -v . &&\
# use cpanm to avoid strong caching of cpm
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MS/MSTROUT/YAML-0.84.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TI/TIMB/DBI-1.633.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/C/CA/CAPTTOFU/DBD-mysql-4.033.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/A/AD/ADAMK/Crypt-DSA-1.17.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TODDR/IPC-Run-0.94.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/C/CL/CLEISHMAN/Cache-2.04.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/R/RU/RURBAN/GD-2.77.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/B/BI/BINGOS/Archive-Tar-2.04.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.41.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/Digest-SHA1-2.13.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MS/MSHELOR/Digest-SHA-5.71.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TONYC/Imager-1.003.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/XML-Atom-0.39.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIVKOVIC/Mail-Sendmail-0.79_16.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/P/PM/PMQS/Compress-Raw-Zlib-2.086.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/B/BB/BBB/File-NFSLock-1.29.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TOMHUGHES/IO-Zlib-1.10.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/K/KA/KANE/Package-Constants-0.02.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GB/GBARR/TimeDate-1.20.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/Time-HiRes-1.9724.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GW/GWYN/File-ShareDir-Install-0.04.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Plack-1.0037.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/L/LE/LEONT/ExtUtils-Config-0.008.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/L/LE/LEONT/ExtUtils-Helpers-0.022.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/L/LE/LEONT/ExtUtils-InstallPaths-0.011.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/L/LE/LEONT/Module-Build-Tiny-0.039.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Starman-0.4014.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/D/DO/DOY/Stream-Buffered-0.02.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Devel-StackTrace-AsHTML-0.11.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-PSGI-0.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/R/RH/RHANDOM/Net-Server-2.008.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/S/SM/SMUELLER/Data-Dumper-2.154.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/Data-Dump-1.23.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/K/KA/KAZUHO/HTTP-Parser-XS-0.16.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TOKUHIROM/HTTP-Headers-Fast-0.18.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/Devel-StackTrace-2.00.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MA/MARKOV/MailTools-2.08.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MA/MARKSTOS/CGI.pm-3.58.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/File-pushd-1.009.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/MIME-Base64-3.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/R/RJ/RJBS/MIME-Lite-3.028.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/D/DO/DOY/Try-Tiny-0.22.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/C/CO/CORION/parent-0.234.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/D/DM/DMUEY/File-Copy-Recursive-0.38.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Emulate-PSGI-0.20.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/IO-String-1.08.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Message-6.06.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/URI-1.60.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/P/PE/PERIGRIN/XML-NamespaceSupport-1.11.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GR/GRANTM/XML-SAX-Base-1.08.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GR/GRANTM/XML-SAX-0.99.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/S/SH/SHLOMIF/XML-LibXML-2.0121.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTML-Parser-3.71.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/P/PM/PMQS/IO-Compress-2.086.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/Encode-Locale-1.03.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MA/MARSCHAP/perl-ldap-0.65.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIKEM/Net-SSLeay-1.85.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/S/SU/SULLR/IO-Socket-SSL-2.058.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GB/GBARR/Authen-SASL-2.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/S/SO/SOENKE/String-CRC32-1.4.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/H/HE/HELENA/SOAP-Transport-HTTP-Plack-0.03.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/K/KA/KASEI/Class-Accessor-0.34.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GE/GETTY/HTTP-Body-1.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MK/MKUTTER/SOAP-Lite-0.714.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/A/AD/ADAMK/Class-Inspector-1.27.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TODDR/YAML-Syck-1.27.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/C/CW/CWEST/Net-SMTP-SSL-1.01.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/A/AW/AWESTHOLM/Net-SMTP-TLS-0.12.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/Digest-HMAC-1.03.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/R/RJ/RJBS/Test-Fatal-0.014.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/E/ET/ETHER/libwww-perl-6.13.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/N/NI/NIGELM/HTML-Format-2.05.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/K/KE/KENTNL/HTML-Tree-5.07.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MA/MAKAMAKA/JSON-2.59.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/G/GA/GAAS/HTTP-Date-6.02.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Hash-MultiValue-0.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/P/PM/PMQS/DB_File-1.828.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/O/OA/OALDERS/HTTP-BrowserDetect-2.04.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/J/JW/JWB/Proc-ProcessTable-0.51.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TA/TADAM/Plack-Middleware-Access-0.4.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MA/MANU/Net-IP-1.26.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MR/MRSAM/Net-CIDR-0.17.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Plack-Middleware-ReverseProxy-0.15.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/A/AB/ABH/Mozilla-CA-20180117.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/J/JH/JHI/BSD-Resource-1.2910.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/R/RG/RGARCIA/Linux-Pid-0.04.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/N/NL/NLNETLABS/Net-DNS-1.22.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/S/SH/SHAY/libnet-3.11.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/C/CL/CLEACH/Net-FTPSSL-0.42.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/L/LK/LKINLEY/Net-SFTP-0.12.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/S/SA/SALVA/Net-SFTP-Foreign-1.90.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/K/KH/KHW/Unicode-Normalize-1.26.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/P/PH/PHRED/Archive-Zip-1.68.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/T/TO/TODDR/IO-Tty-1.14.tar.gz &&\
 cpanm -nfv https://cpan.metacpan.org/authors/id/J/JA/JACOBY/Expect-1.35.tar.gz &&\
 rm -rf cpanfile /root/.perl-cpm /root/.cpanm /root/.qws

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex &&\
  localedef -i en_US -f UTF-8 en_US.UTF-8 &&\
  localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 &&\
  perl -i -pe \
   's!AllowOverride None!AllowOverride All!g; s!#AddEncoding x-gzip \.gz \.tgz!AddEncoding x-gzip .gz .tgz .svgz!g;' \
    /etc/httpd/conf/httpd.conf &&\
  perl -e 'my ($inifile) = `php --ini` =~ m!Loaded Configuration File:\s+(/\S+/php.ini)!; \
    my $ini = do { open my $fh, "<", $inifile; local $/; <$fh> }; \
    $ini =~ s!^;\s*date\.timezone =!date\.timezone = "Asia/Tokyo"!m; \
    open my $fh, ">", $inifile; print $fh $ini' &&\
  sed -i -E 's/inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf


COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
