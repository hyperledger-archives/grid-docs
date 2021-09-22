# Building Grid

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Local Builds

Before building grid locally, make sure you have the following packages 
installed in Debian(Ubuntu):

- `build-essential`
- `libpq-dev`
- `libsasl2-dev`
- `libsqlite3-dev`
- `libssl-dev`
- `libxml2-dev`
- `libzmq3-dev`
- `openssl`
- `pkg-config`

These can be installed, for e.g. for the first package, by:

``
    $ sudo apt install build-essential -y
``

Once you have all the packages installed, you can invoke the build.

To build Grid locally, run `cargo build` from the root directory. This command
builds all of the Grid components, including `gridd` (the grid daemon),
the CLI, and all of the smart contracts in the `contracts` directory.

To build individual components, run `cargo build` in the component directories.
For example, to build only `grid-cli`, navigate to `cli`, then run
`cargo build`.

## Docker Builds

To build Grid using Docker, run `docker-compose build` from the root directory.
This command builds Docker images for all of the Grid components, including
`gridd` (the grid daemon), the CLI, and all of the smart contracts in the
`contracts` directory.

To build individual components using Docker, run
`docker-compose build <component>` from the root directory. For example, to
build only `grid-cli`, run `docker-compose build grid-cli`.

To use Docker to build Grid with experimental features enabled, set an
enviroment variable in your shell before running the build commands. For
example: `export 'CARGO_ARGS=-- --features experimental'`. To go back to
building with default features, unset the evironment variable:
`unset CARGO_ARGS`
