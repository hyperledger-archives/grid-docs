# Upgrading to Grid v0.2.1 from Grid v0.1.2

<!--
  Copyright 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Changes

- [Smart Contract Updates](#smart-contract-updates)
- [System Keygen Command](#system-keygen-commands)

## Smart Contract Updates

Grid Pike has been incremented to version 2. This version made some fundamental
changes to Pike data models and changed the addressing scheme to fit the pattern
of the rest of the Grid smart contracts. Due to the fundamental nature of the
changes, Pike v2 does not support backwards compatibility and Pike org
structures will have to be recreated. The [next section](#grid-pike) has some
recommendations for how to do this. For more information about these specific
changes, please see the [Release Overview](/releases/0.2/index.md#grid-pike-v2).

Other smart contracts that interoperate with Grid Pike have also been
incremented to take advantage of the new Pike functionality. To upgrade your
smart contracts after upgrading to Grid 0.2, please follow the
[Upgrading Smart Contracts for Administrators](/docs/0.2/upgrading_smart_contracts_for_administrators.md)
guide.

### Grid Pike

Prior to upgrading to Grid 0.2, the following steps are recommended:
- If you wish to use the same keys for your agents after upgrading, save each
  key along with the roles that they are permitted to.
- Save the Pike organization ID of your organization.

After upgrading:
- Submit a Create Organization transaction to recreate your organization. When
  creating this transaction, consider the following:
  - The org ID should remain the same as it was previously.
  - There is no longer an address directly associated with the organization.
    Associating the organization with a location will be done after creating the
    organization.
  - Alternative IDs for organizations are now handled through the Alternate ID
    index instead of organization metadata. If you previously had a metadata
    field for a GS1 company prefix, for instance, you should create an alternate
    ID for that prefix instead. Please see the CLI reference for more info.
  - Make sure to submit the transaction to create your organization with the
    same key that previously had the `admin` role. This will automatically
    create an agent from that key with the Admin role for your organization. The
    Admin role includes all Pike permissions.
- Submit Create Role transactions to create roles.
  - Roles in Pike v1 (strings such as `can_create_product`) have been
    reformatted, and they are now considered to be "permissions"
    (`product::can-create-product`). Roles are now objects that comprise
    multiple permissions. You may want to leverage this functionality to create
    roles for your organization.
- Submit Create Agent transactions to recreate your agents.
  - If you saved your agent's keys you can recreate them using the same keys.
  - Instead of permission strings, you will assign roles to each agent.

### GDSN Support in Grid Product

Grid now supports GDSN 3.1 as the default product representation. If you wish to
continue using the previous default Grid schema or a custom schema, no action is
necessary. If you wish to use the GDSN 3.1 representation, you can update your
schema to include the `GDSN_3_1` string property.

## System Keygen Commands

`grid admin keygen` has been replaced with `grid keygen --system gridd`. This
was changed so the behavior is similar to its Splinter counterpart.
