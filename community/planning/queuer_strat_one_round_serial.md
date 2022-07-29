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

See the high-level document on [submission queuer
strategies]({% link community/planning/batch_queuer_strategies.md %})
for a detailed discussion of the decisions behind this strategy's design.

## Logic

> Some of this logic may be implemented in the store for efficiency, but the
> queuer may implement all of it so it can be separated from the store.

Start with a list of all batches that do not have these batch statuses:

* `Committed`
* `Valid`
* `Invalid`

This should leave a list of batches (called `batch_list`) in the following
states:

* `{submitted = false, batch_status = None}` - unsubmitted batches
* `{submitted = true, batch_status = None}` - batches that are in the process
  of being submitted
* `{submitted = true, batch_status = Some(Pending)}` - batches that were
  submitted but haven't yet been committed by the DLT
* `{submitted = false, batch_status = Some(Unknown)}` - batches that may have
  been submitted but that the DLT does not recognize
* `{submitted = false, batch_status = Some(Delayed)}` - batches that the
  submitter attempted to submit, but the DLT was busy

For each `service_id`:

1. If there is a batch with status `Unknown`, or with status `Delayed` and the
  delay window has past, queue this batch. There should only be one of these
  at a time. Do not queue any other batches for this `service_id`.
2. Next, if there is a batch with any of the below, do not queue any other
  batches for the `service_id`:

    * `{submitted = true, batch_status = None}`
    * `{submitted = true, batch_status = Some(Pending)}`
    * `{submitted = false, batch_status = Some(Unknown)}`
    * `{submitted = false, batch_status = Some(Delayed)}`

    This `service_id` is effectively locked, since there is some batch that
    must be committed or resubmitted first.

3. If neither of the above apply and all batches for the `service_id` are
  `{submitted = false, batch_status = None}`, queue the batch with the oldest
  `created_at`. If there are two batches that were created at the same time,
  break the tie by taking the batch with the first alphabetically sorted
  `batch_header`; this will ensure deterministic queuing behavior.

Note that these are the logical rules that the queuing algorithm must follow -
these steps are not necessarily how the algorithm should be implemented. An
efficient implementation could involve one pass over `batch_list`, an enum, a
HashMap, and logic to select the appropriate batch.

### Delay window

Batches with a status of `Delayed` must wait for a delay window to pass before
being resubmitted. The delay window starts when the submitter finishes retrying
its submission and records the submission attempt. The delay window exists to
lessen the load on a DLT that has repeatedly returned a 503 code.

### Additional notes

* `submitted = True` is an indicator that the submitter has the batch and is
  doing something with it when the batch status is `None`, or `Delayed` or
  `Unknown` when resubmitting - it guards against the queuer re-queuing the
  batch while the submitter has it.
* The monitor needs to update `submitted` to false when it sets the batch
  status to `Unknown`.

