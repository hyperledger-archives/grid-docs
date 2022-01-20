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

Purchase Order enables trade partners to collaboratively create and modify
purchase orders, providing a shared view of the order state for all partners.
It offers a common, industry-wide solution for sharing purchase order
information between partners, implemented using Grid's systems of record.

Grid Purchase Order leverages Grid Identity, Grid Workflow, Grid Product and
Grid Location to store purchase order data.

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
* Workflow state
* Buyer organization identifier
* Seller organization identifier
* List of all versions of this purchase order
* Unique identifier of an accepted version of this purchase order
* Alternate identifiers for this purchase order
* Timestamp from when the purchase order was created
* Indicator if the purchase order has been closed
* Workflow name

The `PurchaseOrder` protocol buffer is defined as follows:

```protobuf
  message PurchaseOrder {
    // The unique identifier of the purchase order
    string uid = 1;
    // The current workflow state of the purchase order
    string workflow_state = 2;
    // The organization ID of the "buyer" in the purchase order
    string buyer_org_id = 3;
    // The organization ID of the "seller" in the purchase order
    string seller_org_id = 4;
    // List of all versions of the purchase order
    repeated PurchaseOrderVersion versions = 5;
    // Unique identifier of an accepted purchase order version
    string accepted_version_number = 6;
    // List of alternate IDs for the purchase order
    repeated PurchaseOrderAlternateId alternate_ids = 7;
    // Timestamp of when the purchase order is created
    uint64 created_at = 8;
    // Whether or not the purchase order is in a "closed" state
    bool is_closed = 9;
    // The name of the workflow the purchase order is being processed through
    string workflow_id = 10;
  }
```

### PurchaseOrderVersion

A version of a purchase order is represented by a `PurchaseOrderVersion`.
The `PurchaseOrderVersion` moves through the version workflow if `is_draft` is
false and through the draft workflow if `is_draft` is true. `workflow_state`
indicates the version or draft workflow state the version is in and is independent
of the overall purchase order's workflow state in the `PurchaseOrder` object.

A `PurchaseOrderVersion` has the following attributes:

* Unique identifier of the version
* Workflow state of purchase order version sub-workflow
* Indicator if the purchase order version is a draft
* Identifier of this version's most current revision
* List of all revisions of this purchase order version

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrderVersion {
    // The identifier of the purchase order version
    string version_id = 1;
    // The current workflow state of the purchase order version
    string workflow_state = 2;
    // True if the version is a draft, false otherwise
    bool is_draft = 3;
    // Identifier of the most recent revision made
    uint64 current_revision_id = 4;
    // List of all revisions made to this version
    repeated PurchaseOrderRevision revisions = 5;
  }
```

### PurchaseOrderRevision

A `PurchaseOrderRevision` holds the editable fields of a purchase
order, the time the revision was created, and the public key of the
submitter.

A `PurchaseOrderRevision` has the following attributes:

* Unique identifier of the revision
* Public key of the agent that submitted the revision
* Timestamp from when the revision was created
* An XML payload containing the editable fields of the purchase order

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrderRevision {
    // The identifier of the purchase order revision
    uint64 revision_id = 1;
    // Public key of the agent that submitted the revision
    string submitter = 2;
    // Timestamp when the revision was created
    uint64 created_at = 3;
    // Editable fields of the purchase order
    string order_xml_v3_4 = 4;
  }
```

### PurchaseOrderAlternateId

Similar to the mechanism outlined in the
[Pike 2 RFC](https://github.com/hyperledger/grid-rfcs/pull/23), the purchase
order smart contract implements alternate IDs to enable the creation of
purchase orders without having to specify a purchase order number.

In this object, `id_type` is the name of the field used as an alternate ID,
`id` holds the value of the unique alternate ID, and `org_id` refers to the
owning organization.

The protocol buffer is defined as follows:

```protobuf
  message PurchaseOrderAlternateId {
      // Name of the field used as an alternate ID
      string id_type = 1;
      // Unique alternate identifier of the purchase order
      string id = 2;
      // Unique identifier of the associated purchase order
      string po_uid = 3;
  }
```

## Addressing for Purchase Order

In order to locate Purchase Orders in the Merkle-Radix state system,
an address is constructed that identifies the storage location of the
Purchase Order representation.

All Grid addresses are prefixed by the 6-hex-character namespace prefix
“621dee”. `PurchaseOrder` and `PurchaseOrderAlternateId` are further prefixed
under the Grid namespace with reserved enumeration of 06. Therefore, all
addresses starting with “621dee” + “06” are Grid purchase orders.

The remaining 62 characters of a `PurchaseOrder` address are determined by
taking the first 60 characters of a SHA512 hash of its uid and concatenating it
with the prefix 00.

```
  "612dee" + "06" + "00" + Sha512(uid)[:60]
```
Therefore, a purchase order with an ID hash of
“78901234567890123456789012345678901234567890123456789012345” would have an
address of:

```
  "612dee060078901234567890123456789012345678901234567890123456789012345"
```

## Transaction Payload and Execution

### PurchaseOrderPayload Transaction

`PurchaseOrderPayload` contains an `enum` of actions and associated
payloads. This allows for the action payload to be dispatched to the appropriate
logic. Only the defined actions are available and only one action payload
should be defined in the `PurchaseOrderPayload`. `PurchaseOrderPayload`
contains the following required fields:

* `action` - Action enum, indicating the payload type
* `timestamp` - Time the payload was created

```protobuf
message PurchaseOrderPayload {
  enum Action {
    UNSET_ACTION = 0;
    CREATE_PO = 1;
    UPDATE_PO = 2;
    CREATE_VERSION = 3;
    UPDATE_VERSION = 4;
  }
  Action action = 1;
  uint64 timestamp = 2;

  CreatePurchaseOrderPayload create_po_payload = 3;
  UpdatePurchaseOrderPayload update_po_payload = 4;
  CreateVersionPayload create_version_payload = 5;
  UpdateVersionPayload update_version_payload = 6;
}

message CreatePurchaseOrderPayload {
  string uid = 1;
  uint64 created_at = 2;
  string buyer_org_id = 3;
  string seller_org_id = 4;
  string workflow_state = 5;
  repeated PurchaseOrderAlternateId alternate_ids = 6;
  CreateVersionPayload create_version_payload = 7;
  string workflow_id = 8;
}

message UpdatePurchaseOrderPayload {
  string po_uid = 1;
  string workflow_state = 2;
  bool is_closed = 3;
  string accepted_version_number = 4;
  repeated PurchaseOrderAlternateId alternate_ids = 5;
  repeated UpdateVersionPayload version_updates = 6;
}

message CreateVersionPayload {
  string version_id = 1;
  string po_uid = 2;
  bool is_draft = 3;
  string workflow_state = 4;
  PayloadRevision revision = 5;
}

message UpdateVersionPayload {
  string version_id = 1;
  string po_uid = 2;
  string workflow_state = 3;
  bool is_draft = 4;
  PayloadRevision revision = 5;
}

message PayloadRevision {
  uint64 revision_id = 1;
  string submitter = 2;
  uint64 created_at = 3;

  string order_xml_v3_4 = 4;
}
```

### Create Purchase Order Payload

`CreatePurchaseOrderPayload` adds a new purchase order to the blockchain state.
An optional `PurchaseOrderVersion` can be included in the payload, representing
the initial version of the purchase order.

Validation Requirements:

* The signer must be a Pike agent
* The signing agent must have a workflow role with the `can-create-po`
  permission
* The `uid` must not refer to an existing purchase order
* The `buyer_org_id` must exist in Pike for it be a valid transaction
* The `seller_org_id` must exist in Pike for it be a valid transaction
* The `create_version_payload`, if included, must be valid according to the
  `CreateVersionPayload` validation rules

### Update Purchase Order Payload

`UpdatePurchaseOrderPayload` updates a purchase order's `closed` state,
`workflow_state`, or `accepted_version_number`.

Validation Requirements:

* The signer must be a Pike agent
* The signing agent must have a workflow role with the `can-update-po`
  permission
* The `po_uid` must refer to an existing purchase order

### Create Version Payload

`CreateVersionPayload` creates a new `PurchaseOrderVersion`.

Validation Requirements:
* The signer must be a Pike agent
* The signing agent must have a workflow role with the `can-create-po-version`
  permission
* The `po_uid` must refer to an existing purchase order

### Update Version Payload

`UpdateVersionPayload` updates an existing `PurchaseOrderVersion` with a new
revision.

Validation Requirements:

* The signer must be a Pike agent
* The signing agent must have a workflow role with the `can-update-po-version`
  permission
* The `po_uid` must refer to an existing purchase order

## Dependencies

The Purchase Order smart contract requires:
* the Pike smart contract for permission and organization management
* the Workflow smart contract for workflow management
* the Product and Location smart contracts for defining location and products

## Family

* family_name: “grid_purchase_order”
* family_version: “1”
