# Using Grid Features

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Most Grid features are designed to interact with Pike organizations and Schema
definitions.

For example, each product requires an owning organization, one or more agents
that have permission to create and update the product, and a product schema
that defines the structure and format of product properties.
Likewise, each product schema must have an owning organization and an agent
(or agents) with appropriate permissions.

Follow these general steps when creating a new item:

1. [Create an organization]({% link docs/0.2/creating_organizations.md %})
   with at least one agent that has the permissions to create and manage the
   item.

1. Create a schema that defines the structure of the item's properties.

1. Create an item (such as a product) that conforms to the property definitions
   in the item's schema.

## Important Notes

Before using Grid features such as Grid Product and Grid Location, the following
prerequisites must be met.

* Two or more nodes running Grid with the same backend distributed ledger
  (either Splinter or Hyperledger Sawtooth). The following procedures describe
  how to bring up a Grid node with each type of distributed ledger.

    - [Running Grid on Splinter]({% link docs/0.2/grid_on_splinter.md %})
    - [Running Grid on Sawtooth]({% link docs/0.2/grid_on_sawtooth.md %})
      <br><br>

* For Grid on Splinter, these features require a **Splinter circuit** that
  connects two or more nodes in a private network. Grid shares feature
  information only with the member nodes on a specific circuit. The following
  procedure describes how to create and manage a circuit.

    - [Creating Splinter Circuits](creating_splinter_circuits.md)
