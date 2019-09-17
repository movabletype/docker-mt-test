FROM centos:6

WORKDIR /root

RUN yum -y install\
 gcc curl\
 perl perl-core\
 ImageMagick-perl perl-GD perl-XML-Parser\
 mysql-server mysql-client memcached\
# NetPBM driver
 netpbm-progs\
# for Archive::Zip
 zip unzip\
# for DBD::mysql
 mysql-devel\
# for Imager
 giflib-devel libpng-devel libjpeg-devel\
# for Math::GMP
 gmp-devel\
# for Net::SSLeay
 openssl-devel\
# for XML::LibXML
 libxml2-devel\
# for XML::SAX::ExpatXS
 expat-devel\
 php php-mysql php-gd php-pecl-memcache\
 epel-release &&\
 yum -y install phpunit &&\
 yum clean all &&\
# PHP setting
 sed -i 's/^;date\.timezone =/date\.timezone = "Asia\/Tokyo"/' /etc/php.ini &&\
# CPAN modules
 curl -L http://cpanmin.us | perl - App::cpanminus &&\
 curl -sLO https://raw.githubusercontent.com/movabletype/movabletype/5e636cc16c7c3f96215c8f52d2715cfd835e5584/t/cpanfile &&\
 cpanm\
# for Perl::Critic
  PPI@1.246\
# Installing Devel::GlobalPhase@0.003000 fails
  Devel::GlobalPhase@0.002004\
  JSON::XS\
  TAP::Harness::Env\
  Test::Base\
# for SQL::Translator
  DBD::SQLite\
# for Test::Differences
  Capture::Tiny Text::Diff &&\
 cpanm --notest LWP::UserAgent &&\
 cpanm --installdeps . &&\
 rm -rf cpanfile /root/.cpm /root/.perl-cpm /root/.cpanm /root/.qws &&\
# latest PHPUnit that supports both PHPUnit\Framework\TestCase namespace and PHP 5.3
 curl -sL https://phar.phpunit.de/phpunit-4.8.36.phar > phpunit &&\
 chmod +x phpunit &&\
 mv phpunit /usr/local/bin/

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

