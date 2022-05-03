# DLT Event Monitor
<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

The **DLT Event Monitor** is a utility that updates pending batches in Grid
with the latest information from the DLT. It does this by subscribing to the
DLT’s subscription endpoint.

This is useful for two primary purposes:

 - Tracking whether the batch submitter needs to resubmit a batch
 - Allowing someone who submits a batch to be notified of the current batch
   status

## Input / Output Definition

The DLT polling monitor uses the following inputs:

 - `subscribe_stream` - Normalized stream sourced from Splinter or Sawtooth
 - `rate_limit` - Maximum rate at which polls can occur, as a Duration

And it modifies with the following:

 - `poll_batch_statuses` - Make a request to get the latest batch statuses.
   This will likely be handled through the [DLT Polling
   Monitor](dlt_polling_monitor.md).

## Strategy

The DLT event monitor connects to the `subscribe_stream` via websocket. When a
transaction is received, we can be reasonably certain that a batch has
completed. We then notify the DLT Polling monitor via `poll_batch_statuses`.
The DLT polling monitor then has the opportunity to immediately poll. Events
are rate limited at the `rate_limit`.

### Known limitations

This solution does not provide a method to determine whether a specific
transaction has occurred or failed in real time. The `subscribe_stream` will
only send events that are successful, and not send any accompanying batch
information. This info will need to come in via the [DLT Polling
Monitor](dlt_polling_monitor.md).

Ideally the DLT streams for Sawtooth and Splinter would be expanded to a more
generalized stream that includes not only raw ledger updates, but batch
execution information.

## Current websocket status format

### Scabbard

**Stream URL:** `/scabbard/{circuit_id}/{service_id}/ws/subscribe`.

**Definition:** [Scabbard State Delta
Events](https://www.splinter.dev/docs/0.7/howto/state_delta_websockets.html)

**Example:**

```json
{
  "id": "f62b978a8836013b6ceaac8331a7f720ddd837de7333ae14ab0f4adad445118574735afeeea1f98a51254d8750f1769fc18d6c638963af7f66c5b5086545fba1",
  "state_changes": [
    {
      "Set": {
        "key": "00ec00ebfd680ea8abffc272049e01409cda9efec943f4ddca0263897e715913a04705",
        "value": [
          10,
          117,
          10,
          8
	    ]
      }
    }
  ]
}
```

### Sawtooth

**Stream URL:** `/ws/subscribe`

**Definition:** [Sawtooth State Delta
Events](https://sawtooth.hyperledger.org/docs/1.2/rest_api/state_delta_websockets.html)

**Example:**
```json
{
  "block_num": 8,
  "block_id": "ab7cbc7a...",
  "previous_block_id": "d4b46c1c...",
  "state_changes": [
    {
      "type": "SET",
      "value": "oWZQdmxqcmsZU4w",
      "address": "1cf126613a..."
    }
  ]
}
```
