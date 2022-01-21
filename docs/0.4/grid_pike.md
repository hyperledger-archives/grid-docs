# Grid Pike

<!--
  Copyright 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Grid Pike v2 is a role-based access control system for managing permissions
within Grid and specifically within smart contracts. Agents, which are
identified by their cryptographic public keys, are provided with permissions to
act on behalf of organizations. Grid Pike v2 is an evolution of the Pike v1
identity system used in Grid and Sawtooth.

With Grid Pike, Organizations can create agents and assign them roles that
allow them to transact with smart contracts using Grid.

* Organization administrators can assign roles to agents allowing, fine-grained
  control over who can transact using a specific smart contract and to what
  extent.

* Organizations can delegate specific roles to other organizations to fulfill.

Grid Pike provides an easy way to manage permissions in Grid. The Grid Pike
smart contract provides an easy way to create, update, and delete
organizations, agents, and roles. This provides users with an easy way to
manage who is transacting on their organization's behalf.

To see how permissioning and role delegation works within Pike v2, please see
the example here: [Delegation Example](/docs/0.4/using_pike.md#delegation-example)
