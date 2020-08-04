# Copyright (c) 2018 Bitwise IO, Inc.
#
# Copyright 2020 Cargill Incorporated
#
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

# -------------=== jekyll build ===-------------

FROM jekyll/jekyll:3.8 as jekyll

RUN gem install \
    bundler \
    jekyll-default-layout \
    jekyll-optional-front-matter \
    jekyll-readme-index \
    jekyll-redirect-from \
    jekyll-seo-tag \
    jekyll-target-blank \
    jekyll-titles-from-headings

COPY . /srv/jekyll

WORKDIR /srv/jekyll

RUN rm -rf /srv/jekyll/_site \
 && jekyll build --verbose --destination /tmp

# -------------=== log commit hash ===-------------

FROM alpine as git

RUN apk update \
 && apk add \
    git

COPY .git/ /tmp/.git/
WORKDIR /tmp
RUN git rev-parse HEAD > /commit-hash

# -------------=== apache docker build ===-------------

FROM httpd:2.4

COPY --from=jekyll /tmp/ /usr/local/apache2/htdocs/
COPY --from=git /commit-hash /commit-hash

RUN echo "\
\n\
ServerName grid.hyperledger.org\n\
ErrorDocument 404 /404.html\
\n\
" >>/usr/local/apache2/conf/httpd.conf

EXPOSE 80/tcp
