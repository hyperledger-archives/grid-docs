---
mermaid: true
---
# DLT Polling Monitor
<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

The **DLT Polling Monitor** is a utility that updates pending batches in Grid
with the latest information from the DLT. It does this by polling the database
and the `/batch_statuses` endpoint.

## Input / Output Definition

The DLT polling monitor uses the following inputs:

- `poll_interval` (duration) - This is read from the
  environment, but has a default value. We will want
  to change the poll interval based on whether the DLT
  Polling Monitor is the primary or a fallback means
  of status synchronization.
- `dlt_connection_pool` (usize) - The number of open connections to make to
  the `/batch_statuses` endpoint
- `pending_batches` - Sourced from DB
  - Returns an array of batch IDs and service IDs
- `/batch_statuses` [(doc)](/docs/0.4/references/api/) - Sourced from
  Splinter or Sawtooth

And it modifies with the following:

- `update_batch_statuses` - Updates the batch statuses in DB, grouped by
  service ID

## Polling and Queuing Strategy

The DLT Polling monitor has a queue of pending batches that Grid has submitted,
but the status is unknown. This queue is maintained in the Grid DB.

If there are any items remaining in the queue, the DLT Polling Monitor will
keep attempting to fetch the status from the DLT until there are no items
remaining in the queue.

If there are no items, the DLT Polling Monitor will wait for the given
`poll_interval` until some become available.

Removal of items from the queue is planned for another process, based on time
in queue or the number of failed attempts.

The DLT Polling Monitor will work through the queue in the following manner:

1. By the last retry date, ascending
2. In the order they were submitted

## Status Synchronization Process

![]({% link community/images/DLTPollProcess.svg %} "DLT Poll Process")

1. Requests all `pending_batches` from the database
2. Groups pending batch IDs by the service ID.
3. For each service ID, the monitor runs the following asynchronous logic:
   1. Fetches from the `/batch_statuses` endpoint
   2. Validates the list received from `/batch_statuses` against the sent IDs
   3. Discards if responses with an “Unknown” status. In Sawtooth an Unknown
      status means that the batch was removed from cache, and in Splinter it
      means that there was a wait timeout.
   4. Updates db with `update_batch_statuses`
4. Reruns on the specified `poll_interval`

## Interaction with other services

Below is a sequence diagram that outlines how the DLT polling monitor (Poller)
interacts with the DLT Event Monitor, Grid Daemon, Ledger, and Database.

<div class="mermaid">
sequenceDiagram
    participant Gridd as Grid Daemon
    participant Poller as DLT Polling Monitor
    participant EventMonitor as DLT Event Monitor
    participant Ledger as Splinter / Sawtooth
    participant DB as Grid DB
    Gridd->>Poller: Standup DLT Polling Monitor
    loop Poll
        Poller->>+DB: Select all pending batches
        DB-->>-Poller: 
        Note right of Poller: Scabbard: Group batches by service
        Note right of Poller: Sawtooth: Group all batches together
        loop For each group
            Poller->>+Ledger: GET /batch_statuses
            Ledger-->>-Poller: 
        end
        Poller->>+DB: Update statuses
    end
    Gridd->>EventMonitor: Standup DLT Event Monitor
    EventMonitor->>+Ledger: Connect to websocket DLT event stream
    loop Every event
        EventMonitor->>+Poller: Trigger poll
    end
</div>

## Public Traits and Structs

```rust
pub type BatchResult<T> = Result<T, BatchError>;

#[derive(Debug, Clone)]
pub enum BatchError {
    InternalError(String),
    // . . .
}

/// BatchStatus represents the minimum batch status information
/// necessary for the polling monitor to run
pub trait BatchStatus: Debug + Clone {
    fn get_id(&self) -> &str;
    fn is_unknown(&self) -> bool;
}

/// BatchId represents the minimum batch id information
/// necessary for the polling monitor to run
pub trait BatchId: Debug + Clone + Sync + Send {
    fn get_id(&self) -> &str;
    fn get_service_id(&self) -> &str;
}

/// Store that allows getting a list of pending batch ids
pub trait PendingBatchStore: Send {
    type Id: BatchId;
    fn get_pending_batch_ids(&self, limit: usize) -> BatchResult<Vec<Self::Id>>;
}

/// Reads the batch statuses from an external source
pub trait BatchStatusReader: Send {
    type Status: BatchStatus;

    fn get_batch_statuses<'a>(
        &'a self,
        service_id: &'a str,
        batch_ids: &'a [String],
    ) -> BoxFuture<'a, BatchResult<Vec<Self::Status>>>;

    fn available_connections(&self) -> usize;
}

/// Updates the batch statuses
pub trait BatchUpdater: Send {
    type Status: BatchStatus;

    fn update_batch_statuses(&self, service_id: &str, batches: &[Self::Status]) -> BatchResult<()>;
}
```
