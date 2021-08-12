# Purchase Order Overview

This documentation provides a high level overview of the Purchase Order feature.
It will go into detail on the various components of a Purchase Order as
represented in Grid.

## Purchase Order

In the Grid Purchase Order system, a `PurchaseOrder` object is the top level
representation of a purchase order. Any time the trading partners want to
initialize a new order of a certain product, a new purchase order should be
created. This is likely to correspond with any action that creates a new
purchase order record in existing systems that integrate with Grid.

One of the key features of Grid Purchase Order is the ability for multiple
parties to iterate on a Purchase Order together. This means that each update to
a purchase order does not necessarily mean that a new purchase order should be
created, and may only necessitate a new version or revision.

### PurchaseOrder representation in Grid

Below is the protocol buffer representation of a purchase order in Grid. This is
the data structure that Grid uses to store information about a purchase order.
The following is an explanation of how the properties of this message map to
the general concepts of a purchase order.

```protobuf
message PurchaseOrder {
  required string org_id = 1;
  required string uuid = 2;
  required string workflow_status = 3;
  repeated PurchaseOrderVersion versions = 4;
  string accepted_version_number = 5;
  uint64 created_at = 6;
  bool is_closed = 7;
}
```

- `ord_id` is the ID of the organization that owns the purchase order. This is
  the "buyer" organization in the purchasing relationship.

- `uuid` is the unique identifier of the purchase order. This identifier is
  supplied by the client during transaction creation, to allow it to correspond
  to the ID in existing systems. If a purchase order needs to have multiple
  unique identifiers to support additional systems that are integrated with
  Grid, this can be handled via the alternate ID index.

- `workflow_status` is the current status of the purchase order as it moves
  through the workflow. The specific values for this status are defined by the
  workflow itself. The workflow will define what actions are possible to take on
  a purchase order with a certain workflow status.

- `versions` are a list of versions associated with the purchase order. They are
  described in detail in the next section.

- `accepted_version_number` is the ID of a version that has been accepted after
  the involved parties are done iterating on a purchase order.

- `created_at` acts as a timestamp of when the purchase order was created. Note
  that this value is filled out by the client, so it should not be treated as
  factual data. There will be a delay between when this value is filled out by
  the client and when the transaction is committed to the ledger. Also, there
  is no guarantee that the client filled this out correctly. Use with caution.

- `is_closed` indicates whether a purchase order is final or not. If a purchase
  order is closed, no further updates can happen to it.

## Purchase Order Alternate IDs

Grid Purchase Order supports the case where the ID of a purchase order in an
external system may not be known at the time of creation, or the case where a
purchase order may have more than one identifier. This is supported via the
alternate ID index. This index consists of entries that relate a Grid purchase
order UUID to another ID as defined by the user. For instance, a purchase order
could be defined with an arbitrary Grid-specific UUID, and later associated with
a GS1 purchase order ID.

### Alternate ID Index Entry representation in Grid

```protobuf
message PurchaseOrderAlternateId {
  string id_type = 1;
  string alternate_id = 2;
  string grid_id = 3;
}
```

- `id_type` is the identifier for what kind of ID this is. For instance, if you
  want to relate a GS1 purchase order ID to the Grid-specific ID, this string
  could be "GS1". The smart contract will need to have specific logic to handle
  each type.

- `id` is the alternate identifier.

- `grid_id` is the purchase order's UUID in Grid.

## Purchase Order Versions and Revisions

The `PurchaseOrderVersion` represents a particular version of a purchase order
as it is iterated upon. A `PurchaseOrderVersion` may have multiple
`PurchaseOrderRevision`s associated with it, with one being the current
revision. The `PurchaseOrderRevision` contains the business data for the
purchase order. Any update to the business data of a purchase order will result
in the creation of a new revision of a version.

The permissions around when and how new `PurchaseOrderVersion`s and
`PurchaseOrderRevision`s are created will depend on which purchase order
workflow is being used by the purchase order.

### PurchaseOrderVersion representation in Grid

```protobuf
message PurchaseOrderVersion {
  string version_id = 1;
  string workflow_status = 2;
  bool is_draft = 3;
  string current_revision_id = 4;
  PurchaseOrderRevision revisions = 5;
}
```

- `version_id` is the globally unique ID of a purchase order version.

- `workflow_status` is the status of the purchase order version within the
  workflow. The possible values of the status will depend on which workflow is
  in use.

- `is_draft` determines whether the purchase order version is still being
  iterated on. The workflow may determine what actions are possible to take on
  a purchase order based on this status.

- `current_revision_id` is the identifier of the most recent revision.

- `revisions` is a list of all of the revisions that have been created for a
  version.

### PurchaseOrderRevision representation in Grid

```protobuf
message PurchaseOrderRevision {
  string revision_id = 1;
  string submitter = 2;
  uint64 created_at = 3;

  string order_xml_v3_4 = 4;
}
```

- `revision_id` is the unique identifier for the revision.
- `submitter` is the public key of the agent who submitted this revision.
- `created_at` acts as a timestamp of when the revision was created. This has
  the same stipulations as the `created_at` property of `PurchaseOrder`, as
  described above.
- `order_xml_v3_4` holds a string consisting of the GS1 3.4 purchase order XML
  data. This is the core business data of the system. Note that this data is
  opaque to the purchase order smart contract. However, the Grid CLI parses and
  validates this data against the proper XSD. Other clients should be sure to
  do the same parsing and validation.
