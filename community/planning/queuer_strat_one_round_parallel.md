<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
# One-round parallel queuer strategy

## Overview

Below we examine the practicality and feasibility of queuing parallelization
strategies. The goal of such strategies is to increase the average
throughput of a queuing strategy while maintaining a batch submission order
guarantee (which ensures data integrity). Since we can't directly assess the
average throughput of a strategy at this point in Grid's development, we will
assess the maximum performance benefit a strategy can achieve and the rough
likelihood that it would achieve it.

Fortunately, we can abstract away much of the complexity of Grid and the
underlying distributed ledger technology (DLT) by considering it as a data
structure. Data structures are well-understood (as far as we will be
concerned), so we can quickly understand the queuing strategies through this
characterization.

Given the constraints outlined in the overall
[queuing strategy design document](community/planning/batch_queuer_strategies.md),
the Grid and DLT system is effectively a lock-based data structure. Batches
submitted by Grid to the DLT are concurrent in the sense that the order in
which they are applied is not guaranteed based on the order in which they are
submitted (due to the broadcast protocol); from the DLT's perspective, all
batches submitted within the same commit time frame happen at the same time.
Of course, in reality, it's very likely that the DLT can decern some ordering
information, but we must assume the worst here.

Therefore, the consideration of parallelization in queuing strategies is really
the consideration of lock granularity on a lock-based data structure. In this
context, we are considering operations that perform simultaneous reads and
writes (not atomic read or write operations), since smart contracts can do
both. We need to consider both the practicality of the lock granularity (what's
the performance benefit we gain) and the feasibility of it (can we implement it
given its assumptions and implications, and is the work worth the benefit).

### Performance implications

With lock-based data structures, the number of locks available is typically the
performance constraint, assuming no system resource constraints. Therefore, data
structures with finer lock granularity have more locks available and thus
better performance in a best-case scenario.

## Levels of lock granularity

### By `service_id`

This is the one-round serial strategy that we are implementing.

Since the queuer partitions submissions by `service_id` for resource
allocation, rather than to improve submission throughput, this is a one-lock
approach. We lock the entire `service_id` when a batch is submitted, then
unlock the `service_id` when the batch has been confirmed committed or invalid.
Since the commit cycle can be a minute or more, the data system is in a locked
state the vast majority of the time, even though the submission operation is
relatively quick. Clearly, this is inefficient, and this inefficiency is what
motivated this research into parallel queuing strategies.

### By smart contract type

In this parallel approach, we apply locks based on contract type (ex. Pike vs.
Product vs. Purchase Order, etc.). This partitioning approach has the benefit
of being easier to implement than the other parallelization approach described
below.

Rather than using one lock per `service_id`, we have one lock per contract
type, per `service_id`. We apply a lock to a contract type for a `service_id`
when a batch is submitted, and we unlock that contract type for that
`service_id` when the batch has been confirmed committed or invalid.

However, while somewhat practical, this approach turns out to be infeasible for
the reasons described in a later section, because it assumes that there is no
overlap in used state (read or write) between different contract types.

### By contract contents

In this approach, we examine the batches prior to queuing to see which parts of
state each transaction uses. We can then queue the batches that do not use the
same parts of state in a potentially conflicting way (the mechanics of this are
described below).

This approach significantly increases lock granularity, as we apply read and
write locks to individual parts of state. This clearly comes at a cost of
increased complexity, since the queuer (or another Grid component) must
interpret each transaction and track which part of state each one reads and
writes.

The process looks like this:

* Examines each transaction to determine what parts of the DLT state will be
  read and written
* Applies a write-lock to the parts of state where an earlier,
  still-uncommitted transaction performed either a read or write
* Applies a read-lock to the parts of state where an earlier, still-uncommitted
  transaction performed a write
* Releases the locks on parts of state when all locking transactions for that
  part are committed

This approach provides the greatest benefit when there are many, independent
contracts. If contracts overlap heavily in what parts of state they read and
write (lock use at any given time is concentrated on a few locks), the
performance improvement degrades. The illustration below demonstrates this.

## Illustration of locks by contract content

### Few independent contracts

This example illustrates how a strategy that is locking on content would behave
if many contracts overlap in what they read and write.

Imagine we have a DLT state with 6 parts of state, labeled "A" through "F".
Also imagine we have 7 batches with single transactions that we must submit to
the DLT.

The transactions all read and write to different parts of the state, as shown
by the table below:

Txn | A | B | C | D | E | F
----|---|---|---|---|---|---
1   |   | R |   |   | R | W
2   |   |   |   | R | W |
3   | W | R |   |   |   |
4   | R | W | R |   |   |
5   |   |   | W | R |   |
6   |   |   | W | R |   |
7   |   |   |   | W |   |

### Submission rounds

The rounds of submissions and locks would look like this:

#### Round 1

Txn | Status
----|----
1   | Ok - submitted
2   | Blocked on E
3   | Ok - submitted
4   | Blocked on A, B
5   | Blocked on C
6   | Blocked on C, D
7   | Blocked on D

After this round, 1 and 3 are committed.

#### Round 2

Remaining transactions:

Txn | A | B | C | D | E | F
----|---|---|---|---|---|---
2   |   |   |   | R | W |
4   | R | W | R |   |   |
5   |   |   | W | R |   |
6   |   |   | W | R |   |
7   |   |   |   | W |   |

Txn | Status
----|----
1   | Committed
2   | Ok - submitted
3   | Committed
4   | Ok - submitted
5   | Blocked on C
6   | Blocked on C, D
7   | Blocked on D

After this round, 2 and 4 are committed.

#### Round 3

Remaining transactions:

Txn | A | B | C | D | E | F
----|---|---|---|---|---|---
5   |   |   | W | R |   |
6   |   |   | W | R |   |
7   |   |   |   | W |   |

Txn | Status
----|----
1-4 | Committed
5   | Ok - submitted
6   | Blocked on C, D
7   | Blocked on D

After this round, 5 is committed.

#### Round 4

Remaining transactions:

Txn | A | B | C | D | E | F
----|---|---|---|---|---|---
6   |   |   | W | R |   |
7   |   |   |   | W |   |

Txn | Status
----|----
1-5 | Committed
6   | Ok - submitted
7   | Blocked on D

After this round, 6 is committed.


#### Round 5

Remaining transactions:

Txn | A | B | C | D | E | F
----|---|---|---|---|---|---
7   |   |   |   | W |   |

Txn | Status
----|----
1-6 | Committed
7   | Ok - submitted

After this round, 7 is committed.

### Many independent contracts

This example illustrates how a strategy that is locking on content would behave
if few contracts overlap in what they read and write.

Here we have 5 batches with single transactions that we must submit to the
DLT.

The transactions all write to different parts of the state but read from the
same, as shown by the table below:

Txn | A | B | C | D | E | F
----|---|---|---|---|---|---
1   | W |   |   |   |   | R
2   |   | W |   |   |   | R
3   |   |   | W |   |   | R
4   |   |   |   | W |   | R
5   |   |   |   |   | W | R

Since no transaction writes to a part of state that was read or written to by
an earlier transaction, all of these transactions can be submitted
simultaneously. In this case, the parallelization approach has achieved its
maximum performance improvement.

## Feasibility of parallelization strategies

### Parallelization by contract type

This strategy makes the assumption that contract types are independent of one
another, i.e. that one type does not read the part of state that another type
writes, and vice versa.

Parallelization by contract type is a simplification of parallelization by
contract contents, in which we assume that contract type is a shortcut to
determining contract contents. For this to provide a guarantee of data
integrity, contract type must partition the parts of state that contracts edit
in such a way that no two types of contract use the same part of state (either
read or write). Otherwise, since the order in which transactions are applied is
not guaranteed, the order in which parts of state is read or written is not
guaranteed either.

It turns out that we cannot, and do not want to, make this assumption. Data
created by one contract type is frequently very useful to other contract types.
An example of this is the Pike contract type, which provides identity and
authorization information on which other contract types rely.

Therefore, it is not feasible to use contract type to parallelize the queuing
of batch submissions for a `service_id`.

### Parallelization by contract contents

The ability of Grid to detect the operations on state that a contract will
perform determines the feasibility of this parallelization strategy. We will
need to do more work to determine if this is possible or feasible.

