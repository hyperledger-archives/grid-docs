# Grid Product Catalog Specification

<!--
  Copyright (c) 2020 Cargill Incorporated
  Copyright (c) 2019 Target Brands, Inc.
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Grid Product Catalog is a smart contract designed to run with the
[Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre/)
smart contract engine.

Grid Product Catalog provides the ability to share an assortment of products
between organizations. Each product in a catalog will contain a number of master
data elements. Using Grid Product Catalog, organizations can share collections
of products with other participants in their network.

This specification describes the available data objects, state addressing (how
transaction information is stored and addressed by *namespace*), and the valid
transactions: types, headers, payload format, and execution rules.

## State

All Grid Product Catalog objects are serialized using protocol buffers
(protobufs) before being stored in state. These objects include Catalogs and
Products.

### Catalog

Catalogs are the primary entities stored in state for the Grid Product Catalog
smart contract. A Catalog object has the following fields:

* catalog_id: The unique identifier for a catalog.
* owner: The ID of the Pike organization that created the catalog.
* name: A human readable name for the catalog.
* properties: A list of property values (as defined in Grid Schema) which define
  additional data about the catalog. These property values are not backed by
  any schema or property definitions.

```protobuf
message Catalog {
    string catalog_id = 1;
    string owner = 2;
    string name = 3;
    repeated PropertyValue properties = 4;
}
```


### Catalog Product

A catalog product functions as a reference to a product, as defined by the Grid
Product smart contract. It also defines additional catalog-specific properties
for the referenced product.

Catalog products re-use the `Product` protobuf message from the Product smart
contract. It has the following fields:

* product_id: The unique ID for a product. For GS1 products, this is the GTIN.
  For catalog products, this ID should match the product_id of the referenced
  product.
* product_namespace: The namespace of the product for the purposes of checking
  the properties against the relevant schema. This should match that of the
  referenced product.
* owner: The ID of the Pike organization that created the catalog product.
* properties: A list of additional catalog product attributes, on top of the
  attributes defined by the product.

```protobuf
message Product {
  enum ProductNamespace {
      UNSET_TYPE = 0;
      GS1 = 1;
  }

  string product_id = 1;
  ProductNamespace product_namespace = 2;
  string owner = 3;
  repeated PropertyValue properties = 4;
}
```

#### Catalog Product Schema

The list of properties defined by a catalog product must conform to a catalog
product schema. The Grid Product Catalog smart contract makes several assertions
about this schema:

* The schema must define a required property with the name `catalog_id`. This
  property must be a string.
* The schema must define a required property with the name `status`. This
  property must be an enum with the options `ACTIVE`, `INACTIVE`, and
  `DISCONTINUED`, representing the status of the Product in the Catalog.
* The schema must be named "Catalog Product"

The schema is free to list any other property definitions required for catalog
products in this Grid network.

The Grid Product Catalog depends on the existence of this schema. Therefore, all
Grid Product Catalog transactions will be invalid under the following
circumstances:
* There is no schema in state with the name "Catalog Product"
* The schema with the name "Catalog Product" does not have the `catalog_id` or
  `status` property definitions.

An example "Product Catalog" schema definition is shown below:

```yaml
- name: "Catalog Product"
  description: "Schema defining a catalog product"
  owner: "123456"
  properties:
    - name: "catalog_id"
      data_type: STRING
      description: "The ID of the catalog that this catalog product belongs to"
      required: true
    - name: "status"
      data_type: ENUM
      description: "The current status of the catalog product"
      enum_options: ["ACTIVE", "INACTIVE", "DISCONTINUED"]
      required: true
    - name: "price"
      data_type: STRING
      description: "The price of the product"
      required: true
    - name: "return_policy"
      data_type: STRING
      description: "A description of the return policy for this product"
      required: false
```

Note that this schema is a valid product catalog schema because it has the name
"Catalog Product", and it has the "catalog_id" and "status" required properties
with the correct data types. This is all that is required for a minimal catalog
product schema definition.

This example also defines several additional requirements for catalog products:
"price" and "return policy". In this example Grid network, all catalog products
must include the price, since this property is required. They can optionally
include a description of the return policy, since this is listed as an optional
property in the schema.

## Addressing

In order to uniquely locate Grid Product Catalog state objects in the
Merkle-Radix state system, an address must be constructed which identifies the
storage location of the object.

All state address for Grid Product Catalog objects begin with the Grid
namespace: `621dee`. They are further prefixed with the reserved namespace
prefix for Grid Product Catalog: `03`.

After the namespace prefix, the next two characters of a Grid Product Catalog
object's address are a string based on the object's type:

* Catalog: `00`
* Catalog Product: `01`

The next 60 characters are determined by the object's type:

* Catalog: The first 44 characters of a SHA-512 hash of the catalog ID, followed
  with 16 hex-character zeroes to accommodate potential future storage
  associated with the GS1 Catalog representation.
* Catalog Product: The first 44 characters of a SHA-512 hash of the catalog ID
  that the product is associated with, followed by the 14 character GTIN of the
  product, followed by 2 hex-character zeroes to accommodate potential future
  storage associated with the catalog Product representation.


## Transactions

The following payload contains an action enum and the associated action
payload. This allows for the action payload to be dispatched to the appropriate
logic. Only the defined actions (enum) are available, and only one action
should be performed in a payload.

### CatalogPayload Transaction

```protobuf
message CatalogPayload {
    enum Actions {
        UNSET_ACTION = 0;
        CATALOG_CREATE = 1;
        CATALOG_UPDATE = 2;
        CATALOG_DELETE = 3;
        CATALOG_PRODUCT_CREATE = 100;
        CATALOG_PRODUCT_UPDATE = 101;
        CATALOG_PRODUCT_DELETE = 102;
        CATALOG_PRODUCT_SET_STATUS = 103;
    }

    Action action = 1;

    // Approximately when transaction was submitted, as a Unix UTC timestamp
    uint64 timestamp = 2;

    CatalogCreateAction catalog_create = 3;
    CatalogUpdateAction catalog_update = 4;
    CatalogDeleteAction catalog_delete = 5;
    CatalogProductCreateAction catalog_product_create = 100;
    CatalogProductUpdateAction catalog_product_update = 101;
    CatalogProductDeleteAction catalog_product_delete = 102;
    CatalogProductSetStatusAction set_catalog_product_status = 103;
}
```

### Catalog Actions

#### CatalogCreateAction

CatalogCreateAction adds a new catalog to state. The transaction should be
submitted by an agent, which is identified by its signing key, acting on behalf
of the organization that corresponds to the owner in the create transaction.
Organizations and agents are defined by the Pike smart contract.

```protobuf
message CatalogCreateAction {
    string owner = 1;
    string catalog_id = 2;
    string catalog_name = 3;
    repeated PropertyValues properties = 4;
}
```

Validation requirements:

- If a catalog with catalog_id already exists, the transaction is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The agent must have the permission can_create_catalog for the organization,
  otherwise the transaction is invalid.

The inputs for CatalogCreateAction must include:

- Address of the agent submitting the transaction
- Address of the organization the catalog is being created for
- Address of the catalog to be created

The outputs for CatalogCreateAction must include:
- Address of the catalog created

#### CatalogUpdateAction

CatalogUpdateAction updates an existing catalog in state. The transaction should
be submitted by an agent, which is identified by its signing key, acting on
behalf of the organization that corresponds to the owner in the update
transaction.

```protobuf
message CatalogUpdateAction {
    string owner = 1;
    string catalog_id = 2;
    string catalog_name = 3;
    repeated PropertyValues properties = 4;
}
```

Validation requirements:

- If a catalog with catalog_id does not exist, the transaction is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The agent must have the permission can_update_catalog for the organization,
  otherwise the transaction is invalid.

The inputs for CatalogUpdateAction must include:

- Address of the agent submitting the transaction
- Address of the organization the catalog is being created for
- Address of the catalog to be updated

The outputs for CatalogUpdateAction must include:

- Address of the catalog to be updated

#### CatalogDeleteAction

CatalogDeleteAction deletes an existing catalog from state. The transaction
should be submitted by an agent, which is identified by its signing key, acting
on behalf of the organization that corresponds to the owner in the delete
transaction. (Organizations and agents are defined by the Pike smart contract.)

```protobuf
message CatalogDeleteAction {
    string owner = 1;
    string catalog_id = 2;
}
```

Validation requirements:

- If a catalog with catalog_id exists the transaction is valid, otherwise it's
  invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The agent must have the permission can_delete_catalog for the organization,
  otherwise the transaction is invalid.

The inputs for CatalogDeleteAction must include:

- Address of the agent submitting the transaction
- Address of the organization the catalog is being created for
- Address of the catalog to be deleted

The outputs for CatalogDeleteAction must include:

- Address of the catalog to be deleted

**_NOTE: Deleting a catalog is potentially dangerous operation that could leave
dangling references and should be done with care._**

### Catalog Product Actions

#### CatalogProductCreateAction

The CatalogProductCreateAction adds a new catalog_product to state. The
catalog_product references a Grid Product for the shared item level master
data. The transaction should be submitted by an agent, which is identified by
its signing key, acting on behalf of the organization that corresponds to the
owner in the create transaction. (Organizations and agents are defined by the
Pike smart contract.)

```protobuf
message CatalogProductCreateAction {
    string catalog_id = 1
    string product_id = 2
    repeated PropertyValues properties = 3;
}
```

Validation requirements:

- If a catalog product with product ID and catalog ID already exists the
  transaction is invalid.
- If the Grid product the catalog product is referencing does not exist in
  state the transaction is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The agent must have the permission can_create_product for the organization,
  otherwise the transaction is invalid.
- If the product_namespace is GS1, the Pike organization must contain a GS1
  Company Prefix in its metadata (gs1_company_prefixes), and the prefix must
  match the company prefix in the product_id, which is a GTIN (if GS1),
  otherwise the transaction is invalid.
- The properties must be valid for the catalog product schema.

The inputs for CatalogProductCreateAction must include:

- Address of the agent submitting the transaction
- Address of the organization the Catalog Product is being created for
- Address of the catalog the catalog product is related too
- Address of the Grid Product the catalog product is referencing

The outputs for CatalogProductCreateAction must include:

- Address of the catalog Product to be created

#### CatalogProductUpdateAction

CatalogProductUpdateAction updates an existing product in state. The
transaction should be submitted by an agent, identified by its signing key,
acting on behalf of an organization that corresponds to the owner in the
product being updated.

```protobuf
message CatalogProductUpdateAction {
    string catalog_id = 1;
    string product_id = 2;
    repeated PropertyValues properties = 4;
}
```

Validation requirements:

- If a catalog product with catalog ID does not exist, the transaction
  is invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
  The owner in the product must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
- The agent must have the permission can_update_product for the organization,
  otherwise the transaction is invalid.
- The properties must be valid for the catalog_product schema.

The inputs for CatalogProductUpdateAction must include:

- Address of the agent submitting the transaction
- Address of the organization the Product is being updated for
- Address of the Product to be updated

The outputs for CatalogProductUpdateAction must include:

- Address of the updated catalog product

#### CatalogProductDeleteAction

CatalogProductDeleteAction removes an existing catalog product from state. The
transaction should be submitted by an agent, identified by its signing key,
acting on behalf of the organization that corresponds to the org_id in the
product being deleted.

```protobuf
message CatalogProductDeleteAction {
    string catalog_id = 1;
    string product_id = 2;
}
```

Validation requirements:

- If a catalog product with product ID does not exist, the transaction is
  invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The owner in the product must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
- The agent must have the permission “can_delete_product” for the organization
  otherwise the transaction is invalid.

The inputs for CatalogProductDeleteAction must include:

- Address of the agent submitting the transaction
- Address of the organization the Product is being deleted for
- Address of the catalog Product to be deleted

The outputs for CatalogProductDeleteAction must include:

- Address of the catalog Product to be deleted

#### CatalogProductSetStatusAction

CatalogProductSetStatusAction updates an existing catalog_product in state. The
transaction should be submitted by an agent, identified by its signing key,
acting on behalf of an organization that corresponds to the owner in the
product being updated.

The implementation of the catalogProductSetStatusAction will handle iterating
through the list of catalog_ids, and update the status of the
catalog_product(s) accordingly. Having the address of an individual
catalog_product be a composite key containing the catalog_id and product_id
enables us to easily update the status across one, all, or specific catalogs.

CatalogProductSetStatusAction does not set the status for multiple
catalog_products. It will only change the status of a single
catalog_product. The nuance being that this status change can be reflected in
as many, or as few catalogs an entity desires.

This flexibility is to enable support for use cases like:

- I am discontinuing a catalog_product for entity A, B, C, but not for retailer
  D.
- I want to discontinue catalog_products for all entity A, B, C, and D.
- I am marking a catalog_product as active for entity A and B, but not C or D
  just yet.
- I am making an active catalog_product inactive for entity A and B, but not C
  or D.

```protobuf
message CatalogProductSetStatusAction {
    enum Status {
        INACTIVE = 0;
        ACTIVE = 1;
        DISCONTINUED = 2;
    }
    // catalog_id and product_id are used in deriving the state address
    repeated string catalog_ids = 1;
    string catalog_product_id = 2;
    Status catalog_product_status  = 4;
    // Reason for the change
    string status_change_reason = 5;
}
```
Validation requirements:

- The catalog product's current status must not already be "DISCONTINUED", or
  the transaction is invalid.
- If no catalog product with the provided product ID exists, the transaction is
  invalid.
- The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
- The owner in the product must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
- The agent must have the permission can_update_product for the organization,
  otherwise the transaction is invalid.
- The properties must be valid for the catalog product schema; its properties
  must only contain properties that are included in the catalog product schema.

The inputs for CatalogProductSetStatusAction must include:

- Address of the agent submitting the transaction
- Address of the organization the catalog products are being updated for
- Address of the catalog products to be updated

The outputs for CatalogProductSetStatusAction must include:

- Address of the updated catalog products
