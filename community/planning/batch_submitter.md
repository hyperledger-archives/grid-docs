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

The submitter is the component responsible for submitting batches via
individual http requests to the DLT. It polls the batch queuer component for
batches to submit, and, upon submission, updates the batches' statuses via the
store component.

### What must the submitter do?

* Reliably submit batches to the DLT endpoint
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

The submitter design is based on an actor pattern. This pattern breaks the
design into two parts: an interface, which interfaces with the batch queue and
the store, and the submission actor, which manages the actual submission of
batches to the DLT.

The actor pattern brings two key benefits to the submitter's design. First, it
provides us with a great deal of flexibility in implementation. Second, the
actor pattern translates across implementations, meaning we can solve for a
variety of desired outcomes, such as low-dependency or HA requirements, using
the same overall pattern.

With the actor pattern, the submission actor is a resource that we deploy
somewhere and with which we communicate via messages. If we want control over
everything that's happening, or to minimize dependencies, those actors could be
structs on threads. If we want to leverage an async runtime, the actors could
be async tasks spawned in a tokio runtime. For HA, the actors may be containers
in a cluster.

### Implementation

Since we want the submitter to be scalable, we leverage the async capabilities
of tokio, and the actor is an async runtime in which we spawn tasks.

There are four subcomponents to the submitter: 

* __the leader thread__ - This has two responsibilities: 1) on initialization,
  set up the receiver thread, async runtime, channels, and spawner thread, and
  2) on an ongoing basis, poll the queuer for new batches, create new tasks,
  and send them to the spawner thread.
* __the receiver thread__ - This thread listens for submission responses from
  submission tasks and notifies the observer.
* __the spawner thread__ - This thread represents the tokio async runtime
  (which is likely running on multiple os threads). Its role is to listen for
  new task messages from the leader thread and spawn new tasks accordingly.
* __task handlers__ - These are tasks spawned in the tokio runtime that manage
  the process of submitting a batch to a DLT. They submit the batches to the DLT
  and send the submission response to the listener thread via an mpsc channel.

![]({% link community/images/grid_batch_submitter.svg %} "Grid batch submitter diagram")

#### Process

1. The leader thread polls the Submission queuer for the next thread and
  receives a `BatchSubmission` (called "NewBatch" in the diagram for brevity).
2. The leader thread clones a `Sender` from a `std::sync::mpsc` channel on
  which the listener thread listens for submission responses from tasks.
3. The leader thread packages the new `BatchSubmission` and `Sender` into a
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
8. The listener thread receives the `SubmissionResponse` and notifies the
  observer accordingly.

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

### The `BatchSubmitter` struct

The trait below defines the submitter:

```rust

pub trait Submitter<'a> {
    fn start(
        addresser: Box<dyn Addresser + Send>,
        queue: Box<dyn Iterator<Item = BatchSubmission> + Send>,
        observer: Box<dyn SubmitterObserver + Send>,
    ) -> Result<Box<Self>, InternalError>;

    fn shutdown(self) -> Result<(), InternalError>;
}

```

Since the submitter is an active component, i.e. it drives action within Grid,
there are only `start(...)` and `shutdown()` methods. The addresser, queue, and
observer are described in their respective sections below.

In implementation, the submitter acts like a handle to the submission service.
As a struct, this implementation looks like this:

```rust

struct BatchSubmitter {
    runtime_handle: thread::JoinHandle<()>,
    leader_handle: thread::JoinHandle<()>,
    leader_tx: std::sync::mpsc::Sender<TerminateMessage>,
    listener_handle: thread::JoinHandle<()>,
    listener_tx: std::sync::mpsc::Sender<TerminateMessage>,
}

```

The `start(...)` method initializes the channels and threads that are
represented in the struct fields (as well as many others). The `shutdown()`
method uses the channels in the struct fields to instruct the subcomponents to
drain and terminate, then uses the `JoinHandle`s to join all the subcomponent
threads.

The addresser, queue, and observer are not part of the submitter object. For an
implementation like this, each of them are moved to new threads. Since these
threads could outlive the submitter struct itself, the threads cannot take a
reference to the submitter. Thus, the addresser, queue, and observer must all
implement `Send` and are consumed by the submitter.

### Addressers, queues, and observers

The submitter requires three components to function: an addresser, a queue, and
and observer.

#### Addresser

The following trait defines the `Addresser`:

```rust

pub trait Addresser {
    fn address(&self, routing: Option<String>) -> Result<String, InternalError>;
}

```

Generically, the addresser generates an address to which a batch will be sent,
possibly including specific routing information. In this case, the addresser
contains information about the DLT, namely, the REST endpoint to which batches
can be submitted and the url parameter it accepts, if applicable. Its
implementation is:

```rust

pub struct BatchAddresser {
    base_url: &'static str,
    parameter: Option<&'static str>,
}

impl BatchAddresser {
    fn new(base_url: &'static str, parameter: Option<&'static str>) -> Self {
        Self {
            base_url,
            parameter,
        }
    }
}

impl Addresser for BatchAddresser {
    fn address(&self, routing: Option<String>) -> Result<String, InternalError> {
        match &self.parameter {
            Some(p) => {
                if let Some(r) = routing {
                    Ok(format!(
                        "{base_url}?{parameter}={route}",
                        base_url = self.base_url.to_string(),
                        parameter = p.to_string(),
                        route = r
                    ))
                } else {
                    Err(InternalError::with_message(
                        "Expecting service_id for batch but none was provided".to_string(),
                    ))
                }
            }
            None => {
                if value.is_none() {
                    Ok(self.base_url.to_string())
                } else {
                    Err(InternalError::with_message(
                        "service_id for batch was provided but none was expected".to_string(),
                    ))
                }
            }
        }
    }
}

```

#### Queue

The batch queue is simply any struct that satisfies the trait 
`Iterator<Item = BatchSubmission>`. Further, the submitter uses only the
required trait method `next()`, so the queues implementation is very flexible. 

In the case of Grid, this queue is the
[batch queuer component](community/planning/batch_queuer_strategies.md), which
only has the method `next()`. For testing or other purposes, the queue can be a
vector or other object converted to an iterator, so long as the items in the
iterator are `BatchSubmission` structs.

#### Observer

The following trait defines the observer:

```rust

pub trait SubmitterObserver {
    fn notify(&self, id: String, status: Option<u16>, message: Option<String>);
}

```

The implementation of the observer is also very flexible, both in mechanism and
interpretation. The mechanism could be a method on a store, a call to a REST
API, method calls on multiple other observers, etc. The implementation of the
observer also determines how the observer interprets and acts on the
notification.

Here is the observer implementation in Grid:

```rust

pub struct BatchTrackingObserver {
    store: Box<dyn BatchTrackingStore>,
}

impl SubmitterObserver for BatchTrackingObserver {
    fn notify(&self, id: String, status: Option<u16>, message: Option<String>) {
        if let Some(s) = status {
            // TODO: Do we need to log any of these?
            match &s {
                // TODO: Need these methods
                &200 => self.store.update_batch_submission_successful(id),
                &503 => self.store.update_batch_submission_busy(id), // include message?
                &404 => self.store.update_batch_submission_missing(id, message),
                &500 => self.store.update_batch_submission_internal_error(id), // include message?
                _ => self.store.update_batch_submission_unrecognized_status(id, status, message),
            }
        } else {
            // A missing status code represents an error in the submission process
            self.store.update_batch_dlt_error(id, message);
            todo!(); // Determine if the observer should notify another component
            // This error will have already been logged by the submitter
        }
    }
}

```

### `BatchSubmitter` implementation

The implementation of the `BatchSubmitter` has the following steps:

1. Create channels with which the threads will communicate
2. Build the async runtime
3. Move the async runtime to a new thread
4. Spawn the leader thread, which polls for batches and sends them to the async
  runtime thread
5. Spawn the listener thread, which notifies the observer
6. Returns `Self`

You can see these steps in its implementation:

```rust

struct BatchSubmitter {
    runtime_handle: thread::JoinHandle<()>,
    leader_handle: thread::JoinHandle<()>,
    leader_tx: std::sync::mpsc::Sender<TerminateMessage>,
    listener_handle: thread::JoinHandle<()>,
    listener_tx: std::sync::mpsc::Sender<TerminateMessage>,
}

impl Submitter<'_> for BatchSubmitter {
    fn start<'a>(
        addresser: Box<dyn Addresser + Send>,
        mut queue: Box<dyn Iterator<Item = BatchSubmission> + Send>,
        observer: Box<dyn SubmitterObserver + Send>,
    ) -> Result<Box<Self>, InternalError> {
        // Create channels for for termination messages
        let (leader_tx, leader_rx) = std::sync::mpsc::channel();
        let (listener_tx, listener_rx) = std::sync::mpsc::channel();

        // Channel for messages from the async tasks to the sync listener thread
        let (tx_task, rx_task): (
            std::sync::mpsc::Sender<TaskMessage>,
            std::sync::mpsc::Receiver<TaskMessage>,
        ) = std::sync::mpsc::channel();
        // Channel for messges from this main thread to the task-spawning thread
        let (tx_spawner, mut rx_spawner) = mpsc::channel(64);

        // Create the runtime here to better catch errors on building
        let rt = Builder::new_multi_thread()
            .enable_all()
            .thread_name("submitter_async_runtime")
            .build()
            .map_err(|e| InternalError::with_message(format!("{:?}", e)))?;

        // Move the asnyc runtime to a separate thread so it doesn't block this one
        let runtime_handle = std::thread::Builder::new()
            .name("submitter_async_runtime_host".to_string())
            .spawn(move || {
                rt.block_on(async move {
                    while let Some(msg) = rx_spawner.recv().await {
                        match msg {
                            CentralMessage::NewTask(t) => {
                                tokio::spawn(TaskHandler::spawn(t));
                            }
                            CentralMessage::Terminate => break,
                        }
                    }
                })
            })
            .map_err(|e| InternalError::with_message(format!("{:?}", e)))?;

        // Set up and run the leader thread
        let leader_handle = std::thread::Builder::new()
            .name("submitter_poller".to_string())
            .spawn(move || {
                loop {
                    // Check for shutdown command
                    match leader_rx.try_recv() {
                        Ok(_) => {
                            // Send terminate message to async runtime
                            match tx_spawner.blocking_send(CentralMessage::Terminate) {
                                Ok(()) => (),
                                Err(e) => {
                                    error!("Error sending terminate messsage to runtime: {:?}", e)
                                }
                            };
                            break;
                        }
                        Err(std::sync::mpsc::TryRecvError::Disconnected) => break,
                        Err(std::sync::mpsc::TryRecvError::Empty) => (),
                    }
                    // Poll for next batch and submit it
                    match queue.next() {
                        Some(next_batch) => match BatchEnvelope::create(next_batch, &addresser) {
                            Ok(b) => {
                                info!("Batch {}: received from queue", &b.id);
                                match tx_spawner.blocking_send(CentralMessage::NewTask(
                                    NewTask::new(tx_task.clone(), b),
                                )) {
                                    Ok(()) => (),
                                    Err(e) => {
                                        error!("Error sending NewTask message: {:?}", e)
                                    }
                                };
                            }
                            Err(e) => error!("Error creating batch envelope: {:?}", e),
                        },
                        None => std::thread::sleep(time::Duration::from_millis(POLLING_INTERVAL)),
                    }
                }
            })
            .map_err(|e| InternalError::with_message(format!("{:?}", e)))?;

        // Set up and run the listener thread
        let listener_handle = std::thread::Builder::new()
            .name("submitter_listener".to_string())
            .spawn(move || {
                loop {
                    // Check for shutdown command
                    match listener_rx.try_recv() {
                        Ok(_) => break,
                        Err(std::sync::mpsc::TryRecvError::Disconnected) => break,
                        Err(std::sync::mpsc::TryRecvError::Empty) => (),
                    }
                    // Check for submisison response
                    match rx_task.try_recv() {
                        Ok(msg) => {
                            match msg {
                                TaskMessage::SubmissionResponse(s) => {
                                    info!(
                                        "Batch {id}: received submission response [{code}]",
                                        id = &s.id,
                                        code = &s.status
                                    );
                                    // TODO: Log the number of submission attempts?
                                    observer.notify(s.id, Some(s.status), Some(s.message))
                                }
                                TaskMessage::ErrorResponse(e) => {
                                    error!("Submission error for batch {}: {:?}", &e.id, &e.error);
                                    observer.notify(e.id, None, Some(e.error.to_string()));
                                }
                            }
                        }
                        _ => (),
                    }
                }
            })
            .map_err(|e| InternalError::with_message(format!("{:?}", e)))?;

        Ok(Box::new(Self {
            runtime_handle,
            leader_handle,
            leader_tx,
            listener_handle,
            listener_tx,
        }))
    }

```

See the below sections for discussions on error handling and logging.

### Error handling

Errors can arise in two primary activities: 1) startup/shutdown and 2) runtime
behavior. We handle errors from these activities differently.

#### Startup/shutdown

On startup, the submitter initializes channels, an async tokio runtime, and
three native threads. A call to `Submitter::start(...)` returns a
`Result<Box<Self>, InternalError>`, where such initialization errors are
returned. These would all represent serious errors that prevent the submitter
component from functioning properly and should be handled elsewhere in Grid.

Similarly, a call to `Submitter::shutdown()` returns a
`Result<(), InternalError>` that returns errors from the shutdown process.
Errors here also represent problems far outside the scope of the submitter
component and should be handled elsewhere.

#### Runtime

Errors during runtime stem from issues with the submission process and are
may be isolated to a particular service or batch; therefore, we do not want
these errors to disrupt the submission of other services or batches. An example
would be a TCP connect error.

These errors are ultimately collected and logged for further investigation and
notification, and the associated batches' records in the batch database are
updated to reflect the issue.

Runtime errors originate in the `SubmissionCommand`, are returned to the
`SubmissionController`, and are packaged into a `TaskMessage::ErrorResponse` by
the `TaskHandler`. The `TaskHandler` then sends the message to the listener
thread, which logs the error and notifies the `Observer`.

### Info-level logging

To be able to monitor the status of the submission process, we want info-level
logging to give us information about two things: 1) how long is it taking for
batches to be submitted, and 2) if there are any batches that are for some
reason "stuck" (this includes batches that were successfully submitted, but for
which the listener thread didn't receive a `SubmissionResponse`).

Fortunately, we can determine both of these by logging 1) the point at which
the submitter receives the batch from the batch queue and 2) the point at which
the listener thread receives an update about the batch submission (either a
`SubmissionResponse` or an `ErrorResponse`).

### Batch wrappers

There are two structs that the submitter uses to handle batches: the
`BatchSubmission` and the `BatchEnvelope`:

```rust

pub struct BatchSubmission {
    id: String,
    service_id: Option<String>,
    payload: String,
}

struct BatchEnvelope {
    id: String,
    address: String,
    payload: String,
}

```

The `BatchSubmission` struct is what the submitter receives from the queuer and
is used briefly. As soon as the submitter receives the `BatchSubmission`, it
converts it to a `BatchEnvelope` using the addresser.

The `BatchEnvelope` has three parts: the tracking number (the batch `id`), the
address (the url to which it will be sent), and the contents (the `payload`,
i.e. the serialized batch). Addressing the batch immediately gives the gives
the submitter just the minimum information it needs to send and track the batch
correctly.

