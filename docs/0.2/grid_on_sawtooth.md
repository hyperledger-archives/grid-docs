# Running Hyperledger Grid on Sawtooth

Hyperledger Grid supports [Sawtooth](https://sawtooth.hyperledger.org/) as a
backend distributed ledger. This document shows how to set up a
Grid-on-Sawtooth environment that runs in a set of Docker containers.

The example Sawtooth [docker-compose](https://github.com/hyperledger/grid/blob/master/examples/sawtooth/docker-compose.yaml)
file creates a network with two nodes (alpha and beta) that can be used for
demos or application development. This environment includes the Pike, Product,
Location, and Schema smart contracts.

- **Pike** handles organization and identity permissions with the Sabre smart
  contract engine.
- [Grid Product]({% link docs/0.2/grid_product.md %})
  provides a way to share GS1-compatible product data (items
  that are transacted, traded, or referenced in a supply chain).
- [Schema]({% link docs/0.2/schema_smart_contract_specification.md %})
  provides a reusable, standard approach to defining, storing, and
  consuming the product properties. Property definitions are collected into a
  Schema data type that defines all the possible properties for an item.

## Prerequisites

- Docker Engine
- Docker Compose

## Set Up and Run Grid

1. Clone the [Hyperledger Grid repository](https://github.com/hyperledger/grid)
   ([https://github.com/hyperledger/grid](https://github.com/hyperledger/grid)).
2. Navigate to the grid root directory and build the Grid Docker containers.

   `$ docker-compose -f examples/sawtooth/docker-compose.yaml build --pull`

3. Start the Grid Docker containers.

   `$ docker-compose -f examples/sawtooth/docker-compose.yaml up`

   This docker-compose file creates a network with two nodes (alpha and beta)
   that includes the Pike, Schema, and Product smart contracts.

## Next Steps

Once the Grid on Sawtooth environment is running, you can demonstrate Grid
functionality with existing smart contracts, such as Pike organizations and
Grid products. You can also upload new smart contracts.

### Demonstrate Grid Smart Contract Functionality

You can use the Pike and Grid Product smart contracts to demonstrate Grid
functionality by creating an organization and agent, defining a schema for the
product properties, and creating a product.

* [Creating Organizations]({% link docs/0.2/creating_organizations.md %})
  describes how to create an owning organization for Grid items (such as
  products), and set the permissions for an agent who is
  allowed to create and manage those items.

* [Creating Schemas]({% link docs/0.2/creating_schemas.md %})
  explains how to define the format of properties for Grid items such as
  products.

* [Creating Products]({% link docs/0.2/creating_products.md %}) shows how to
  create, update, and delete products as the organization's agent.

### Smart Contract Deployment

* [Uploading Smart Contracts]({% link docs/0.2/uploading_smart_contracts.md %})
  explains how to upload and configure a new smart contract.
