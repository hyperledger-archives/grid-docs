# Uploading Smart Contracts for Grid on Splinter

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This procedure summarizes how to use the `scabbard` command-line interface to
package a compiled smart contract with a manifest, create a contract registry,
upload the smart contract to a Splinter circuit, and configure the contract
registry and namespace.

The examples in this procedure use the `sawtooth_xo` smart contract, which
allows users to play a distributed game of tic-tac-toe, storing player data and
game moves in shared state. For information about writing and compiling new
smart contracts, see the [Sabre
documentation](https://sawtooth.hyperledger.org/docs/sabre/releases/latest/application_developer_guide.html).

## Prerequisites

* Two or more working Grid nodes. (See [Running Grid on
  Splinter](grid_on_splinter.md) for the procedure to set up and run Grid
  in Docker containers.) This procedure assumes that there are two nodes,
  `alpha-node-000` and `beta-node-000`, running in a Docker environment.

* An approved Splinter circuit with two or more member nodes.
  (See [Creating Splinter Circuits]({% link
  docs/0.2/creating_splinter_circuits.md %}) for more information.)
  This procedure assumes that there is a circuit with `alpha-node-000` and
  `beta-node-000` as members.

* A fully qualified service ID for the scabbard service on this circuit, in
  the format <code><i>CircuitID</i>::<i>ServiceString</i></code>.
  (See [Determine the Service ID]({% link docs/0.2/creating_splinter_circuits.md
  %}#determine-the-service-id) for the commands to display this
  information.) This procedure uses the example ID `01234-ABCDE::gsAA`.

* The endpoint for the Splinter (`splinterd`) REST API. This example uses
  `http://splinterd-alpha:8085`.

* The public/private key pair for the smart contract owner. This example assumes
  that Grid daemon (`gridd`) will be the smart contract owner and will sign
  transactions with a private key in `/root/.splinter/keys/gridd.priv`.

* A smart contract that has been compiled to WASM (as described in the
  [Sabre Application Developer's
  Guide](https://sawtooth.hyperledger.org/docs/sabre/releases/latest/application_developer_guide.html).
  This example uses the `sawtooth_xo` smart contract that is already packaged
  in a smart contract archive (scar) file.

## Important Notes

The examples in this procedure use the node hostnames, container names, node
IDs, and URLs that are defined in the example docker-compose file,
`examples/splinter/docker-compose.yaml`. If you are not using this example
environment, replace these items with the actual values for your nodes.

## Procedure

### Package the Smart Contract

The examples in this procedure uses a pre-packaged smart contract,
`sawtooth_xo`, which is available at
[files.splinter.dev/scar/xo_0.4.2.scar](https://files.splinter.dev/scar/xo_0.4.2.scar).

To use a different smart contract, follow these steps to package the
smart contract.

1. Create a `manifest.yaml` file that specifies the smart contract name,
   version, and the inputs and outputs (the addresses in state that the smart
   contract will read from and write to).

   The example smart contract has a manifest with the following contents:

    ``` yaml
    name: sawtooth_xo
    version: '1.0'
    inputs:
      - '5b7349'
    outputs:
      - '5b7349'
    ```

1. Package the smart contract WASM file and the manifest in a smart contract
   archive (a tar file with the `.scar` extension).

    ``` console
    $ tar -jcvf mycontract_0.1.0.scar mycontract.wasm manifest.yaml
    ```

    **IMPORTANT**: The name of the scar file must use the format
    <code><i>name</i>_<i>version</i></code>, where <i>version</i> is a valid
    semantic versioning version number (see [semver.org](https://semver.org/)),
    such as `mycontract_0.1.0` in this example. This name corresponds to the
    contract argument used with the `scabbard contract upload` command in a
    later step.

### Connect to the scabbard-cli Container

{:start="3"}

3. Start a bash session in your node’s `scabbard-cli` Docker container (such as
   `scabbard-cli-alpha`).  You will use this container to run the `scabbard`
   commands to upload and configure the smart contract.

   ```
   $ docker exec -it scabbard-cli-alpha bash
   root@scabbard-cli-alpha:/#
   ```

1. To simplify entering the `scabbard` commands in this procedure, set
   `SERVICE_ID` to the fully qualified service ID for the scabbard service on
   this circuit (such as `01234-ABCDE::gsAA`).

   ```
   root@scabbard-cli-alpha:/# export SERVICE_ID=01234-ABCDE::gsAA
   ```

### Download the Smart Contract Package

{:start="5"}

5. Download the scar file (such as `xo_0.4.2.scar`) to the `scabbard-cli`
   container.

   ```
   root@scabbard-cli-alpha:/# curl -OLsS https://files.splinter.dev/scar/xo_0.4.2.scar
   ```

### Create a Contract Registry

Each smart contract requires a contract registry that specifies the contract's
name and owner. You must create a contract registry before you can upload the
smart contract to the circuit.

{:start="6"}

6. Create a contract registry for the new smart contract.

   This example creates a smart contract registry for `sawtooth_xo`, with the
   Grid daemon as the owner (the `gridd` public key is used as the owner ID).
   The Grid daemon's private key is used to sign this transaction.

   ```
   root@scabbard-cli-alpha:/# scabbard cr create sawtooth_xo \
   --owners $(cat /root/.splinter/keys/gridd.pub) \
   -k gridd \
   -U 'http://splinterd-alpha:8085' \
   --service-id $SERVICE_ID
   ```

### Upload the Smart Contract

{:start="7"}

7. Upload the smart contract to the Splinter circuit by specifying the smart
   contract name and version (such as `xo:0.4.2`) and the path to the scar file.

   ```
   root@scabbard-cli-alpha:/# scabbard contract upload xo:0.4.2 \
   --path . \
   -k gridd \
   -U 'http://splinterd-alpha:8085' \
   --service-id $SERVICE_ID
   ```

   **IMPORTANT**: The smart contract name and version must match the scar file
   name (with `:` instead of `_`). You can use a `*` character in place
   of a specific version number; see the [scabbard-contract-upload(1) man
   page](https://www.splinter.dev/docs/0.4/references/cli/scabbard-contract-upload.1.html)
   for more information.

### Create a Namespace Registry

{:start="8"}

8. Create the namespace registry for the smart contract.

   This example creates a new namespace with the `5b7349` address prefix and
   `gridd` as the owner.

   ```
   root@scabbard-cli-alpha:/# scabbard ns create 5b7349 \
   --owners $(cat /root/.splinter/keys/gridd.pub) \
   -k gridd \
   -U 'http://splinterd-alpha:8085' \
   --service-id $SERVICE_ID
   ```

1. Grant the appropriate contract namespace permissions.

   This example lets the `sawtooth_xo` smart contract read from and write to
   the namespace with the state address prefix `5b7349`.

   ```
   root@scabbard-cli-alpha:/# scabbard perm 5b7349 sawtooth_xo --read --write \
   -k gridd \
   -U 'http://splinterd-alpha:8085' \
   --service-id $SERVICE_ID
   ```

### Display Smart Contract Information

Use `scabbard contract list` and `scabbard contract show`
to verify that the smart contract has been uploaded to the circuit.

Tip: You can run these commands on the first node, or connect to another node's
`scabbard-cli` container (such as `scabbard-cli-beta`) and set the
`$SERVICE_ID` variable for that node (such as `01234-ABCDE::gsBB`).

1. List all uploaded smart contracts.

   ```
   root@scabbard-cli-beta:/# scabbard contract list \
   -U 'http://splinterd-beta:8085' \
   --service-id $SERVICE_ID
   ```

   The output shows each smart contract's name, version, and owners, as in this
   example:

   ```
   NAME        VERSIONS OWNERS
   .
   .
   .
   pike         0.1      {gridd-alpha_public_key}
   sawtooth_xo  1.0      {gridd-alpha_public_key}
   .
   .
   .
   ```

1. Display the details of the new smart contract (such as `sawtooth_xo`).

   ```
   root@scabbard-cli-beta:/# scabbard contract show sawtooth_xo:1.0 \
   -U 'http://splinterd-beta:8085' \
   --service-id $SERVICE_ID
   ```

   The output shows the smart contract name and version, plus the
   inputs, outputs, and creator's public key (the person or entity that
   signed the transaction to upload the smart contract).

   ```
   sawtooth_xo 1.0
     inputs:
     - 5b7349
     outputs:
     - 5b7349
     creator: {gridd-alpha_public_key}
   ```
