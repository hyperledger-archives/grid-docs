# Grid v0.2 Downloads

<!--
  Copyright 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Grid repository

Clone the core [GitHub repository](https://github.com/hyperledger/grid/tree/0-2)
to view the Grid source code, demo applications, and example Docker compose
files for starting up a Grid network. Learn more
by browsing the [Grid documentation]({% link docs/0.2/index.md %}).

NOTE: Grid v0.2 exists as a branch on the core repository. Checkout the `0-2`
branch after cloning the core to view the Grid v0.2 source code.

## Grid-contrib repository

Additional community contributed code is located in the
[Grid-contrib repository](https://github.com/hyperledger/grid-contrib).

## Rust crates

Use the following crates in your Rust project:

- [Grid-sdk](https://crates.io/crates/Grid-sdk) Grid SDK for building apps on
  Grid.

## Docker images

Grid provides the following prebuilt Docker images for the Grid daemon, CLI, and
UI.

- [hyperledger/gridd](https://hub.docker.com/r/hyperledger/gridd)
  Provides a REST API for fetching data and submitting transactions, and manages
  the connection to the underlying distributed ledger
- [hyperledger/grid-cli](https://hub.docker.com/r/hyperledger/grid-cli)
  Grid's command line interface for submitting transactions and fetching data
- [hyperledger/grid-ui](https://hub.docker.com/r/hyperledger/grid-ui)
  Front end interface for Grid built using the Canopy framework
