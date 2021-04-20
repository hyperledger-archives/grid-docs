<!--
  Copyright 2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Batch Submitter

The batch submitter is a proposed component meant to monitor a database that
holds batched transactions and send them to either a Hyperledger Sawtooth or
Splinter network. Batch submitters are meant to be run as part of a cluster with
other batch submitters in order to provide redundancy or reduce the time it
takes for batches to be processed.

## Batch Submission Algorithm

A batch submitter sleeps for a configurable number of seconds before waking
up and performing the following actions.

1. A submitter will acquire a lock from the database and fetch a configurable
number of unclaimed batches (the `claim_limit`). An unclaimed batch is a batch
whose submitted status is `false`, and its `claim_expires` time stamp is `NULL`
or less than the `CURRENT_TIMESTAMP` of the database.
```
SELECT * FROM batches
  WHERE submitted = false
    AND (claim_expires is NULL
      OR claim_expires < CURRENT_TIMESTAMP) LIMIT {claim_limit};
```

The submitter will then update the `claim_expires` column to lay claim to
each batch it retrieved for a configurable number of seconds. This step and
the initial query for unclaimed batches are a part of the same database
transaction.

3. For each batch, the submitter will attempt to submit the batch. If the
submitter receives an internal error or service unavailable error from the
Splinter or Sawtooth network it will relinquish its claim to the batch, so
that it or another submitter can retry sending the batch at a later interval.
If The submitter receives a bad request error from the splinter network it will
update the database by setting the submitted column to `true`, and updating the
`submission_error` and `submission_error_message` columns describing why the
batch was not submitted. If the batch was submitted successfully the submitted
column is simply updated to `true`.

4. The submitter will go to sleep for a configurable number of seconds and then
repeat the process.

## Database Schema

```
CREATE TABLE batches (
    header_signature TEXT PRIMARY KEY,
    data_change_id TEXT,
    signer_public_key TEXT NOT NULL,
    trace BOOLEAN NOT NULL,
    serialized_batch TEXT NOT NULL,
    submitted BOOLEAN NOT NULL,
    submission_error VARCHAR(16),
    submission_error_message TEXT,
    dlt_status VARCHAR(16),
    claim_expires TIMESTAMP,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    service_id TEXT
);

CREATE TABLE transactions (
    header_signature TEXT PRIMARY KEY,
    batch_id TEXT NOT NULL,
    family_name TEXT NOT NULL,
    family_version TEXT NOT NULL,
    signer_public_key TEXT NOT NULL,
    FOREIGN KEY (batch_id) REFERENCES batches(header_signature) ON DELETE CASCADE
);

CREATE TABLE transaction_receipts (
    id BIGSERIAL PRIMARY KEY,
    transaction_id TEXT UNIQUE,
    result_valid BOOLEAN NOT NULL,
    error_message TEXT,
    error_data TEXT,
    serialized_receipt TEXT NOT NULL,
    external_status VARCHAR(16),
    external_error_message TEXT
);
```
