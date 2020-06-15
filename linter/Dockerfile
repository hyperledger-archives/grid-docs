# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
FROM ruby:alpine

RUN apk add --update \
    python2 \
    python2-dev \
    py-pip \
    build-base && \
    pip install --upgrade pip && \
    pip install restructuredtext_lint && \
    rm -rf /var/cache/apk/*

RUN gem install mdl