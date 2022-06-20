---
mermaid: true
---
<!--
  Copyright 2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Grid High-availability Plan

## Background

We want to be able to run multiple Grid instances at a time to ensure Grid batch
submission is highly available.

Each instance maintains its own connection to the Grid database, which is
managed according to its own HA plan. The result looks something like this
(for illustration only):

<div class = "mermaid">
erDiagram
        DATABASE ||--|| GRID_INSTANCE_1 : connection
        DATABASE ||--|| GRID_INSTANCE_2 : connection
        DATABASE ||--|| GRID_INSTANCE_3 : connection
        DATABASE ||--|| GRID_INSTANCE_4 : connection
        DATABASE ||--|| GRID_INSTANCE_5 : connection
</div>

In this way, the overall implementation of Grid achieves high availability.

## Overview

* Grid instances are completely ignorant of one another and still, together,
  provide a high-availability system
* Grid instances indirectly coordinate their work through actions they take on
  a shared database
* The more the instances rely on the shared database, the better the system can
  handle hung or failed instances; this creates a tradeoff between
  fault-/delay-tolerance and database load
* A service_id claim system with an expiry and a carefully-planned queuing
  algorithm eliminate the need for centralized down-detection while providing
  reasonable performance expectations

### Key components of the HA plan

* Instance identities
* Claims and expiries
* Queuing algorithm
* Database (centralized state and clock)
* Database operations

## Detail

### Instance identities

A core assumption of this plan is that each instance is able to create and
maintain a unique identifier, good for the life of the instance, that enables
that instance to identify resources associated with itself in a database. This
also implies that the instance can recognize that a resource does not belong to
it if a different identifier is associated with that resource. Further, it can
recognize that a resource does not belong to any instance (and could be claimed
by it) if no identifier is associated with the resource.

### Claims and expiries

In order to avoid duplicating work and overloading the DLT, only one instance
should be submitting work for a given service_id at a time. This leads to a
claim system, whereby an instance will claim a service_id using its instance
ID, giving it the exclusive right to do work for that service_id.

However, an instance can fail or get hung up, which would prevent any work
being done on the claimed service_id. This leads to an expiry system for the
claim, so that another instance can pick up the work of the now-unavailable
instance.

To reduce the time spent on the claim acquisition process, an instance can
quickly renew its existing claim on a service_id to continue doing work for
that service_id.

We expect a healthy instance to be actively managing its claims. We can easily
tell if an instance is not managing its claims, and therefore is not healthy,
by checking the database to see if its claims have expired. If its claims have
expired, we should assume that the instance is not healthy and another, healthy
instance should take over its work.

### Queuing algorithm

The queuing algorithm does more than get batches to queue; because the
requeuing process represents the beginning of a new work cycle, it's helpful to
us for performing claim management activities as well.

There are four things that we can use this algorithm to accomplish:

1. Renewing the instance's current claims
2. Claiming service_ids that are unclaimed or whose claims have expired
3. Fetching batches of the instance's claimed service_ids
4. Determining which batches should be queued for the submitter and creating
  the queue

Below is an example of how the queuer and poller interaction might happen:

<div class = "mermaid">
sequenceDiagram
    participant Q as Queuer
    participant P as Poller
    participant A as Async submission
    note over Q: queue empty
    P->>Q: next()
    Q-->Q: Renew claims
    Q-->Q: Get new & expired claims
    Q-->Q: Fetch and queue batches
    Q->>P: batch
    P->>A: batch submission
    P->>Q: next()
    Q->>P: batch
    note over Q: queue empty
    P->>A: batch submission
    P->>Q: next()
    Q-->Q: Renew claims
    Q-->Q: Get new & expired claims
    Q-->Q: Fetch and queue batches
    note over Q: queue empty
    Q->>P: None
    P-->P: Sleep
    P->>Q: next()
    note over Q: ...
</div>

#### Renewing claims

First, an instance renews its existing claims. Unlike getting new/expired
claims (described below), every instance must complete this step.

Importantly, the instance does not know if it has been hung up itself (in which
case the claims it had have expired). Because of this, it cannot rely on its
own state to determine which claims it can renew; it must use the database's
record of its active claims. In fact, the instance should never store a record
of its claims in its own state.

This renewal process is straightforward: the instance executes a transaction
that updates the expiry times for any claim associated with its instance ID.

#### Making new claims and taking expired claims

Next, an instance attempts to claim any service_ids that are unclaimed or on
which a claim has expired (the instance that originally claimed the service_id
has gone down). However, it does not need to do this if it can tell that
another instance is doing this already. While typically instances would be
completely ignorant of one another, in some cases the database can tell an
instance that another is already performing the same transaction. In this case,
the second instance can move on to renewing its existing claims.

The new claims process is also straightforward: the instance executes a
transaction that updates the claim owner to be its instance ID and populates
the claim expiry times with the current time plus designated intervals. All
timestamps and intervals are calculated by the database.

#### Fetching batches for claimed service_ids

After it has attempted or completed the above steps, an instance fetches
batches for the service_ids for which it has an active claim. The batches it
fetches represent candidates for submission - due to the specific queuing
logic, many of the batches may not be submittable.

As mentioned above, an instance should never rely on its internal state to
determine its active claims. Therefore, when an instance goes to fetch batches
to potentially queue, it uses the service_id_claims table as the definitive
list of its active claims.

The batches it fetches are stored in the instance's state. This is the only
time in this process that the instance copies and retains data from the
database. This creates an opportunity for the data that the queuer gives to the
submitter to be stale (if the instance was delayed between fetching the batches
and delivering batches to the submitter, and its claim expired). The submitter
can verify that the batch is still ok to be submitted before submission,
ensuring that it is not receiving stale data from the queuer; this places an
additional load on the database but reduces the chance of a batch being
submitted multiple times via multiple instances.

#### Creating the queue

Finally, the instance is ready to queue batches from submission. This is a
simple process by which the queuer makes batches available to the submitter via
the queuer's `next()` method.

If the queuer attempts to fetch batches for its claimed service_ids but
receives none (there are no batches to submit), it does not queue any batches
but returns `None` when the submitter calls its `next()` method.

### Database

The database plays a critical role in this HA plan: it serves as a centralized,
source-of-truth state and the clock by which expiry times are set and compared.

Using the database as centralized memory allows us to avoid implementing shared
memory across instances, greatly simplifying implementation. It allows Grid
instances to be ignorant of one another, eliminating the need for coordination
among instances.

To do this, we must use a database that can safely handle concurrent
transactions. "Safely" in this sense means that it will only execute
transactions in such a way that they could have been executed serially (based
on the concepts behind the [serializable transaction level in PostgreSQL]
(https://www.postgresql.org/docs/14/transaction-iso.html)). Transactions that
would create results that would not be possible via serial execution are
rejected with an error. Note that databases that actually execute updates
serially would be safe.

To avoid issues with synchronizing multiple clocks, the database also acts as
the central timekeeper. Instances do not need to know anything about times or
intervals - by using transactions that leverage the database's clock, they can
avoid tracking time altogether.

#### Database considerations

Below are a few considerations on database type from an HA perspective:

__SQLite__

Benefits:

* Small, simple for testing and development
* Stable / no concurrency problems

Cons:

* Complete table lock on write -> slow, not suitable for high concurrency

__PostgreSQL__

Benefits:

* Very good concurrency handling and control
* Scales well

Cons:

* More setup/admin involved for testing and development
* More complex queries/reasoning to control concurrency

### Database operations

#### Example queries

__Queuer - Renew claims__

```sql
UPDATE service_id_claims
SET
  expiry = (now() + INTERVAL '10 seconds'),
WHERE claimant = {instance_id};
```

_Note: The 10 second interval is an example_

__Queuer - Get new and expired claims__

```sql
UPDATE service_id_claims
SET
  claimant = {instance_id},
  expiry = (now() + INTERVAL '10 seconds'),
WHERE claimant IS NULL
OR EXTRACT(EPOCH FROM now()) - EXTRACT(EPOCH FROM expiry) > 0;
```

_Note: The 10 second interval is an example_

__Queuer - Get batches of claims__

This might incorporate the queuing logic.
If the queuer gives the submitter a `batch_id` instead of a batch, this query
would not include `b.serialized_batch`.

```sql
SELECT FOR UPDATE
  s.service_id,
  b.batch_id,
  b.submitted,
  b.created_at,
  b.serialized_batch,
  bs.dlt_status AS status,
  bs.updated_at AS last_status_update
FROM service_id_claims s
LEFT JOIN batches b
ON service_id, batch_id
LEFT JOIN batch_statuses bs
ON service_id, batch_id
WHERE s.claimant == {instance_id}
AND bs.dlt_status NOT IN (
  'PENDING', 'INVALID', 'VALID', 'COMMITTED'
)
```

## Outstanding questions

* __How long should the expiry be?__
*   At least longer than the poller sleep time
* __How long should the poller sleep time be?__
*   Will impact database load
* __Should the queuer give the submitter a batch (or BatchSubmission) or a
  pointer to a batch, (i.e. batch_id)?__
*   Pointer to a batch means the submitter will go back and verify that the
    batch is ok to submit and get the batch directly from the store
*   Will significantly impact database load

## DLT Monitor

When the DLT monitor gets the list of pending batches from the database, it
filters for only those that the instance has a claim on. Since claims are per
service_id, regardless of if there are batches to submit for that service_id,
some instance will always have a claim on each service_id, so batch statuses
for every service_id will always be polled.

## Alternative approaches

One alternative to using claims and expiries is to use active database
connections as a proxy for an instance's health. This approach is outlined
[here](https://www.crunchydata.com/blog/message-queuing-using-native-postgresql)
. In summary, a SQL transaction consists of multiple statements. An instance
would begin the transaction with an update to mark a job complete (a batch
submitted in this case), locking the row from other instances. However, the
instance would actually do the work between executing the update command and
committing it. If the job fails, the transaction is rolled back and the job is
still marked as not started. Of course, if the job completes, then the update
is committed to the database.

There are a few issues with this approach. First, if work is taken in batches
(for example, 10 jobs at a time), there is the possibility that the instance
fails after 5 jobs. This means the update for all 10 will roll back to being
not started when, in fact, 5 of the jobs are complete.

One can reduce the chances of this happening by working on one batch at a time
(there is still a chance, but a much smaller one). However, in the context of
Grid, this makes queuing significantly more complicated; it requires that all
queuing logic is baked into the SQL transaction, including logic to manage
distribution across, and locks on, service_ids.

Finally, it means that the instance will have a lock on a job as long as that
instance is still alive, not as long as it is making progress on the job. If
the instance were to hang for an indefinite amount of time, that job would be
hung as well. With the claim and expiry system, another instance would pick the
job up after the hung instance's claim expired.

