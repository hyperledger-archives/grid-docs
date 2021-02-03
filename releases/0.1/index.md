# Grid v0.1 Release

<!--
  Copyright 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Grid v0.1 is the first major release of Grid. Here's a summary of the initial
features included in this release. For detailed changes related to the v0.1
release, see the [Grid release notes](https://github.com/hyperledger/grid/blob/0-1/RELEASE_NOTES.md).

If you're new to Grid, see the [Grid documentation]({% link docs/0.1/index.md %})
to learn about Grid concepts and features.

## Grid Components

### Grid Daemon

The Grid daemon includes REST API endpoints for submitting transactions and
fetching Grid data. It also manages the connection to the underlying distributed
ledger and to the Grid database. For more information about the Grid REST API
endpoints, see
the [Grid REST API Reference]({% link docs/0.1/references/api/index.md %}).
To view the Grid Database tables, see
the [Grid Database Reference]({% link docs/0.1/references/database/index.md %}).

### Grid CLI

The Grid CLI provides subcommands to submit transactions and fetch data via the
Grid REST API. It also provides functionality to run database migrations and
generate keys with which a user can sign transactions and batches. For more
information, see the [CLI Command Reference]({% link docs/0.1/cli_references.md %}).

### Grid UI

The Grid UI is a modular front end for Grid built using the [Canopy framework](https://www.splinter.dev/docs/0.4/concepts/canopy_application_framework.html).
The Grid v0.1 release includes a saplings for authentication, profile
management, and Grid Product. Saplings for other Grid features are forthcoming
in later releases. As of Grid v0.1, the Grid UI only works with Splinter backed
deployments of Grid.

## Grid Features

Grid v0.1 includes two high level features for building applications:
[Product]({% link docs/0.1/grid_product.md %}) and
[Location]({% link docs/0.1/grid_location.md %}). It also includes two
supporting features,
[Pike]({% link docs/0.1/pike_smart_contract_specification.md %}) and
[Schema]({% link docs/0.1/schema_smart_contract_specification.md %}). Each of
these features includes a smart contract, handlers for translating data from
Scabbard or Sawtooth state change events into database records in the Grid
database, as well as CLIs and REST API endpoints for fetching data.

## Grid Software

Grid is an open-source software platform that is available on Github in the
[hypeledger/grid](https://github.com/hyperledger/grid) repository.

Prebuilt Docker images are published on Dockerhub:
 - Grid daemon: [hyperledger/gridd](https://hub.docker.com/r/hyperledger/gridd)
 - Grid CLI: [hyperledger/grid-cli](https://hub.docker.com/r/hyperledger/grid-cli)
 - Grid UI: [hyperledger/grid-ui](https://hub.docker.com/r/hyperledger/grid-ui)
