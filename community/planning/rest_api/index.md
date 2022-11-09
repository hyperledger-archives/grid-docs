# Proposed Future REST API Reference

<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This document is intended to capture proposed updates to the Grid REST API.
This document is a work-in-progress and proposed changes may or may not be
implemented as project requirements evolve.

## Planned functionality

Mainly, the REST API will be updated to support more robust batch handling.
The proposed functionality will accept transactions in JSON, the request body,
while arguments for the batch can be submitted in the request headers. Arguments
for a batch may include a service ID, if Grid is running with Splinter, or a
user-created identifier for the batch submitted. More specific headers pertaining
to batch arguments may be added. The array of JSON arguments will be converted
into the appropriate transactions and signed. As Grid will support batch
tracking, the REST API will not directly submit batches. Instead, once a batch
has been signed and built, it will be stored in Grid's database. Other
components will handle the batch for the rest of its lifecycle and the database
entry will reflect updates.

The REST API is provided by two components, gridd and griddle. Griddle is a
client component that will act as both a proxy and signing utility. Grid may
also perform transaction and batch signing, if configured at run-time. Griddle
will communicate with gridd over REST API and may be run from a separate
security domain. Access to the internet is not required by Griddle, which allows
it to handle sensitive data, such as private key files, without worry this data
may become compromised. As griddle does not have access to gridd's database, it
will also proxy batches it creates to gridd's `/batches` endpoint to be stored
in the database. Database support may be added to griddle in the future.

All smart contract actions that may be performed in Grid will be represented by
`POST` endpoints. An example of a request for the `POST /organizations` endpoint
is below:

```
POST /locations
Content-Type: application/json+grid-simple
Headers:
  data_change_id: <User-defined batch ID>
  // Batch arguments
Body:
[
  {
    "namespace": "GS1",
    "location_id": "1234",
    "properties": [
      "..."
    ],
  },
]
```

This JSON is converted by the endpoint into it's respective transaction type,
the action of this example would be `CreateLocation`. There may be multiple
transactions in the JSON body. Endpoints receiving these requests must account
for the list of transactions when deserializing the request body. More complex
batches may include transactions with different action types. The `/batches`
endpoint allows for this situation. An example request to this endpoint follows:

```
POST /batches
Content-Type: application/json
Headers:
  data_change_id: <User-defined batch ID>
  // Batch arguments
Body:
[
  {
    "target": "POST /locations"
    "namespace": "GS1",
    "location_id": "1234",
    "properties": [
      "..."
    ],
  },
  {
    "target": "PUT /locations"
    "namespace": "GS1",
    "location_id": "5678",
    "properties": [
      "..."
    ],
  },
]
```

This request will create a batch containing two transactions, one for creating
a location and one for updating another location. The endpoint handling this
request will deserialize the request body into transactions, depending on
value of the `target` field. If the endpoint is unable to recognize the targeted
transaction, it will return `400 Bad Request`. A signer object is passed to
each endpoint and is required to build the batch. If the endpoint does not have
access to a signer, it will return `400 Bad Request`.

Once a batch has been built from the request body and signed, it can be stored
in gridd's database. As endpoints may be provided by both gridd and griddle,
the signed batch should be handled by an implementation-specific object.
Endpoints have access to a trait object, `BatchSubmissionHandler`, which
submits the batch once it is signed. This trait implements a `submit_batches`
method, which takes in pertinent batch information to store. If an endpoint is
provided by griddle, the submission handler is required to send the batch
to gridd to be stored. An endpoint provided by gridd is able to directly store
the batch.

If a batch is submitted successfully, the endpoint will respond with
status code `202 Accepted` and a JSON body of the identifiers for the batch
stored. An example response body to a request that included a Splinter service
ID and a user-defined ID.

```
{
  [
    {
      "dlt_batch_id": <Batch header signature>,
      "data_change_id": <User-defined ID>,
      "service_id": <Splinter service ID>,
    },
  ]
}
```

If Grid is not running with Splinter services, the `service_id` field will not
be returned. Similarly, if no `data_change_id` was submitted in the original
request, it will also not be returned.

If a batch is not submitted successfully, the endpoint will respond with a
status code to describe the error and a JSON body with any additional data. For
example, an error is returned at the point griddle attempts to send a batch
to gridd, a `SendError` with a message describing what went wrong. The griddle
endpoint may return a `402 Bad Gateway` if it is unable to connect to gridd.

All previous design documents for the REST API are linked in the following
section.

## Proposed functionality

- Accept JSON Batches. The Grid REST API will be updated to support
  batches encoded in bytes or JSON, providing a more natural
  experience for users. An initial design document for the future
  REST API, [High-level and Low-level Transaction REST API]({%
  link community/planning/rest_api/high_low_level_transaction_rest_api.md %}),
  explains that Grid will support both byte-encoded and JSON-encoded
  batches. JSON-encoded batches will be signed and encoded by the
  Grid daemon, as needed before submission.

- Proxy. Griddle is a client component that runs separately from the Grid daemon,
  communicating with Grid via REST API. Griddle is able to proxy requests to Grid
  and will create and sign batches submitted as JSON. The initial design
  document, [Griddle Proxy]({%
  link community/planning/rest_api/griddle_proxy.md %}), explains this
  functionality more thoroughly.

- Backwards compatibility. Especially as the API changes greatly, setting
  forth a plan for handling backwards compatibility will smooth the process
  for both developers and users. See [Rest API Backwards
  Compatibility]({% link community/planning/rest_api/backwards_compatibility.md %})
  for more details.

## Proposed API

* [Future REST API Reference](/community/planning/rest_api/api/)

- Added `POST` and `PUT` routes for various Grid resources. These endpoints
  will be used to submit batches to create and update resources. This takes the
  place of submitting everything through a `POST` to `/batches` and will
  provide users with a more familiar REST API experience.
- Updated resource schemas. The resource schemas for various Grid features
  have been updated to reflect their protobuf message counterparts and what a
  user can expect to see when fetching that resource. Some resources do not
  differ between their create and update messages and have not changed.
- Removed Track and Trace endpoints. This feature will no longer be supported.

## Proposed for further consideration

  - Change `/batch_statuses` to `/batch-statuses`. This would bring
  this endpoint in line with other endpoints in this API but consideration must
  be given to the impact this will have on the corresponding endpoints in
  Sawtooth and Splinter as well as backwards-compatibility concerns.
