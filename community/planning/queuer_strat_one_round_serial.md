<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
# One-round serial queuer strategy

## Overview

The one-round serial queuing strategy is a simple strategy for queuing batches
for submission to a distributed ledger (DLT). It ensures that batches are
submitted and committed to the DLT in the order in which they are submitted to
Grid.

See the high-level document on (submission queuer
strategies)[{% link community/planning/batch_queuer_strategies.md %}]
for a detailed discussion of the decisions behind this strategy's design.

## Algorithm

> Some of these steps may be pre-implemented in the store for efficiency, but
> the queuer should implement all of these so it can be separated from the
> store.

1. Start with a list of all batches that do not have these batch statuses:

    * `Some(Committed)`
    * `Some(Valid)`
    * `Some(Invalid)`

    This should leave a list of batches (called `batch_list`) in the following
    states:

    * `{submitted = false, batch_status = None}`
    * `{submitted = true, batch_status = Some(Pending)}`
    * `{submitted = false, batch_status = Some(Unknown)}`
    * `{submitted = false, batch_status = Some(Delayed)}`

2. Create a mutable vector called `batch_queue`.

3. Get all batches from `batch_list` where `batch_status = Some(Unknown)` and
  add these to `batch_queue`.

4. Get all batches from `batch_list` where `batch_status = Some(Delayed)` and
  the last submission attempt is outside the delay window, then add these to
  `batch_queue`.

5. Get a list of all `service_id`s, excluding any `service_id` of batches with
  a `batch_status` of `Some(Pending)`, `Some(Unknown)`, or `Some(Delayed)`.
  Call this list `service_id_list`.

5. For each `service_id` in `service_id_list`, find the batch or
  batches with the oldest `created_at` date (there may be more than one if the
  oldest batches were created at the same time).

    If there is one oldest batch, add this batch to `batch_queue`.

    If there is more than one oldest batch, select the batch with the first
    alphabetically-sorted `batch_header` (this ensures deterministic queuing
    behavior). Add this batch to `batch_queue`.

### Which batches to queue?

From the queuer's perspective, batches fall into three categories:

#### Queue now

These batches look like (there are additional criteria for prioritization):
* `{submitted = false, batch_status = None}` - These have not been submitted
  and there are no pending batches with this service_id; there are also no
  batches with status `unknown` or `delayed`
* `{submitted = false, batch_status = Some(Unknown)}` - These have been submitted,
  but the DLT doesn't recognize them
* `{submitted = false, batch_status = Some(Delayed), last_submitted_at <= now - 15
  seconds?}` - The submitter attempted to submit these, but something went
  wrong and these need to be retried; the delay window has expired, so these
  should be retried now

#### Queue later

These batches look like:
* `{submitted = false, batch_status = Some(Delayed), last_submitted_at > now - 15
  seconds?}` - The submitter attempted to submit these, but something went
  wrong and these need to be retried; the delay window has not expired yet
* `{submitted = false, batch_status = None, service_id = (service_id of a
  pending, unknown, or delayed batch)}` - These are new batches, but there is a
  batch with the same service_id that must be committed or declared invalid
  before another batch with this service_id can be submitted

#### Don't queue

These batches look like:
* `{submitted = true, batch_status = Some(Pending)}`
* `{submitted = true, batch_status = Some(Invalid)}`
* `{submitted = true, batch_status = Some(Valid)}`
* `{submitted = true, batch_status = Some(Committed)}`
* `{submitted = true, batch_status = None}` - These bathes are in process of
  being submitted and should not be queued

### Additional notes

* `submitted = True` is an indicator that the submitter has the batch and is
  doing something with it when the batch status is `None` or `Delayed` or
  `Unknown` - it guards against the queuer re-queuing the batch while the
  submitter has it.
* The monitor needs to update `submitted` to false when it sets the batch
  status to `Unknown`.

