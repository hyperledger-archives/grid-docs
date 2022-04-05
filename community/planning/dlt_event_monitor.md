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

And it modifies with the following:

 - `update_batch_statuses` - Updates the batch statuses in DB. In the future
   this may also perform other actions based on the status, such as a webhook
   request.

## Strategy

The DLT event monitor connects to the `subscribe_stream` via websocket. When a
known transaction id is received, we correlate that transaction id to the known
associated batch id, and `update_batch_statuses` as they are committed.

### Known limitations

This solution does not provide a method to determine whether a transaction has
failed in real time. The `subscribe_stream` will only send events that are
successful. Error events will need to come in via the [DLT Polling
Monitor](dlt_polling_monitor.md).

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
