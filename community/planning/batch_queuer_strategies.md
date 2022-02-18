# Submission queuer strategies
<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Overview

Submission queuer strategies are the algorithms that determine in what order
Grid submits batches to the underlying distributed ledger technology (DLT).
The strategies vary based on the underlying DLT and user preferences. The
designs of these strategies determine the guarantees that Grid can make to the
user and much of the overall performance of the Grid instance.

### Why must these strategies exist?

* The strategies determine the order in which the submitters submit batches
* For simplicity, we want one component to determine the submission order and
  serve it to multiple submitter threads, rather than having those threads
  decide amongst themselves
* We need different strategies for different underlying DLTs and different
  user priorities
* Without these strategies, Grid cannot guarantee updates will be applied in 
  the order in which they are sent, which would lead to data integrity failures

### How will these strategies be used?

* They will be abstracted behind a batch queue trait
* The strategies will interface heavily with the store, and some of their logic
  will be embedded in store methods

### What must these strategies do?

* They must ensure that edits to state are applied in the order in which they
  are submitted to Grid by the user
* Only serve one batch per submitter
* Balance the submitter load fairly across all services
* Provide an absolute guarantee that batches are submitted to the correct
  `service_id`

### What must the strategies not do?

* Submit batches to incorrect `service_id`s
* Submit edits to state in an order other than the order in which they were
  submitted
* Create a situation in which the DLT could apply edits to state in an
  incorrect order
* Inadvertently allocate submission resources (submitter threads) unevenly
  across service_ids
* Get into a permanently locked state
* Inadvertently “forget” batches by getting into a state in which some
  batches are never applied (the exception being batches that were submitted
  but were invalid)
* Resubmit an invalid batch

## Design Priorities

1. Data accuracy - DLT state reflects the intentions of the users
2. Data persistence - valid data that is submitted to Grid is applied
3. Performance - considerations include throughput and HA-readiness
4. Transparency - information about the status of the queue, such as depth

## Strategy considerations

* Underlying DLT characteristics
* Explicit user-defined dependencies
* Optional implicit dependencies based on order
* Resubmission
* Service allocation
* CAP theorem
* Batch status resolution

### Underlying DLT characteristics

* Guaranteed vs. non-guaranteed edit order
* Persistence

#### DLT types

For the purposes of the queuer strategies, there are two types of DLTs:

* __DLTs with guaranteed order__ - These DLTs ensure that the order in which
  edits to state are submitted is the same order in which they will be applied.
  These DLTs use consensus algorithms, such as two-phase commit, that do not
  rely on gossip protocol.
* __DLTs without guaranteed order__ - These DLTs rely on broadcast algorithms
  (frequently the gossip protocol) that cannot guarantee the order in which
  edits are applied

Differentiating between the two is important because they imply different
performance opportunities given that Grid must guarantee edit order.

#### Edit order

Edit order is simply the order in which edits are applied to the same part of
the ledger state.

Say we have a purchase order (PO) contract in Grid, and the price for the good
is driven by changes in an underlying commodity’s spot price. Let’s also say
the current price listed on the PO is 2.75 USD. If we update the PO price to
3.00 USD and shortly thereafter need to update the PO price again to 3.25 USD
due to a spike in the commodity price, our edit order would for that PO’s price
would be 2.75 → 3.00 → 3.25.

However, without a guarantee of edit order, the edits could be applied
2.75 → 3.25 → 3.00, leaving the final PO contract price at 3.00 USD. Clearly,
this could be disastrous.

#### Guaranteed order

For strategies with guaranteed order, our strategy considerations are contained
to its implementation inside Grid itself. So, our goal is to optimize a
strategy’s performance (i.e. throughput) given certain scenarios or constraints
(ex. high submitter-to-service ratios or resubmission timers, respectively). We
simply submit batches as fast as we can, slowing the pace if we get back
pressure from the DLT. These strategy implementations are simpler than those
that handle DLTs without order guarantees.

#### Non-guaranteed order

For strategies to handle DLTs without order guarantees, we must ensure the
strategies themselves provide the order guarantee; this becomes our top design
priority. Performance then becomes the second priority.

These strategies are necessarily more complex and less performant than the
guaranteed-order strategies. Improvements in performance usually require
significant increases in complexity.

#### Persistence

In developing queuing strategies, we want to also consider how DLTs persist
their pending batch queues, i.e. how batches are held prior to being committed.
In the normal course of operation, this will not matter to the queuer. However,
were the DLT node to restart, this can impact a queuing strategy's requirement
to ensure edits to state are applied in the order in which they are submitted
to Grid.

For various reasons, DLT designers can choose to hold batches in the commit
queue in either memory or in a persisted database. While holding the queue
in memory may have performance benefits, the batches in that queue can be lost 
should the node restart or otherwise lose its state. This possibility becomes
another constraint on our strategy design when working with such DLTs.

### Explicit user-defined dependencies

Some DLTs provide the option for users to specify that a transaction is
dependent on another transaction. If we say that batch B is dependent on batch
A, that means that the DLT must apply the edits of batch A before applying the
edits of batch B, and that if batch A fails, batch B also fails automatically.
This can be useful in situations where we want A to be applied if possible, but
B to only be applied if batch A is successful (as opposed to putting the
transactions of batches A and B together in one batch so they are committed or
fail together). DLTs that enable explicit dependencies like this give us
an extra option when designing strategies.

Some DLTs do not provide the option for explicit dependencies; however, this
may still be an option we want to offer Grid users. In this case, we need to
design strategies in such a way that Grid enforces the explicit dependencies
for the DLT.

### Optional implicit dependencies based on order

In some cases, users may want to enforce implicit dependencies based on the
order in which batches are submitted to Grid. In other words, every batch is
dependent on the one that was submitted before it. This ensures that the queue
halts if a batch is invalid, giving a user time to investigate the batch before
any other edits are applied.

One option for handling this is, for a DLT that handles explicit dependencies,
to add an explicit dependency on each transaction. If a user chooses such a DLT
and also chooses to have Griddle handle batch signing, Griddle could add such
explicit dependencies, in which case the queuer strategy could simply rely on
the transactions' stated dependencies. However, since this is not likely to be
a common use case, we will probably not develop such a strategy in the near
term. Thus, for implicit dependencies, we will proceed as though we cannot add
explicit dependencies to a transaction.

### Resubmission

Under normal circumstances, batches need to be submitted only once. However,
if the DLT loses track of a batch due to a restart or other anomaly, a batch
may need to be resubmitted. To preserve edit order (as described above), a
successful resubmission must occur before any other batch can be submitted.

This is a simple consideration, but it has a substantial impact on certain
types of strategies.

### Service allocation

This and the CAP theorem below are particularly important considerations,
though they affect strategy design in a different way than the considerations
listed above. In the above, our considerations were on a per-service basis and
largely focussed on the DLT. Service allocation and the CAP theorem primarily
impact how Grid handles queuing internally.

Service allocation refers to how a pool of submitter threads (or even a "pool"
of one) are allocated across services (i.e. unique `service_ids` running on the
Grid instance). For example, if we have four services and Grid receives batches
randomly and unevenly across these services, how should we prioritize the
allocation of the submitter threads?

We discuss this consideration in more detail below in "Strategy
types."

### The CAP theorem

To summarize, the CAP theorem states that, for a distributed data store, there
are three primary tradeoffs: Consistency, Availability, and Partition
tolerance. Further, it states that you can only design a system for two at a
time. Popular distributed databases are distinguished based on which two
factors they prioritize. There is plenty of content online that explains the
CAP theorem in detail.

The CAP theorem also applies to our batch queue in that the queue is, in a way,
a replication of a part of the batch database inside Grid. How we design for
service allocation dictates what two of the three factors we need to
prioritize in our strategy.

### Batch status resolution

The consideration deals with how a strategy handles feedback from the DLT
regarding the status of batches that have already been submitted. The statuses
that are most important for the strategy are `committed`, `invalid`, and
`unknown`.

In particular, we need to carefully consider how the DLT monitor and queuer
work together to safely resolve a batch's `unknown` status to either
`committed` or `invalid`. The underlying DLT's behavior also influences how the
strategy's design accomplishes this.

## Strategy types

If we start with the last two considerations, service allocation and the CAP
theorem, there are a few types of queues we can consider:

* Single queue
* One queue per service
* One-round queue
* Multi-round queue

### Single queue

This queue simply consists of all unsubmitted batches in the order in which
they were submitted to Grid. In fact, we would not need a separate queue to
implement this strategy; we could query the batch database for the oldest
unsubmitted batch to get the next batch to submit.

However, this strategy type does not give any consideration to service
allocation. For example, imagine we had four services that typically submit
about one batch per second. Then, imagine one of those services submits 1,000
batches all at once. With a single queue, the other three services would
effectively be blocked from submitting new batches until the submitters had
processed all 1,000 batches from the one service.

This means that the performance of a service was dependent on the behavior of
another, making it unpredictable and vulnerable to what amounts to denial of
service.

### One queue per service

This type of strategy implements a separate queue for each service. This is the
most complex type outlined here - while services have separate queues, the
strategy can manage multiple queues at once, applying sophisticated logic to
maximize availability to submitter threads. Thread management of the strategy
implementation itself makes this type particularly complex.

Since performance is not our primary design objective, and because performance
is constrained by other factors, we will not initially implement this strategy
type.

### One-round queue

A one-round queue both is simple and allocates submitters fairly across
services. The strategy selects the oldest unsubmitted batch for each service
that has unsubmitted batches. It then distributes the queued batches to the
submitter threads, so that every service has an opportunity to have one batch
submitted each round. When the queue is empty, the process repeats.

This strategy type is simple and free of issues or tradeoffs that other types
have, however, it is relatively inefficient for Grid instances that have many
submitter threads but few services. For example, if a Grid instance has 64
available submitter threads but only 4 active services, a one-round queue would
need to replenish itself 16 times to fully saturate the submitter thread pool.

That said, we believe that inefficiency is worth the strategy's benefits (and,
as stated before, we have other performance constraints), so we will begin by
implementing this type.

### Multi-round queue

This is an extension of a one-round queue and is effectively multiple
one-round queues strung together. It aims to solve the inefficiency of the
one-round type described above.

To populate a multi-round queue that is 3 rounds deep, this strategy type would
select the oldest unsubmitted batch for each service that has unsubmitted
batches. Then, it would queue up behind those the second-oldest unsubmitted
batch from each service that had one, and likewise for the third. When
distributing batches to submitter threads, it could provide up to 3 times as
many batches before replenishing.

However, we run into the CAP theorem with a multi-round queue (simplified, we
have a cache invalidation problem). We have effectively created a partition of
our batch database. Since we must guarantee the availability of queue to the
submitter threads, we cannot guarantee consistency with the batch database.

Say we have a 3-round queue across 3 services: `A`, `B`, and `C`. Let's also
say that when we go to fill this queue, `A` has 3 unsubmitted batches, `B` has
3, and `C` has one. So our queue looks like: [[A, B, C], [A, B], [A]].

If, after we submit the first round of batches [A, B, C], Grid receives a new,
unsubmitted batch from `C`, that batch will not be in the queue until `A` and
`B` have had two rounds of batches submitted. Put another way, the queue is no
longer consistent with the batch database, and submitter threads are no longer
allocated evenly across services. Clearly, this becomes more of an issue as the
number of rounds increases and/or the number of services exceeds the number of
submitter threads.

## Submission approaches

There are three approaches we can take to submitting batches to a DLT:

* Unconstrained
* Serial
* Parallel

### Unconstrained

With this approach, we simply submit batches to the DLT as quickly as we like,
accommodating any back pressure we get from the DLT. It is the simplest and
fastest approach, but requires that the DLT guarantee order (see "Underlying
DLT characteristics" discussion above). It also requires that the DLT either
persist its own batch queue or somehow notify Grid that the batch queue has
been dropped and that batches after a given point must be resubmitted (see
"Persistence" discussion above).

### Serial

In a serial approach, we submit one batch and wait for the DLT monitor to
update that batch's status to `committed` before submitting the next batch.
In other words, we must wait until we know that one batch has been successfully
applied before submitting the next batch. This approach can provide guarantees
about edit order (accuracy) and persistence if the underlying DLT cannot
provide these itself.

These guarantees come at a performance cost. Throughput of this strategy is
limited to the complete batch submission cycle time, meaning roughly the
sum of time it takes for:

1. a batch to be submitted by a submitter thread
2. the DLT to commit the batch
3. the DLT monitor to receive the batch's `committed` status and update the
  batch database
4. the queuer to notice the updated status

Since the duration of steps 1, 3, and 4 can be relatively short and are mostly
in Grid's control, the transaction processing time of the underlying DLT has
a large impact on the maximum performance of a serial strategy.

### Parallel

A parallel approach is similar to a serial approach in that it waits for a
batch to be confirmed `committed` before submitting the next batch if the next
batch would edit or read the same data as the first batch. If, however, two
successive batches do not overlap in the parts of state they read and/or edit,
a parallel strategy can submit the second batch before receiving the first.

While a parallel strategy can have significant performance improvements over a
serial strategy, it comes with an equally significant increase in complexity.
First, the strategy must determine which parts of state each batch edits and
reads. This can be done at varying levels of granularity, but we must be very
careful when designing this functionality to ensure we can guarantee no overlap
between the data the two batches edit and use. Second, the parallel strategy
needs to keep track of all pending batches to check new batches against,
creating a sort of side-queue it must manage. This side queue needs to be
persisted in a database.

The performance of a parallel strategy is primarily limited by the transaction
processing time of the DLT and the granularity with which the strategy can
detect overlapping data use between batches. Of course, the degree to which
batches overlap has a significant impact on actual performance: if every batch
edits or uses the same data, a parallel strategy will perform identically to a
serial strategy.

## Development plan

Considering all of the above, we plan to implement a one-round serial queue
first. This strategy gives us simplicity and the guarantees we would like to
offer in Grid. It will also be helpful for simple testing.

However, we expect to find the performance of a one-round serial strategy to be
limiting, so we will also start development on a one-round parallel strategy.
Given such a strategy's complexity, we will need to do more research to
understand what the optimal granularity of edit overlap detection will be.
