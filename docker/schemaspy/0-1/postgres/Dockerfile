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
# ------------------------------------------------------------------------------
FROM hyperledger/gridd:0.1

RUN apt-get update \
    && apt-get install -y -q \
    build-essential \
    graphviz \
    libpq-dev \
    libsqlite3-dev \
    openjdk-8-jre \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /output && \
    mkdir -p /org/schemaspy/drivers && \
    mkdir /schemaspy

COPY docker/schemaspy/0-1/postgres/generate .

COPY docker/schemaspy/0-1/postgres/pgsql11.properties /schemaspy

RUN chmod a+x generate

COPY --from=schemaspy/schemaspy:snapshot /usr/local/lib/schemaspy/schemaspy-6.1.1-SNAPSHOT.jar /schemaspy/schemaSpy.jar

COPY --from=schemaspy/schemaspy:snapshot /drivers_inc/ /org/schemaspy/drivers

RUN chmod a+x schemaspy/schemaSpy.jar

ENTRYPOINT ["./generate"]
