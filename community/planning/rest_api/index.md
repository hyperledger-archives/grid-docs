# Proposed Future REST API Reference

<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->


This document is intended to capture proposed updates to the Grid REST API.
This document is a work-in-progress and proposed changes may or may not be
implemented as project requirements evolve.

* [Future REST API Reference](/community/planning/rest_api/api/)

## REST API resource details

### Changes

  - Added `POST` and `PUT` routes for various Grid resources. These endpoints
  will be used to submit batches to create and update resources. This takes the
  place of submitting everything through a `POST` to `/batches`, which accepts
  binary data, and will provide users with a more familiar REST API experience.
  - Updated resource schemas. The resource schemas for various Grid features
  have been updated to reflect their protobuf message counterparts and what a
  user can expect to see when fetching that resource. Some resources do not
  differ between their create and update messages and have not changed.
  - Removed Track and Trace endpoints. This feature will no longer be supported.

### For further consideration

  - Consider changing `/batch_statuses` to `/batch-statuses`. This would bring
  this endpoint in line with other endpoints in this API but consideration must
  be given to the impact this will have on the corresponding endpoints in
  Sawtooth and Splinter as well as backwards-compatibility concerns.

## REST API implementation details

The goal of the updated REST API is to provide a more natural way for users to
go about interacting with a distributed ledger. Grid’s future REST API will
have the ability to create batches using simple JSON payloads representing
Grid’s protobuf transactions. The REST API will also offer functionality to
create and sign transactions and batches, depending on the enabled features and
which component is being accessed.

This implementation uses Actix Web 3.0, further documentation can be found
here: https://actix.rs/.

### Griddle

Griddle has two primary functions, signing and proxying requests to the Grid
daemon. Griddle and gridd will communicate via REST API, so these components
are able to exist in separate security zones. Griddle will act as a signing
utility when submitting transactions. It is the only component, by default, to
require signing keys. Griddle will forward batches to the gridd `/batches`
endpoint, once the batch has been generated from the request payload and
signed. Any read requests will be immediately proxied to the corresponding
gridd endpoint. Griddle will pass back the response it receives from gridd to
the user.

### Request Payloads

The REST API resources will be represented as native Rust structs that are able
to be deserialized using Serde. More information on Serde can be found here:
https://serde.rs/. Specifically, the resources will use the `Deserialize` trait
Serde offers. An example of a resource representing a payload to create
a location is below:

```
#[derive(Deserialize)]
pub struct CreateLocation {
    pub location_id: String,
    pub location_namespace: NamespaceEnum,
    pub owner: String,
    pub properties: Vec<PropertyValue>,
    #[serde(default)]
    pub service_id: Option<String>,
    #[serde(default)]
    pub target: Option<String>,
}
```

The `service_id` and `target` fields are optional fields shared by all
transaction payload resources. The `service_id` field must be defined when
using a Splinter DLT backend as it indicates which service to send the batch to
when submitted. The `target` field must be defined when submitting a list of
transactions, for example when using the `/batches` endpoint. The `target`
refers to the endpoint resource the batch is structured after and determines
how the payload is deserialized. The rest of the values in the payload
resources are transaction-specific.

### Request Headers

When creating a new batch, users may want to set their own identifier for the
state changes. This ID may correspond to external systems or data that inform
the batch. An `event_id` may be set for a batch and can be used
interchangeably with the traditional batch ID. This value is set using an
`event_id` header in the initial request to create a batch. This identifier
must be unique as required by the backend service, whether the uniqueness must
be circuit- or network-wide.

### Payload submission

Batches submitted to either Griddle or the Grid daemon will be handled in
similar ways. The updated REST API will offer endpoints that will accept
incoming batches as either binary data or JSON, and singular or multiples of
batches. Specific contract actions will be reflected in the method and
endpoint. For example, an endpoint used to update a location will be
`PUT / locations/{location_id}`. An example of the Rust API for this endpoint
that accepts a JSON payload is below:

```
#[put("/locations/{location_id}")]
pub async fn put_location(
    payload: web::Json<UpdateLocationActionSlice>,
    batch_client: web::Data<BatchClient>,
    #[cfg(feature = “batch-signing”)]
    key_state: web::Data<KeyState>,
    query_service_id: web::Query<QueryServiceId>,
    query_location_id: web::Query<LocationId>,
    version: ProtocolVersion,
    _: AcceptServiceIdParam,
) -> HttpResponse;
```

Endpoints that accept binary data will substitute the `payload` type in this
function signature with `web::Payload`. This payload must then go through
several transformations to be accepted by the batch client. First, the action
that is submitted must be turned into a contract-specific payload. From there,
that payload can be wrapped in a transaction that will be included in the final
batch. The number of transactions in a batch will depend on the amount of
payloads that were submitted. The transaction and batch will be signed if the
request is submitted to Griddle, or when the experimental `batch-signing` gridd
feature is enabled. If the `batch-signing` feature is not enabled, the Grid
daemon will return a `400 Bad Request` response. The batch is then sent to the
`/batches` endpoint using a `BatchClient` for further processing.

An example of what the `BatchClient` trait may look like:

```
pub trait BatchClient: Send + Sync + ‘static {
	fn submit_batch(batch: Batch) -> Result<Batch, BatchClientError>;

	fn submit_batches(batch_list: BatchList) -> Result<BatchList, BatchClientError>;
}
```

### Submitting variable transactions

The added resources for contract-specific actions are limited in that they are
only able to accept transaction types of the same kind. However, the `/batches`
endpoint will be updated to accept a list of variable types of transactions.
Therefore, a user may submit a string of transactions to the `/batches`
endpoint to do all of the following actions:

1. Create an organization
2. Add a role to that organization
3. Assign the new role to the admin agent

All of these transactions will be submitted in a single batch. Currently, the
`/batches` endpoint accepts binary data representing a signed batch, which is
then submitted to the DLT backend. However, future Grid components will take
ownership over the submission of a batch and tracking it through its lifecycle
in the DLT. Therefore, the `/batches` endpoint will no longer directly submit a
batch to the backend.

This endpoint, instead, will need to store the signed batches in the database.
In order to correspond with the database, the `/batches` endpoint will require
access to the `BatchStore`. Regardless of the type data, i.e. bytes or JSON,
submitted to the `/batches` endpoint, the request body will be transformed into
a native representation of a `Batch` to be signed and added to the store.

An example Rust API that handles bytes submitted to the gridd `/batches`
endpoint is below:

```
#[post("/batches")]
pub async fn submit_batches(
    req: HttpRequest,
    mut body: web::Payload,
    store_state: web::Data<StoreState>,
    query_service_id: web::Query<QueryServiceId>,
    version: ProtocolVersion,
    _: AcceptServiceIdParam,
) -> HttpResponse;
```
