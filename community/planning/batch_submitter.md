<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Batch Submitter

## Overview

The batch submitter component manages the submission of batches to the
underlying distributed ledger technology (DLT). It is responsible for providing
the submission queuer and DLT monitor with the information they need to
accurately perform their own functions via updates to the batch database.

### Why must the submitter exist?

* We need to submit batches via individual http requests to the DLT

### How will the submitter be used?

* The submitter will poll the batch queue for batches to submit
* The submitter will update the batch database via the store

### What must the submitter do?

* Submit batches in the order in which it receives them from the queuer
* Update a batch's status via the store as soon as possible
* Handle and report connection issues with the DLT or service

### What must the submitters not do?

* Submit batches to the wrong service
* Get hung up on a slow request

### Design priorities

1. Accuracy
2. Stability
3. Scalability
4. High availability (HA)

## Detail

### Actor pattern

The submitter design is based on an actor pattern. There is a main thread, which
interfaces with the submission queuer and the stores, and the submission
actor, which manages the actual submission of batches to the DLT.

The actor pattern brings two key benefits to the submitter's design. First, it
provides us with a great deal of flexibility in implementation. Second, the
actor pattern translates across implementations, meaning we can solve for a
variety of desired outcomes, such as low-dependency or HA requirements, using
the same overall pattern.

With the actor pattern, the submission actor is a resource that we deploy
somewehere and with which we communicate via messages. If we want control over
everything that's happening, or to minimize dependencies, those actors could be
structs on threads. If we want to leverage an async runtime, the actors could
be async tasks spawned in a tokio runtime. For HA, the actors may be containers
in a cluster.

### Implementation

Since we want the submitter to be scalable, we leverage the async capablities
of tokio, and the actor is an async runtime in which we spawn tasks.

There are four subcomponents to the submitter: 

* __the main thread__ - This has two responsibilities: 1) on initialization,
  set up the receiver thread, async runtime, channels, and spawner thread, and
  2) on an ongoing basis, poll the queuer for new batches, create new tasks,
  and send them to the spawner thread.
* __the receiver thread__ - This thread listens for submission responses from
  submission tasks and updates the store accordingly.
* __the spawner thread__ - This thread represents the tokio async runtime
  (which is likely running on multiple os threads). It's role is to listen for
  new task messages from the main thread and spawn new tasks accordingly.
* __task handlers__ - These are tasks spawned in the tokio runtime that manage
  the process of submitting a batch to a DLT. They submit the batches to the DLT
  and send the submission response back to the main thread via an mpsc channel.

![]({% link community/images/grid_batch_submitter.svg %} "Grid batch submitter diagram")

#### Process

1. The main thread polls the Submission queuer for the next thread and receives
  a `BatchSubmission` (called "NewBatch" in the diagram for brevity).
2. The main thread clones a `Sender` from a `std::sync::mpsc` channel that it
  has dedicated for the listener thread to listen for submission responses from
  tasks.
3. The main thread packages the new `BatchSubmission` and `Sender` into a
  `NewTask` message that it sends to the spawner thread via a capped
  `tokio::sync::mpsc` channel.
4. The spawner thread receives the `NewTask` message and spawns a new task in
  tokio runtime, passing the `NewTask` message contents to the task.
5. The task creates and runs a new `SubmissionController`, which submits the
  new batch to the DLT.
6. The task receives a response from the DLT and packages it into a
  `SubmissionResponse` struct.
7. The task uses the `Sender` that was bundled with the `BatchSubmission` to
  send the `SubmissionResponse` to the listener thread.
8. The listener thread receives the `SubmissionResponse` and updates the
  batch's status in the batch database via the store accordingly.

#### `SubmissionController` Detail

As described above, the `SubmissionController` is the component that is 
responsible for the submission of an individual batch. It has one subcomponent,
the `SubmissionCommand`, that makes a single, non-blocking call (using 
`reqwest`) to the DLT's batch submission endpoint. The `SubmissionController`
creates a new `SubmissionCommand` and calls `execute()` on it.

For most responses from the DLT, the `SubmissionController` will simply send
the `SubmissionResponse` back to the `TaskHandler` (these will typically be 200
responses). For 503 responses, the SubmissionController will retry the
submission according to its retry logic by calling `execute()` on the
`SubmissionCommand`. After a set number of retries, it will return a
`SubmissionResponse` with a 503 status to the `TaskHandler`.

