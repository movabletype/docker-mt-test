FROM movabletype/test:buster

RUN apt-get update &&\
 curl -sL https://deb.nodesource.com/setup_lts.x | bash - &&\
 apt install -y nodejs chromium &&\
 npm install -g playwright uuid express &&\
 cpm install -g Playwright
ENV NODE_PATH=/usr/lib/node_modules

