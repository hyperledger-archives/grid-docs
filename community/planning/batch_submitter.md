---
mermaid: true
---
<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Batch Submitter

## Overview

The batch submitter component drives and manages the submission of batches to the
underlying distributed ledger technology (DLT).

The submitter is the component responsible for submitting batches via
individual http requests to the DLT. It polls the batch queuer component for
batches to submit and updates the batch's status via its submitter observer (in
this case, the observer updates the batch records via the store).

## Detail

### Overall design

At a high level, we need the submitter to do three things:

1. Drive the submission action - we decided it would be most appropriate to the
  overall Grid design if the submitter drove submission action, i.e. polled
  for work rather than being sent work
2. Make post requests to the DLT with higher throughput and reliability than
  serial execution would allow - in particular, we don't want slow http
  responses to delay the submission of other batches
3. Inform other components of its actions (i.e. changes to a batch's submission
  status) and the responses back from the DLT, including information it learns
  about the DLT's status

More concretely, these translate into the needs to actively poll the queue for
submissions, execute submissions asynchronously and concurrently, and actively
notify the outside world of its actions and information (push information out).

These lead to the three main parts of the submission service: the poller, the
async runtime, and the response collector.

<div class="mermaid">
graph LR
    A[queue] -->|submissions| B[poller]
    subgraph async runtime
        task1
        task2
        task3
        ...
    end
    B -->|submission| task1 & task2 & task3 & ...
    task1 & task2 & task3 & ... -->|response| C[response collector]
    C -->|notifications| D[observer]
    B -->|notifications of submission starts| D
</div>

It the above diagram, the poller continuously polls the queue for a new
submission and sends the submission to the async runtime. If the queue does not
have a new submission ready, the poller will pause for a predetermined interval
before polling again.

The async runtime drives the execution of the async POST requests to the DLT.
Each submission is spawned in its own task handler, which controls retry
behavior and collects relevant information on the submission process through
its subcomponents. The task handler then sends a message to the response
collector that contains either the latest submission response or error
information.

The response collector collects the incoming information from all tasks in the
async runtime upon the tasks' completion. It pushes this information to the
outside world via notifications to an observer component or logging.

### Implementation

The diagram below illustrates the overall process of how a batch is submitted
in Grid's submitter implementation.

<div class="mermaid">
sequenceDiagram
participant Listener/Observer
participant Queue
participant Polling Thread
participant Async Task
participant Submission Controller
participant Submission Command
participant URL Resolver
participant DLT REST API
    Queue ->> Polling Thread: `Submission`
    Polling Thread ->> Listener/Observer: in-progress notification via `notify()`
    Polling Thread ->>+ Async Task: new submission task
    rect rgb(240, 240, 240)
    note right of Async Task: async
    Async Task ->>+ Submission Controller: `Submission`
    Submission Controller ->>+ Submission Command: `execute()`
    loop while DLT is busy for i <= 10
        Submission Command ->>+ URL Resolver: get_URL method call
        URL Resolver ->>- Submission Command: DLT REST endpoint URL
        Submission Command ->>+ DLT REST API: PUT request
        DLT REST API ->>- Submission Command: http response
        Submission Command ->>- Submission Controller: `SubmissionResponse`
    end
    Submission Controller ->>- Async Task: `SubmissionResponse`
    end
    Async Task ->>- Listener/Observer: submission response via `notify()`
</div>

There are a number of high-level parts that comprise the submitter
implementation:

#### Submission

This struct represents a batch to be submitted. It is how the batch payload and
relevant data are passed through the submitter and is what the queue delivers
to the submitter when the submitter polls it.

```rust
pub struct Submission<S: ScopeId> {
    batch_header: String,
    scope_id: S,
    serialized_batch: Vec<u8>,
}
```

#### ScopeId

This identifier varies by underlying DLT and defines the scope to which the
batch applies. This topic will likely get its own documentation.

#### Submission response

This struct captures the http response from the submission POST request. This
information can then be passed to the observer and/or used for logging.

```rust
pub struct SubmissionResponse<S: ScopeId> {
    batch_header: String,
    scope_id: S,
    status: u16,
    message: String,
    attempts: u16,
}
```

#### Queue

This is simply something of type `Iterator<Item = Submission<S>> where S:
ScopeId`. In Grid, this is the queuer subcomponent, but could be a simple
`Vec<Submission<S>>` for testing or other purposes. The poller polls this queue
via the queue's `next()` method.

#### URL Resolver

The URL Resolver is a component that the submitter references _every_ time a
POST request is executed. The resolver's responsibility is to provide the URL
to which the batch should be posted. In its initial implementation, it is a
simple component that returns the same URL each time. However, future
implementations may be more sophisticated and route requests to multiple URLs
based on DLT instance availability or load.

```rust
pub trait UrlResolver: std::fmt::Debug + Sync + Send {
    type Id: ScopeId;
    /// Generates an address (i.e. URL) to which the batch will be sent.
    fn url(&self, scope_id: &Self::Id) -> String;
}
```

#### Observer

This is a generic component that receives notifications from the submitter. Its
implementation determines how this information is handled: it can write to a
database, log, conditionally implement other observer components, ignore
certain notifications, etc. In its initial implementation, it writes updates to
a database via the store.

```rust
pub trait SubmitterObserver: Sync + Send {
    type Id: ScopeId;
    /// Notify the observer of an update. The interpretation and recording
    /// of the update is determined by the observer's implementation.
    fn notify(
        &self,
        batch_header: String,
        scope_id: Self::Id,
        status: Option<u16>,
        message: Option<String>,
    );
}
```

#### Poller

As mentioned above, the poller thread runs a loop that polls the queue for new
submissions. If the queue returns `None`, the poller will pause for a
predefined polling interval before polling again.

In the submitter's implementation, the poller thread is called the leader
thread because it has other responsibilities beyond polling (namely managing
the shutdown of the other threads).

#### Async runtime

A runtime thread spawns new tasks in the async runtime, which drives all
submission tasks to completion. In the submitter's initial implementation, this
is a tokio runtime.

#### Submission task

A new submission task is spawned for every batch submission. These run in the
async runtime and complete concurrently.

The submission task has three nested subcomponents, which are organized by the
actions the task needs to complete. They are the task handler (labeled "Async
Task" in the diagram below), the submission controller, and the submission
command.

The task handler is responsible for running the submission controller and, upon
completion of the submission, sending the submission response to a listener
thread that notifies the observer.

The submission controller controls the retry and response behavior of the
submission command. For example, if the DLT is busy, the controller will
continue to execute the submission command until the submission is successful
or a predetermined number of submission attempts have failed. The controller
propagates any errors up to the task handler, which communicates them to the
observer via a message.

The submission command executes the POST request to the DLT. As mentioned
above, each time the command executes, it fetches a URL from the URL resolver.
Internally, the command also tracks the number of submission attempts it has
made. For each execution, it creates a new submission response that it passes
back to the submission controller.

#### Messages

The submitter uses a variety of message types to move information between
threads and subcomponents. This includes submissions, submission responses,
error messages, and termination commands.

### Building, running, and controlling the submitter

There are two interfaces for a submitter: a runnable submitter and a running
submitter. The runnable submitter represents a fully-configured submitter that
is ready to run. The running submitter is effectively a handle to the running
submitter service.

Note that `RunningSubmitter` requires the `ShutdownHandle` trait, which
provides the `signal_shutdown()` and `wait_for_shutdown()` methods.

```rust
/// The interface for a submitter that is built but not yet running.
pub trait RunnableSubmitter<S: ScopeId> {
    type RunningSubmitter: RunningSubmitter<S>;

    /// Start running the submission service.
    ///
    /// This method consumes the `RunnableSubmitter` and returns a `RunningSubmitter`
    fn run(self) -> Result<Self::RunningSubmitter, InternalError>;
}

/// The interface for a running submitter.
pub trait RunningSubmitter<S: ScopeId>: ShutdownHandle {
    type RunnableSubmitter: RunnableSubmitter<S>;

    /// Stop the running submitter service and return a runnable submitter (pause the service).
    fn stop(self) -> Result<Self::RunnableSubmitter, InternalError>;
}
```

Grid constructs the runnable submitter via a builder pattern, which allows for
configuration at runtime.

#### Run

To start the submission service, Grid calls `run()` on the `RunnableSubmitter`,
which spawns separate threads on which the service runs. These are independent
of the main thread so the main thread is not blocked while the submitter is
running. The queue, submitter observer, and a configured submission command
factory (which contains the url resolver) are each moved to the thread that
requires them.

`run()` returns a `RunningSubmitter`, with which Grid can stop/pause or
shutdown the submission service.

#### Stop and shutdown 

`RunningSubmitter` has a `stop()` method that stops the submission service and
returns a `RunnableSubmitter`. This can be useful for stopping and restarting
the submitter without needing to reconfigure it.

When `stop()` is called, the submitter uses messages to wind down its threads.
It also uses a mutex-guarded `Collector` struct within the `RunningSubmitter`
to collect the queue, submitter observer, and configured submission command
factory, rebuilding and returning a `RunnableSubmitter` identical to the one
that spawned it. Calling `run()` on this `RunnableSubmitter` restarts the
submission service.

__Note__: Stopping the submitter does not stop the submissions in progress -
these will continue to execute to completion before the submission service
fully stops. However, no new submissions will begin after `stop()` is called.

When `signal_shutdown()` is called on the running submitter, it sends stop
messages to its threads, which begin the same wind-down process. While the
collector still collects the queue, observer, and configured factory, the
submitter does nothing more with it.

When `wait_for_shutdown()` is called, the submitter joins its threads and
returns `Result<(), InternalError>`, consuming itself.

If Grid ever drops the handle to the submitter service (the `RunningSubmitter`
struct), the leader thread will detect this and initiate the shutdown process
on its own.

#### Submitter Lifecycle

<div class="mermaid">
sequenceDiagram
    participant M as Main thread
    participant Li as Listener thread
    participant Le as Leader thread
    participant R as Runtime thread
    participant A as Async runtime
    participant C as Collector struct
    M->>+Li: spawn
    M-->>Li: move SubmitterObserver
    M->>+R: spawn
    M-->>R: move CommandFactory
    R->>+A: spawn
    M->>+Le: spawn
    M-->>Le: move Queue
    note over M: Thread freed
    note over Li,A: Service running
    M->>Le: signal stop
    Le-->>C: move Queue
    Le->>R: stop msg
    R-->>C: move CommandFactory
    A->>-R: drained
    R->>Li: stop msg
    Li-->>C: move SubmitterObserver
    Le->>-M: join
    R->>-M: join
    Li->>-M: join
    C-->>M: move Queue, CommandFactory, and SubmitterObserver
</div>

### Error handling

Errors can arise in two primary activities: 1) startup/shutdown and 2) runtime
behavior. We handle errors from these activities differently.

#### Startup/shutdown errors

Errors during startup and shutdown are returned as a `Err` from the submitter
methods, such as `run()` on the runnable submitter or `signal_shutdown()` on
the running submitter. These errors represent problems spawning a thread or
runtime and tend to be low-level issues outside the scope of Grid.

#### Runtime errors

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

