FROM debian:buster-slim

RUN apt-get update &&\
 DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes\
 apt-get --no-install-recommends -y install\
  chromium-driver &&\
 apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENTRYPOINT [ "chromedriver", "--headless", "--no-sandbox", "--disable-gpu", "--url-base=wd/hub", "--whitelisted-ips=" ]

EXPOSE 9515
