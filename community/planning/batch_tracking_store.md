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
    fn get_batch_status(&self, id: &str) -> Result<BatchStatus, BatchStoreError> {
        (**self).get_batch_status(id)
    }

    /// Updates the status of a batch in the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `id` - The ID or data change ID of the batch with the status to
    ///    update
    ///  * `status` - The new status for the batch
    ///  * `errors` - Any errors encountered while attempting to submit the
    ///    batch
    fn update_batch_status(
        &self,
        id: String,
        status: BatchStatus,
        errors: Vec<SubmissionError>,
    ) -> Result<(), BatchStoreError> {
        (**self).update_batch_status(id, status, errors)
    }

    /// Adds batches to the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `batches` - The batches to be added
    fn add_batches(&self, batches: Vec<TransactBatch>) -> Result<(), BatchStoreError> {
        (**self).add_batches(batches)
    }

    /// Updates a batch's status to a submitted state
    ///
    /// # Arguments
    ///
    ///  * `batch_id` - The ID or data change ID of the batch to update
    fn change_batch_to_submitted(&self, batch_id: &str) -> Result<(), BatchStoreError> {
        (**self).change_batch_to_submitted(batch_id)
    }

    /// Gets a batch from the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `id` - The ID or data change ID of the batch to fetch
    fn get_batch(&self, id: &str) -> Result<Option<Batch>, BatchStoreError> {
        (**self).get_batch(id)
    }

    /// Lists batches with a given status from the underlying storage
    ///
    /// # Arguments
    ///
    ///  * `status` - The status to fetch batches for
    fn list_batches_by_status(&self, status: BatchStatus) -> Result<BatchList, BatchStoreError> {
        (**self).list_batches(status)
    }

    /// Removes records for batches and batch submissions before a given time
    ///
    /// # Arguments
    ///
    ///  * `submitted_by` - The timestamp for which to delete records submitted before
    fn clean_stale_records(&self, submitted_by: &str) -> Result<BatchList, BatchStoreError> {
        (**self).clean_stale_records(submitted_by)
    }

    /// Gets batches that have not yet been submitted from the underlying storage
    fn get_unsubmitted_batches(&self) -> Result<BatchList, BatchStoreError> {
        (**self).get_unsubmitted_batches()
    }

    /// Gets batches that failed either due to validation or submission errors
    /// from the underlying storage
    fn get_failed_batches(&self) -> Result<BatchList, BatchStoreError> {
        (**self).get_failed_batches()
    }
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
    Invalid(Vec<InvalidTransactionResponse<'a>>),
    Valid(Vec<ValidTransactionResponse<'a>>),
    Committed(Vec<ValidTransactionResponse<'a>>),
}

pub struct InvalidTransactionResponse<'a> {
    pub transaction_id: &'a str,
    pub error_message: &'a str,
    pub error_data: &'a [u8],
}

pub struct ValidTransactionResponse<'a> {
    pub transaction_id: &'a str,
}

pub struct SubmissionError {
    error_type: String,
    error_message: String,
}

pub struct Batch {
    pub data_change_id: Option<String>,
    pub signer_public_key: String,
    pub submitted: bool,
    pub trace: bool,
    pub serialized_batch: String,
    pub transactions: Vec<Transaction>,
    pub batch_status: BatchStatus,
    pub claim_expires: Option<String>,
    pub submission_error: Option<SubmissionError>,
    pub dlt_status: Option<String>,
    pub created_at: i64,
    pub service_id: Option<String>,
}

pub struct TransactBatch {
    pub header: Vec<u8>,
    pub header_signature: String,
    pub data_change_id: Option<String>,
    pub signer_public_key: String,
    pub trace: bool,
    pub serialized_batch: String,
    pub transactions: Vec<Transaction>,
    pub batch_status: BatchStatus,
    pub claim_expires: Option<String>,
    pub dlt_status: Option<String>,
    pub service_id: Option<String>,
}

pub struct BatchList {
    pub batches: Vec<Batch>,
}

pub struct Transaction {
    pub family_name: String,
    pub family_version: String,
    pub payload: Vec<u8>,
    pub signer_public_key: String,
    pub service_id: Option<String>,
}

pub struct TransactionReceipt {
    pub transaction_id: String,
    pub result_valid: bool,
    pub error_message: Option<String>,
    pub error_data: Option<Vec<u8>>,
    pub serialized_receipt: String,
    pub external_status: Option<String>,
    pub external_error_message: Option<String>,
}
```

## Database Schema

```
CREATE TABLE batches
  (
     id                VARCHAR(256) PRIMARY KEY,
     signer_public_key VARCHAR(256) NOT NULL,
     trace             BOOLEAN NOT NULL,
     serialized_batch  BYTEA NOT NULL,
     claim_expires     TIMESTAMP,
     created_at        TIMESTAMP,
     service_id        TEXT
  );

CREATE TABLE transactions
  (
     transaction_id    BIGSERIAL PRIMARY KEY,
     batch_id          VARCHAR(256) REFERENCES batches(id),
     family_name       TEXT NOT NULL,
     family_version    VARCHAR(64) NOT NULL,
     signer_public_key VARCHAR(256) NOT NULL,
     service_id        TEXT
  );

CREATE TABLE transaction_receipts
  (
     receipt_id             BIGSERIAL PRIMARY KEY,
     transaction_id         BIGSERIAL REFERENCES transactions(transaction_id),
     result_valid           BOOLEAN NOT NULL,
     error_message          VARCHAR(256),
     error_data             BYTEA,
     serialized_receipt     BYTEA NOT NULL,
     external_status        VARCHAR(256),
     external_error_message VARCHAR(256),
     service_id             TEXT
  );

CREATE TABLE submissions
  (
     batch_id        VARCHAR(256) REFERENCES batches(id),
     status          VARCHAR(64) NOT NULL,
     submission_time TIMESTAMP NOT NULL,
     last_checked    TIMESTAMP,
     times_checked   VARCHAR(32),
     PRIMARY KEY (batch_id, submission_time)
  );

CREATE TABLE submission_errors
  (
     error_id      BIGSERIAL PRIMARY KEY,
     batch_id      VARCHAR(256) REFERENCES batches(id),
     error_type    VARCHAR(64) NOT NULL,
     error_message VARCHAR(256) NOT NULL
  );

CREATE TABLE data_change_id_index
  (
     data_change_id  VARCHAR(256) PRIMARY KEY,
     batch_id        VARCHAR(256) REFERENCES batches(id),
     service_id      TEXT
  );
```
