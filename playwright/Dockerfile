FROM movabletype/test:bullseye

RUN apt-get update &&\
 curl -sL https://deb.nodesource.com/setup_lts.x | bash - &&\
 apt install -y nodejs chromium &&\
 npm install -g playwright uuid express &&\
 cpm install -g Playwright &&\
 rm -rf /root/.perl-cpm
ENV NODE_PATH=/usr/lib/node_modules

