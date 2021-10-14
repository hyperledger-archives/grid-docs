# Copyright 2018-2020 Cargill Incorporated
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

build: ci-build

ci-build *build_mode:
    ./ci/build-website {{build_mode}}

ci-lint:
    docker-compose \
        -f docker/compose/run-lint.yaml \
        up \
        --abort-on-container-exit \
        --build \
        lint-grid-docs

docker-run:
    docker-compose up --build; docker-compose down

lint: ci-lint

run: docker-run
