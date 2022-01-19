# Upgrading to Grid v0.3.1 from Grid v0.2.3

<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Changes

- [Smart Contract Updates](#smart-contract-updates)

## Smart Contract Updates

Grid has a new smart contract, Purchase Order. This contract allows for the
creation and management of purchase orders between organizations. This contract
is new and must be added to the contract registry for the Grid network. The
[next section](#grid-purchase-order) has some recommendations for how to do
this. For more information about these specific changes, please see the
[Release Overview](/releases/0.3/index.md#grid-purchase-order).

To add the new smart contract after upgrading to Grid 0.3, please follow the
[Upgrading Smart Contracts for Administrators](/docs/0.3/upgrading_smart_contracts_for_administrators.md)
guide.

### Grid Purchase Order

Prior to upgrading to Grid 0.3, the following steps are recommended:

- If you wish to use the same keys for your agents after upgrading, save each
  key along with the roles that they are permitted to.
