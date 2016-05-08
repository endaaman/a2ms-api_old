FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y \
  make g++ \
  curl git \
  supervisor

ENV NODE_ENV production

RUN curl -kL git.io/nodebrew | perl - setup
ENV PATH /root/.nodebrew/current/bin:$PATH
RUN nodebrew install-binary v4.4.3
RUN nodebrew use v4.4.3


ADD supervisor.conf /etc/supervisor/conf.d/

RUN mkdir -p /var/www/a2ms-api

ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /var/www/a2ms-api && cp -a /tmp/node_modules /var/www/a2ms-api/

ADD . /var/www/a2ms-api
WORKDIR /var/www/a2ms-api

CMD ["/usr/bin/supervisord"]

EXPOSE 3000
