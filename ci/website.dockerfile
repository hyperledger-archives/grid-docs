# Copyright (c) 2018 Bitwise IO, Inc.
#
# Copyright 2020 Cargill Incorporated
#
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

# -------------=== redoc build ===-------------

FROM node:lts-stretch as redoc

RUN npm install -g redoc
RUN npm install -g redoc-cli

COPY . /project

RUN redoc-cli bundle /project/docs/0.1/references/api/openapi.yaml -o index_0.1.html

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

ARG jekyll_env=development
ENV JEKYLL_ENV=$jekyll_env

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

COPY --from=redoc /index_0.1.html /usr/local/apache2/htdocs/docs/0.1/api/index.html
COPY --from=jekyll /tmp/ /usr/local/apache2/htdocs/
COPY ./database/postgres/0.1 /usr/local/apache2/htdocs/docs/0.1/database/postgres
COPY ./database/sqlite/0.1 /usr/local/apache2/htdocs/docs/0.1/database/sqlite
COPY ./database/postgres/0.2 /usr/local/apache2/htdocs/docs/0.2/database/postgres
COPY ./database/sqlite/0.2 /usr/local/apache2/htdocs/docs/0.2/database/sqlite
COPY --from=git /commit-hash /commit-hash
COPY apache/rewrite.conf /usr/local/apache2/conf/rewrite.conf

RUN echo "\
\n\
ServerName grid.hyperledger.org\n\
ErrorDocument 404 /404.html\n\
\n\
Include /usr/local/apache2/conf/rewrite.conf\n\
\n\
" >>/usr/local/apache2/conf/httpd.conf

EXPOSE 80/tcp
