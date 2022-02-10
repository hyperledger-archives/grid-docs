# Copyright 2020 Cargill Incorporated
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ruby

RUN gem install jekyll -- --use-system-libaries

RUN gem install \
    bundler \
    jekyll-default-layout \
    jekyll-optional-front-matter \
    jekyll-readme-index \
    jekyll-redirect-from \
    jekyll-seo-tag \
    jekyll-target-blank \
    jekyll-titles-from-headings

RUN gem install webrick

ENV JEKYLL_ENV=development

CMD ["jekyll", "--help"]
WORKDIR /srv/jekyll
VOLUME  /srv/jekyll
EXPOSE 35729
EXPOSE 4000
