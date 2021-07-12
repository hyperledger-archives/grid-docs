# Upgrading Smart Contracts

<!--
  Copyright (c) 2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This tutorial covers how to upgrade a smart contract. This procedure will focus
on updating a smart contract for Grid on Splinter run using the Docker compose
file located in `grid/examples/splinter`.

## Prerequisites

* Grid running on Splinter using the example Docker compose file

* Access to the scabbard command line tool

* An updated smart contract. Instructions for incrementing the protocol version
  for a contract can be found in the [Upgrading Smart Contracts for Developers](/docs/0.2/upgrading_smart_contracts_for_developers.md)
  section.

## Procedure

### Rebuild the Smart Contract

This procedure will likely be done by an administrator for the Splinter circuit
or network. These steps include rebuilding or compiling the upgraded contract
and then deploying it.

1. Rebuild the contract builder container (in this case, for the Pike smart
   contract) and the Grid daemon containers.

   ```
   $ docker-compose -f examples/splinter/docker-compose.yaml build \
        --no-cache pike-contract-builder gridd-alpha gridd-beta gridd-gamma
   ```

1. Restart those containers:

   ```
   $ docker-compose -f examples/splinter/docker-compose.yaml up \
        --detach pike-contract-builder gridd-alpha gridd-beta gridd-gamma
   ```

## Important Note

If not running using the example Docker compose files you will need to package
the smart contract. A procedure for this can be found in the
[Uploading smart contracts](/docs/0.2/uploading_smart_contracts.md) section.
This will then need to be uploaded via Scabbard.

### Add the contract to your circuit

{:start="3"}

3. Start a bash session in your node’s `scabbard-cli`
Docker container (such as `scabbard-cli-alpha`).  You will use this container
to run the `scabbard` commands to upload and configure the smart contract.

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

1. Upload the updated contract:

   ```
   $ scabbard contract upload grid-pike:0.2.2 \
        --path ./usr/share/scar \
        -k gridd \
        -U 'http://splinterd-alpha:8085' \
        --service-id $SERVICE_ID
   ```

   You can verify that the contract was added successfully using the command:

   ```
   $ scabbard contract list \
        -U 'http://splinterd-alpha:8085' \
        --service-id $SERVICE_ID
   ```

1. If the address prefix for the contract changes in your update, create a new
   namespace:

   ```
   $ scabbard ns create <prefix> \
        --owner <alpha_node_public_key> \
        --key <path_to_alpha_node_private_key> \
        --url http://splinterd-alpha:8080 \
        --service-id $CIRCUIT_ID::scabbard-service-alpha
    ```

1. Update the permissions for the namespace:

    ```
    $ scabbard perm <prefix> my_contract --read --write \
        --key <path_to_alpha_node_private_key> \
        --url http://splinterd-alpha:8080 \
        --service-id $CIRCUIT_ID::scabbard-service-alpha
    ```
