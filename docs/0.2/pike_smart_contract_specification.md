# Pike Smart Contract Specification

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Pike is a smart contract designed to run with the
[Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre/)
smart contract engine.

Pike is designed to track the identities of the actors involved in the supply
chain. These actors are agents and the organizations they represent. The roles
that the agents play within said organizations are also tracked. This
information can be used to determine who is allowed to interact with a platform,
and to what extent they are allowed to interact with the platform.

This specification describes the available data objects, state addressing (how
transaction information is stored and addressed by *namespace*), and the valid
transactions: types, headers, payload format, and execution rules.

## State

### Agent

An agent is a cryptographic public key which has a relationship, defined by
roles, with an organization.  The list of roles can be used by transaction
processors for permissioning or in combination with Smart Permissions.

An agent has five fields:

* public_key: An agent’s cryptographic public key. Only one agent can belong to
  the public key.
* org_id: The identifier of the organization to which the agent belongs.
* active: Whether the agent is currently considered active at the organization.
* roles: A list of roles the agent has with the organization.
* metadata: A list of key value pairs describing organization specific data
  about the agent.

The public_key is the unique key for an Agent.

```protobuf
    message Agent {
        string org_id = 1;
        string public_key = 2;
        bool active = 3;
        repeated string roles = 4;
        repeated KeyValueEntry metadata = 5;
    }

    message KeyValueEntry {
      string key = 1;
      string value = 2;
    }
```

### Agent List

Agents whose addresses collide are stored in an agent list. An agent list
contains one field:

* agents: a list of agents

```protobuf
    message AgentList {
        repeated Agent agents = 1;
    }
```

### Organization

An organization has four fields:

* org_id: A unique identifier for the organization.
* name: A user defined identifier for the organization.
* locations: A list of physical addresses for the organization.
* alternate_ids: A list of alternate identifiers for the organization.
* metadata: A list of key value pairs describing data about the organization.

The id is the unique key for an Organization.

```protobuf
    message Organization {
        string org_id = 1;
        string name = 2;
        repeated string locations = 3;
        repeated AlternateID alternate_ids = 4;
        repeated KeyValueEntry metadata = 5;
    }
```

### Organization List

Organizations whose addresses collide are stored in an organization list. An
organization list contains one field:

* organizations: a list of organization


```protobuf

    message OrganizationList {
        repeated Organization organizations = 1;
    }
```

### Agent List

Agents whose addresses collide are stored in an agent list. An agent list
contains one field:

* agents: a list of agents

```protobuf
    message AgentList {
        repeated Agent agents = 1;
    }
```

### Role

An role has seven fields:

* org_id: A unique identifier for the organization the role belongs to.
* name: A user defined identifier for the role.
* description: A user defined description for the role.
* active: A field for determining if the role is currently active.
* permissions: A list of permissions that this role grants.
* allowed_organizations: A list of organizations allowed to inherit or grant
  this role.
* inherit_from: A list of roles that this role inherits permissions from.

The unique key for a Role is its name. Roles belonging to external
Organizations can be referenced by their owning `org_id` and `name` in
the format `<org_id>.<name>`.

```protobuf
    message Role {
        string org_id = 1;
        string name = 2;
        string description = 3;
        bool active = 4;
        repeated string permissions = 5;
        repeated string allowed_organizations = 6;
        repeated string inherit_from= 7;
    }
```

### Role List

Roles whose addresses collide are stored in a role list. A role list contains
one field:

* roles: a list of roles


```protobuf

    message RoleList {
        repeated Role roles = 1;
    }
```

### Alternate ID

An Alternate ID is any identifier given to an Organization that is not its
Grid org ID (the `org_id` field). For some smart contracts it is necessary to
record an additional ID to identify an organization in a certain context. For
example, in Grid Product, the organization must have the proper GS1 company
prefix in order to interact with products with correlating GTINs. An
Alternate ID has two fields:

* id_type: The type of ID. In the example above this would be
  `gs1_company_prefix`.
* id: The alternate ID

```protobuf
    message AlternateID {
        string id_type = 1;
        string id = 2;
    }
```

### Alternate ID Index Entry

The AlternateIDIndexEntry message serves as an index to fetch a Grid Pike
organization from an externally known ID, and also ensures that no organization
can have an alternate ID that is already assigned. An Alternate ID Index Entry
has three fields:

* id_type: The type of ID. In the example above this would be
  `gs1_company_prefix`.
* id: The alternate ID
* grid_identity_id: The identifier of the organization in Grid (the
  Organization's `org_id`)

```protobuf
    message AlternateIDIndexEntry {
        string id_type = 1;
        string id = 2;
        string grid_identity_id = 3;
    }
```

### Addressing

#### Pike State

The specifiv namespace for Pike with Grid is `621dee05`, which is the general
Grid namespace `621dee` concatenated with `05`.

#### Agent State

The specific namespace prefix within Pike for Agent State is `621dee0500`,
which is the general Pike namespace `621dee05` concatenated with `00`. The
remaining 60 characters are made of the first 60 characters of the hash of the
agent's public key.

#### Organization State

The specific namespace prefix within Pike for Organization State is
`621dee0501`, which is the general Pike namespace `621dee05` concatenated with
`01`. The remaining 60 characters are made of the first 60 character of the
hash of the organization's ID.

### Role State

The specific namespace prefix within Pike for Role State is `621dee0502`, which
is the general Pike namespace `621dee05` concatenated with `02`. The remaining
60 characters are made of the first 60 characters of the hash of the role's
`org_id` and `name` in the format `<org_id>.<name>`.

### Alternate ID State

The specific namespace prefix within Pike for Alternate ID State is
`621dee0503`, which is the general Pike namespace `621dee05` concatenated with
`03`. The remaining 60 characters are made of the first 60 characters of the
hash of the role's `id_type` and `id` in the format `<id_type>:<id>`.


## Transaction Payload

Pike payloads are defined by the following protocol
buffers code:

```protobuf
    message PikePayload {
        enum Action {
            ACTION_UNSET = 0;

            CREATE_AGENT = 1;
            UPDATE_AGENT = 2;
            DELETE_AGENT = 8;

            CREATE_ORGANIZATION = 3;
            UPDATE_ORGANIZATION = 4;
            DELETE_ORGANIZATION = 9;

            CREATE_ROLE = 5;
            UPDATE_ROLE = 6;
            DELETE_ROLE = 7;
        }

        Action action = 1;

        CreateAgentAction create_agent = 2;
        UpdateAgentAction update_agent = 3;
        DeleteAgentAction delete_agent = 4;

        CreateOrganizationAction create_organization = 5;
        UpdateOrganizationAction update_organization = 6;
        DeleteOrganizationAction delete_organization = 7;

        CreateRoleAction create_role = 8;
        UpdateRoleAction update_role = 9;
        DeleteRoleAction delete_role = 10;
    }
```

## Transaction Header

### Inputs and Outputs

The inputs for Pike transactions must include:

* The address of the agent, role, or organization being modified
* The address of the admin agent (agent correlating to the signing key)

The outputs for Pike transactions must include:

* The address of the agent, role, or organization being modified
* If creating an organization, the address of the agent that will be created as
  admin

### Dependencies

None

### Contract

- `name`: `"pike"`
- `version`: `"2"`

**Note**: The terms family, `family_name`, and `family_version` are a legacy
of the previous name for a smart contract, "transaction family".

## Execution

One of the following actions is performed while applying the transaction:

### CREATE_AGENT

This operation adds a new agent into Global State. Only another agent that
holds a role with the `pike::can-create-agent` permission for the included
organization may create an agent.

```protobuf
    message CreateAgentAction {
        string org_id = 1;
        string public_key = 2;
        bool active = 3;
        repeated string roles = 4;
        repeated KeyValueEntry metadata = 5;
    }
```

### UPDATE_AGENT

This operation updates the roles, metadata, and active status of an
existing agent stored in Global State. Only another agent that holds a
role with the `pike::can-update-agent` permission for the included organization
may update an agent. An agent cannot remove the admin role from themselves.

```protobuf
    message UpdateAgentAction {
        string org_id = 1;
        string public_key = 2;
        string active = 3;
        repeated string roles = 4;
        repeated KeyValueEntry metadata = 5;
    }
```

### DELETE_AGENT

This operation removes an Agent from Global state. Only another agent that
holds a role with the `pike::can-delete-agent` permission for the included
organization may delete an agent. An admin cannot remove themselves as admin.

```protobuf
    message DeleteAgentAction {
        string org_id = 1;
        string public_key = 2;
    }
```

### CREATE_ORGANIZATION

This operation adds a new organization to the Global State. The ID for each
organization must be unique and cannot be changed once the organization is
created. The public key used to sign the transaction will automatically be
added as an new agent with the admin role. An agent must hole a role with the
`pike::can-create-organization` permission to create an organization.

```protobuf
    message CreateOrganizationAction {
        string id = 1;
        string name = 2;
        repeated AlternateId alternate_ids = 3;
        repeated KeyValueEntry metadata = 4;
    }
```

### UPDATE_ORGANIZATION

This operation updates an existing organization stored in Global State. Only an
agent that holds a role with the `pike::can-update-organization` for the
included organization may update the organization. This operation can also be
used to add locations to the organization.

```protobuf
    message UpdateOrganizationAction {
        string id = 1;
        string name = 2;
        repeated string locations = 3;
        repeated AlternateId alternate_ids = 4;
        repeated KeyValueEntry metadata = 5;
    }
```

### DELETE_ORGANIZATION

This operation removes an organization from Global State. Only an agent that
holds a role with the `pike::can-delete-organization` permission for the
included organization may delete the organization.

```protobuf
    message DeleteOrganizationAction {
        string id = 1;
    }
```

### CREATE_ROLE

This operation adds a new role to the Global State. The name for each role must
be unique for the organization it belongs to. The `admin` role is automatically
created when an organization is created and is granted to the signer of the
`CREATE_ORGANIZATION` transaction. This role grants permissions to create,
update, and delete agents, organizations, and roles. The
`pike::can-create-role` permission is required to create roles.

```protobuf
    message CreateRoleAction {
        string org_id = 1;
        string name = 2;
        string description = 3;
        repeated string permissions = 4;
        repeated string allowed_organizations = 5;
        repeated string inherit_from = 6;
        bool active = 7;
    }
```

### UPDATE_ROLE

This operation updates a role in the Global State. The `pike::can-update-role`
permission is required to update roles.

```protobuf
    message UpdateRoleAction {
        string org_id = 1;
        string name = 2;
        string description = 3;
        repeated string permissions = 4;
        repeated string allowed_organizations = 5;
        repeated string inherit_from = 6;
        bool active = 7;
    }
```

### DELETE_ROLE

This operation removes a role from the Global State. The
`pike::can-delete-role` permission is required to delete roles.

```protobuf
    message DeleteRoleAction {
        string org_id = 1;
        string name = 2;
    }
```
