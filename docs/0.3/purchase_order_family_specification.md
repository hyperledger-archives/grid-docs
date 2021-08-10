# Purchase Order Smart Contract Specification

<!--
  Copyright (c) 2019-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Purchase Order is a smart contract designed to run with the
[Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre/)
smart contract engine.

Purchase Order provides a mechanism for trade partners to collaborate on the
creation and modification of a purchase order, while also offering a shared
view of the state of the order for all partners.

Grid Purchase Order leverages Grid Identity, Grid Workflow, Grid Product and
Grid Location to store data related to a purchase order. Purchase Order
provides a common industry solution for sharing purchase order information
between trade partners, while using Grid’s existing systems of record to
support this implementation.

## State

All Purchase Order state objects are serialized using protocol buffers
(protobufs) before being stored in state. These objects include PurchaseOrder,
PurchaseOrderVersion, PurchaseOrderRevision, and PurchaseOrderAlternateId.

### PurchaseOrder

Purchase orders are represented in state using the `PurchaseOrder` protocol
buffer. This object holds information about the current state of the Purchase
Order.

The state attributes of a purchase order include:

* Unique identifier
* Workflow Status
* Indicator if the purchase order has been closed
* Unique identifier of an accepted version of this purchase order
* List of all versions of this purchase order
* Timestamp from when the purchase order was created

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrder {
      // The unique identifier of the purchase order
      required string uuid = 1;
      // The workflow status of the purchase order
      required string workflow_status = 2;
      // List of all versions of the purchase order
      repeated PurchaseOrderVersion versions = 3;
      // Unique identifier of an accepted purchase order version
      string accepted_version_number = 4;
      // Time the purchase order was created.
      uint64 created_at = 5;
      // True if the purchase order was closed, false otherwise
      bool is_closed = 6;
  }
```

### PurchaseOrderVersion

A new version of a purchase order is represented by a `PurchaseOrderVersion`.
The `PurchaseOrderVersion` is moved through a workflow, depending on its status
as a draft or not. A `PurchaseOrderVersion` is defined with the following
attributes:

* Unique identifier of the version
* Workflow status
* Indicator if the purchase order version is a draft, or not
* Identifier for the most current revision of this version
* List of all revisions of this purchase order version

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrderVersion {
      // The unique identifier of the purchase order version
      string version_id = 1;
      // The workflow status of the purchase order version
      string workflow_status = 2;
      // True if the version is a draft, false otherwise
      bool is_draft = 3;
      // Unique identifier of the most recent revision made
      string current_revision_id = 4;
      // List of all revisions made to this version
      repeated PurchaseOrderRevision revisions = 5;
  }
```

### PurchaseOrderRevision

A `PurchaseOrderRevision` represents all of the editable fields of a purchase
order. This struct also contains information about the creation of the
revision. A `PurchaseOrderRevision` is defined with the following attributes:

* Unique identifier of the revision
* Public key of the agent that submitted the revision
* Timestamp from when the revision was created
* An XML file containing the editable fields of the purchase order

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrderRevision {
      // The unique identifier of the purchase order revision
      string revision_id = 1;
      // Public key of the agent that submitted the revision
      string submitter = 2;
      // Timestamp when the revision was created
      uint64 created_at = 3;
      // Editable fields of the purchase order
      string order_xml_v3_4 = 4;
  }
```

### PurchaseOrderAlternateId

Similar to the mechanism outlined in the Pike 2 RFC, the purchase order smart
contract will implement alternate IDs to allow purchase orders to be created
without having to specify a purchase order number at creation. This struct
contains an `id_type` which refers to the field used as an alternate ID, an
`id` which holds the unique identifier of the purchase order and the unique
identifier, `org_id`, of the owning organization.

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrderAlternateId {
      // Specify the field used as an alternate ID
      string id_type = 1;
      // Unique identifier of the purchase order
      string id = 2;
      // Unique identifier of the owning organization
      string org_id = 3;
  }
```

## Addressing for Purchase Order

In order to uniquely locate Purchase Orders in the Merkle-Radix state system,
an address must be constructed which identifies the storage location of the
Purchase Order representation.

All Grid addresses are prefixed by the 6-hex-character namespace prefix
“621dee”. `PurchaseOrder` and `PurchaseOrderAlternateId` are further prefixed
under the Grid namespace with reserved enumeration of 06. Therefore, all
addresses starting with “621dee” + “06” are Grid purchase orders.

The remaining 62 characters of a `PurchaseOrder` address is calculated by
taking the first 60 characters of a SHA512 hash of its uid and concatenating it
with the prefix 00.

```
  “612dee” + “06” + “00” + Sha512(uid)[:60]
```
Therefore, a purchase order with an ID hash of
“78901234567890123456789012345678901234567890123456789012345” would have an
address of:

```
  “612dee060078901234567890123456789012345678901234567890123456789012345”
```

## Transaction Payload and Execution

### PurchaseOrderPayload Transaction

`PurchaseOrderPayload` contains an action `enum` and the associated action
payload. This allows for the action payload to be dispatched to the appropriate
logic. Only the defined actions are available and only one action payload
should be defined in the `PurchaseOrderPayload`. `PurchaseOrderPayload`
contains the following required fields:

* `action` - Action enum, indicating the payload type
* `org_id` - The Pike organization that is sending the payload
* `public_key` - The public key of a Pike agent that is sending the payload
* `timestamp` - Time the payload was created

```protobuf
message PurchaseOrderPayload {
  enum Action {
    UNSET_ACTION = 0;
    CREATE_PO = 1;
    CREATE_VERSION = 2;
    UPDATE_VERSION = 3;
  }

  Action action = 1;
  string org_id = 2;
  string public_key = 3;
  // Approximately when the transaction was submitted, as a Unix UTC timestamp
  uint64 timestamp = 4;

  CreatePurchaseOrderPayload create_po_payload = 5;
  UpdatePurchaseOrderPayload update_po_payload = 6;
  CreateVersionPayload create_version_payload = 7;
  UpdateVersionPayload update_version_payload = 8;
}

message CreatePurchaseOrderPayload {
  string uuid = 1;
  uint64 created_at = 2;
}

message UpdatePurchaseOrderPayload {
  string workflow_status = 1;
  bool is_closed = 2;
  string accepted_version_number = 3;
}

message CreateVersionPayload {
  string version_id = 1;
  bool is_draft = 2;
  PayloadRevision revision = 3;
}

message UpdateVersionPayload {
  string version_id = 1;
  string workflow_status = 2;
  bool is_draft = 3;
  string current_revision_id = 4;
  PayloadRevision revision = 5;
}

message PayloadRevision {
  string revision_id = 1;
  string submitter = 2;
  uint64 created_at = 3;

  string order_xml_v3_4 = 4;
}
```

### Create Purchase Order Payload

`CreatePurchaseOrderPayload` adds a new purchase order to state. An optional
`PurchaseOrderVersion` can be included in the payload representing the initial
version of the purchase order.

Validation Requirements:

* The `org_id` must exist in Pike for it to be a valid transaction.
* The `public_key` must belong to a Pike agent that is a part of the
  organization designated by `org_id`, otherwise the transaction is invalid.
* The Pike agent must have the permission `can-create-po`, otherwise the
  transaction is invalid.
* All fields marked required in the `CreatePurchaseOrderPayload` must be
  supplied or the transaction is considered invalid.

### Update Purchase Order Payload

`UpdatePurchaseOrderPayload` updates a purchase order's closed status,
`workflow_status`, or `accepted_version_number`.

Validation Requirements:

* The `org_id` must exist in Pike for it to be a valid transaction.
* The `public_key` must belong to a Pike agent that is a part of the
  organization designated by `org_id`, otherwise the transaction is considered
  invalid.
* The Pike agent must have the permission `can-update-po`, otherwise the
  transaction is considered invalid.

### Create Version Payload

`CreateVersionPayload` creates a new `PurchaseOrderVersion`.

Validation Requirements:
* The `org_id` must exist in Pike for it be a valid transaction
* The `public_key` must belong to a Pike agent that is a part of the
  organization designated by `org_id`
* The Pike agent must have the permission `can-create-po-version`
* All fields marked required in the `CreateVersionPayload` must be supplied

### Update Version Payload

`UpdateVersionPayload` updates an existing `PurchaseOrderVersion` with a new
revision.

Validation Requirements:

* The `org_id` must exist in Pike for it be a valid transaction
* The `public_key` must belong to a Pike agent that is a part of the
  organization designated by `org_id`
* All fields marked required in the `UpdateVersionPayload` must be supplied

## Dependencies

The Purchase Order smart contract requires the Pike smart contract for
permission and organization management, the Workflow smart contract for
workflow management, and the Product and Location smart contracts for defining
location and products.

## Family

* family_name: “grid_purchase_order”
* family_version: “1”
