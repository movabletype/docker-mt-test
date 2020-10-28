FROM fedora:32

RUN dnf -y install chromedriver && dnf clean all

ENTRYPOINT [ "chromedriver", "--headless", "--no-sandbox", "--disable-gpu", "--url-base=wd/hub", "--whitelisted-ips=" ]

EXPOSE 9515
