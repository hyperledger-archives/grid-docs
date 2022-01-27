# Upgrading Smart Contracts

<!--
  Copyright (c) 2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This tutorial covers how to upgrade a smart contract. This procedure will focus
on updating a smart contract for Grid on Splinter run using the Docker compose
file located in `grid/examples/splinter`.

There are two sets of tasks associated with upgrading a smart contract. The
first set will likely be done by a developer working on the smart contract
itself and will be covered in this section. The second set will likely be done
by an administrator to actually deploy the smart contract. This document can be
found in the [Upgrading Smart Contracts for Administrators](/docs/0.4/upgrading_smart_contracts_for_administrators.md)
section.

## Procedure

### Update the Smart Contract

This set of steps will likely be done by a developer working on the smart
contract code. These steps increment the protocol version of the smart contract
alongside functional changes and get the smart contract ready for deployment.

1. Update the `manifest.yaml` and `<contract_name>.yaml` files for the smart
   contract with updated inputs, outputs, and increment the protocol version
   number.

1. Increment the family version constants for the Smart Contract in the
   following files:

     * `grid/cli/src/transaction.rs`

     * `grid/contracts/<contract_name>/src/handler.rs`
