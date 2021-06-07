# Grid v0.2 Release

<!--
  Copyright 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Note: This release is currently in development.

If you're new to Grid, see the [Grid documentation]({% link docs/0.2/index.md %})
to learn about Grid concepts and features.

Grid v0.2 is the second major release of Grid. Below is a summary of the
features and changes included in this release.

## New and Noteworthy

### GDSN support for Grid Product

Prior to this release, Grid Product required a custom-defined Grid Schema to be
used to support validation. It also could only accept products defined one at a
time via command-line args or using the Grid UI, or bulk uploaded from a custom
yaml format. These limitations presented some challenges when trying to directly
support GDSN-compliant data. It also had been a challenge to create typical Grid
schemas that accurately represent GDSN data structures, due to the heavily
nested structure and large number of attributes present within the standard.

GS1 already provides a robust set of
[GDSN schemas](http://www.gdsregistry.org/3.1/schemas/gs1/gdsn/) in XML Schema
Definition (XSD) format. With this new feature, Grid can take advantage of these
schemas directly, eliminating much of the difficulty in defining custom schemas
based on GDSN.

Note that if GDSN is not the preferred format for GS1 standards for a certain
use-case, users can still define custom schemas for Grid Product.

#### Support for adding GDSN product data via the CLI

GDSN products can be created and updated on Grid via the CLI. In addition to the
previously supported YAML format, Grid will now accept XML wrapped in the
gridTradeItems element as defined in the
[GridTradeItems XSD](https://github.com/hyperledger/grid/blob/main/sdk/src/products/gdsn/GridTradeItems.xsd).
For more information, please see the
[Grid CLI Command Reference]({% link docs/0.2/cli_references.md %}).

#### Grid Product UI with view capabilities

The Grid Product UI has been updated to support displaying GDSN XML data by
default. In this release, product creation functionality has been removed from
the UI. See the [Product Sapling]({% link community/planning/product_sapling.md %})
planning document for future plans for this UI.
