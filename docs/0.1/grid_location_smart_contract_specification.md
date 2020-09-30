# Grid Location Smart Contract Specification

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Grid Location is a smart contract designed to run with the
[Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre/)
smart contract engine.

Grid Location is designed to supply Hyperledger Grid with a generic and extendable
framework for storing and managing location entities. Grid Location offers
explicit support for locations defined using
the [GS1 data standard](https://www.gs1.org/), but is also designed to be
flexible enough to support other standards.

Grid Location uses the Pike smart contract to manage location create, update,
and delete permissions, as well as the organizations that own each location,
and uses the Schema smart contract to describe the requirements for location
entities.

## State

All Grid Location objects are serialized using Protocol Buffers before being
stored in state. These objects include Location, LocationList, and
PropertyValue.

### Location

A location is an arbitrary list of properties that is uniquely identified by a
`location_id`. The `properties` are described by a schema that was previously
defined using the Schema smart contract. The schema that the location will be
checked against is dictated by the Location's `namespace` field.
Currently, only the `GS1` namespace has been defined.

A location has four fields

* location_id: A unique identifier for the location. For the GS1 namespace the
  location_id is a Global Location Number or [GLN](https://www.gs1.org/standards/id-keys/gln).
* namespace: The namespace that the location belongs to. A location's namespace
  dictates the rules for defining its `location_id` and the properties belonging
  to the location. Currently only the GS1 namespace is defined.
* owner: The Pike organization ID of the organization that owns the location.
* properties: An arbitrary list of properties that describe the location. These properties
  are defined by a schema defined by the Schema smart contract.

```protobuf
    message Location {
        enum LocationNamespace {
            UNSET_TYPE = 0;
            GS1 = 1;
        }
        // Global Location Number as defined by GS1 specification
        string location_id = 1;

        LocationNamespace namespace = 2;

        // Who owns this product (pike organization id)
        string owner = 3;

        // Addition attributes for custom configurations
        repeated PropertyValue properties = 4;
    }
```

### Location List

Locations whose addresses collide are stored in a location list. A location list
contains only one field.

```protobuf
    message LocationList {
        repeated Location entries = 1;
    }
```

### Addressing for GS1 locations

In order to uniquely locate GS1 locations in the Merkle-Radix state system, an
address must be constructed which identifies the storage location of the
Grid Location representation.

All Grid addresses are prefixed by the 6-hex-character namespace prefix “621dee”.
Locations are further prefixed under the Grid namespace with reserved
enumerations of “04” indicating Locations. (“01” = Schema, “02” = Product, and
“03” = Product Catalog.) An additional “01” indicates “GS1 Locations”.

Therefore, all addresses starting with “621dee” + “04” are Grid locations, and
more specifically, all addresses starting with “621dee” + “04” + “01” are Grid
GS1 Locations identified by a GLN.

The GLN format consists of a 13-digit “numeric string” that follows a similar
structure to GTIN-13. The GLN structure first includes a GS1 Company Prefix
which is 7-10 digits in length and is assigned by a GS1 Member Organization. A
location Reference number follows which is 2-5 digits in length and is
allocated by the company to a location or party. Lastly, a single digit Check
Digit is calculated and applied according to a GS1 algorithm. See
[GLN Data Format](https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSFo3J
5QULgkCWyIH3yeddRPx1H5aQusLRRq47y1n2FqTshGxs%3Ax-raw-image%3A%2F%2F%2Ff4fc819af
c288cee1948ca0d40d76c3bcd56a6d270fcfeeac80fd25784eb6071
&usqp=CAU "GLN Data Format").

After the 10-hex-characters that are consumed by the grid namespace prefix, the
location, and GS1 prefixes, there are 60 hex characters remaining in the address.
The 13 digits of the GLN can be left padded with 45-hex-character zeroes and
right padded with 2-hex-character zeroes to accommodate potential future storage
associated with the GS1 Location representation, for example:

    “621dee” + “04” + “01” + “000000000000000000000000000000000000000000000” +
    13-character “numeric string” location_id + “00” // location_id == GLN

A full GS1 Location address (for example purposes) would therefore be:

    “621dee0401000000000000000000000000000000000000000000000123456789012800”

## Transaction Payload

### Location Payload Transaction

`LocationPayload` contains an action enum and the associated action payload. This
allows for the action payload to be dispatched to the appropriate logic.

Only the defined actions are available and only one action payload should be
defined in the `LocationPayload`.

```protobuf
    message LocationPayload {
        enum Actions {
            UNSET_ACTION = 0;
            LOCATION_CREATE = 1;
            LOCATION_UPDATE = 2;
            LOCATION_DELETE = 3;
        }

        Action action = 1;

        // Approximately when transaction was submitted, as a Unix UTC timestamp
        uint64 timestamp = 2;

        LocationCreateAction location_create = 3;
        LocationUpdateAction location_update = 4;
        LocationDeleteAction location_delete = 5;
    }

    message LocationCreateAction {
        Location.LocationNamespace location_namespace = 1;
        string location_id = 2;
        string owner = 3;
        repeated PropertyValue properties = 4;
    }

    message LocationUpdateAction {
        // Not modified. Only  used to find location object in state
        Location.LocationNamespace location_namespace = 1;
        // Not modified. Only  used to find location object in state
        string location_id = 2;
        // This will replace all properties currently defined
        repeated PropertyValue properties = 3;
    }

    message LocationDeleteAction {
        // Not modified. Only  used to find location object in state
        Location.LocationNamespace location_namespace = 1;
        // Not modified. Only  used to find location object in state
        string location_id = 2;
    }
```

### Location Create Action

`LocationCreateAction` adds a new location to state. The transaction should be
submitted by an agent, which is identified by its signing key, acting on behalf
of the organization that corresponds to the owner in the create transaction.
(Organizations and agents are defined by the Pike smart contract.)

Validation requirements:

- If a location with `location_id` already exists the transaction is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The owner in the location must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
- The agent must have the permission `can_create_location` for the organization,
  otherwise the transaction is invalid.
- If the location namespace is `GS1`, the organization must contain a GS1 Company
  Prefix in its metadata (`gs1_company_prefixes`), and the prefix must match the
  company prefix in the `location_id`, which is a GLN if GS1, otherwise the
  transaction is invalid.
- The properties must be valid for the location namespace. For example, if the
  location is GS1 location, its properties must only contain properties that are
  included in the GS1 Schema. If it includes a property not in the GS1 Schema the
  transaction is invalid.

If all requirements are met, the transaction will be accepted and the location
will be created in state.

### Location Update Action

`LocationUpdateAction` updates an existing location in state. The transaction
should be submitted by an agent, identified by its signing key, acting on behalf
of an organization that corresponds to the owner in the location being updated.
(Organizations and agents are defined by the Pike smart contract.)

Validation requirements:
- If a location with `location_id` does not exist the transaction is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The owner in the location must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
- The agent must have the permission `can_update_location` for the organization,
  otherwise the transaction is invalid.
- The new properties must be valid for the location namespace. For example, if
  the location is a GS1 location, its properties must only contain properties that
  are included in the GS1 Schema. If it includes a property not in the GS1 Schema
  the transaction is invalid.

The properties in the location will be swapped for the new properties and the
updated location will be set in state.

### Location Delete Action

`LocationDeleteAction` removes an existing location from state. The transaction
should be submitted by an agent, identified by its signing key, acting on behalf
of the organization that corresponds to the owner in the location being updated.
(Organizations and agents are defined by the Pike smart contract.)

Validation requirements:
- If a location with `location_id` does not exist the transaction is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The owner in the location must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
- The agent must have the permission `can_delete_location` for the organization
  otherwise the transaction is invalid.

### Inputs and Outputs

#### Location Create Action

The inputs for `LocationCreateAction` must include:
- Grid address of the Agent submitting the transaction
- Grid address of the Organization the Location is being created for
- Grid address of the Location Namespace Schema the location’s properties must 
match
- Grid address of the Location to be created

The outputs for `LocationCreateAction` must include:
- Grid address of the Location created

#### Location Update Action

The inputs for `LocationUpdateAction` must include:
- Grid address of the Agent submitting the transaction
- Grid address of the Organization the Location is being updated for
- Grid address of the Location Namespace Schema the location’s properties must
match
- Grid address of the Location to be updated

The outputs for `LocationUpdateAction` must include:
- Grid address of the Location updated

#### Location Delete Action

The inputs for `LocationDeleteAction` must include:
- Grid address of the Agent submitting the transaction
- Grid address of the Organization the Location is being deleted for Grid 
address of the Location to be deleted

The outputs for `LocationDeleteAction` must include:
- Grid address of the Location to be deleted

### Dependencies

The Location smart contract requires the Pike smart contract for permission
and organization management, and the Schema smart contract
for defining location schemas.

### Family

- family_name: "grid_location"
- family_version: "1.0"
