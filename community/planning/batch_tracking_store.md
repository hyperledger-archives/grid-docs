# Batch Tracking Store
<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The batch tracking store is a proposed component meant to provide functionality
to the batch submitter/queuer and the DLT monitor on either a Hyperledger
Sawtooth or Splinter network. This component will provide functionality to
create records of batches and transactions and the status of their submissions
to the underlying DLT.

## Store Operations

The batch tracking store provides a set of methods for the other batch tracking
components to utilize to interact with the database. These components may
implement their own traits to provide a subset of the functionality provided by
the store to limit the API of those components to what is strictly necessary
for their own functionality.

```
pub trait BatchTrackingStore {
    /// Gets the status of a batch from the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `id` - The ID or data change ID of the batch with the status to
    ///    fetch
    ///  * `service_id` - The service ID
    fn get_batch_status(
        &self,
        id: &str,
        service_id: &str,
    ) -> Result<Option<BatchStatus>, BatchTrackingStoreError>;

    /// Updates the status of a batch in the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `id` - The ID or data change ID of the batch with the status to
    ///    update
    ///  * `service_id` - The service ID
    ///  * `status` - The new status for the batch
    ///  * `transaction_receipts` - A list of transaction receipts for the
    ///    transactions in the batch
    ///  * `submission_error` - A submission error for the batch if it exists
    fn update_batch_status(
        &self,
        id: &str,
        service_id: &str,
        status: Option<BatchStatus>,
        transaction_receipts: Vec<TransactionReceipt>,
        submission_error: Option<SubmissionError>,
    ) -> Result<(), BatchTrackingStoreError>;

    /// Adds batches to the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `batches` - The batches to be added
    fn add_batches(&self, batches: Vec<TrackingBatch>) -> Result<(), BatchTrackingStoreError>;

    /// Updates a batch's status to a submitted state
    ///
    /// # Arguments
    ///
    ///  * `batch_id` - The ID or data change ID of the batch to update
    ///  * `service_id` - The service ID
    ///  * `transaction_receipts` - A list of transaction receipts for the
    ///    transactions in the batch
    ///  * `dlt_status` - The new status for the batch
    ///  * `submission_error` - A submission error for the batch if it exists
    fn change_batch_to_submitted(
        &self,
        batch_id: &str,
        service_id: &str,
        transaction_receipts: Vec<TransactionReceipt>,
        dlt_status: Option<&str>,
        submission_error: Option<SubmissionError>,
    ) -> Result<(), BatchTrackingStoreError>;

    /// Gets a batch from the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `id` - The ID or data change ID of the batch to fetch
    ///  * `service_id` - The service ID
    fn get_batch(
        &self,
        id: &str,
        service_id: &str,
    ) -> Result<Option<TrackingBatch>, BatchTrackingStoreError>;

    /// Lists batches with a given status from the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `status` - The status to fetch batches for
    fn list_batches_by_status(
        &self,
        status: BatchStatus,
    ) -> Result<TrackingBatchList, BatchTrackingStoreError>;

    /// Removes records for batches and batch submissions before a given time
    ///
    /// # Arguments
    ///
    ///  * `submitted_by` - The timestamp for which to delete records submitted before
    fn clean_stale_records(&self, submitted_by: i64) -> Result<(), BatchTrackingStoreError>;

    /// Gets batches that have not yet been submitted from the underlying storage
    fn get_unsubmitted_batches(&self) -> Result<TrackingBatchList, BatchTrackingStoreError>;

    /// Gets batches that failed either due to validation or submission errors
    /// from the underlying storage
    fn get_failed_batches(&self) -> Result<TrackingBatchList, BatchTrackingStoreError>;
}
```

## Grid Struct Representations

The information stored in the database must have a corresponding Grid
representation. These Grid structs may combine information from several
database tables in order to provide a more concise representation of the batch
data.

```
pub enum BatchStatus {
    Unknown,
    Pending,
    Delayed,
    Invalid(Vec<InvalidTransaction>),
    Valid(Vec<ValidTransaction>),
    Committed(Vec<ValidTransaction>),
}

// This is used for matching when it is not useful to instantiate a list of
// transactions
pub enum BatchStatusName {
    Unknown,
    Pending,
    Delayed,
    Invalid,
    Valid,
    Committed,
}

pub struct InvalidTransaction {
    transaction_id: String,
    // These are for errors from the DLT itself
    error_message: Option<String>,
    error_data: Option<Vec<u8>>,
    // These are for other errors, such as a 404 when attempting to submit
    // to the DLT
    external_error_status: Option<String>,
    external_error_message: Option<String>,
}

pub struct ValidTransaction {
    transaction_id: String,
}

pub struct SubmissionError {
    error_type: String,
    error_message: String,
}

pub struct TrackingBatch {
    service_id: Option<String>,
    batch_header: String,
    data_change_id: Option<String>,
    signer_public_key: String,
    trace: bool,
    serialized_batch: Vec<u8>,
    submitted: bool,
    created_at: i64,
    transactions: Vec<TrackingTransaction>,
    batch_status: Option<BatchStatus>,
    submission_error: Option<SubmissionError>,
}

pub struct TrackingBatchList {
    pub batches: Vec<TrackingBatch>,
}

pub struct TrackingTransaction {
    family_name: String,
    family_version: String,
    transaction_header: String,
    payload: Vec<u8>,
    signer_public_key: String,
    service_id: String,
}

pub struct TransactionReceipt {
    transaction_id: String,
    result_valid: bool,
    error_message: Option<String>,
    error_data: Option<Vec<u8>>,
    serialized_receipt: String,
    external_status: Option<String>,
    external_error_message: Option<String>,
}
```

## Database Schema

The database schema for batch tracking follows many similar patterns to other
Grid stores with some notable exceptions.

One of these exceptions relates to the `service_id` column on the tables. In
other Grid stores, this value is set to `NULL` when Grid is running on Sawtooth
or another DLT without a concept of services. In this store, it is used as a
part of composite keys so it may not be `NULL`. In these cases, this value
should be some consistent value that will not conflict with any valid Splinter
service IDs.

A second difference when compared to other Grid stores is the lack of a foreign
key constraint in the `transaction_receipts` table. There may not be a foreign
key on the transaction ID because you will receive receipts for all
transactions committed on the circuit, not just ones that you have submitted so
you may not have records of the batch the transactions belong to.

Other things to note:

 - batches may be looked up by either the batch ID or a data change ID. Because
 a data change ID may take any form, they must have some prefix to be
 determined later.

 - The `batch_statuses` table is updated when the DLT status of a batch
 changes. Therefore, a batch will not have an entry in this table if it
 does not have a status from the DLT yet.

 - The `submissions` and `batch_statuses` tables each contain columns
 `created_at` and `updated_at`. These columns track when the batch was
 submitted to the DLT and when the DLT reports a status for the batch
 respectively.

```
CREATE TABLE batches
  (
     service_id        VARCHAR(17) NOT NULL,
     batch_id          VARCHAR(128) NOT NULL,
     data_change_id    VARCHAR(256) UNIQUE,
     signer_public_key VARCHAR(70) NOT NULL,
     trace             BOOLEAN NOT NULL,
     serialized_batch  BYTEA NOT NULL,
     submitted         BOOLEAN NOT NULL,
     created_at        INTEGER NOT NULL DEFAULT utc_timestamp(),
     PRIMARY KEY (service_id, batch_id)
  );

CREATE TABLE transactions
  (
     service_id         VARCHAR(17) NOT NULL,
     transaction_id     VARCHAR(128) NOT NULL,
     batch_id           VARCHAR(128) NOT NULL,
     payload            BYTEA NOT NULL,
     family_name        VARCHAR(128) NOT NULL,
     family_version     VARCHAR(16) NOT NULL,
     signer_public_key  VARCHAR(70) NOT NULL,
     PRIMARY KEY (service_id, transaction_id),
     FOREIGN KEY (service_id, batch_id) REFERENCES batches(service_id, batch_id) ON DELETE CASCADE
  );

CREATE TABLE transaction_receipts
  (
     service_id             VARCHAR(17) NOT NULL,
     transaction_id         VARCHAR(128) NOT NULL,
     result_valid           BOOLEAN NOT NULL,
     error_message          TEXT,
     error_data             BYTEA,
     serialized_receipt     BYTEA NOT NULL,
     external_status        VARCHAR(16),
     external_error_message TEXT,
     FOREIGN KEY (service_id, transaction_id) REFERENCES transactions(service_id, transaction_id) ON DELETE CASCADE
  );

  CREATE TABLE submissions
  (
     service_id            VARCHAR(17) NOT NULL,
     batch_id              VARCHAR(128) NOT NULL,
     last_checked          INTEGER NOT NULL DEFAULT utc_timestamp(),
     times_checked         INTEGER NOT NULL DEFAULT 1,
     error_type            VARCHAR(64),
     error_message         TEXT,
     -- Keep track of when created and updated so we don't keep too many useless records
     -- These are updated on `UPDATE` using a trigger
     created_at            INTEGER NOT NULL DEFAULT utc_timestamp(),
     updated_at            INTEGER NOT NULL DEFAULT utc_timestamp(),
     PRIMARY KEY (service_id, batch_id),
     FOREIGN KEY (service_id, batch_id) REFERENCES batches(service_id, batch_id) ON DELETE CASCADE
  );

-- This gets updated when DLT status changes
CREATE TABLE batch_statuses
  (
     service_id        VARCHAR(17) NOT NULL,
     batch_id          VARCHAR(70) NOT NULL,
     dlt_status        VARCHAR(16) NOT NULL,
     -- Keep track of when created and updated so we don't keep too many useless records
     -- These are updated on `UPDATE` using a trigger
     created_at        INTEGER NOT NULL DEFAULT utc_timestamp(),
     updated_at        INTEGER NOT NULL DEFAULT utc_timestamp(),
     PRIMARY KEY (service_id, batch_id),
     FOREIGN KEY (service_id, batch_id) REFERENCES batches(service_id, batch_id) ON DELETE CASCADE
  );
```
