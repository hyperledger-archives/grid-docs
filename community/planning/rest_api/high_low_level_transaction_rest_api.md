# High-level and Low-level Transaction REST API
<!--
  Copyright 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The current Grid API has two facets: a high-level API for reading the results of
transactions (after being populated by state delta export), and a low-level API
for submitting the transactions and monitoring for the result.  This creates a
situation where developers using the API's are required to submit transactions
in a binary format.

This proposes a change to provide a set of high-level APIs for submitting the
data. The high-level API would be invoked by posting to a resource collection
(e.g. locations) using `application/json`. Likewise, batches would be submitted
in the same fashion.

When a client submits a transaction in this manner, the daemon will both sign
the transactions, and monitor the commit status.

The following sections will use the location and product endpoints as their
examples.

## Transaction Submission

Currently, there is an endpoint for locations, `/location`.  This should be
changed to `/locations`.  This endpoint returns a list of locations, or, if a
location ID is added (e.g. `/locations/{id}`), a single location is returned.

### High-level

The high level API for the `/locations` endpoint would accept POST requests that
would take the data in the form of JSON.  The server would process this input
with assembling the batch and the transaction, signing it, and, finally,
submitting it to the transaction service (sawtooth or scabbard).

In addition to accepting JSON to describe the transaction, the JSON will
represent the data directly.  That is, the user would not need to post the data
using the schema formats.

For example,

```
POST /locations
Content-Type: application/json+grid-simple
Body:
{
  "location_id": "1234",
  "owner": "owner_id",
  "address_line_1": "123 Main St.",
  "address_line_2": "Suite 100",
  // and so on
}
```

This would respond with `202: ACCEPTED` and include a JSON body with a batch ID
to use for checking on the item. For example,

```
{
   "batch_id": "123e4567e89b12d3a456426614174000",
}
```

The user would provide this batch ID to the `/batch_status` endpoint to check if
the location has been committed. If a user was to request the item before it was
committed, it would return a 404.

Once a location was committed, a standard GET to `/locations/1234` would return
the current JSON representation, for backwards compatibility, but if the header
`Accepts: application/json+grid-simple` was sent, the more natural JSON response
would be returned (close to the simple version submitted above - this may also
include additional information, like last update date-time and the like).

### Low-level

The low level version of this API would accept a single protobuf-encoded batch.
This batch and transaction would be signed by the client user, but the batch
would be signed by the server process, just as the high-level API.  It will be
validated specifically as a single location transaction in a batch.

For example:

```
POST /locations
Content-Type: application/octet-stream
Body:
<binary data>
```

This would also respond with `202: ACCEPTED` and include a JSON body with the
batch ID.

```
{
  "batch_id": "123e4567e89b12d3a456426614174000"
}
```

The client could use the batch ID with the existing low-level `/batch_status`
endpoint.

## Batch Submission

Both the high- and low-level APIs will use the existing `/batches`.

### High-level

The high level API would batch a set of transactions by accepting a list of
high-level transactions as they would be submitted individually. Each
transaction entry in the array would include the target endpoint if it was
submitted individually, the content type (in this case limited to the variants
of `"application/json"`), and the body.  The high-level content would be
consumed by simply passing `application/json`.

For example, a batch that creates a location and a product at that location:

```
POST /batches
Content-Type: application/json
Body:
[
  {
    "target": "/locations",
    "content_type": "application/json+grid-simple",
    "body": <JSON simple format Location>
  },
  {
    "target": "/products",
    "content_type": "application/json+grid-schema",
    "body": <JSON schema formatted Product>
  }
]
```

This would respond with `202: ACCEPTED` and include a JSON body with the
resulting batch ID. The tokens would be returned in the same order as the
original POST's body. For example

```
{
    "batch_id": "123e4567e89b12d3a456426614174000"
}
```


The batch ID could be used against the traditional `/batch_statuses` endpoint.

### Low-level

The low-level API would remain the same, taking a protobuf `BatchList` with
Batch messages signed by the client.  It would specify its content type as
`application/octet-stream`. The server process would not take responsibility for
monitoring the batch.
