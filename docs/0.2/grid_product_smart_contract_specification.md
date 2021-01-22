# Grid Product Smart Contract Specification

<!--
  Copyright (c) 2018-2020 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Grid Product is a smart contact designed to run with the
[Sawtooth Sabre](https://github.com/hyperledger/sawtooth-sabre/)
smart contract engine.

Grid Product is designed to supply Hyperledger Grid with a generic and
extendable framework for storing product master data. A product in this case, is
any  item that is transacted, traded or referenced in a supply chain. Grid
Product offers explicit support for products defined using the
[GS1](https://www.gs1.org), but is also designed to be flexible enough to
support other standards.

Grid Product uses the Pike smart contract to manage permissions for creating,
updating, and deleting products, as well as for managing the organizations
that own each product, and uses the Schema smart contract to describe the
requirements for the product entities.

## State

All Grid Product object are serialized using Protocol Buffers before being
stored in state. These objects include Product, `ProductList`, and
`PropertyValue`.

### Product

A product is an arbitrary list of properties that is uniquely identified by a
`product_id`. The `properties` are described by a schema that was previously
defined using the Schema smart contract. The schema that the product will be
checked against is dictated by the product's `product_namespace` field.
Currently, only the `GS1` namespace has been defined.

A product has four fields

* product_id: A unique identifier for the product. For the GS1 namespace the
  product_id is a GS1 GTIN.
* product_namespace: The namespace that the product belongs to. A product's
  namespace dictates the rules for defining its `product_id` and the
  properties belonging to the product. Currently only the GS1 namespace is
  defined.
* owner: The Pike organization ID of the organization that owns the product.
* properties: An arbitrary list of properties that describes the product. These
  properties are defined by a schema defined by the Schema smart contract.

```protobuf
    message Product {
        enum ProductNamespace {
            UNSET_NAMESPACE = 0;
            GS1 = 1;
        }

        ProductNamespace product_namespace = 1;
        string product_id = 2;
        string owner = 3;
        repeated PropertyValue properties = 4;
    }
```

### Product List

Products whose addresses collide are stored in a product list. A product list
contains only one field.

```protobuf
    message ProductList {
      repeated Product entries = 1;
    }
```

### Addressing for GS1 products

In order to uniquely locate GS1 products in the Merkle-Radix state system, an
address must be constructed which identifies the storage location of the Product
representation.

All Grid addresses are prefixed by the 6-hex-character namespace prefix
“621dee”,  Products are further prefixed under the Grid namespace with reserved
enumerations of “02” (“00” and “01” being reserved for other purposes)
indicating “Products” and an additional “01” indicating “GS1 Products”.

Therefore, all addresses starting with the following string are Grid products:

```
“621dee” + “02” + “01”
 ```

Grid GS1 Products are identified by a GTIN and are expected to contain a Product
representation which conforms with the GS1 product schema.

GTIN formats consist of 14-digit “numeric strings” which include some amount of
internal “0” padding depending on the specific GTIN format (GTIN-8, GTIN-12,
GTIN-13, or GTIN-14).  After the 10-hex-characters that are consumed by the grid
namespace prefix, the product, and GS1 prefixes, there are 60 hex characters
remaining in the address.  The 14 digits of the GTIN can be left padded with
44-hex-character zeroes and right padded with 2-hex-character zeroes to
accommodate potential future storage associated with the GS1 Product
representation, for example:

```
“621dee” + “02” + “01” +“00000000000000000000000000000000000000000000” +
14-character “numeric string” product_id + “00” // product_id == GTIN
```

A full GS1 Product address using the example GTIN from https://www.gtin.info/
would therefore be:

```
“621dee0201000000000000000000000000000000000000000000000001234560001200”
```

## Transaction Payload

### Product Payload Transaction

`ProductPayload` contains an action enum and the associated action payload. This
allows for the action payload to be dispatched to the appropriate logic.

Only the defined actions are available and only one action payload should be
defined in the `ProductPayload`.

```protobuf
    message ProductPayload {
        enum Actions {
            UNSET_ACTION = 0;
            PRODUCT_CREATE = 1;
            PRODUCT_UPDATE = 2;
            PRODUCT_DELETE = 3;
        }

        Action action = 1;

        // Approximately when transaction was submitted, as a Unix UTC timestamp
        uint64 timestamp = 2;

        ProductCreateAction product_create = 3;
        ProductUpdateAction product_update = 4;
        ProductDeleteAction product_delete = 5;
    }

    message ProductCreateAction {
        enum Product_Namespace {
            UNSET_NAMESPACE = 0;
            GS1 = 1;
        }
        // product_namespace and product_id are used in deriving the state address
        Product_Namespace product_namespace = 1;
        string product_id = 2;
        string owner = 3;
        repeated PropertyValues properties = 4;
    }

    message ProductUpdateAction {
        enum Product_Namespace {
            UNSET_NAMESPACE = 0;
            GS1 = 1;
        }
        // product_namespace and product_id are used in deriving the state address
        Product_Namespace product_namespace = 1;
        string product_id = 2;
        // this will replace all properties currently defined
        repeated PropertyValues properties = 4;
    }

    message ProductDeleteAction {
        enum Product_Namespace {
            UNSET_NAMESPACE = 0;
            GS1 = 1;
        }
        // product_namespace and product_id are used in deriving the state address
        Product_Namespace product_namespace = 1;
        string product_id = 2;
    }
```

### Product Create Action

`ProductCreateAction` adds a new product to state. The transaction should be
submitted by an agent, which is identified by its signing key, acting on behalf
of the organization that corresponds to the owner in the create transaction.
(Organizations and agents are defined by the Pike smart contract.)

Validation requirements:

* If a product with `product_id` already exists the transaction is invalid.
* The signer of the transaction must be an agent in the Pike state and must
belong to an organization in Pike state, otherwise the transaction is invalid.
* The agent must have the permission `can_create_product` for the organization,
  otherwise the transaction is invalid.
* If the `product_namespace` is GS1, the organization must contain a GS1 Company
  Prefix in its metadata (`gs1_company_prefixes`), and the prefix must match the
  company prefix in the `product_id`, which is a GTIN if GS1, otherwise the
  transaction is invalid.
* The properties must be valid for the `product_namespace`. For example, if the
  product is GS1 product, its properties must only contain properties that are
  included in the GS1 Schema. If it includes a property not in the GS1 Schema
  the transaction is invalid.

If all requirements are met, the transaction will be accepted, the batch will 
be written to a block, and the product will be created in state.

### Product Update Action

`ProductUpdateAction` updates an existing product in state. The transaction
should be submitted by an agent, identified by its signing key, acting on
behalf of an organization that corresponds to the owner in the product being
updated. (Organizations and agents are defined by the Pike smart contract.)

Validation requirements:

* If a product with `product_id` does not exist the transaction is invalid.
* The signer of the transaction must be an agent in the Pike state and must
  belong to an organization in Pike state, otherwise the transaction is invalid.
* The owner in the product must match the organization that the agent belongs
  to, otherwise the transaction is invalid.
* The agent must have the permission `can_update_product` for the organization,
  otherwise the transaction is invalid.
* The new properties must be valid for the `product_namespace`. For example, if
  the product is GS1 product, its properties must only contain properties that
  are included in the GS1 Schema. If it includes a property not in the GS1
  Scheme the transaction is invalid.

The properties in the product will be swapped for the new properties and the
updated product will be set in state.

### Product Delete Action

`ProductDeleteAction` removes an existing product from state. The transaction
should be submitted by an agent, identified by its signing key, acting on behalf
of the organization that corresponds to the `org_id` in the product being updated.
(Organizations and agents are defined by the Pike smart contract.)

Validation requirements:

* If a product with `product_id` does not exist the transaction is invalid.
* The signer of the transaction must be an agent in the Pike state and must
belong to an organization in Pike state, otherwise the transaction is invalid.
* The owner in the product must match the organization that the agent belongs to,
  otherwise the transaction is invalid.
* The agent must have the permission `can_delete_product` for the organization
  otherwise the transaction is invalid.

### Inputs and Outputs

#### Product Create Action

The inputs for `ProductCreateAction` must include:

* Address of the Agent submitting the transaction
* Address of the Organization the Product is being created for
* Address of the Product Namespace Schema the product’s properties must match
* Address of the Product to be created

The outputs for `ProductCreateAction` must include:

* Address of the Product created

#### Product Update Action

The inputs for `ProductUpdateAction` must include:

* Address of the Agent submitting the transaction 
* Address of the Organization the Product is being updated for
* Address of the Product Namespace Schema the product’s properties must match
* Address of the Product to be updated

The outputs for `ProductUpdateAction` must include:

* Address of the Product updated

#### Product Delete Action

The inputs for `ProductDeleteAction` must include:

* Address of the Agent submitting the transaction
* Address of the Organization the Product is being deleted for
* Address of the Product to be deleted

The outputs for `ProductDeleteAction` must include:

* Address of the Product to be deleted
