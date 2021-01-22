# Running Hyperledger Grid on Splinter

Hyperledger Grid supports [Splinter](https://www.splinter.dev/) as a backend
distributed ledger. This document shows how to set up a Grid-on-Splinter
environment that runs in a set of Docker containers.

The example Splinter docker-compose file creates a network with three nodes
(alpha, beta, and gamma) that can be used for demos or application development.
This environment includes the Pike, Product, and Schema smart contracts.

- **Pike** handles organization and identity permissions with Sabre, a smart
  contract engine that is included in the Splinter scabbard service.
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


## Important Notes

Due to ongoing development of Splinter the images in this example can become
stale. If you have used this procedure before, run the following command to
ensure that your images are up to date:

```
$ docker-compose -f examples/splinter/docker-compose.yaml pull generate-registry db-alpha scabbard-cli-alpha splinterd-alpha
```

## Set Up and Run Grid

1. Clone the [Hyperledger Grid repository](https://github.com/hyperledger/grid)
   ([https://github.com/hyperledger/grid](https://github.com/hyperledger/grid)).
2. Navigate to the grid root directory and build the Grid Docker containers.

   `$ docker-compose -f examples/splinter/docker-compose.yaml build --pull`

3. Start the Grid Docker containers.

   `$ docker-compose -f examples/splinter/docker-compose.yaml up`

   This docker-compose file creates a network with two nodes (alpha and beta)
   that includes the Pike, Schema, and Product smart contracts.

## Next Steps

Once the Grid on Splinter environment is running, you can create a circuit to
connect two nodes, then demonstrate Grid functionality with existing smart
contracts, such as Pike organizations and Grid products. You can also upload
new smart contracts to the circuit.

### Create a Circuit

[Creating Splinter
Circuits]({% link docs/0.2/creating_splinter_circuits.md %})
explains the procedure to connect nodes on a circuit.

Tip: After the circuit exists, you can [demonstrate circuit
scope](#demonstrate-circuit-scope) to show that Splinter isolates information
to members of a circuit.

For more information on Splinter circuits, see the
[Splinter documentation](https://www.splinter.dev/docs/).

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


### Demonstrate Smart Contract Deployment

You can use the `scabbard` CLI to deploy custom smart contracts on existing
circuits.

* [Uploading Smart Contracts]({% link docs/0.2/uploading_smart_contracts.md %})
  explains how to upload and configure a new smart contract.


### Demonstrate Circuit Scope

If a node is not a part of a circuit, that node cannot access information about
that circuit or any transactions that occur on that circuit.

Use the following steps to demonstrate that the third node in the network
(gamma-node-000) cannot see the circuit between alpha and beta, even when it
participates in a new multi-party circuit with those nodes.

1. Connect to the splinterd-gamma Docker container. You will use this container
   to run Splinter commands on gamma-node-000.

   ```
   $ docker-compose -f examples/splinter/docker-compose.yaml exec splinterd-gamma bash
   root@splinterd-gamma:/#
   ```

2. Verify that splinterd-gamma does not see any circuits.
   ```
   root@splinterd-gamma:/# splinter circuit list --url http://splinterd-gamma:8085
   ID MANAGEMENT MEMBERS
   ```

Final note: Splinter strictly enforces privacy for all information on a
circuit, including participants, available smart contracts, and transactions
performed by the participants using those smart contracts.

For example, if gamma creates a circuit with alpha and a separate circuit with
beta, then uploads the XO smart contract and plays a tic-tac-toe game with
alpha, the xo list command on gamma will show only the gamma-alpha game. Even
though alpha and beta are using the same XO smart contract, their game moves
(smart contract transactions) remain private to their two-party circuit.
